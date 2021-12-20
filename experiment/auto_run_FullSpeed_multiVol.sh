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


# date
# # iostat -mx 1 3600 /dev/md0 /dev/sdb /dev/sdc /dev/sdd > originIO_tmpfs.txt &
# ../build/db_bench_origin --benchmarks="fillrandom,stats" --db="/home/colin/tmpDir/test" --num=62914560 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 > originOUT_tmpfs.txt 2>&1
# echo "../build/db_bench_origin --benchmarks="fillrandom,stats" --db="/home/colin/tmpDir/test" --num=62914560 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864" >> originOUT_tmpfs.txt
# date
# workDirs=("/home/colin/hub/YCSB-C-RocksDB/build/testDir/vol1" "/home/colin/hub/YCSB-C-RocksDB/build/testDir/vol2" "/home/colin/hub/YCSB-C-RocksDB/build/testDir/vol3")
# workDevs=("/dev/sdb1" "/dev/sdc1" "/dev/sdd1")


# for loop in 1
# do
#     #卸载磁盘
#     for dir in ${workDirs[@]}
#         do 
#             sudo umount ${dir}
#         done

#     #格式化磁盘
#     for dev in ${workDevs[@]}
#         do  
#             sudo mkfs.ext4 -F ${dev}
#         done

#     #挂载磁盘
#     for i in ${!workDevs[@]}
#         do
#             sudo mount ${workDevs[$i]} ${workDirs[$i]}
#         done

#     #变更所有者
#     for dir in ${workDirs[@]}
#         do
#             sudo chown colin:colin ${dir}
#         done


#     # 需要控制每个存储卷 100MB/s的读写速度

#     # 测试levelbase load , update, read, scan, hotread
#     workTime=`date +%Y-%m-%d_%H:%M:%S`
#     # 记录了compaction的数量和时延
#     style="levelbase_normal_wtCnums"

#     # load
#     workload="load"

#     iostat -mx 1 3600 /dev/sdb /dev/sdc /dev/sdd > ${style}IO_${workload}_${workTime}\(${loop}\).txt &
#     echo `date +%Y-%m-%d_%H:%M:%S` >> ${style}OUT_${workload}_${workTime}\(${loop}\).txt
#     lsblk >> ${style}OUT_${workload}_${workTime}\(${loop}\).txt
#     ../build/db_bench --benchmarks="fillrandom,stats,sstables" --db="/home/colin/hub/YCSB-C-RocksDB/build/testDir" --num=62914560 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 >> ${style}OUT_${workload}_${workTime}\(${loop}\).txt 2>&1
#     # if [ ${loop} == 1 ]
#     #     then 
#     #         cp -r /home/colin/hub/YCSB-C-RocksDB/build/testDir /home/colin/hub/YCSB-C-RocksDB/build/backup/${style}_${workTime}
#     # fi
#     # rm -rf /home/colin/hub/YCSB-C-RocksDB/build/testDir/*

#     # 删除数据
#     sudo rm -rf /home/colin/hub/YCSB-C-RocksDB/build/testDir/*


#     # 测试blockbase load, update, read, scan, hotread
#     style="blockbase_normal_wtCnums"

#     # load
#     workload="load"
#     iostat -mx 1 3600 /dev/sdb /dev/sdc /dev/sdd > ${style}IO_${workload}_${workTime}\(${loop}\).txt &
#     echo `date +%Y-%m-%d_%H:%M:%S` >> ${style}OUT_${workload}_${workTime}\(${loop}\).txt
#     lsblk >> ${style}OUT_${workload}_${workTime}\(${loop}\).txt
#     /home/colin/hub/my-leveldb/build/db_bench --benchmarks="fillrandom,stats,sstables" --db="/home/colin/hub/YCSB-C-RocksDB/build/testDir" --num=62914560 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 >> ${style}OUT_${workload}_${workTime}\(${loop}\).txt 2>&1
#     # if [ ${loop} == 1 ]
#     #     then 
#     #         sudo cp -r /home/colin/hub/YCSB-C-RocksDB/build/testDir /home/colin/hub/YCSB-C-RocksDB/build/backup/${style}_${workTime}
#     # fi
#     # rm -rf /home/colin/hub/YCSB-C-RocksDB/build/testDir/*

#     # 删除数据
#     sudo rm -rf /home/colin/hub/YCSB-C-RocksDB/build/testDir/*


#     # 构建raid0
#     sudo umount /home/colin/hub/YCSB-C-RocksDB/build/testDir/vol1
#     sudo umount /home/colin/hub/YCSB-C-RocksDB/build/testDir/vol2
#     sudo umount /home/colin/hub/YCSB-C-RocksDB/build/testDir/vol3

#     sudo mdadm --create --verbose /dev/md0 --level=0 --raid-devices=3 /dev/sd{b1,c1,d1} --run
#     sudo mkfs.ext4 -F /dev/md0
#     sudo mount /dev/md0 /home/colin/hub/YCSB-C-RocksDB/build/testDirRaid
#     sudo chown colin:colin /home/colin/hub/YCSB-C-RocksDB/build/testDirRaid

#     # 测试origin raid0 load , update, read, scan, hotread
#     style="origin_normal_wtCnums"

#     # load
#     workload="load"
#     iostat -mx 1 3600 /dev/sdb /dev/sdc /dev/sdd /dev/md0 > ${style}IO_${workload}_${workTime}\(${loop}\).txt &
#     echo `date +%Y-%m-%d_%H:%M:%S` >> ${style}OUT_${workload}_${workTime}\(${loop}\).txt
#     lsblk >> ${style}OUT_${workload}_${workTime}\(${loop}\).txt
#     /home/colin/hub/leveldb_origin/build/db_bench --benchmarks="fillrandom,stats,sstables" --db="/home/colin/hub/YCSB-C-RocksDB/build/testDirRaid" --num=62914560 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 >> ${style}OUT_${workload}_${workTime}\(${loop}\).txt 2>&1
#     # if [ ${loop} == 1 ]
#     #     then 
#     #         sudo cp -r /home/colin/hub/YCSB-C-RocksDB/build/testDirRaid /home/colin/hub/YCSB-C-RocksDB/build/backup/${style}_${workTime}
#     # fi
#     # rm -rf /home/colin/hub/YCSB-C-RocksDB/build/testDir/*

#     # 删除数据
#     sudo rm -rf /home/colin/hub/YCSB-C-RocksDB/build/testDirRaid/*

#     #卸载raid0
#     sudo umount /home/colin/hub/YCSB-C-RocksDB/build/testDirRaid

#     # 停用raid0
#     sudo mdadm --stop /dev/md0
# done


    workTime=`date +%Y-%m-%d_%H:%M:%S`
    # 记录了compaction的数量和时延
    # 在writeable file中使用更小的buf
    style="blockbase_normal_wtCnums_smallBuf"
    # load
    workload="load"
    iostat -mxt 1 3600 /dev/sdb > ${style}IO_${workload}_${workTime}.txt &
    echo `date +%Y-%m-%d_%H:%M:%S` >> ${style}OUT_${workload}_${workTime}.txt
    lsblk >> ${style}OUT_${workload}_${workTime}.txt
    /home/colin/hub/my-leveldb/build/db_bench --benchmarks="fillrandom,stats,sstables" --db="/home/colin/hub/YCSB-C-RocksDB/build/testDir" --num=62914560 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 >> ${style}OUT_${workload}_${workTime}.txt 2>&1
    echo `date +%Y-%m-%d_%H:%M:%S` >> ${style}OUT_${workload}_${workTime}.txt
    # 中止iostat
    pidof iostat | xargs kill -9


