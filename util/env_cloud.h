#include <iostream>

#include "leveldb/env.h"
#include "leveldb/slice.h"
#include "leveldb/status.h"

#include "port/port.h"
#include "port/thread_annotations.h"
#include "util/env_posix_test_helper.h"
#include "util/posix_logger.h"
namespace leveldb {

class CloudEnv : public EnvWrapper {
 public:
  CloudEnv(Env* t) : EnvWrapper(t) {
    std::cout << "hello leveldb" << std::endl;
  }
  Status NewSequentialFile(const std::string& fname,
                           SequentialFile** result) override;

  Status NewRandomAccessFile(const std::string& fname,
                             RandomAccessFile** result) override;

  Status NewWritableFile(const std::string& fname,
                         WritableFile** result) override;

  Status NewAppendableFile(const std::string& fname,
                           WritableFile** result) override;

  bool FileExists(const std::string& fname) override;

  Status RemoveFile(const std::string& fname) override;

 private:
  std::string getFilename(const std::string& fname);
};
}  // namespace leveldb