#!/bin/bash
ulimit -n 65535
workDirs=("/home/colin/hub/testDir/vol1" "/home/colin/hub/testDir/vol2" "/home/colin/hub/testDir/vol3")
workDevs=("/dev/sdb1" "/dev/sdc1" "/dev/sdd1")
workTime=`date +%Y-%m-%d_%H:%M:%S`
recordDir=/home/colin/hub/experiment_record/microbench

# # 创建记录文件夹
# mkdir ${recordDir}

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

#     #创建文件夹
#     for dir in ${workDirs[@]}
#         do
#             mkdir ${dir}
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

# for loop in {1..3}
# for loop in 1
# do

#     # 复制已有数据库
#     # cp -r /root/backup/origin_data/* /root/testDir
#     sudo bash -c "echo 1 > /proc/sys/vm/drop_caches"
#     # 测试levelbase load , update, read, scan, hotread
#     style="levelbase_normal_wtCnums"

#     # # cgroup 限制磁盘速度为140MB/s
#     # sudo bash -c "echo '8:16 146800640' >  /sys/fs/cgroup/blkio/test_write/blkio.throttle.read_bps_device"
#     # sudo bash -c "echo '8:32 146800640' >  /sys/fs/cgroup/blkio/test_write/blkio.throttle.read_bps_device"
#     # sudo bash -c "echo '8:48 146800640' >  /sys/fs/cgroup/blkio/test_write/blkio.throttle.read_bps_device"
#     # sudo bash -c "echo '8:16 0' >  /sys/fs/cgroup/blkio/test_write/blkio.throttle.write_bps_device"
#     # sudo bash -c "echo '8:32 0' >  /sys/fs/cgroup/blkio/test_write/blkio.throttle.write_bps_device"
#     # sudo bash -c "echo '8:48 0' >  /sys/fs/cgroup/blkio/test_write/blkio.throttle.write_bps_device"


#     # read
#     workload="read_40Threads_pagecache"
#     ioFile=${recordDir}/${workTime}_${style}IO_${workload}\(${loop}\).txt
#     resultFile=${recordDir}/${workTime}_${style}OUT_${workload}\(${loop}\).txt
#     echo `date +%Y-%m-%d_%H:%M:%S` >> ${resultFile}
#     echo "cgroup write: "
#     sudo cat /sys/fs/cgroup/blkio/test_write/blkio.throttle.write_bps_device >> ${resultFile}
#     echo "cgroup read: "
#     sudo cat /sys/fs/cgroup/blkio/test_write/blkio.throttle.read_bps_device >>${resultFile}
#     lsblk >> ${resultFile}
#     echo "du -h  : " >> ${resultFile}
#     sudo du -h /home/colin/hub/testDir >> ${resultFile}
#     free -h >> ${resultFile}   
#     iostat -mx 1 3600 /dev/sdb /dev/sdc /dev/sdd > ${ioFile} &
#     sudo cgexec -g blkio:test_write /home/colin/hub/leveldb/build/db_bench --benchmarks="stats,sstables,readrandom,stats,sstables" --db="/home/colin/hub/testDir" --threads=40 --use_existing_db=1 --reads=262144 --num=104857600 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 >> ${resultFile} #2>&1
#     pidof iostat | xargs kill -9
#     free -h >> ${resultFile}
#     echo "du -h  : " >> ${resultFile}
#     sudo du -h /home/colin/hub/testDir >> ${resultFile}
#     echo "levelbase readrandom 40Threads end!!!"
#     sudo bash -c "echo 1 > /proc/sys/vm/drop_caches"

#     # 删除数据
#     sudo rm -rf /home/colin/hub/testDir/*

#     # 复制已有数据库
#     cp -r /home/colin/hub/testBackup/100G/levelbase_normal_wtCnums_100G_2021-12-15_17:44:33/* /home/colin/hub/testDir
#     sudo bash -c "echo 1 > /proc/sys/vm/drop_caches"

#     workload="scan_40Threads_pagecache"
#     ioFile=${recordDir}/${workTime}_${style}IO_${workload}\(${loop}\).txt
#     resultFile=${recordDir}/${workTime}_${style}OUT_${workload}\(${loop}\).txt
#     echo `date +%Y-%m-%d_%H:%M:%S` >> ${resultFile}
#     echo "cgroup write: "
#     sudo cat /sys/fs/cgroup/blkio/test_write/blkio.throttle.write_bps_device >> ${resultFile}
#     echo "cgroup read: "
#     sudo cat /sys/fs/cgroup/blkio/test_write/blkio.throttle.read_bps_device >>${resultFile}
#     lsblk >> ${resultFile}
#     echo "du -h  : " >> ${resultFile}
#     sudo du -h /home/colin/hub/testDir >> ${resultFile}
#     free -h >> ${resultFile}
#     iostat -mx 1 3600 /dev/sdb /dev/sdc /dev/sdd > ${ioFile} &
#     sudo cgexec -g blkio:test_write /home/colin/hub/leveldb/build/db_bench --benchmarks="stats,sstables,scan,stats,sstables" --db="/home/colin/hub/testDir" --threads=40 --use_existing_db=1 --reads=524 --num=104857600 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 >> ${resultFile} #2>&1
#     pidof iostat | xargs kill -9
#     free -h >> ${resultFile}
#     echo "du -h  : " >> ${resultFile}
#     sudo du -h /home/colin/hub/testDir >> ${resultFile}

#     echo "levelbase scan 40Threads end!!!"
#     sudo bash -c "echo 1 > /proc/sys/vm/drop_caches"

#     # 删除数据
#     sudo rm -rf /home/colin/hub/testDir/*
# done


# for loop in {1..3}
# for loop in 1
# do

#     # 复制已有数据库
#     cp -r /home/colin/hub/testBackup/100G/blockbase_normal_wtCnums_100G_2021-12-06_11:11:59/* /home/colin/hub/testDir
#     sudo bash -c "echo 1 > /proc/sys/vm/drop_caches"
#     # 测试blockbase load, update, read, scan, hotread
#     style="blockbase_normal_wtCnums"

#     # cgroup 限制磁盘速度为140MB/s
#     sudo bash -c "echo '8:16 146800640' >  /sys/fs/cgroup/blkio/test_write/blkio.throttle.read_bps_device"
#     sudo bash -c "echo '8:32 146800640' >  /sys/fs/cgroup/blkio/test_write/blkio.throttle.read_bps_device"
#     sudo bash -c "echo '8:48 146800640' >  /sys/fs/cgroup/blkio/test_write/blkio.throttle.read_bps_device"
#     sudo bash -c "echo '8:16 0' >  /sys/fs/cgroup/blkio/test_write/blkio.throttle.write_bps_device"
#     sudo bash -c "echo '8:32 0' >  /sys/fs/cgroup/blkio/test_write/blkio.throttle.write_bps_device"
#     sudo bash -c "echo '8:48 0' >  /sys/fs/cgroup/blkio/test_write/blkio.throttle.write_bps_device"

#     # read 
#     workload="read_40Threads_pagecache"
#     ioFile=${recordDir}/${workTime}_${style}IO_${workload}\(${loop}\).txt
#     resultFile=${recordDir}/${workTime}_${style}OUT_${workload}\(${loop}\).txt
#     echo `date +%Y-%m-%d_%H:%M:%S` >> ${resultFile}
#     echo "cgroup write: "
#     sudo cat /sys/fs/cgroup/blkio/test_write/blkio.throttle.write_bps_device >> ${resultFile}
#     echo "cgroup read: "
#     sudo cat /sys/fs/cgroup/blkio/test_write/blkio.throttle.read_bps_device >>${resultFile}
#     lsblk >> ${resultFile}
#     echo "du -h  : " >> ${resultFile}
#     sudo du -h /home/colin/hub/testDir >> ${resultFile}
#     iostat -mx 1 3600 /dev/sdb /dev/sdc /dev/sdd > ${ioFile} &
#     free -h >> ${resultFile}
#     sudo cgexec -g blkio:test_write /home/colin/hub/my-leveldb/build/db_bench --benchmarks="stats,sstables,readrandom,stats,sstables" --db="/home/colin/hub/testDir" --threads=40 --use_existing_db=1 --reads=262144 --num=104857600 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 >> ${resultFile} #2>&1
#     pidof iostat | xargs kill -9
#     free -h >> ${resultFile}
#     echo "du -h  : " >> ${resultFile}
#     sudo du -h /home/colin/hub/testDir >> ${resultFile}
#     echo "blockbase readrandom 40Threads end!!!"
#     sudo bash -c "echo 1 > /proc/sys/vm/drop_caches"


#     # 删除数据
#     sudo rm -rf /home/colin/hub/testDir/*

#     # scan

#     cp -r /home/colin/hub/testBackup/100G/blockbase_normal_wtCnums_100G_2021-12-06_11:11:59/* /home/colin/hub/testDir
#     sudo bash -c "echo 1 > /proc/sys/vm/drop_caches"

#     workload="scan_40Threads_pagecache"
#     ioFile=${recordDir}/${workTime}_${style}IO_${workload}\(${loop}\).txt
#     resultFile=${recordDir}/${workTime}_${style}OUT_${workload}\(${loop}\).txt
#     echo `date +%Y-%m-%d_%H:%M:%S` >> ${resultFile}
#     echo "cgroup write: "
#     sudo cat /sys/fs/cgroup/blkio/test_write/blkio.throttle.write_bps_device >> ${resultFile}
#     echo "cgroup read: "
#     sudo cat /sys/fs/cgroup/blkio/test_write/blkio.throttle.read_bps_device >>${resultFile}
#     lsblk >> ${resultFile}
#     echo "du -h  : " >> ${resultFile}
#     sudo du -h /home/colin/hub/testDir >> ${resultFile}
#     free -h >> ${resultFile}
#     iostat -mx 1 3600 /dev/sdb /dev/sdc /dev/sdd > ${ioFile} &
#     sudo cgexec -g blkio:test_write /home/colin/hub/my-leveldb/build/db_bench --benchmarks="stats,sstables,scan,stats,sstables" --db="/home/colin/hub/testDir" --threads=40 --use_existing_db=1 --reads=524 --num=104857600 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 >> ${resultFile} #2>&1
#     pidof iostat | xargs kill -9
#     free -h >> ${resultFile}
#     echo "du -h  : " >> ${resultFile}
#     sudo du -h /home/colin/hub/testDir >> ${resultFile}

#     echo "blockbase scan 40Threads end!!!"
#     sudo bash -c "echo 1 > /proc/sys/vm/drop_caches"


#     # 删除数据
#     sudo rm -rf /home/colin/hub/testDir/*
# done


#     # 构建raid0
#     sudo umount /home/colin/hub/testDir/vol1
#     sudo umount /home/colin/hub/testDir/vol2
#     sudo umount /home/colin/hub/testDir/vol3

#     sudo mdadm --create --verbose /dev/md0 --level=0 --raid-devices=3 /dev/sd{b1,c1,d1} --run
#     sudo mkfs.ext4 -F /dev/md0
#     sudo mount /dev/md0 /home/colin/hub/testDir_raid0
#     sudo chown colin:colin /home/colin/hub/testDir_raid0

# for loop in {1..3}
for loop in 1
do
    # 复制已有数据
    # cp -r /root/backup/origin_data/* /root/testDir
    sudo bash -c "echo 1 > /proc/sys/vm/drop_caches"
    # 测试origin raid0 load , update, read, scan, hotread
    style="origin_normal_wtCnums"


    # sudo bash -c "echo '8:16 0' >  /sys/fs/cgroup/blkio/test_write/blkio.throttle.read_bps_device"
    # sudo bash -c "echo '8:32 0' >  /sys/fs/cgroup/blkio/test_write/blkio.throttle.read_bps_device"
    # sudo bash -c "echo '8:48 0' >  /sys/fs/cgroup/blkio/test_write/blkio.throttle.read_bps_device"
    # sudo bash -c "echo '8:16 0' >  /sys/fs/cgroup/blkio/test_write/blkio.throttle.write_bps_device"
    # sudo bash -c "echo '8:32 0' >  /sys/fs/cgroup/blkio/test_write/blkio.throttle.write_bps_device"
    # sudo bash -c "echo '8:48 0' >  /sys/fs/cgroup/blkio/test_write/blkio.throttle.write_bps_device"

    # sudo bash -c "echo '9:0 440401920' >  /sys/fs/cgroup/blkio/test_write/blkio.throttle.read_bps_device"
    # sudo bash -c "echo '9:0 0' >  /sys/fs/cgroup/blkio/test_write/blkio.throttle.write_bps_device"

    # read 
    workload="read_40Threads_pagecache"
    ioFile=${workTime}_${style}IO_${workload}\(${loop}\).txt
    resultFile=${workTime}_${style}OUT_${workload}\(${loop}\).txt
    echo `date +%Y-%m-%d_%H:%M:%S` >> ${resultFile}
    # echo "cgroup write: "
    # sudo cat /sys/fs/cgroup/blkio/test_write/blkio.throttle.write_bps_device >> ${resultFile}
    # echo "cgroup read: "
    # sudo cat /sys/fs/cgroup/blkio/test_write/blkio.throttle.read_bps_device >>${resultFile}
    lsblk >> ${resultFile}
    echo "du -h  : " >> ${resultFile}
    sudo du -h /root/testDir >> ${resultFile}
    free -h >> ${resultFile}
    iostat -mx 1 3600 /dev/vdb > ${ioFile} &
    /root/leveldb/build/db_bench --benchmarks="stats,sstables,readrandom,stats,sstables" --db="/root/testDir" --threads=40 --use_existing_db=1 --reads=262144 --num=104857600 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 >> ${resultFile} #2>&1
    pidof iostat | xargs kill -9
    free -h >> ${resultFile}

    echo "du -h  : " >> ${resultFile}
    sudo du -h /root/testDir >> ${resultFile}

    echo "origin readrandom 40Threads end!!!"
    sudo bash -c "echo 1 > /proc/sys/vm/drop_caches"

    # 删除数据
    sudo rm -rf /root/testDir/*


    cp -r /root/backup/origin_data/* /root/testDir
    sudo bash -c "echo 1 > /proc/sys/vm/drop_caches"

    # scan
    workload="scan_40Threads_pagecache"
    ioFile=${workTime}_${style}IO_${workload}\(${loop}\).txt
    resultFile=${workTime}_${style}OUT_${workload}\(${loop}\).txt
    echo `date +%Y-%m-%d_%H:%M:%S` >> ${resultFile}
    # echo "cgroup write: "
    # sudo cat /sys/fs/cgroup/blkio/test_write/blkio.throttle.write_bps_device >> ${resultFile}
    # echo "cgroup read: "
    # sudo cat /sys/fs/cgroup/blkio/test_write/blkio.throttle.read_bps_device >>${resultFile}
    lsblk >> ${resultFile}
    echo "du -h  : " >> ${resultFile}
    sudo du -h /root/testDir >> ${resultFile}
    free -h >> ${resultFile}
    iostat -mx 1 3600 /dev/sdb /dev/sdc /dev/sdd /dev/md0 > ${ioFile} &
    /root/leveldb/build/db_bench --benchmarks="stats,sstables,scan,stats,sstables" --db="/root/testDir" --threads=40 --use_existing_db=1 --reads=524 --num=104857600 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 >> ${resultFile} #2>&1
    pidof iostat | xargs kill -9
    free -h >> ${resultFile}
    echo "du -h  : " >> ${resultFile}
    sudo du -h /root/testDir >> ${resultFile}

    echo "origin scan 40Threads end!!!"
    sudo bash -c "echo 1 > /proc/sys/vm/drop_caches"

    # 删除数据
    sudo rm -rf /root/testDir/*
done

    # #卸载raid0
    # sudo umount /home/colin/hub/testDir_raid0

    # # 停用raid0
    # sudo mdadm --stop /dev/md0