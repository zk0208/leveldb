// Copyright (c) 2011 The LevelDB Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file. See the AUTHORS file for names of contributors.

#include "db/builder.h"

#include "db/dbformat.h"
#include "db/filename.h"
#include "db/table_cache.h"
#include "db/version_edit.h"
#include <bits/stdint-uintn.h>

#include "leveldb/db.h"
#include "leveldb/env.h"
#include "leveldb/iterator.h"

namespace leveldb {

Status BuildTable(const std::string& dbname, Env* env, const Options& options,
                  TableCache* table_cache, Iterator* iter, FileMetaData* meta) {
  Status s;
  meta->file_size = 0;
  iter->SeekToFirst();

  std::string fname = TableFileName(dbname, meta->number);
  if (iter->Valid()) {
    WritableFile* file;
    s = env->NewWritableFile(fname, &file);
    if (!s.ok()) {
      return s;
    }

    TableBuilder* builder = new TableBuilder(options, file);
    meta->smallest.DecodeFrom(iter->key());
    Slice key;
    for (; iter->Valid(); iter->Next()) {
      key = iter->key();
      builder->Add(key, iter->value());
    }
    if (!key.empty()) {
      meta->largest.DecodeFrom(key);
    }

    // Finish and check for builder errors
    s = builder->Finish();
    if (s.ok()) {
      meta->file_size = builder->FileSize();
      assert(meta->file_size > 0);
    }
    delete builder;

    // Finish and check for file errors
    if (s.ok()) {
      s = file->Sync();
    }
    if (s.ok()) {
      s = file->Close();
    }
    delete file;
    file = nullptr;

    if (s.ok()) {
      // Verify that the table is usable
      Iterator* it = table_cache->NewIterator(ReadOptions(), meta->number,
                                              meta->file_size);
      s = it->status();
      delete it;
    }
  }

  // Check for input iterator errors
  if (!iter->status().ok()) {
    s = iter->status();
  }

  if (s.ok() && meta->file_size > 0) {
    // Keep it
  } else {
    env->RemoveFile(fname);
  }
  return s;
}

Status BuildTableFromMem(const std::string& dbname, Env* env,
                         const Options& options, TableCache* table_cache,
                         Iterator* iter,
                         const std::vector<FileMetaData*>& files) {
  Status s;
  files[0]->file_size = 0;
  iter->SeekToFirst();

  std::string fname = TableFileName(dbname, files[0]->number);
  std::vector<std::string> data_fnames;
  for (int i = 1; i < options.db_paths.size(); i++) {
    data_fnames.emplace_back(
        TableFileDataName(options.db_paths[i].path, files[i]->number));
  }
  if (iter->Valid()) {
    WritableFile* file;
    s = env->NewWritableFile(fname, &file);
    if (!s.ok()) {
      return s;
    }
    std::vector<WritableFile*> writable_files;
    if (options.multi_path) {
      for (int i = 0; i < data_fnames.size(); i++) {
        WritableFile* tmp;
        s = env->NewWritableFile(data_fnames[i], &tmp);
        writable_files.emplace_back(tmp);
        if (!s.ok()) {
          return s;
        }
      }
    }
    TableBuilder* builder;
    if (!options.multi_path) {
      builder = new TableBuilder(options, file);
    } else {
      std::vector<uint64_t> file_numbers;
      for (int i = 1; i < files.size(); i++) {
        file_numbers.push_back(files[i]->number);
      }
      builder = new TableBuilder(options, file, writable_files, file_numbers);
    }
    files[0]->smallest.DecodeFrom(iter->key());
    Slice key;
    for (; iter->Valid(); iter->Next()) {
      key = iter->key();
      builder->Add(key, iter->value());
    }
    if (!key.empty()) {
      files[0]->largest.DecodeFrom(key);
    }

    // Finish and check for builder errors
    s = builder->Finish();
    if (s.ok()) {
      files[0]->file_size = builder->FileSize();
      assert(files[0]->file_size > 0);
    }
    delete builder;

    // Finish and check for file errors
    if (s.ok()) {
      s = file->Sync();
    }
    if (s.ok()) {
      s = file->Close();
    }
    delete file;
    file = nullptr;

    if (s.ok()) {
      // Verify that the table is usable
      Iterator* it = table_cache->NewIterator(ReadOptions(), files[0]->number,
                                              files[0]->file_size);
      s = it->status();
      delete it;
    }
  }

  // Check for input iterator errors
  if (!iter->status().ok()) {
    s = iter->status();
  }

  if (s.ok() && files[0]->file_size > 0) {
    // Keep it
  } else {
    env->RemoveFile(fname);
  }
  return s;
}

}  // namespace leveldb
