#!/bin/bash

# 不会没压满吧
workTime=`date +%Y-%m-%d_%H:%M:%S`
recordDir=/home/colin/hub/experiment_record

    

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

  speed=(136314880 272629760 408944640 545259520 681574400 817889280)
    for s in ${speed[@]}
    do 
        #cgroupSpeed=${s}'000000'
        for loop in {1..3}
        do
        # 测试 leveldb_origin raid0下的build table 速度
            #workTime=`date +%Y-%m-%d_%H:%M:%S`
            # 记录了compaction的数量和时延
            style="builder_test_leveldb_origin_raid0_64M_100file"
            echo ${style} START ${loop}
            workload="${s}MBSpeed"
            resultFile="${recordDir}/${workTime}(${loop})_${style}OUT_${workload}.txt"
            ioFile="${recordDir}/${workTime}(${loop})_${style}IO_${workload}.txt"
            sudo bash -c "echo '9:0 ${s}' >  /sys/fs/cgroup/blkio/test_write/blkio.throttle.write_bps_device"
            cat /sys/fs/cgroup/blkio/test_write/blkio.throttle.write_bps_device >> ${resultFile}
            echo `date +%Y-%m-%d_%H:%M:%S` >> ${resultFile}
            lsblk >> ${resultFile}
            # /home/colin/hub/rocksdb/build/db_bench_multi --benchmarks="fillrandom,stats" -compression_type=none -db="/home/colin/hub/YCSB-C-RocksDB/build/testDir" -num=83886080 -value_size=1000 -max_background_jobs=6 >> ${style}OUT_${workload}_${workTime}.txt 2>&1
            # cmd="/home/colin/hub/leveldb_origin/build/builder_test --db=/home/colin/hub/YCSB-C-RocksDB/build/testDirRaid --nums=10485760"
            cmd="/home/colin/hub/leveldb_origin/build/builder_test --db=/home/colin/hub/testDir_raid0 --nums=65536 --filenums=100"
            echo ${cmd} >> ${resultFile}
            iostat -mxt 1 3600 /dev/sdb /dev/sdc /dev/sdd /dev/md0> ${ioFile} &
            sudo cgexec -g blkio:test_write ${cmd} >> ${resultFile} 2>&1
            echo `date +%Y-%m-%d_%H:%M:%S` >> ${resultFile}
            echo "# du -h /home/colin/hub/testDir_raid0" >> ${resultFile}
            du -h /home/colin/hub/testDir_raid0 >> ${resultFile}
            echo "# ls -alh /home/colin/hub/testDir_raid0" >> ${resultFile}
            ls -alh /home/colin/hub/testDir_raid0 >> ${resultFile}
            # 中止iostat
            pidof iostat | xargs kill -9
            rm -rf /home/colin/hub/testDir_raid0/*

        done 
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