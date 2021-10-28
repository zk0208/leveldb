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
# iostat -m 1 3600 /dev/sdb /dev/sdc /dev/sdd > levelbaseIO.txt &
# ../build/db_bench --benchmarks="fillrandom,stats" --db="/home/colin/hub/YCSB-C-RocksDB/build/testDir" --num=62914560 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 > levelbaseOUT.txt 2>&1
# cp -r /home/colin/hub/YCSB-C-RocksDB/build/testDir /home/colin/hub/YCSB-C-RocksDB/build/backup/levelbase
# rm -rf /home/colin/hub/YCSB-C-RocksDB/build/testDir/*

# iostat -m 1 3600 /dev/sdb /dev/sdc /dev/sdd > blockbaseIO.txt &
# /home/colin/hub/my-leveldb/build/db_bench --benchmarks="fillrandom,stats" --db="/home/colin/hub/YCSB-C-RocksDB/build/testDir" --num=62914560 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 > blockbaseOUT.txt 2>&1

date
iostat -m 1 3600 /dev/sdb /dev/sdc /dev/sdd > blockbaseIO_multithread_3.txt &
/home/colin/hub/my-leveldb/build/db_bench --benchmarks="fillrandom,stats" --db="/home/colin/hub/YCSB-C-RocksDB/build/testDir" --num=20971520 --threads=3 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 > blockbaseOUT_multithread_3.txt 2>&1
date