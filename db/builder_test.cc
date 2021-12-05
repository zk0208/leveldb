// Copyright (c) 2011 The LevelDB Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file. See the AUTHORS file for names of contributors.

#include "db/builder.h"

#include "db/memtable.h"
#include "db/table_cache.h"
#include "db/version_edit.h"
#include "db/write_batch_internal.h"
#include <cstdint>
#include <string>

#include "leveldb/db.h"
#include "leveldb/env.h"
#include "leveldb/slice.h"

#include "util/logging.h"

#include "gtest/gtest.h"

namespace leveldb {

const int kNumNonTableCacheFiles = 10;

Slice RandomString(Random* rnd, int len, std::string* dst) {
  dst->resize(len);
  for (int i = 0; i < len; i++) {
    (*dst)[i] = static_cast<char>(' ' + rnd->Uniform(95));  // ' ' .. '~'
  }
  return Slice(*dst);
}

Slice CompressibleString(Random* rnd, double compressed_fraction, size_t len,
                         std::string* dst) {
  int raw = static_cast<int>(len * compressed_fraction);
  if (raw < 1) raw = 1;
  std::string raw_data;
  RandomString(rnd, raw, &raw_data);

  // Duplicate the random data until we have filled "len" bytes
  dst->clear();
  while (dst->size() < len) {
    dst->append(raw_data);
  }
  dst->resize(len);
  return Slice(*dst);
}

// Helper for quickly generating random data.
class RandomGenerator {
 private:
  std::string data_;
  int pos_;

 public:
  RandomGenerator() {
    // We use a limited amount of data over and over again and ensure
    // that it is larger than the compression window (32KB), and also
    // large enough to serve all typical value sizes we want to write.
    Random rnd(301);
    std::string piece;
    while (data_.size() < 1048576) {
      // Add a short fragment that is as compressible as specified
      // by FLAGS_compression_ratio.
      CompressibleString(&rnd, 1, 100, &piece);  // 没有压缩
      data_.append(piece);
    }
    pos_ = 0;
  }

  Slice Generate(size_t len) {
    if (pos_ + len > data_.size()) {
      pos_ = 0;
      assert(len < data_.size());
    }
    pos_ += len;
    return Slice(data_.data() + pos_ - len, len);
  }
};

void initMemtable(int num, MemTable* mem) {
  RandomGenerator gen;
  for (int i = 0; i < num; i++) {
    // mem->Add();
    // slice(i);
    // mem->Add(i, kTypeValue, Slice("key" + std::to_string(i)),
    //          Slice("value" + std::to_string(i)));
    mem->Add(i, kTypeValue, Slice("key" + std::to_string(i)),
             gen.Generate(1024));  // 1KB大小kv
  }
}

static int TableCacheSize(const Options& sanitized_options) {
  // Reserve ten files or so for other uses and give the rest to TableCache.
  return sanitized_options.max_open_files - kNumNonTableCacheFiles;
}

// TEST(BuilderTest, speed) {
void builderTest(std::string db_name, int nums, int filenums) {
  InternalKeyComparator cmp(BytewiseComparator());
  MemTable* mem = new MemTable(cmp);
  mem->Ref();
  initMemtable(nums, mem);
  auto iter = mem->NewIterator();
  // std::string db_name_ =
  //     "/home/colin/hub/YCSB-C-RocksDB/build/testDirRaid/testBuilder";
  // std::string db_name_ = "/tmp/testBuilder";
  Options options;
  options.multi_path = true;
  options.compression = kNoCompression;
  auto table_cache_ = new TableCache(db_name, options, TableCacheSize(options));
  FileMetaData meta;
  meta.number = 1;

  options.db_paths = {{db_name + "/vol1", (uint64_t)1 * 1024 * 1024 * 1024},
                      {db_name + "/vol2", (uint64_t)3 * 1024 * 1024 * 1024},
                      {db_name + "/vol3", (uint64_t)300 * 1024 * 1024 * 1024}};

  // 基于当前系统的当前日期/时间
  time_t now = time(0);

  // 把 now 转换为字符串形式
  char* dt = ctime(&now);

  std::cout << "build table 开始时间：" << dt << std::endl;

  uint64_t start = options.env->NowMicros();
  for (int i = 1; i <= filenums; i++) {
    meta.number = i;
    Status s =
        BuildTable(db_name, options.env, options, table_cache_, iter, &meta);
    if (!s.ok()) {
      std::cout << "build 出错" << std::endl;
    }
  }
  uint64_t end = options.env->NowMicros();
  std::cout << "spend time in build table: " << end - start << " micros"
            << std::endl;
  now = time(0);
  dt = ctime(&now);
  std::cout << "build table 结束时间：" << dt << std::endl;
  // EXPECT_TRUE(s.ok());
}

// static std::string PrintContents(WriteBatch* b) {
//   InternalKeyComparator cmp(BytewiseComparator());
//   MemTable* mem = new MemTable(cmp);
//   mem->Ref();
//   std::string state;
//   Status s = WriteBatchInternal::InsertInto(b, mem);
//   int count = 0;
//   Iterator* iter = mem->NewIterator();
//   for (iter->SeekToFirst(); iter->Valid(); iter->Next()) {
//     ParsedInternalKey ikey;
//     EXPECT_TRUE(ParseInternalKey(iter->key(), &ikey));
//     switch (ikey.type) {
//       case kTypeValue:
//         state.append("Put(");
//         state.append(ikey.user_key.ToString());
//         state.append(", ");
//         state.append(iter->value().ToString());
//         state.append(")");
//         count++;
//         break;
//       case kTypeDeletion:
//         state.append("Delete(");
//         state.append(ikey.user_key.ToString());
//         state.append(")");
//         count++;
//         break;
//     }
//     state.append("@");
//     state.append(NumberToString(ikey.sequence));
//   }
//   delete iter;
//   if (!s.ok()) {
//     state.append("ParseError()");
//   } else if (count != WriteBatchInternal::Count(b)) {
//     state.append("CountMismatch()");
//   }
//   mem->Unref();
//   return state;
// }

// TEST(WriteBatchTest, Empty) {
//   WriteBatch batch;
//   ASSERT_EQ("", PrintContents(&batch));
//   ASSERT_EQ(0, WriteBatchInternal::Count(&batch));
// }

// TEST(WriteBatchTest, Multiple) {
//   WriteBatch batch;
//   batch.Put(Slice("foo"), Slice("bar"));
//   batch.Delete(Slice("box"));
//   batch.Put(Slice("baz"), Slice("boo"));
//   WriteBatchInternal::SetSequence(&batch, 100);
//   ASSERT_EQ(100, WriteBatchInternal::Sequence(&batch));
//   ASSERT_EQ(3, WriteBatchInternal::Count(&batch));
//   ASSERT_EQ(
//       "Put(baz, boo)@102"
//       "Delete(box)@101"
//       "Put(foo, bar)@100",
//       PrintContents(&batch));
// }

// TEST(WriteBatchTest, Corruption) {
//   WriteBatch batch;
//   batch.Put(Slice("foo"), Slice("bar"));
//   batch.Delete(Slice("box"));
//   WriteBatchInternal::SetSequence(&batch, 200);
//   Slice contents = WriteBatchInternal::Contents(&batch);
//   WriteBatchInternal::SetContents(&batch,
//                                   Slice(contents.data(), contents.size() -
//                                   1));
//   ASSERT_EQ(
//       "Put(foo, bar)@200"
//       "ParseError()",
//       PrintContents(&batch));
// }

// TEST(WriteBatchTest, Append) {
//   WriteBatch b1, b2;
//   WriteBatchInternal::SetSequence(&b1, 200);
//   WriteBatchInternal::SetSequence(&b2, 300);
//   b1.Append(b2);
//   ASSERT_EQ("", PrintContents(&b1));
//   b2.Put("a", "va");
//   b1.Append(b2);
//   ASSERT_EQ("Put(a, va)@200", PrintContents(&b1));
//   b2.Clear();
//   b2.Put("b", "vb");
//   b1.Append(b2);
//   ASSERT_EQ(
//       "Put(a, va)@200"
//       "Put(b, vb)@201",
//       PrintContents(&b1));
//   b2.Delete("foo");
//   b1.Append(b2);
//   ASSERT_EQ(
//       "Put(a, va)@200"
//       "Put(b, vb)@202"
//       "Put(b, vb)@201"
//       "Delete(foo)@203",
//       PrintContents(&b1));
// }

// TEST(WriteBatchTest, ApproximateSize) {
//   WriteBatch batch;
//   size_t empty_size = batch.ApproximateSize();

//   batch.Put(Slice("foo"), Slice("bar"));
//   size_t one_key_size = batch.ApproximateSize();
//   ASSERT_LT(empty_size, one_key_size);

//   batch.Put(Slice("baz"), Slice("boo"));
//   size_t two_keys_size = batch.ApproximateSize();
//   ASSERT_LT(one_key_size, two_keys_size);

//   batch.Delete(Slice("box"));
//   size_t post_delete_size = batch.ApproximateSize();
//   ASSERT_LT(two_keys_size, post_delete_size);
// }

}  // namespace leveldb

int main(int argc, char** argv) {
  // testing::InitGoogleTest(&argc, argv);
  // return RUN_ALL_TESTS();
  std::string db_;
  int nums_ = 0;
  int filenums_ = 1;
  if (argc < 3) {
    std::fprintf(stderr, "Invalid flag num %d!\n", argc - 1);
    std::exit(1);
  }
  for (int i = 1; i < argc; i++) {
    double d;
    int n;
    int fn;
    char junk;
    if (leveldb::Slice(argv[i]).starts_with("--db=")) {
      db_ = argv[i] + strlen("--db=");
    } else if (sscanf(argv[i], "--nums=%d%c", &n, &junk) == 1) {
      nums_ = n;
    } else if (sscanf(argv[i], "--filenums=%d%c", &fn, &junk) == 1) {
      filenums_ = fn;
    } else {
      std::fprintf(stderr, "Invalid flag '%s'\n", argv[i]);
      std::exit(1);
    }
  }
  std::cout << "db = " << db_ << std::endl;
  std::cout << "nums = " << nums_ << std::endl;
  leveldb::builderTest(db_, nums_, filenums_);
  return 0;
}
