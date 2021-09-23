// Copyright (c) 2011 The LevelDB Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file. See the AUTHORS file for names of contributors.

#include "leveldb/table_builder.h"

#include <atomic>
#include <bits/stdint-uintn.h>
#include <cassert>
#include <condition_variable>
#include <deque>
#include <thread>
#include <vector>

#include "leveldb/comparator.h"
#include "leveldb/env.h"
#include "leveldb/filter_policy.h"
#include "leveldb/options.h"
#include "leveldb/status.h"

#include "table/block_builder.h"
#include "table/filter_block.h"
#include "table/format.h"
#include "util/coding.h"
#include "util/crc32c.h"

namespace leveldb {

struct TableBuilder::DataBlockWithHandle {
  BlockBuilder* data_block;
  BlockHandle* pending_handle;
};

struct TableBuilder::Rep {
  Rep(const Options& opt, WritableFile* f)
      : options(opt),
        index_block_options(opt),
        file(f),
        meta_offset(0),
        // data_block(&options),
        index_block(&index_block_options),
        num_entries(0),
        closed(false),
        filter_block(opt.filter_policy == nullptr
                         ? nullptr
                         : new FilterBlockBuilder(opt.filter_policy)),
        pending_index_entry(false) {
    index_block_options.block_restart_interval = 1;
  }

  Rep(const Options& opt, WritableFile* f, std::vector<WritableFile*> fs)
      : options(opt),
        index_block_options(opt),
        file(f),
        meta_offset(0),
        // data_block(&options),
        index_block(&index_block_options),
        num_entries(0),
        closed(false),
        filter_block(opt.filter_policy == nullptr
                         ? nullptr
                         : new FilterBlockBuilder(opt.filter_policy)),
        pending_index_entry(false),
        files(fs) {
    index_block_options.block_restart_interval = 1;
  }

  Options options;
  Options index_block_options;
  WritableFile* file;
  std::vector<WritableFile*> files;
  // std::vector<uint64_t> file_numbers;
  // uint64_t offset;
  uint64_t meta_offset;
  std::vector<uint64_t> offsets;
  // std::atomic<Status> status;
  Status status;
  BlockBuilder* data_block;
  std::deque<DataBlockWithHandle> data_block_queue;  // todo 避免拷贝，提高性能
  BlockBuilder index_block;
  std::string last_key;
  int64_t num_entries;
  std::atomic<bool> closed;  // Either Finish() or Abandon() has been called.
  FilterBlockBuilder* filter_block;
  std::mutex m;
  std::condition_variable cv_empty;
  std::condition_variable cv_withMember;
  // std::atomic<bool>

  // We do not emit the index entry for a block until we have seen the
  // first key for the next data block.  This allows us to use shorter
  // keys in the index block.  For example, consider a block boundary
  // between the keys "the quick brown fox" and "the who".  We can use
  // "the r" as the key for the index block entry since it is >= all
  // entries in the first block and < all entries in subsequent
  // blocks.
  //
  // Invariant: r->pending_index_entry is true only if data_block is empty.
  bool pending_index_entry;
  BlockHandle* pending_handle = nullptr;  // Handle to add to index block
  std::deque<BlockHandle*> pending_handle_queue;  // todo 避免拷贝，提高性能
  std::deque<std::string> last_key_queue;

  std::string compressed_output;
};

TableBuilder::TableBuilder(const Options& options, WritableFile* file)
    : rep_(new Rep(options, file)) {
  rep_->offsets.push_back(0);
  if (rep_->filter_block != nullptr) {
    rep_->filter_block->StartBlock(0);
  }
}

TableBuilder::TableBuilder(const Options& options, WritableFile* file,
                           std::vector<WritableFile*> files)
    : rep_(new Rep(options, file, files)) {
  if (rep_->filter_block != nullptr) {
    rep_->filter_block->StartBlock(0);
  }
  // 创建线程
  int threadNum = files.size();
  for (int i = 0; i < threadNum; i++) {
    rep_->offsets.push_back(0);
    std::thread background_thread(&TableBuilder::BackgroundThreadEntryPoint,
                                  this, i);
    background_thread.detach();
  }
}

TableBuilder::~TableBuilder() {
  assert(rep_->closed);  // Catch errors where caller forgot to call Finish()
  delete rep_->filter_block;
  delete rep_;
}

Status TableBuilder::ChangeOptions(const Options& options) {
  // Note: if more fields are added to Options, update
  // this function to catch changes that should not be allowed to
  // change in the middle of building a Table.
  if (options.comparator != rep_->options.comparator) {
    return Status::InvalidArgument("changing comparator while building table");
  }

  // Note that any live BlockBuilders point to rep_->options and therefore
  // will automatically pick up the updated options.
  rep_->options = options;
  rep_->index_block_options = options;
  rep_->index_block_options.block_restart_interval = 1;
  return Status::OK();
}

void TableBuilder::Add(const Slice& key, const Slice& value) {
  Rep* r = rep_;
  assert(!r->closed);
  if (!ok()) return;
  if (r->num_entries > 0) {
    assert(r->options.comparator->Compare(key, Slice(r->last_key)) > 0);
  }

  // if (r->pending_index_entry) {
  //   assert(r->data_block->empty());
  //   r->options.comparator->FindShortestSeparator(&r->last_key, key);
  //   std::string handle_encoding;
  //   r->pending_handle->EncodeTo(&handle_encoding);
  //   r->index_block.Add(r->last_key, Slice(handle_encoding));
  //   r->pending_index_entry = false;
  // }
  if (r->pending_index_entry) {
    assert(r->data_block->empty());
    r->options.comparator->FindShortestSeparator(&r->last_key, key);
    // std::string handle_encoding;
    // r->pending_handle->EncodeTo(&handle_encoding);
    // r->index_block.Add(r->last_key, Slice(handle_encoding));
    r->last_key_queue.emplace_back(
        r->last_key);  // 考虑冲突嘛，生产者 消费者模型 todo
    r->pending_index_entry = false;
  }

  if (r->data_block == nullptr) {
    r->data_block = new BlockBuilder(&r->options);
  }

  if (r->filter_block != nullptr) {
    r->filter_block->AddKey(key);
  }

  r->last_key.assign(key.data(), key.size());
  r->num_entries++;
  r->data_block->Add(key, value);

  const size_t estimated_block_size = r->data_block->CurrentSizeEstimate();
  if (estimated_block_size >= r->options.block_size) {
    Flush();
  }
}

void TableBuilder::Flush() {
  Rep* r = rep_;
  assert(!r->closed);
  if (!ok()) return;
  if (r->data_block->empty()) return;
  assert(!r->pending_index_entry);
  if (r->options.multi_path) {
    BlockHandle* index_handle = new BlockHandle();
    DataBlockWithHandle tmpDBH;
    tmpDBH.data_block = r->data_block;
    tmpDBH.pending_handle = index_handle;
    r->data_block_queue.emplace_back(tmpDBH);  // datablock放到队列中去
    r->data_block = nullptr;
    r->pending_handle_queue.emplace_back(
        index_handle);  // index handle放到队列中去
    r->pending_index_entry = true;
    r->cv_withMember.notify_all();
  } else {
    WriteBlock(r->data_block, r->pending_handle);
    if (ok()) {
      r->pending_index_entry = true;
      r->status = r->file->Flush();
    }
  }

  // to do surpport bloom filter
  // if (r->filter_block != nullptr) {
  //   r->filter_block->StartBlock(r->offset);
  // }
}

void TableBuilder::WriteBlock(BlockBuilder* block, BlockHandle* handle,
                              int index) {
  // File format contains a sequence of blocks where each block has:
  //    block_data: uint8[n]
  //    type: uint8
  //    crc: uint32
  assert(ok());
  Rep* r = rep_;
  Slice raw = block->Finish();

  Slice block_contents;
  CompressionType type = r->options.compression;
  // TODO(postrelease): Support more compression options: zlib?
  switch (type) {
    case kNoCompression:
      block_contents = raw;
      break;

    case kSnappyCompression: {
      std::string* compressed = &r->compressed_output;
      if (port::Snappy_Compress(raw.data(), raw.size(), compressed) &&
          compressed->size() < raw.size() - (raw.size() / 8u)) {
        block_contents = *compressed;
      } else {
        // Snappy not supported, or compressed less than 12.5%, so just
        // store uncompressed form
        block_contents = raw;
        type = kNoCompression;
      }
      break;
    }
  }
  WriteRawBlock(block_contents, type, handle, index);
  r->compressed_output.clear();
  block->Reset();
}

void TableBuilder::WriteRawBlock(const Slice& block_contents,
                                 CompressionType type, BlockHandle* handle,
                                 int index) {
  Rep* r = rep_;
  handle->set_offset(r->offsets[index]);
  handle->set_size(block_contents.size());  // todo 改一下
  handle->finish();
  if (r->options.multi_path && index != -1) {
    r->status = r->files[index]->Append(block_contents);
  } else {
    r->status = r->file->Append(block_contents);
  }

  if (r->status.ok()) {
    char trailer[kBlockTrailerSize];
    trailer[0] = type;
    uint32_t crc = crc32c::Value(block_contents.data(), block_contents.size());
    crc = crc32c::Extend(crc, trailer, 1);  // Extend crc to cover block type
    EncodeFixed32(trailer + 1, crc32c::Mask(crc));
    if (r->options.multi_path && index != -1) {
      r->status = r->files[index]->Append(Slice(trailer, kBlockTrailerSize));
    } else {
      r->status = r->file->Append(Slice(trailer, kBlockTrailerSize));
    }

    if (r->status.ok()) {
      if (r->options.multi_path && index != -1) {
        r->offsets[index] += block_contents.size() + kBlockTrailerSize;
      }
    }
  }
}

Status TableBuilder::status() const { return rep_->status; }

Status TableBuilder::Finish() {
  Rep* r = rep_;
  Flush();
  assert(!r->closed);

  // Write index block
  if (ok()) {
    if (r->pending_index_entry) {
      r->options.comparator->FindShortSuccessor(&r->last_key);
      r->last_key_queue.emplace_back(r->last_key);
      r->pending_index_entry = false;
    }
  }

  std::unique_lock<std::mutex> lock(r->m);
  r->cv_empty.wait(lock, [r] {
    return r->data_block_queue.empty() && r->pending_handle_queue.empty();
  });

  r->closed = true;
  lock.unlock();  //确保所有的data block和对应的block handle都写下

  BlockHandle filter_block_handle, metaindex_block_handle, index_block_handle;

  // Write filter block
  if (ok() && r->filter_block != nullptr) {
    WriteRawBlock(r->filter_block->Finish(), kNoCompression,
                  &filter_block_handle);
  }

  // Write metaindex block
  if (ok()) {
    BlockBuilder meta_index_block(&r->options);
    if (r->filter_block != nullptr) {
      // Add mapping from "filter.Name" to location of filter data
      std::string key = "filter.";
      key.append(r->options.filter_policy->Name());
      std::string handle_encoding;
      filter_block_handle.EncodeTo(&handle_encoding);
      meta_index_block.Add(key, handle_encoding);
    }

    // TODO(postrelease): Add stats and other meta blocks
    WriteBlock(&meta_index_block, &metaindex_block_handle);
  }

  // Write index block
  // if (ok()) {
  //   if (r->pending_index_entry) {
  //     r->options.comparator->FindShortSuccessor(&r->last_key);
  //     std::string handle_encoding;
  //     r->pending_handle->EncodeTo(&handle_encoding);
  //     r->index_block.Add(r->last_key, Slice(handle_encoding));
  //     r->pending_index_entry = false;
  //   }
  //   WriteBlock(&r->index_block, &index_block_handle);
  // }

  // Write index block
  WriteBlock(&r->index_block, &index_block_handle);

  // Write footer
  if (ok()) {
    Footer footer;
    // footer.set_files(r->file_numbers);
    footer.set_metaindex_handle(metaindex_block_handle);
    footer.set_index_handle(index_block_handle);
    std::string footer_encoding;
    footer.EncodeTo(&footer_encoding);
    r->status = r->file->Append(footer_encoding);
    if (r->status.ok()) {
      r->meta_offset += footer_encoding.size();
    }
  }
  return r->status;
}

void TableBuilder::Abandon() {
  Rep* r = rep_;
  assert(!r->closed);
  r->closed = true;
}

uint64_t TableBuilder::NumEntries() const { return rep_->num_entries; }

uint64_t TableBuilder::FileSize() const {  // return rep_->offset;
  uint64_t res = rep_->meta_offset;
  for (int i = 0; i < rep_->offsets.size(); i++) {
    res += rep_->offsets[i];
  }
  return res;
}

void TableBuilder::BackgroundThreadEntryPoint(int index) {
  Rep* r = rep_;
  while (!r->closed) {
    std::unique_lock<std::mutex> lock(r->m);
    r->cv_withMember.wait(lock, [r] {
      return !r->last_key_queue.empty() && !r->data_block_queue.empty() &&
             !r->pending_handle_queue.empty();
    });
    // 取一个出来处理
    assert(!r->data_block_queue.empty());
    assert(!r->last_key_queue.empty());
    // TableBuilder::DataBlockWithHandle tmp = r->data_block_queue.front();
    auto dataBlockWithHandle = r->data_block_queue.front();
    r->data_block_queue.pop_front();
    lock.unlock();
    WriteBlock(dataBlockWithHandle.data_block,
               dataBlockWithHandle.pending_handle, index);
    dataBlockWithHandle.pending_handle->set_file_number(index);
    if (ok()) {
      r->status = r->files[index]->Flush();  //刷新文件
    }
    if (index == 0) {
      std::unique_lock<std::mutex> lock(r->m);
      while (!r->last_key_queue.empty() && !r->pending_handle_queue.empty() &&
             r->pending_handle_queue.front()->isFinished()) {
        std::string handle_encoding;
        auto pending_handle = r->pending_handle_queue.front();
        pending_handle->EncodeTo(&handle_encoding);
        delete pending_handle;
        r->pending_handle_queue.pop_front();
        r->index_block.Add(r->last_key_queue.front(), Slice(handle_encoding));
        r->last_key_queue.pop_front();
      }
    }  //第一个线程负责写元数据
    lock.lock();
    if (r->data_block_queue.empty()) {  // 结束 唤醒
      r->cv_empty.notify_all();
    }
  }
}

}  // namespace leveldb
