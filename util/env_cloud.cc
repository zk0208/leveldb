#include "util/env_cloud.h"

namespace leveldb {

Status CloudEnv::NewSequentialFile(const std::string& fname,
                                   SequentialFile** result) {
  std::string newFilename = getFilename(fname);
  return EnvWrapper::NewSequentialFile(newFilename, result);
}

Status CloudEnv::NewRandomAccessFile(const std::string& fname,
                                     RandomAccessFile** result) {
  std::string newFilename = getFilename(fname);
  return EnvWrapper::NewRandomAccessFile(newFilename, result);
}

Status CloudEnv::NewWritableFile(const std::string& fname,
                                 WritableFile** result) {
  std::string newFilename = getFilename(fname);
  return EnvWrapper::NewWritableFile(newFilename, result);
}

Status CloudEnv::NewAppendableFile(const std::string& fname,
                                   WritableFile** result) {
  std::string newFilename = getFilename(fname);
  return EnvWrapper::NewAppendableFile(newFilename, result);
}

bool CloudEnv::FileExists(const std::string& fname) {
  std::string newFilename = getFilename(fname);
  return EnvWrapper::FileExists(newFilename);
}

Status CloudEnv::RemoveFile(const std::string& fname) {
  std::string newFilename = getFilename(fname);
  return EnvWrapper::RemoveFile(newFilename);
}

std::string CloudEnv::getFilename(const std::string& fname) {
  std::string newFilename = fname;
  size_t lastDot = fname.find_last_of('.');
  if (lastDot != -1) {
    if (fname.substr(lastDot + 1) == "ldb") {
      size_t last_partition = fname.find_last_of('/');
      newFilename = fname.substr(0, last_partition) + "/test" +
                    fname.substr(last_partition);
    }
  }
  return newFilename;
}
}  // namespace leveldb