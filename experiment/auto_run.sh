#!/bin/bash
ulimit -n 65535
# 1GB
# ./db_bench --benchmarks="fillrandom,stats" --db="/home/colin/hub/YCSB-C-RocksDB/build/testDir" --num=1048576 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864
# level‘s max size
# l0    320M ---+
#               +
# l1    320M ---+
#
# l2    3.2G ---+
#               +
# l3    32G  ---+
#
# l4    320G ---+

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


# date
# # iostat -mx 1 3600 /dev/md0 /dev/sdb /dev/sdc /dev/sdd > originIO_tmpfs.txt &
# ../build/db_bench_origin --benchmarks="fillrandom,stats" --db="/home/colin/tmpDir/test" --num=62914560 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 > originOUT_tmpfs.txt 2>&1
# echo "../build/db_bench_origin --benchmarks="fillrandom,stats" --db="/home/colin/tmpDir/test" --num=62914560 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864" >> originOUT_tmpfs.txt
# date

for loop in 1 2 3
do
    #卸载磁盘
    sudo umount /home/colin/hub/YCSB-C-RocksDB/build/testDir/vol1
    sudo umount /home/colin/hub/YCSB-C-RocksDB/build/testDir/vol2
    sudo umount /home/colin/hub/YCSB-C-RocksDB/build/testDir/vol3

    #格式化磁盘
    sudo mkfs.ext4 -F /dev/sdb1
    sudo mkfs.ext4 -F /dev/sdc1
    sudo mkfs.ext4 -F /dev/sdd1

    #挂载磁盘
    sudo mount /dev/sdb1 /home/colin/hub/YCSB-C-RocksDB/build/testDir/vol1
    sudo mount /dev/sdc1 /home/colin/hub/YCSB-C-RocksDB/build/testDir/vol2
    sudo mount /dev/sdd1 /home/colin/hub/YCSB-C-RocksDB/build/testDir/vol3

    #变更所有者
    sudo chown colin:colin /home/colin/hub/YCSB-C-RocksDB/build/testDir/vol1
    sudo chown colin:colin /home/colin/hub/YCSB-C-RocksDB/build/testDir/vol2
    sudo chown colin:colin /home/colin/hub/YCSB-C-RocksDB/build/testDir/vol3


    # 需要控制每个存储卷 100MB/s的读写速度

    # 测试levelbase load , update, read, scan, hotread
    # load
    iostat -mx 1 3600 /dev/sdb /dev/sdc /dev/sdd > levelbaseIO_load_11_8\(${loop}\).txt &
    sudo cgexec -g blkio:test_write ../build/db_bench_multipath --benchmarks="fillrandom,stats" --db="/home/colin/hub/YCSB-C-RocksDB/build/testDir" --num=62914560 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 > levelbaseOUT_load_11_8\(${loop}\).txt 2>&1
    if [ ${loop} == 1 ]
        then 
            cp -r /home/colin/hub/YCSB-C-RocksDB/build/testDir /home/colin/hub/YCSB-C-RocksDB/build/backup/levelbase_11_8
    fi
    # rm -rf /home/colin/hub/YCSB-C-RocksDB/build/testDir/*

    # read 
    iostat -mx 1 3600 /dev/sdb /dev/sdc /dev/sdd > levelbaseIO_read_11_8\(${loop}\).txt &
    sudo cgexec -g blkio:test_write ../build/db_bench_multipath --benchmarks="readrandom,stats" --db="/home/colin/hub/YCSB-C-RocksDB/build/testDir" --reads=6291456 --num=62914560 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 > levelbaseOUT_read_11_8\(${loop}\).txt 2>&1

    #scan
    iostat -mx 1 3600 /dev/sdb /dev/sdc /dev/sdd > levelbaseIO_scan_11_8\(${loop}\).txt &
    sudo cgexec -g blkio:test_write ../build/db_bench_multipath --benchmarks="seekordered,stats" --db="/home/colin/hub/YCSB-C-RocksDB/build/testDir" --reads=6291456 --num=62914560 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 > levelbaseOUT_scan_11_8\(${loop}\).txt 2>&1

    #hotread
    iostat -mx 1 3600 /dev/sdb /dev/sdc /dev/sdd > levelbaseIO_hotread_11_8\(${loop}\).txt &
    sudo cgexec -g blkio:test_write ../build/db_bench_multipath --benchmarks="readhot,stats" --db="/home/colin/hub/YCSB-C-RocksDB/build/testDir" --reads=6291456 --num=62914560 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 > levelbaseOUT_hotread_11_8\(${loop}\).txt 2>&1

    # update
    iostat -mx 1 3600 /dev/sdb /dev/sdc /dev/sdd > levelbaseIO_update_11_8\(${loop}\).txt &
    sudo cgexec -g blkio:test_write ../build/db_bench_multipath --benchmarks="overwrite,stats" --db="/home/colin/hub/YCSB-C-RocksDB/build/testDir" --num=6291456 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 > levelbaseOUT_update_11_8\(${loop}\).txt 2>&1

    # 删除数据
    sudo rm -rf /home/colin/hub/YCSB-C-RocksDB/build/testDir/*


    # 测试blockbase load, update, read, scan, hotread
    # load
    iostat -mx 1 3600 /dev/sdb /dev/sdc /dev/sdd > blockbaseIO_load_11_8\(${loop}\).txt &
    sudo cgexec -g blkio:test_write /home/colin/hub/my-leveldb/build/db_bench --benchmarks="fillrandom,stats" --db="/home/colin/hub/YCSB-C-RocksDB/build/testDir" --num=62914560 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 > blockbaseOUT_load_11_8\(${loop}\).txt 2>&1
    if [ ${loop} == 1 ]
        then 
            sudo cp -r /home/colin/hub/YCSB-C-RocksDB/build/testDir /home/colin/hub/YCSB-C-RocksDB/build/backup/blockbase_11_8
    fi
    # rm -rf /home/colin/hub/YCSB-C-RocksDB/build/testDir/*

    # read 
    iostat -mx 1 3600 /dev/sdb /dev/sdc /dev/sdd > blockbaseIO_read_11_8\(${loop}\).txt &
    sudo cgexec -g blkio:test_write /home/colin/hub/my-leveldb/build/db_bench --benchmarks="readrandom,stats" --db="/home/colin/hub/YCSB-C-RocksDB/build/testDir" --reads=6291456 --num=62914560 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 > blockbaseOUT_read_11_8\(${loop}\).txt 2>&1

    #scan
    iostat -mx 1 3600 /dev/sdb /dev/sdc /dev/sdd > blockbaseIO_scan_11_8\(${loop}\).txt &
    sudo cgexec -g blkio:test_write /home/colin/hub/my-leveldb/build/db_bench --benchmarks="seekordered,stats" --db="/home/colin/hub/YCSB-C-RocksDB/build/testDir" --reads=6291456 --num=62914560 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 > blockbaseOUT_scan_11_8\(${loop}\).txt 2>&1

    #hotread
    iostat -mx 1 3600 /dev/sdb /dev/sdc /dev/sdd > blockbaseIO_hotread_11_8\(${loop}\).txt &
    sudo cgexec -g blkio:test_write /home/colin/hub/my-leveldb/build/db_bench --benchmarks="readhot,stats" --db="/home/colin/hub/YCSB-C-RocksDB/build/testDir" --reads=6291456 --num=62914560 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 > blockbaseOUT_hotread_11_8\(${loop}\).txt 2>&1

    # update
    iostat -mx 1 3600 /dev/sdb /dev/sdc /dev/sdd > blockbaseIO_update_11_8\(${loop}\).txt &
    sudo cgexec -g blkio:test_write /home/colin/hub/my-leveldb/build/db_bench --benchmarks="overwrite,stats" --db="/home/colin/hub/YCSB-C-RocksDB/build/testDir" --num=6291456 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 > blockbaseOUT_update_11_8\(${loop}\).txt 2>&1

    # 删除数据
    sudo rm -rf /home/colin/hub/YCSB-C-RocksDB/build/testDir/*


    # 构建raid0
    sudo umount /home/colin/hub/YCSB-C-RocksDB/build/testDir/vol1
    sudo umount /home/colin/hub/YCSB-C-RocksDB/build/testDir/vol2
    sudo umount /home/colin/hub/YCSB-C-RocksDB/build/testDir/vol3

    sudo mdadm --create --verbose /dev/md0 --level=0 --raid-devices=3 /dev/sd{b1,c1,d1} --run
    sudo mkfs.ext4 -F /dev/md0
    sudo mount /dev/md0 /home/colin/hub/YCSB-C-RocksDB/build/testDirRaid
    sudo chown colin:colin /home/colin/hub/YCSB-C-RocksDB/build/testDirRaid

    # 测试origin raid0 load , update, read, scan, hotread
    # load
    iostat -mx 1 3600 /dev/sdb /dev/sdc /dev/sdd > originIO_raid_load_11_8\(${loop}\).txt &
    sudo cgexec -g blkio:test_write ../build/db_bench_origin --benchmarks="fillrandom,stats" --db="/home/colin/hub/YCSB-C-RocksDB/build/testDir" --num=62914560 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 > originOUT_raid_load_11_8\(${loop}\).txt 2>&1
    if [ ${loop} == 1 ]
        then 
            sudo cp -r /home/colin/hub/YCSB-C-RocksDB/build/testDirRaid /home/colin/hub/YCSB-C-RocksDB/build/backup/origin_11_8
    fi
    # rm -rf /home/colin/hub/YCSB-C-RocksDB/build/testDir/*

    # read 
    iostat -mx 1 3600 /dev/sdb /dev/sdc /dev/sdd > originIO_raid_read_11_8\(${loop}\).txt &
    sudo cgexec -g blkio:test_write ../build/db_bench_origin --benchmarks="readrandom,stats" --db="/home/colin/hub/YCSB-C-RocksDB/build/testDir" --reads=6291456 --num=62914560 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 > originOUT_raid_read_11_8\(${loop}\).txt 2>&1

    #scan
    iostat -mx 1 3600 /dev/sdb /dev/sdc /dev/sdd > originIO_raid_scan_11_8\(${loop}\).txt &
    sudo cgexec -g blkio:test_write ../build/db_bench_origin --benchmarks="seekordered,stats" --db="/home/colin/hub/YCSB-C-RocksDB/build/testDir" --reads=6291456 --num=62914560 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 > originOUT_raid_scan_11_8\(${loop}\).txt 2>&1

    #hotread
    iostat -mx 1 3600 /dev/sdb /dev/sdc /dev/sdd > originIO_raid_hotread_11_8\(${loop}\).txt &
    sudo cgexec -g blkio:test_write ../build/db_bench_origin --benchmarks="readhot,stats" --db="/home/colin/hub/YCSB-C-RocksDB/build/testDir" --reads=6291456 --num=62914560 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 > originOUT_raid_hotread_11_8\(${loop}\).txt 2>&1

    # update
    iostat -mx 1 3600 /dev/sdb /dev/sdc /dev/sdd > originIO_raid_update_11_8\(${loop}\).txt &
    sudo cgexec -g blkio:test_write ../build/db_bench_origin --benchmarks="overwrite,stats" --db="/home/colin/hub/YCSB-C-RocksDB/build/testDir" --num=6291456 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 > originOUT_raid_update_11_8\(${loop}\).txt 2>&1

    # 删除数据
    sudo rm -rf /home/colin/hub/YCSB-C-RocksDB/build/testDirRaid/*

    #卸载raid0
    sudo umount /home/colin/hub/YCSB-C-RocksDB/build/testDirRaid

    # 停用raid0
    sudo mdadm --stop /dev/md0
done

