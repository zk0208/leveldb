#!/bin/bash

# 不会没压满吧
workTime=`date +%Y-%m-%d_%H:%M:%S`


##############################################################################################################################################################
# 测试 leveldb_origin 单盘下的build table 速度
sudo umount /dev/sdc1
sudo mkfs.ext4 -F /dev/sdc1
sudo mount /dev/sdc1 /home/colin/hub/testDir
sudo chown colin:colin /home/colin/hub/testDir

for loop in {1..5}
do
    # 记录了compaction的数量和时延
    style="builder_test_leveldb_origin_单盘_64M_100file"
    echo ${style} START ${loop}
    # load
    workload=""
    reslutFile="${workTime}(${loop})_${style}OUT_${workload}.txt"
    ioFile="${workTime}(${loop})_${style}IO_${workload}.txt"
    echo `date +%Y-%m-%d_%H:%M:%S` >> ${reslutFile}
    lsblk >> ${reslutFile}
    # /home/colin/hub/rocksdb/build/db_bench_multi --benchmarks="fillrandom,stats" -compression_type=none -db="/home/colin/hub/YCSB-C-RocksDB/build/testDir" -num=83886080 -value_size=1000 -max_background_jobs=6 >> ${style}OUT_${workload}_${workTime}.txt 2>&1
    # cmd="/home/colin/hub/leveldb_origin/build/builder_test --db=/home/colin/hub/YCSB-C-RocksDB/build/testDir --nums=10485760"
    cmd="/home/colin/hub/leveldb_origin/build/builder_test --db=/home/colin/hub/testDir --nums=65536 --filenums=100"
    echo ${cmd} >> ${reslutFile}
    iostat -mxt 1 3600 /dev/sdc > ${ioFile} &
    ${cmd} >> ${reslutFile} 2>&1
    echo `date +%Y-%m-%d_%H:%M:%S` >> ${reslutFile}
    echo "du -h /home/colin/hub/testDir" >> ${reslutFile}
    du -h /home/colin/hub/testDir >> ${reslutFile}
    echo "ls -alh /home/colin/hub/testDir" >> ${reslutFile}
    ls -alh /home/colin/hub/testDir >> ${reslutFile}
    # 中止iostat
    pidof iostat | xargs kill -9

    rm -rf /home/colin/hub/testDir/*
done


for loop in {1..5}
do
    # 记录了compaction的数量和时延
    style="builder_test_leveldb_origin_单盘_640M_10file"
    echo ${style} START ${loop}
    # load
    workload=""
    reslutFile="${workTime}(${loop})_${style}OUT_${workload}.txt"
    ioFile="${workTime}(${loop})_${style}IO_${workload}.txt"
    echo `date +%Y-%m-%d_%H:%M:%S` >> ${reslutFile}
    lsblk >> ${reslutFile}
    # /home/colin/hub/rocksdb/build/db_bench_multi --benchmarks="fillrandom,stats" -compression_type=none -db="/home/colin/hub/YCSB-C-RocksDB/build/testDir" -num=83886080 -value_size=1000 -max_background_jobs=6 >> ${style}OUT_${workload}_${workTime}.txt 2>&1
    # cmd="/home/colin/hub/leveldb_origin/build/builder_test --db=/home/colin/hub/YCSB-C-RocksDB/build/testDir --nums=10485760"
    cmd="/home/colin/hub/leveldb_origin/build/builder_test --db=/home/colin/hub/testDir --nums=655360 --filenums=10"
    echo ${cmd} >> ${reslutFile}
    iostat -mxt 1 3600 /dev/sdc > ${ioFile} &
    ${cmd} >> ${reslutFile} 2>&1
    echo `date +%Y-%m-%d_%H:%M:%S` >> ${reslutFile}
    echo "du -h /home/colin/hub/testDir" >> ${reslutFile}
    du -h /home/colin/hub/testDir >> ${reslutFile}
    echo "ls -alh /home/colin/hub/testDir" >> ${reslutFile}
    ls -alh /home/colin/hub/testDir >> ${reslutFile}
    # 中止iostat
    pidof iostat | xargs kill -9

    rm -rf /home/colin/hub/testDir/*
done


for loop in {1..5}
do
    # 记录了compaction的数量和时延
    style="builder_test_leveldb_origin_单盘_6400M_1file"
    echo ${style} START ${loop}
    # load
    workload=""
    reslutFile="${workTime}(${loop})_${style}OUT_${workload}.txt"
    ioFile="${workTime}(${loop})_${style}IO_${workload}.txt"
    echo `date +%Y-%m-%d_%H:%M:%S` >> ${reslutFile}
    lsblk >> ${reslutFile}
    # /home/colin/hub/rocksdb/build/db_bench_multi --benchmarks="fillrandom,stats" -compression_type=none -db="/home/colin/hub/YCSB-C-RocksDB/build/testDir" -num=83886080 -value_size=1000 -max_background_jobs=6 >> ${style}OUT_${workload}_${workTime}.txt 2>&1
    # cmd="/home/colin/hub/leveldb_origin/build/builder_test --db=/home/colin/hub/YCSB-C-RocksDB/build/testDir --nums=10485760"
    cmd="/home/colin/hub/leveldb_origin/build/builder_test --db=/home/colin/hub/testDir --nums=6553600 --filenums=1"
    echo ${cmd} >> ${reslutFile}
    iostat -mxt 1 3600 /dev/sdc > ${ioFile} &
    ${cmd} >> ${reslutFile} 2>&1
    echo `date +%Y-%m-%d_%H:%M:%S` >> ${reslutFile}
    echo "du -h /home/colin/hub/testDir" >> ${reslutFile}
    du -h /home/colin/hub/testDir >> ${reslutFile}
    echo "ls -alh /home/colin/hub/testDir" >> ${reslutFile}
    ls -alh /home/colin/hub/testDir >> ${reslutFile}
    # 中止iostat
    pidof iostat | xargs kill -9

    rm -rf /home/colin/hub/testDir/*
done
###############################################################################################################################################################################


# for loop in {1..10}
# do
# # 测试 my_leveldb 单盘下的build table 速度
#     mkdir /home/colin/hub/YCSB-C-RocksDB/build/testDir/vol1
#     mkdir /home/colin/hub/YCSB-C-RocksDB/build/testDir/vol2
#     mkdir /home/colin/hub/YCSB-C-RocksDB/build/testDir/vol3

#     # workTime=`date +%Y-%m-%d_%H:%M:%S`
#     # 记录了compaction的数量和时延
#     style="builder_test_my_leveldb_单盘"
#     echo ${style} START ${loop}
#     # load
#     workload=""
    # reslutFile="${style}OUT_${workload}_${workTime}\(${loop}\).txt"
    # ioFile="${style}IO_${workload}_${workTime}\(${loop}\).txt"
#     echo `date +%Y-%m-%d_%H:%M:%S` >> ${resultFile}
#     lsblk >> ${resultFile}
#     # /home/colin/hub/rocksdb/build/db_bench_multi --benchmarks="fillrandom,stats" -compression_type=none -db="/home/colin/hub/YCSB-C-RocksDB/build/testDir" -num=83886080 -value_size=1000 -max_background_jobs=6 >> ${style}OUT_${workload}_${workTime}.txt 2>&1
#     iostat -mxt 1 3600 /dev/sdc > ${ioFile} &
#     /home/colin/hub/my-leveldb/build/builder_test --db="/home/colin/hub/YCSB-C-RocksDB/build/testDir" --nums=10485760 >> ${resultFile} 2>&1
#     echo `date +%Y-%m-%d_%H:%M:%S` >> ${resultFile}
#     echo "# du -h /home/colin/hub/YCSB-C-RocksDB/build/testDir" >> ${resultFile}
#     du -h /home/colin/hub/YCSB-C-RocksDB/build/testDir >> ${resultFile}
#     echo "# ls -alh /home/colin/hub/YCSB-C-RocksDB/build/testDir" >> ${resultFile}
#     ls -alh /home/colin/hub/YCSB-C-RocksDB/build/testDir >> ${resultFile}
#     # 中止iostat
#     pidof iostat | xargs kill -9
#     rm -rf /home/colin/hub/YCSB-C-RocksDB/build/testDir/*
# done

############################################################################################################################################################################################
# 测试 my_leveldb 多盘下的build table速度
    sudo umount /dev/sdb1
    sudo umount /dev/sdc1
    sudo umount /dev/sdd1
    sudo mkfs.ext4 -F /dev/sdb1
    sudo mkfs.ext4 -F /dev/sdc1
    sudo mkfs.ext4 -F /dev/sdd1
    mkdir /home/colin/hub/testDir_multiVol/vol1
    mkdir /home/colin/hub/testDir_multiVol/vol2
    mkdir /home/colin/hub/testDir_multiVol/vol3
    sudo mount /dev/sdb1 /home/colin/hub/testDir_multiVol/vol1
    sudo mount /dev/sdc1 /home/colin/hub/testDir_multiVol/vol2
    sudo mount /dev/sdd1 /home/colin/hub/testDir_multiVol/vol3
    sudo chown colin:colin /home/colin/hub/testDir_multiVol/vol1
    sudo chown colin:colin /home/colin/hub/testDir_multiVol/vol2
    sudo chown colin:colin /home/colin/hub/testDir_multiVol/vol3

for loop in {1..5}
do
    # workTime=`date +%Y-%m-%d_%H:%M:%S`
    # 记录了compaction的数量和时延
    style="builder_test_my_leveldb_多盘_64M_100file"
    echo ${style} START ${loop}
    # load
    workload=""
    resultFile="${workTime}(${loop})_${style}OUT_${workload}.txt"
    ioFile="${workTime}(${loop})_${style}IO_${workload}.txt"
    echo `date +%Y-%m-%d_%H:%M:%S` >> ${resultFile}
    lsblk >> ${resultFile}
    # /home/colin/hub/rocksdb/build/db_bench_multi --benchmarks="fillrandom,stats" -compression_type=none -db="/home/colin/hub/YCSB-C-RocksDB/build/testDir" -num=83886080 -value_size=1000 -max_background_jobs=6 >> ${style}OUT_${workload}_${workTime}.txt 2>&1
    cmd="/home/colin/hub/my-leveldb/build/builder_test --db=/home/colin/hub/testDir_multiVol --nums=65536 --filenums=100"
    # cmd="/home/colin/hub/my-leveldb/build/builder_test --db=/home/colin/hub/YCSB-C-RocksDB/build/testDir --nums=65536"
    echo ${cmd} >> ${resultFile}
    iostat -mxt 1 3600 /dev/sdb /dev/sdc /dev/sdd > ${ioFile} &
    ${cmd} >> ${resultFile} 2>&1
    echo `date +%Y-%m-%d_%H:%M:%S` >> ${resultFile}
    echo "# du -h /home/colin/hub/testDir_multiVol" >> ${resultFile}
    du -h /home/colin/hub/testDir_multiVol >> ${resultFile}
    echo "# ls -alh /home/colin/hub/testDir_multiVol" >> ${resultFile}
    ls -alh /home/colin/hub/testDir_multiVol >> ${resultFile}
    # 中止iostat
    pidof iostat | xargs kill -9
    rm -rf /home/colin/hub/testDir_multiVol/*
done

for loop in {1..5}
do
    # workTime=`date +%Y-%m-%d_%H:%M:%S`
    # 记录了compaction的数量和时延
    style="builder_test_my_leveldb_多盘_640M_10file"
    echo ${style} START ${loop}
    # load
    workload=""
    resultFile="${workTime}(${loop})_${style}OUT_${workload}.txt"
    ioFile="${workTime}(${loop})_${style}IO_${workload}.txt"
    echo `date +%Y-%m-%d_%H:%M:%S` >> ${resultFile}
    lsblk >> ${resultFile}
    # /home/colin/hub/rocksdb/build/db_bench_multi --benchmarks="fillrandom,stats" -compression_type=none -db="/home/colin/hub/YCSB-C-RocksDB/build/testDir" -num=83886080 -value_size=1000 -max_background_jobs=6 >> ${style}OUT_${workload}_${workTime}.txt 2>&1
    cmd="/home/colin/hub/my-leveldb/build/builder_test --db=/home/colin/hub/testDir_multiVol --nums=655360 --filenums=10"
    # cmd="/home/colin/hub/my-leveldb/build/builder_test --db=/home/colin/hub/YCSB-C-RocksDB/build/testDir --nums=65536"
    echo ${cmd} >> ${resultFile}
    iostat -mxt 1 3600 /dev/sdb /dev/sdc /dev/sdd > ${ioFile} &
    ${cmd} >> ${resultFile} 2>&1
    echo `date +%Y-%m-%d_%H:%M:%S` >> ${resultFile}
    echo "# du -h /home/colin/hub/testDir_multiVol" >> ${resultFile}
    du -h /home/colin/hub/testDir_multiVol >> ${resultFile}
    echo "# ls -alh /home/colin/hub/testDir_multiVol" >> ${resultFile}
    ls -alh /home/colin/hub/testDir_multiVol >> ${resultFile}
    # 中止iostat
    pidof iostat | xargs kill -9
    rm -rf /home/colin/hub/testDir_multiVol/*
done

for loop in {1..5}
do
    # workTime=`date +%Y-%m-%d_%H:%M:%S`
    # 记录了compaction的数量和时延
    style="builder_test_my_leveldb_多盘_6400M_1file"
    echo ${style} START ${loop}
    # load
    workload=""
    resultFile="${workTime}(${loop})_${style}OUT_${workload}.txt"
    ioFile="${workTime}(${loop})_${style}IO_${workload}.txt"
    echo `date +%Y-%m-%d_%H:%M:%S` >> ${resultFile}
    lsblk >> ${resultFile}
    # /home/colin/hub/rocksdb/build/db_bench_multi --benchmarks="fillrandom,stats" -compression_type=none -db="/home/colin/hub/YCSB-C-RocksDB/build/testDir" -num=83886080 -value_size=1000 -max_background_jobs=6 >> ${style}OUT_${workload}_${workTime}.txt 2>&1
    cmd="/home/colin/hub/my-leveldb/build/builder_test --db=/home/colin/hub/testDir_multiVol --nums=6553600 --filenums=1"
    # cmd="/home/colin/hub/my-leveldb/build/builder_test --db=/home/colin/hub/YCSB-C-RocksDB/build/testDir --nums=65536"
    echo ${cmd} >> ${resultFile}
    iostat -mxt 1 3600 /dev/sdb /dev/sdc /dev/sdd > ${ioFile} &
    ${cmd} >> ${resultFile} 2>&1
    echo `date +%Y-%m-%d_%H:%M:%S` >> ${resultFile}
    echo "# du -h /home/colin/hub/testDir_multiVol" >> ${resultFile}
    du -h /home/colin/hub/testDir_multiVol >> ${resultFile}
    echo "# ls -alh /home/colin/hub/testDir_multiVol" >> ${resultFile}
    ls -alh /home/colin/hub/testDir_multiVol >> ${resultFile}
    # 中止iostat
    pidof iostat | xargs kill -9
    rm -rf /home/colin/hub/testDir_multiVol/*
done

############################################################################################################################################################################################

    

##############################################################################################################################################
# 配置 raid0

# 删除数据
    # sudo rm -rf /home/colin/hub/YCSB-C-RocksDB/build/sdc/*
    rm -rf /home/colin/hub/testDir_raid0/*

    # 构建raid0
    # sudo umount /home/colin/hub/YCSB-C-RocksDB/build/testDir/vol1
    # sudo umount /home/colin/hub/YCSB-C-RocksDB/build/testDir/vol2
    # sudo umount /home/colin/hub/YCSB-C-RocksDB/build/testDir/vol3
    sudo umount /dev/sdb1
    sudo umount /dev/sdc1
    sudo umount /dev/sdd1
    # sudo umount /home/colin/hub/YCSB-C-RocksDB/build/sdc

    sudo mdadm --create --verbose /dev/md0 --level=0 --raid-devices=3 /dev/sd{b1,c1,d1} --run
    sudo mkfs.ext4 -F /dev/md0
    sudo mount /dev/md0 /home/colin/hub/testDir_raid0
    sudo chown colin:colin /home/colin/hub/testDir_raid0

for loop in {1..5}
do
# 测试 leveldb_origin raid0下的build table 速度
    #workTime=`date +%Y-%m-%d_%H:%M:%S`
    # 记录了compaction的数量和时延
    style="builder_test_leveldb_origin_raid0_64M_100file"
    echo ${style} START ${loop}
    # load
    workload=""
    resultFile="${workTime}(${loop})_${style}OUT_${workload}.txt"
    ioFile="${workTime}(${loop})_${style}IO_${workload}.txt"
    echo `date +%Y-%m-%d_%H:%M:%S` >> ${resultFile}
    lsblk >> ${resultFile}
    # /home/colin/hub/rocksdb/build/db_bench_multi --benchmarks="fillrandom,stats" -compression_type=none -db="/home/colin/hub/YCSB-C-RocksDB/build/testDir" -num=83886080 -value_size=1000 -max_background_jobs=6 >> ${style}OUT_${workload}_${workTime}.txt 2>&1
    # cmd="/home/colin/hub/leveldb_origin/build/builder_test --db=/home/colin/hub/YCSB-C-RocksDB/build/testDirRaid --nums=10485760"
    cmd="/home/colin/hub/leveldb_origin/build/builder_test --db=/home/colin/hub/testDir_raid0 --nums=65536 --filenums=100"
    echo ${cmd} >> ${resultFile}
    iostat -mxt 1 3600 /dev/sdb /dev/sdc /dev/sdd /dev/md0> ${ioFile} &
    ${cmd} >> ${resultFile} 2>&1
    echo `date +%Y-%m-%d_%H:%M:%S` >> ${resultFile}
    echo "# du -h /home/colin/hub/testDir_raid0" >> ${resultFile}
    du -h /home/colin/hub/testDir_raid0 >> ${resultFile}
    echo "# ls -alh /home/colin/hub/testDir_raid0" >> ${resultFile}
    ls -alh /home/colin/hub/testDir_raid0 >> ${resultFile}
    # 中止iostat
    pidof iostat | xargs kill -9
    rm -rf /home/colin/hub/testDir_raid0/*

done 

for loop in {1..5}
do
# 测试 leveldb_origin raid0下的build table 速度
    #workTime=`date +%Y-%m-%d_%H:%M:%S`
    # 记录了compaction的数量和时延
    style="builder_test_leveldb_origin_raid0_640M_10file"
    echo ${style} START ${loop}
    # load
    workload=""
    resultFile="${workTime}(${loop})_${style}OUT_${workload}.txt"
    ioFile="${workTime}(${loop})_${style}IO_${workload}.txt"
    echo `date +%Y-%m-%d_%H:%M:%S` >> ${resultFile}
    lsblk >> ${resultFile}
    # /home/colin/hub/rocksdb/build/db_bench_multi --benchmarks="fillrandom,stats" -compression_type=none -db="/home/colin/hub/YCSB-C-RocksDB/build/testDir" -num=83886080 -value_size=1000 -max_background_jobs=6 >> ${style}OUT_${workload}_${workTime}.txt 2>&1
    # cmd="/home/colin/hub/leveldb_origin/build/builder_test --db=/home/colin/hub/YCSB-C-RocksDB/build/testDirRaid --nums=10485760"
    cmd="/home/colin/hub/leveldb_origin/build/builder_test --db=/home/colin/hub/testDir_raid0 --nums=655360 --filenums=10"
    echo ${cmd} >> ${resultFile}
    iostat -mxt 1 3600 /dev/sdb /dev/sdc /dev/sdd /dev/md0> ${ioFile} &
    ${cmd} >> ${resultFile} 2>&1
    echo `date +%Y-%m-%d_%H:%M:%S` >> ${resultFile}
    echo "# du -h /home/colin/hub/testDir_raid0" >> ${resultFile}
    du -h /home/colin/hub/testDir_raid0 >> ${resultFile}
    echo "# ls -alh /home/colin/hub/testDir_raid0" >> ${resultFile}
    ls -alh /home/colin/hub/testDir_raid0 >> ${resultFile}
    # 中止iostat
    pidof iostat | xargs kill -9
    rm -rf /home/colin/hub/testDir_raid0/*

done 


for loop in {1..5}
do
# 测试 leveldb_origin raid0下的build table 速度
    #workTime=`date +%Y-%m-%d_%H:%M:%S`
    # 记录了compaction的数量和时延
    style="builder_test_leveldb_origin_raid0_6400M_1file"
    echo ${style} START ${loop}
    # load
    workload=""
    resultFile="${workTime}(${loop})_${style}OUT_${workload}.txt"
    ioFile="${workTime}(${loop})_${style}IO_${workload}.txt"
    echo `date +%Y-%m-%d_%H:%M:%S` >> ${resultFile}
    lsblk >> ${resultFile}
    # /home/colin/hub/rocksdb/build/db_bench_multi --benchmarks="fillrandom,stats" -compression_type=none -db="/home/colin/hub/YCSB-C-RocksDB/build/testDir" -num=83886080 -value_size=1000 -max_background_jobs=6 >> ${style}OUT_${workload}_${workTime}.txt 2>&1
    # cmd="/home/colin/hub/leveldb_origin/build/builder_test --db=/home/colin/hub/YCSB-C-RocksDB/build/testDirRaid --nums=10485760"
    cmd="/home/colin/hub/leveldb_origin/build/builder_test --db=/home/colin/hub/testDir_raid0 --nums=6553600 --filenums=1"
    echo ${cmd} >> ${resultFile}
    iostat -mxt 1 3600 /dev/sdb /dev/sdc /dev/sdd /dev/md0> ${ioFile} &
    ${cmd} >> ${resultFile} 2>&1
    echo `date +%Y-%m-%d_%H:%M:%S` >> ${resultFile}
    echo "# du -h /home/colin/hub/testDir_raid0" >> ${resultFile}
    du -h /home/colin/hub/testDir_raid0 >> ${resultFile}
    echo "# ls -alh /home/colin/hub/testDir_raid0" >> ${resultFile}
    ls -alh /home/colin/hub/testDir_raid0 >> ${resultFile}
    # 中止iostat
    pidof iostat | xargs kill -9
    rm -rf /home/colin/hub/testDir_raid0/*

done 

    # 中止raid0
    sudo umount /dev/md0
    sudo mdadm --stop /dev/md0
###########################################################################################################################################################################################################################################

# # 测试 my_leveldb raid0下的build table速度
#     mkdir /home/colin/hub/YCSB-C-RocksDB/build/testDirRaid/vol1
#     mkdir /home/colin/hub/YCSB-C-RocksDB/build/testDirRaid/vol2
#     mkdir /home/colin/hub/YCSB-C-RocksDB/build/testDirRaid/vol3
#     workTime=`date +%Y-%m-%d_%H:%M:%S`
#     # 记录了compaction的数量和时延
#     style="builder_test_my_leveldb_raid0"
#     # load
#     workload=""
#     iostat -mxt 1 3600 /dev/sdc > ${style}IO_${workload}_${workTime}.txt &
#     echo `date +%Y-%m-%d_%H:%M:%S` >> ${style}OUT_${workload}_${workTime}.txt
#     lsblk >> ${style}OUT_${workload}_${workTime}.txt
#     # /home/colin/hub/rocksdb/build/db_bench_multi --benchmarks="fillrandom,stats" -compression_type=none -db="/home/colin/hub/YCSB-C-RocksDB/build/testDir" -num=83886080 -value_size=1000 -max_background_jobs=6 >> ${style}OUT_${workload}_${workTime}.txt 2>&1
#     iostat -mxt 1 3600 /dev/sdb /dev/sdc /dev/sdd /dev/md0 > ${style}IO_${workload}_${workTime}.txt &
#     /home/colin/hub/my-leveldb/build/builder_test --db="/home/colin/hub/YCSB-C-RocksDB/build/testDirRaid" --nums=10485760 >> ${style}OUT_${workload}_${workTime}.txt 2>&1
#     echo `date +%Y-%m-%d_%H:%M:%S` >> ${style}OUT_${workload}_${workTime}.txt
#     echo "# du -h /home/colin/hub/YCSB-C-RocksDB/build/testDirRaid" >> ${style}OUT_${workload}_${workTime}.txt
#     du -h /home/colin/hub/YCSB-C-RocksDB/build/testDirRaid >> ${style}OUT_${workload}_${workTime}.txt
#     echo "# ls -alh /home/colin/hub/YCSB-C-RocksDB/build/testDirRaid" >> ${style}OUT_${workload}_${workTime}.txt
#     ls -alh /home/colin/hub/YCSB-C-RocksDB/build/testDirRaid >> ${style}OUT_${workload}_${workTime}.txt
#     # 中止iostat
#     pidof iostat | xargs kill -9