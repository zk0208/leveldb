#pragma once

#include <hdb/env.h>
#include <pthread.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>

#include <string>

namespace hdb {

#define QUEUE_LOG
// #define LOG_FLUSH

static const size_t QUEUE_SIZE = 1024;

struct WorkQueue {
 public:
  WorkQueue(std::string &tag, Logger* info_log);
  ~WorkQueue();

  void Close(bool force);
  uint32_t Pull();
  void Push(uint32_t id);

 private:
  const std::string tag_;
  const bool enable_log_ = true;
  Logger* info_log_;
  uint32_t* ids_;
  uint32_t size_;
  int head_;
  int tail_;
  bool closing_;
  pthread_mutex_t mutex_current_;
  pthread_cond_t cond_producer_;
  pthread_cond_t cond_consumer_;
  pthread_cond_t cond_queue_empty_;
};

}  // namespace hdb
