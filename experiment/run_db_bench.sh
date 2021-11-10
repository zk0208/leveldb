#!/bin/bash
ulimit -n 65535
# 1GB
# ./db_bench --benchmarks="fillrandom,stats" --db="/home/colin/hub/YCSB-C-RocksDB/build/testDir" --num=1048576 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864
# level‘s max size
# l0    320M
# l1    320M
# l2    3.2G
# l3    32G
# l4    320G

# 预计60G 数据库
# iostat -mx 1 3600 /dev/sdb /dev/sdc /dev/sdd > levelbaseIO.txt &
# ../build/db_bench --benchmarks="fillrandom,stats" --db="/home/colin/hub/YCSB-C-RocksDB/build/testDir" --num=62914560 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 > levelbaseOUT.txt 2>&1
# cp -r /home/colin/hub/YCSB-C-RocksDB/build/testDir /home/colin/hub/YCSB-C-RocksDB/build/backup/levelbase
# rm -rf /home/colin/hub/YCSB-C-RocksDB/build/testDir/*

# iostat -mx 1 3600 /dev/sdb /dev/sdc /dev/sdd > blockbaseIO.txt &
# /home/colin/hub/my-leveldb/build/db_bench --benchmarks="fillrandom,stats" --db="/home/colin/hub/YCSB-C-RocksDB/build/testDir" --num=62914560 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 > blockbaseOUT.txt 2>&1

# date
# iostat -mx 1 3600 /dev/sdb /dev/sdc /dev/sdd > blockbaseIO_multithread_3.txt &
# /home/colin/hub/my-leveldb/build/db_bench --benchmarks="fillrandom,stats" --db="/home/colin/hub/YCSB-C-RocksDB/build/testDir" --num=20971520 --threads=3 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 > blockbaseOUT_multithread_3.txt 2>&1
# date

# date
# iostat -mx 1 3600 /dev/md0 /dev/sdb /dev/sdc /dev/sdd > originIO.txt &
# ../build/db_bench_origin --benchmarks="fillrandom,stats" --db="/home/colin/hub/YCSB-C-RocksDB/build/testDirRaid/test" --num=62914560 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 > originOUT.txt 2>&1
# date

# date
# iostat -mx 1 3600 /dev/md0 /dev/sdb /dev/sdc /dev/sdd > originIO_multithread_6_11_7.txt &
# ../build/db_bench_origin --benchmarks="fillrandom,stats" --db="/home/colin/hub/YCSB-C-RocksDB/build/testDirRaid/test" --num=62914560 --threads=6 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 > originOUT_multithread_6_11_7.txt 2>&1
# date


# date
# iostat -mx 1 3600 /dev/sdb  > originIO_multithread2_singleVol_11_8.txt &
# ../build/db_bench_origin --benchmarks="fillrandom,stats" --db="/home/colin/hub/YCSB-C-RocksDB/build/testDir/vol1" --num=31457280 --threads=2 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 > originOUT_multithread2_singleVol_11_8.txt 2>&1
# echo "../build/db_bench_origin --benchmarks="fillrandom,stats" --db="/home/colin/hub/YCSB-C-RocksDB/build/testDirRaid/test" --num=62914560 --threads=6 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864" >>  originOUT_multithread2_singleVol_11_8.txt
# date


date
# iostat -mx 1 3600 /dev/md0 /dev/sdb /dev/sdc /dev/sdd > originIO_tmpfs.txt &
../build/db_bench_origin --benchmarks="fillrandom,stats" --db="/home/colin/tmpDir/test" --num=62914560 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 > originOUT_tmpfs.txt 2>&1
echo "../build/db_bench_origin --benchmarks="fillrandom,stats" --db="/home/colin/tmpDir/test" --num=62914560 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864" >> originOUT_tmpfs.txt
date
