#include "util/env_cloud.h"

#include <cstdlib>
#include <time.h>

namespace leveldb {

Status CloudEnv::NewSequentialFile(const std::string& fname,
                                   SequentialFile** result) {
  // std::string newFilename = getFilename(fname);
  // return EnvWrapper::NewSequentialFile(newFilename, result);
  if (isSST(fname)) {
    return EnvWrapper::NewSequentialFile(getSSTPath(fname), result);
  } else {
    return EnvWrapper::NewSequentialFile(fname, result);
  }
}

Status CloudEnv::NewRandomAccessFile(const std::string& fname,
                                     RandomAccessFile** result) {
  // std::string newFilename = getFilename(fname);
  // return EnvWrapper::NewRandomAccessFile(newFilename, result);
  if (isSST(fname)) {
    return EnvWrapper::NewRandomAccessFile(getSSTPath(fname), result);
  } else {
    return EnvWrapper::NewRandomAccessFile(fname, result);
  }
}

Status CloudEnv::NewWritableFile(const std::string& fname,
                                 WritableFile** result) {
  // std::string newFilename = getFilename(fname);
  // return EnvWrapper::NewWritableFile(newFilename, result);
  if (isSST(fname)) {
    int writeDir = 0;
    std::string newFilename = getRandomFilename(fname, &writeDir);
    fileNums[writeDir]++;
    if (fileNums[writeDir] >= max_file_num) {
      availableDirs.erase("test" + std::to_string(writeDir));
      if (availableDirs.size() < vol_num) {
        availableDirs.insert("test" + std::to_string(++vol_num));
      }
    }
    sstToDir.insert({getSSTName(fname), writeDir});
    return EnvWrapper::NewWritableFile(newFilename, result);
  } else {
    return EnvWrapper::NewWritableFile(fname, result);
  }
}

Status CloudEnv::NewAppendableFile(const std::string& fname,
                                   WritableFile** result) {
  // std::string newFilename = getFilename(fname);
  // return EnvWrapper::NewAppendableFile(newFilename, result);
  if (isSST(fname)) {
    int writeDir = 0;
    std::string newFilename = getRandomFilename(fname, &writeDir);
    fileNums[writeDir]++;
    if (fileNums[writeDir] >= max_file_num) {
      availableDirs.erase("test" + std::to_string(writeDir));
      if (availableDirs.size() < vol_num) {
        availableDirs.insert("test" + std::to_string(++vol_num));
      }
    }
    sstToDir.insert({getSSTName(fname), writeDir});
    return EnvWrapper::NewAppendableFile(newFilename, result);
  } else {
    return EnvWrapper::NewAppendableFile(fname, result);
  }
}

bool CloudEnv::FileExists(const std::string& fname) {
  // std::string newFilename = getFilename(fname);
  // return EnvWrapper::FileExists(newFilename);
  if (isSST(fname)) {
    // std::string newFilename=
    if (sstToDir.find(getSSTName(fname)) == sstToDir.end()) {
      return false;
    }
    return true;
  } else {
    return EnvWrapper::FileExists(fname);
  }
}

Status CloudEnv::RemoveFile(const std::string& fname) {
  // std::string newFilename = getFilename(fname);
  // return EnvWrapper::RemoveFile(newFilename);
  if (isSST(fname)) {
    return EnvWrapper::RemoveFile(getSSTPath(fname));
  } else {
    return EnvWrapper::RemoveFile(fname);
  }
}

bool CloudEnv::isSST(const std::string& fname) {
  size_t lastDot = fname.find_last_of('.');
  if (lastDot != -1) {
    if (fname.substr(lastDot + 1) == "ldb") {
      return true;
    }
  }
  return false;
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

std::string CloudEnv::getRandomFilename(const std::string& fname,
                                        int* writeDir) {
  size_t last_partition = fname.find_last_of('/');
  *writeDir = rand() % max_dir + 1;
  std::string randomDir = "test" + std::to_string(*writeDir);
  while (!availableDirs.count(randomDir)) {
    *writeDir = rand() % max_dir + 1;
    randomDir = "test" + std::to_string(*writeDir);
  }
  return fname.substr(0, last_partition) + "/" + randomDir +
         fname.substr(last_partition);
}

std::string CloudEnv::getSSTName(const std::string& fname) {
  size_t last_partition = fname.find_last_of('/');
  return fname.substr(last_partition + 1);
}

std::string CloudEnv::getSSTPath(const std::string& fname) {
  std::string SSTname = getSSTName(fname);
  int DirNum = sstToDir.at(SSTname);
  size_t last_partition = fname.find_last_of('/');
  return fname.substr(0, last_partition) + "/" + "test" +
         std::to_string(DirNum) + fname.substr(last_partition);
}

}  // namespace leveldb