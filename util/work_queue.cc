#include "util/work_queue.h"

#include <stdlib.h>
#include <string.h>

#include <string>

namespace hdb {

WorkQueue::WorkQueue(std::string &tag, Logger* info_log)
    : tag_(tag),
      info_log_(info_log),
      size_(0),
      head_(-1),
      tail_(-1),
      closing_(false) {
  ids_ = (uint32_t*)malloc(sizeof(uint32_t) * QUEUE_SIZE);

  pthread_mutex_init(&(mutex_current_), NULL);
  pthread_cond_init(&(cond_producer_), NULL);
  pthread_cond_init(&(cond_consumer_), NULL);
  pthread_cond_init(&(cond_queue_empty_), NULL);
}

WorkQueue::~WorkQueue() { free(ids_); }

void WorkQueue::Close(bool force) {
  pthread_mutex_lock(&(mutex_current_));
  if (force)
    size_ = 0;
  else {
    while (size_ != 0)
      pthread_cond_wait(&(cond_queue_empty_), &(mutex_current_));
  }
  closing_ = true;
  pthread_cond_broadcast(&(cond_producer_));
  pthread_mutex_unlock(&(mutex_current_));
}

uint32_t WorkQueue::Pull() {
  char th_name[16] = {0};
  pthread_getname_np(pthread_self(), th_name, sizeof(th_name));
  pthread_mutex_lock(&(mutex_current_));
  while (size_ == 0 && !closing_) {
    if (enable_log_)
      Log(info_log_, "[%s: %s] in WorkQueue::Pull: size == 0, wait\n",
          tag_.c_str(), th_name);

    pthread_cond_signal(&(cond_queue_empty_));
    pthread_cond_wait(&(cond_producer_), &(mutex_current_));
  }
  if (closing_) {
    if (enable_log_)
      Log(info_log_, "[%s: %s] in WorkQueue::Pull: closing\n", tag_.c_str(),
          th_name);
    pthread_mutex_unlock(&(mutex_current_));
    return (uint32_t)-1;
  }
  head_ = (head_ + 1) % QUEUE_SIZE;
  size_--;
  uint32_t id = ids_[head_];

  if (enable_log_)
    Log(info_log_, "[%s: %s] in WorkQueue::Pull: pull id %d\n", tag_.c_str(),
        th_name, (int)id);

  pthread_cond_signal(&(cond_consumer_));
  pthread_mutex_unlock(&(mutex_current_));
  return id;
}

void WorkQueue::Push(uint32_t id) {
  char th_name[16] = {0};
  pthread_getname_np(pthread_self(), th_name, sizeof(th_name));
  pthread_mutex_lock(&(mutex_current_));
  while (size_ == QUEUE_SIZE && !closing_) {
    if (enable_log_)
      Log(info_log_, "[%s: %s] in queue_push: queue is full", tag_.c_str(),
          th_name);
    pthread_cond_wait(&(cond_consumer_), &(mutex_current_));
  }
  if (closing_) {
    pthread_mutex_unlock(&(mutex_current_));
    return;
  }
  tail_ = (tail_ + 1) % QUEUE_SIZE;
  size_++;
  ids_[tail_] = id;

  if (enable_log_)
    Log(info_log_, "[%s: %s] in queue_push: push id %d\n", tag_.c_str(),
        th_name, id);

  if (size_ > 64)
    pthread_cond_broadcast(&(cond_producer_));
  else
    pthread_cond_signal(&(cond_producer_));
  pthread_mutex_unlock(&(mutex_current_));
}

}  // namespace hdb
