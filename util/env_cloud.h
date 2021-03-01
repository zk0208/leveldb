#include <iostream>
#include <unordered_map>
#include <unordered_set>
#include <vector>

#include "leveldb/env.h"
#include "leveldb/slice.h"
#include "leveldb/status.h"

#include "port/port.h"
#include "port/thread_annotations.h"
#include "util/env_posix_test_helper.h"
#include "util/posix_logger.h"

// 每个存储卷的最大sst数
static int max_file_num = 10;

// 可用存储卷数量
static int vol_num = 3;

// 最大的sst文件就夹数
static int max_dir = 10;
namespace leveldb {

class CloudEnv : public EnvWrapper {
 public:
  CloudEnv(Env* t) : EnvWrapper(t) {
    srand(time(NULL));
    fileNums = new int[max_dir + 1];
    memset(fileNums, 0, (max_dir + 1) * sizeof(int));
    std::string tmpDir;
    GetTestDirectory(&tmpDir);
    tmpDir = tmpDir + "/dbbench";
    for (int i = 1; i <= max_dir; i++) {
      CreateDir(tmpDir + "/test" + std::to_string(i));
    }
    availableDirs.insert("test1");
    availableDirs.insert("test2");
    availableDirs.insert("test3");
    dirNum = 3;
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
  std::unordered_map<std::string, int> sstToDir;
  std::unordered_set<std::string> availableDirs;
  int* fileNums;
  int dirNum;

  bool isSST(const std::string& fname);

  std::string getFilename(const std::string& fname);

  std::string getRandomFilename(const std::string& fname, int* writeDir);
  std::string getSSTName(const std::string& fname);
  std::string getSSTPath(const std::string& fname);
};
}  // namespace leveldb