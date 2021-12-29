#!/bin/bash
# MICROBENCH
# RUN UPDATE,READ,SCAN IN CGROUP
# read scan 
# 是否要限制write???

ulimit -n 65535
workDirs=("/home/colin/hub/testDir/vol1" "/home/colin/hub/testDir/vol2" "/home/colin/hub/testDir/vol3")
workDevs=("/dev/sdb1" "/dev/sdc1" "/dev/sdd1")
workTime=`date +%Y-%m-%d_%H:%M:%S`
recordDir=/home/colin/hub/experiment_record/microbench

# 创建记录文件夹
mkdir ${recordDir}

    #卸载磁盘
    for dir in ${workDirs[@]}
        do 
            sudo umount ${dir}
        done

    #格式化磁盘
    for dev in ${workDevs[@]}
        do  
            sudo mkfs.ext4 -F ${dev}
        done

    #创建文件夹
    for dir in ${workDirs[@]}
        do
            mkdir ${dir}
        done

    #挂载磁盘
    for i in ${!workDevs[@]}
        do
            sudo mount ${workDevs[$i]} ${workDirs[$i]}
        done

    #变更所有者
    for dir in ${workDirs[@]}
        do
            sudo chown colin:colin ${dir}
        done


#     # 需要控制每个存储卷 100MB/s的读写速度

# for loop in {1..3}
for loop in 1
do

    # cgroup 限制磁盘速度为140MB/s
    sudo bash -c "echo '8:16 146800640' >  /sys/fs/cgroup/blkio/test_write/blkio.throttle.read_bps_device"
    sudo bash -c "echo '8:32 146800640' >  /sys/fs/cgroup/blkio/test_write/blkio.throttle.read_bps_device"
    sudo bash -c "echo '8:48 146800640' >  /sys/fs/cgroup/blkio/test_write/blkio.throttle.read_bps_device"

    sudo bash -c "echo '8:16 3800' > /sys/fs/cgroup/blkio/test_write/blkio.throttle.read_iops_device"
    sudo bash -c "echo '8:32 3800' > /sys/fs/cgroup/blkio/test_write/blkio.throttle.read_iops_device"
    sudo bash -c "echo '8:48 3800' > /sys/fs/cgroup/blkio/test_write/blkio.throttle.read_iops_device"


    # 复制已有数据库
    cp -r /home/colin/hub/testBackup/100G/levelbase_normal_wtCnums_100G_2021-12-15_17:44:33/* /home/colin/hub/testDir
    sudo bash -c "echo 1 > /proc/sys/vm/drop_caches"
    style="levelbase_normal_wtCnums"

    workload="scan_40Threads_pagecache_cgroup_Length1000"
    ioFile=${recordDir}/${workTime}_${style}IO_${workload}\(${loop}\).txt
    resultFile=${recordDir}/${workTime}_${style}OUT_${workload}\(${loop}\).txt
    echo `date +%Y-%m-%d_%H:%M:%S` >> ${resultFile}
    echo "cgroup write: "
    sudo cat /sys/fs/cgroup/blkio/test_write/blkio.throttle.write_bps_device >> ${resultFile}
    sudo cat /sys/fs/cgroup/blkio/test_write/blkio.throttle.write_iops_device >> ${resultFile}
    echo "cgroup read: "
    sudo cat /sys/fs/cgroup/blkio/test_write/blkio.throttle.read_bps_device >>${resultFile}
    sudo cat /sys/fs/cgroup/blkio/test_write/blkio.throttle.read_iops_device >>${resultFile}
    lsblk >> ${resultFile}
    echo "du -h  : " >> ${resultFile}
    sudo du -h /home/colin/hub/testDir >> ${resultFile}
    free -h >> ${resultFile}
    iostat -mx 1 3600 /dev/sdb /dev/sdc /dev/sdd > ${ioFile} &
    sudo cgexec -g blkio:test_write /home/colin/hub/leveldb/build/db_bench --benchmarks="stats,sstables,scan,stats,sstables" --db="/home/colin/hub/testDir" --scanLength=1000 --open_files=65530  --disable_compaction=1 --threads=40 --use_existing_db=1 --reads=524 --num=104857600 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 >> ${resultFile} #2>&1
    # /home/colin/hub/leveldb/build/db_bench --benchmarks="stats,sstables,scan,stats,sstables" --db="/home/colin/hub/testDir" --cache_size=8589934592  --disable_compaction=1 --threads=40 --use_existing_db=1 --reads=524 --num=104857600 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 >> ${resultFile} #2>&1
    pidof iostat | xargs kill -9
    free -h >> ${resultFile}
    echo "du -h  : " >> ${resultFile}
    sudo du -h /home/colin/hub/testDir >> ${resultFile}

    echo "levelbase scan 40Threads end!!!"
    sudo bash -c "echo 1 > /proc/sys/vm/drop_caches"

    ###################
    sudo bash -c "echo 1 > /proc/sys/vm/drop_caches"
    style="levelbase_normal_wtCnums"

    workload="scan_40Threads_pagecache_cgroup_Length100"
    ioFile=${recordDir}/${workTime}_${style}IO_${workload}\(${loop}\).txt
    resultFile=${recordDir}/${workTime}_${style}OUT_${workload}\(${loop}\).txt
    echo `date +%Y-%m-%d_%H:%M:%S` >> ${resultFile}
    echo "cgroup write: "
    sudo cat /sys/fs/cgroup/blkio/test_write/blkio.throttle.write_bps_device >> ${resultFile}
    sudo cat /sys/fs/cgroup/blkio/test_write/blkio.throttle.write_iops_device >> ${resultFile}
    echo "cgroup read: "
    sudo cat /sys/fs/cgroup/blkio/test_write/blkio.throttle.read_bps_device >>${resultFile}
    sudo cat /sys/fs/cgroup/blkio/test_write/blkio.throttle.read_iops_device >>${resultFile}
    lsblk >> ${resultFile}
    echo "du -h  : " >> ${resultFile}
    sudo du -h /home/colin/hub/testDir >> ${resultFile}
    free -h >> ${resultFile}
    iostat -mx 1 3600 /dev/sdb /dev/sdc /dev/sdd > ${ioFile} &
    sudo cgexec -g blkio:test_write /home/colin/hub/leveldb/build/db_bench --benchmarks="stats,sstables,scan,stats,sstables" --db="/home/colin/hub/testDir"  --scanLength=100 --open_files=65530  --disable_compaction=1 --threads=40 --use_existing_db=1 --reads=5240 --num=104857600 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 >> ${resultFile} #2>&1
    # /home/colin/hub/leveldb/build/db_bench --benchmarks="stats,sstables,scan,stats,sstables" --db="/home/colin/hub/testDir" --cache_size=8589934592  --disable_compaction=1 --threads=40 --use_existing_db=1 --reads=524 --num=104857600 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 >> ${resultFile} #2>&1
    pidof iostat | xargs kill -9
    free -h >> ${resultFile}
    echo "du -h  : " >> ${resultFile}
    sudo du -h /home/colin/hub/testDir >> ${resultFile}

    echo "levelbase scan 40Threads end!!!"
    sudo bash -c "echo 1 > /proc/sys/vm/drop_caches"
    ###################
    sudo bash -c "echo 1 > /proc/sys/vm/drop_caches"
    style="levelbase_normal_wtCnums"

    workload="scan_40Threads_pagecache_cgroup_Length20"
    ioFile=${recordDir}/${workTime}_${style}IO_${workload}\(${loop}\).txt
    resultFile=${recordDir}/${workTime}_${style}OUT_${workload}\(${loop}\).txt
    echo `date +%Y-%m-%d_%H:%M:%S` >> ${resultFile}
    echo "cgroup write: "
    sudo cat /sys/fs/cgroup/blkio/test_write/blkio.throttle.write_bps_device >> ${resultFile}
    sudo cat /sys/fs/cgroup/blkio/test_write/blkio.throttle.write_iops_device >> ${resultFile}
    echo "cgroup read: "
    sudo cat /sys/fs/cgroup/blkio/test_write/blkio.throttle.read_bps_device >>${resultFile}
    sudo cat /sys/fs/cgroup/blkio/test_write/blkio.throttle.read_iops_device >>${resultFile}
    lsblk >> ${resultFile}
    echo "du -h  : " >> ${resultFile}
    sudo du -h /home/colin/hub/testDir >> ${resultFile}
    free -h >> ${resultFile}
    iostat -mx 1 3600 /dev/sdb /dev/sdc /dev/sdd > ${ioFile} &
    sudo cgexec -g blkio:test_write /home/colin/hub/leveldb/build/db_bench --benchmarks="stats,sstables,scan,stats,sstables" --db="/home/colin/hub/testDir"  --scanLength=20 --open_files=65530  --disable_compaction=1 --threads=40 --use_existing_db=1 --reads=26200 --num=104857600 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 >> ${resultFile} #2>&1
    # /home/colin/hub/leveldb/build/db_bench --benchmarks="stats,sstables,scan,stats,sstables" --db="/home/colin/hub/testDir" --cache_size=8589934592  --disable_compaction=1 --threads=40 --use_existing_db=1 --reads=524 --num=104857600 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 >> ${resultFile} #2>&1
    pidof iostat | xargs kill -9
    free -h >> ${resultFile}
    echo "du -h  : " >> ${resultFile}
    sudo du -h /home/colin/hub/testDir >> ${resultFile}

    echo "levelbase scan 40Threads end!!!"
    sudo bash -c "echo 1 > /proc/sys/vm/drop_caches"

    ###################

    ###################

    # 删除数据
    sudo rm -rf /home/colin/hub/testDir/*

    sudo bash -c "echo '8:16 0' >  /sys/fs/cgroup/blkio/test_write/blkio.throttle.read_bps_device"
    sudo bash -c "echo '8:32 0' >  /sys/fs/cgroup/blkio/test_write/blkio.throttle.read_bps_device"
    sudo bash -c "echo '8:48 0' >  /sys/fs/cgroup/blkio/test_write/blkio.throttle.read_bps_device"

    sudo bash -c "echo '8:16 0' > /sys/fs/cgroup/blkio/test_write/blkio.throttle.read_iops_device"
    sudo bash -c "echo '8:32 0' > /sys/fs/cgroup/blkio/test_write/blkio.throttle.read_iops_device"
    sudo bash -c "echo '8:48 0' > /sys/fs/cgroup/blkio/test_write/blkio.throttle.read_iops_device"
done


for loop in 1
do

  # cgroup 限制磁盘速度为140MB/s
    sudo bash -c "echo '8:16 146800640' >  /sys/fs/cgroup/blkio/test_write/blkio.throttle.read_bps_device"
    sudo bash -c "echo '8:32 146800640' >  /sys/fs/cgroup/blkio/test_write/blkio.throttle.read_bps_device"
    sudo bash -c "echo '8:48 146800640' >  /sys/fs/cgroup/blkio/test_write/blkio.throttle.read_bps_device"

    sudo bash -c "echo '8:16 3800' > /sys/fs/cgroup/blkio/test_write/blkio.throttle.read_iops_device"
    sudo bash -c "echo '8:32 3800' > /sys/fs/cgroup/blkio/test_write/blkio.throttle.read_iops_device"
    sudo bash -c "echo '8:48 3800' > /sys/fs/cgroup/blkio/test_write/blkio.throttle.read_iops_device"

    # scan

    cp -r /home/colin/hub/testBackup/100G/blockbase_normal_wtCnums_100G_2021-12-06_11:11:59/* /home/colin/hub/testDir
    sudo bash -c "echo 1 > /proc/sys/vm/drop_caches"
    style="blockbase_normal_wtCnums_cgroup"

    workload="scan_40Threads_pagecache_cgroup_Length1000"
    ioFile=${recordDir}/${workTime}_${style}IO_${workload}\(${loop}\).txt
    resultFile=${recordDir}/${workTime}_${style}OUT_${workload}\(${loop}\).txt
    echo `date +%Y-%m-%d_%H:%M:%S` >> ${resultFile}
    echo "cgroup write: "
    sudo cat /sys/fs/cgroup/blkio/test_write/blkio.throttle.write_bps_device >> ${resultFile}
    sudo cat /sys/fs/cgroup/blkio/test_write/blkio.throttle.write_iops_device >> ${resultFile}
    echo "cgroup read: "
    sudo cat /sys/fs/cgroup/blkio/test_write/blkio.throttle.read_bps_device >>${resultFile}
    sudo cat /sys/fs/cgroup/blkio/test_write/blkio.throttle.read_iops_device >>${resultFile}
    lsblk >> ${resultFile}
    echo "du -h  : " >> ${resultFile}
    sudo du -h /home/colin/hub/testDir >> ${resultFile}
    free -h >> ${resultFile}
    iostat -mx 1 3600 /dev/sdb /dev/sdc /dev/sdd > ${ioFile} &
    sudo cgexec -g blkio:test_write /home/colin/hub/my-leveldb/build/db_bench --benchmarks="stats,sstables,scan,stats,sstables" --db="/home/colin/hub/testDir" --scanLength=1000 --open_files=65530  --disable_compaction=1 --threads=40 --use_existing_db=1 --reads=524 --num=104857600 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 >> ${resultFile} #2>&1
    # /home/colin/hub/my-leveldb/build/db_bench --benchmarks="stats,sstables,scan,stats,sstables" --db="/home/colin/hub/testDir" --cache_size=8589934592  --disable_compaction=1 --threads=40 --use_existing_db=1 --reads=524 --num=104857600 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 >> ${resultFile} #2>&1
    pidof iostat | xargs kill -9
    free -h >> ${resultFile}
    echo "du -h  : " >> ${resultFile}
    sudo du -h /home/colin/hub/testDir >> ${resultFile}

    echo "blockbase scan 40Threads end!!!"
    sudo bash -c "echo 1 > /proc/sys/vm/drop_caches"

    ##############
    sudo bash -c "echo 1 > /proc/sys/vm/drop_caches"
    style="blockbase_normal_wtCnums_cgroup"

    workload="scan_40Threads_pagecache_cgroup_Length100"
    ioFile=${recordDir}/${workTime}_${style}IO_${workload}\(${loop}\).txt
    resultFile=${recordDir}/${workTime}_${style}OUT_${workload}\(${loop}\).txt
    echo `date +%Y-%m-%d_%H:%M:%S` >> ${resultFile}
    echo "cgroup write: "
    sudo cat /sys/fs/cgroup/blkio/test_write/blkio.throttle.write_bps_device >> ${resultFile}
    sudo cat /sys/fs/cgroup/blkio/test_write/blkio.throttle.write_iops_device >> ${resultFile}
    echo "cgroup read: "
    sudo cat /sys/fs/cgroup/blkio/test_write/blkio.throttle.read_bps_device >>${resultFile}
    sudo cat /sys/fs/cgroup/blkio/test_write/blkio.throttle.read_iops_device >>${resultFile}
    lsblk >> ${resultFile}
    echo "du -h  : " >> ${resultFile}
    sudo du -h /home/colin/hub/testDir >> ${resultFile}
    free -h >> ${resultFile}
    iostat -mx 1 3600 /dev/sdb /dev/sdc /dev/sdd > ${ioFile} &
    sudo cgexec -g blkio:test_write /home/colin/hub/my-leveldb/build/db_bench --benchmarks="stats,sstables,scan,stats,sstables" --db="/home/colin/hub/testDir" --scanLength=100 --open_files=65530  --disable_compaction=1 --threads=40 --use_existing_db=1 --reads=5240 --num=104857600 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 >> ${resultFile} #2>&1
    # /home/colin/hub/my-leveldb/build/db_bench --benchmarks="stats,sstables,scan,stats,sstables" --db="/home/colin/hub/testDir" --cache_size=8589934592  --disable_compaction=1 --threads=40 --use_existing_db=1 --reads=524 --num=104857600 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 >> ${resultFile} #2>&1
    pidof iostat | xargs kill -9
    free -h >> ${resultFile}
    echo "du -h  : " >> ${resultFile}
    sudo du -h /home/colin/hub/testDir >> ${resultFile}

    echo "blockbase scan 40Threads end!!!"
    sudo bash -c "echo 1 > /proc/sys/vm/drop_caches"
    ##############
    sudo bash -c "echo 1 > /proc/sys/vm/drop_caches"
    style="blockbase_normal_wtCnums_cgroup"

    workload="scan_40Threads_pagecache_cgroup_Length20"
    ioFile=${recordDir}/${workTime}_${style}IO_${workload}\(${loop}\).txt
    resultFile=${recordDir}/${workTime}_${style}OUT_${workload}\(${loop}\).txt
    echo `date +%Y-%m-%d_%H:%M:%S` >> ${resultFile}
    echo "cgroup write: "
    sudo cat /sys/fs/cgroup/blkio/test_write/blkio.throttle.write_bps_device >> ${resultFile}
    sudo cat /sys/fs/cgroup/blkio/test_write/blkio.throttle.write_iops_device >> ${resultFile}
    echo "cgroup read: "
    sudo cat /sys/fs/cgroup/blkio/test_write/blkio.throttle.read_bps_device >>${resultFile}
    sudo cat /sys/fs/cgroup/blkio/test_write/blkio.throttle.read_iops_device >>${resultFile}
    lsblk >> ${resultFile}
    echo "du -h  : " >> ${resultFile}
    sudo du -h /home/colin/hub/testDir >> ${resultFile}
    free -h >> ${resultFile}
    iostat -mx 1 3600 /dev/sdb /dev/sdc /dev/sdd > ${ioFile} &
    sudo cgexec -g blkio:test_write /home/colin/hub/my-leveldb/build/db_bench --benchmarks="stats,sstables,scan,stats,sstables" --db="/home/colin/hub/testDir" --scanLength=20 --open_files=65530  --disable_compaction=1 --threads=40 --use_existing_db=1 --reads=26200 --num=104857600 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 >> ${resultFile} #2>&1
    # /home/colin/hub/my-leveldb/build/db_bench --benchmarks="stats,sstables,scan,stats,sstables" --db="/home/colin/hub/testDir" --cache_size=8589934592  --disable_compaction=1 --threads=40 --use_existing_db=1 --reads=524 --num=104857600 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 >> ${resultFile} #2>&1
    pidof iostat | xargs kill -9
    free -h >> ${resultFile}
    echo "du -h  : " >> ${resultFile}
    sudo du -h /home/colin/hub/testDir >> ${resultFile}

    echo "blockbase scan 40Threads end!!!"
    sudo bash -c "echo 1 > /proc/sys/vm/drop_caches"
    ##############


    # 删除数据
    sudo rm -rf /home/colin/hub/testDir/*


    sudo bash -c "echo '8:16 0' >  /sys/fs/cgroup/blkio/test_write/blkio.throttle.read_bps_device"
    sudo bash -c "echo '8:32 0' >  /sys/fs/cgroup/blkio/test_write/blkio.throttle.read_bps_device"
    sudo bash -c "echo '8:48 0' >  /sys/fs/cgroup/blkio/test_write/blkio.throttle.read_bps_device"

    sudo bash -c "echo '8:16 0' > /sys/fs/cgroup/blkio/test_write/blkio.throttle.read_iops_device"
    sudo bash -c "echo '8:32 0' > /sys/fs/cgroup/blkio/test_write/blkio.throttle.read_iops_device"
    sudo bash -c "echo '8:48 0' > /sys/fs/cgroup/blkio/test_write/blkio.throttle.read_iops_device"
done



# google原版
   # 构建raid0
    sudo umount /dev/sdb1
    sudo umount /dev/sdc1
    sudo umount /dev/sdd1

    sudo mkfs.ext4 -F /dev/sdb1

    sudo mount /dev/sdb1 /home/colin/hub/testDir_raid0
    sudo chown colin:colin /home/colin/hub/testDir_raid0

    # sudo mdadm --create --verbose /dev/md0 --level=0 --raid-devices=3 /dev/sd{b1,c1,d1} --run
    # sudo mkfs.ext4 -F /dev/md0
    # sudo mount /dev/md0 /home/colin/hub/testDir_raid0
    # sudo chown colin:colin /home/colin/hub/testDir_raid0


# for loop in {1..3}
for loop in 1
do

    # cgroup 限制磁盘速度为140MB/s *3
    sudo bash -c "echo '8:16 440401920' >  /sys/fs/cgroup/blkio/test_write/blkio.throttle.read_bps_device"

    sudo bash -c "echo '8:16 11400' > /sys/fs/cgroup/blkio/test_write/blkio.throttle.read_iops_device"


    cp -r /home/colin/hub/testBackup/100G/google_normal_wtCnums_100G_2021-12-18_23:39:56/* /home/colin/hub/testDir_raid0
    sudo bash -c "echo 1 > /proc/sys/vm/drop_caches"
    style="google_normal_wtCnums"

    # scan
    workload="scan_40Threads_pagecache_cgroup_Length1000"
    ioFile=${recordDir}/${workTime}_${style}IO_${workload}\(${loop}\).txt
    resultFile=${recordDir}/${workTime}_${style}OUT_${workload}\(${loop}\).txt
    echo `date +%Y-%m-%d_%H:%M:%S` >> ${resultFile}
    echo "cgroup write: "
    sudo cat /sys/fs/cgroup/blkio/test_write/blkio.throttle.write_bps_device >> ${resultFile}
    sudo cat /sys/fs/cgroup/blkio/test_write/blkio.throttle.write_iops_device >> ${resultFile}
    echo "cgroup read: "
    sudo cat /sys/fs/cgroup/blkio/test_write/blkio.throttle.read_bps_device >>${resultFile}
    sudo cat /sys/fs/cgroup/blkio/test_write/blkio.throttle.read_iops_device >>${resultFile}
    lsblk >> ${resultFile}
    echo "du -h  : " >> ${resultFile}
    sudo du -h /home/colin/hub/testDir_raid0 >> ${resultFile}
    free -h >> ${resultFile}
    iostat -mx 1 3600 /dev/sdb /dev/sdc /dev/sdd > ${ioFile} &
    sudo cgexec -g blkio:test_write /home/colin/hub/google_leveldb/build/db_bench --benchmarks="stats,sstables,scan,stats,sstables" --db="/home/colin/hub/testDir_raid0" --scanLength=1000 --open_files=65530  --disable_compaction=1 --threads=40 --use_existing_db=1 --reads=524 --num=104857600 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 >> ${resultFile} #2>&1
    # /home/colin/hub/leveldb_origin/build/db_bench --benchmarks="stats,sstables,scan,stats,sstables" --db="/home/colin/hub/testDir_raid0" --cache_size=8589934592  --disable_compaction=1 --threads=40 --use_existing_db=1 --reads=524 --num=104857600 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 >> ${resultFile} #2>&1
    pidof iostat | xargs kill -9
    free -h >> ${resultFile}
    echo "du -h  : " >> ${resultFile}
    sudo du -h /home/colin/hub/testDir_raid0 >> ${resultFile}

    echo "origin scan 40Threads end!!!"
    sudo bash -c "echo 1 > /proc/sys/vm/drop_caches"

    #############
    sudo bash -c "echo 1 > /proc/sys/vm/drop_caches"
    style="google_normal_wtCnums"

    # scan
    workload="scan_40Threads_pagecache_cgroup_Length100"
    ioFile=${recordDir}/${workTime}_${style}IO_${workload}\(${loop}\).txt
    resultFile=${recordDir}/${workTime}_${style}OUT_${workload}\(${loop}\).txt
    echo `date +%Y-%m-%d_%H:%M:%S` >> ${resultFile}
    echo "cgroup write: "
    sudo cat /sys/fs/cgroup/blkio/test_write/blkio.throttle.write_bps_device >> ${resultFile}
    sudo cat /sys/fs/cgroup/blkio/test_write/blkio.throttle.write_iops_device >> ${resultFile}
    echo "cgroup read: "
    sudo cat /sys/fs/cgroup/blkio/test_write/blkio.throttle.read_bps_device >>${resultFile}
    sudo cat /sys/fs/cgroup/blkio/test_write/blkio.throttle.read_iops_device >>${resultFile}
    lsblk >> ${resultFile}
    echo "du -h  : " >> ${resultFile}
    sudo du -h /home/colin/hub/testDir_raid0 >> ${resultFile}
    free -h >> ${resultFile}
    iostat -mx 1 3600 /dev/sdb /dev/sdc /dev/sdd > ${ioFile} &
    sudo cgexec -g blkio:test_write /home/colin/hub/google_leveldb/build/db_bench --benchmarks="stats,sstables,scan,stats,sstables" --db="/home/colin/hub/testDir_raid0" --scanLength=100 --open_files=65530  --disable_compaction=1 --threads=40 --use_existing_db=1 --reads=5240 --num=104857600 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 >> ${resultFile} #2>&1
    # /home/colin/hub/leveldb_origin/build/db_bench --benchmarks="stats,sstables,scan,stats,sstables" --db="/home/colin/hub/testDir_raid0" --cache_size=8589934592  --disable_compaction=1 --threads=40 --use_existing_db=1 --reads=524 --num=104857600 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 >> ${resultFile} #2>&1
    pidof iostat | xargs kill -9
    free -h >> ${resultFile}
    echo "du -h  : " >> ${resultFile}
    sudo du -h /home/colin/hub/testDir_raid0 >> ${resultFile}

    echo "origin scan 40Threads end!!!"
    sudo bash -c "echo 1 > /proc/sys/vm/drop_caches"

    #############
    sudo bash -c "echo 1 > /proc/sys/vm/drop_caches"
    style="google_normal_wtCnums"

    # scan
    workload="scan_40Threads_pagecache_cgroup_Length20"
    ioFile=${recordDir}/${workTime}_${style}IO_${workload}\(${loop}\).txt
    resultFile=${recordDir}/${workTime}_${style}OUT_${workload}\(${loop}\).txt
    echo `date +%Y-%m-%d_%H:%M:%S` >> ${resultFile}
    echo "cgroup write: "
    sudo cat /sys/fs/cgroup/blkio/test_write/blkio.throttle.write_bps_device >> ${resultFile}
    sudo cat /sys/fs/cgroup/blkio/test_write/blkio.throttle.write_iops_device >> ${resultFile}
    echo "cgroup read: "
    sudo cat /sys/fs/cgroup/blkio/test_write/blkio.throttle.read_bps_device >>${resultFile}
    sudo cat /sys/fs/cgroup/blkio/test_write/blkio.throttle.read_iops_device >>${resultFile}
    lsblk >> ${resultFile}
    echo "du -h  : " >> ${resultFile}
    sudo du -h /home/colin/hub/testDir_raid0 >> ${resultFile}
    free -h >> ${resultFile}
    iostat -mx 1 3600 /dev/sdb /dev/sdc /dev/sdd > ${ioFile} &
    sudo cgexec -g blkio:test_write /home/colin/hub/google_leveldb/build/db_bench --benchmarks="stats,sstables,scan,stats,sstables" --db="/home/colin/hub/testDir_raid0" --scanLength=20 --open_files=65530  --disable_compaction=1 --threads=40 --use_existing_db=1 --reads=26200 --num=104857600 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 >> ${resultFile} #2>&1
    # /home/colin/hub/leveldb_origin/build/db_bench --benchmarks="stats,sstables,scan,stats,sstables" --db="/home/colin/hub/testDir_raid0" --cache_size=8589934592  --disable_compaction=1 --threads=40 --use_existing_db=1 --reads=524 --num=104857600 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 >> ${resultFile} #2>&1
    pidof iostat | xargs kill -9
    free -h >> ${resultFile}
    echo "du -h  : " >> ${resultFile}
    sudo du -h /home/colin/hub/testDir_raid0 >> ${resultFile}

    echo "origin scan 40Threads end!!!"
    sudo bash -c "echo 1 > /proc/sys/vm/drop_caches"
    #############

    # 删除数据
    sudo rm -rf /home/colin/hub/testDir_raid0/*

    # cgroup 限制磁盘速度为140MB/s
    sudo bash -c "echo '8:16 0' >  /sys/fs/cgroup/blkio/test_write/blkio.throttle.read_bps_device"

    sudo bash -c "echo '8:16 0' > /sys/fs/cgroup/blkio/test_write/blkio.throttle.read_iops_device"


    
done
    

    #卸载raid0
    sudo umount /home/colin/hub/testDir_raid0

