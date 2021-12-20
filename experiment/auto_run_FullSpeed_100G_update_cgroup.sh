#!/bin/bash
ulimit -n 65535
# 基于100G数据库执行update

workDirs=("/home/colin/hub/testDir/vol1" "/home/colin/hub/testDir/vol2" "/home/colin/hub/testDir/vol3")
workDevs=("/dev/sdb1" "/dev/sdc1" "/dev/sdd1")
workTime=`date +%Y-%m-%d_%H:%M:%S`
recordDirs=/home/colin/hub/experiment_record

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


    # 需要控制每个存储卷 140MB/s的读写速度

# for loop in {1..3}
for loop in 1
do

    # 复制已有数据库
    cp -r /home/colin/hub/testBackup/100G/levelbase_normal_wtCnums_100G_2021-12-06_11:11:59/* /home/colin/hub/testDir
    # sudo bash -c "echo 1 > /proc/sys/vm/drop_caches"
    # 测试levelbase load , update, read, scan, hotread
    style="levelbase_100G_cgroup_normal_wtCnums"
    # cgroup 限制磁盘速度为300MB/s
    sudo bash -c "echo '8:16 314572800' >  /sys/fs/cgroup/blkio/test_write/blkio.throttle.write_bps_device"
    sudo bash -c "echo '8:32 314572800' >  /sys/fs/cgroup/blkio/test_write/blkio.throttle.write_bps_device"
    sudo bash -c "echo '8:48 314572800' >  /sys/fs/cgroup/blkio/test_write/blkio.throttle.write_bps_device"

    # update
    workload="update"
    ioFile=${recordDirs}/${workTime}_${style}IO_${workload}\(${loop}\).txt
    resultFile=${recordDirs}/${workTime}_${style}OUT_${workload}\(${loop}\).txt
    cat /sys/fs/cgroup/blkio/test_write/blkio.throttle.write_bps_device >> ${resultFile}
    iostat -mx 1 3600 /dev/sdb /dev/sdc /dev/sdd > ${ioFile} &
    echo `date +%Y-%m-%d_%H:%M:%S` >> ${resultFile}
    sudo cgexec -g blkio:test_write /home/colin/hub/leveldb/build/db_bench --benchmarks="overwrite,stats,sstables" --db="/home/colin/hub/testDir" --use_existing_db=1 --num=10485760 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 >> ${resultFile} #2>&1
    pidof iostat | xargs kill -9

    echo "levelbase update end!!!"
    # sudo bash -c "echo 1 > /proc/sys/vm/drop_caches"

    # 删除数据
    sudo rm -rf /home/colin/hub/testDir/*
done


# for loop in {1..3}
for loop in 1
do

     # 复制已有数据库
    cp -r /home/colin/hub/testBackup/100G/blockbase_normal_wtCnums_100G_2021-12-06_11:11:59/* /home/colin/hub/testDir
    # sudo bash -c "echo 1 > /proc/sys/vm/drop_caches"
    # 测试blockbase load, update, read, scan, hotread
    style="blockbase_100G_cgroup_normal_wtCnums"
    # cgroup 限制磁盘速度为300MB/s
    sudo bash -c "echo '8:16 314572800' >  /sys/fs/cgroup/blkio/test_write/blkio.throttle.write_bps_device"
    sudo bash -c "echo '8:32 314572800' >  /sys/fs/cgroup/blkio/test_write/blkio.throttle.write_bps_device"
    sudo bash -c "echo '8:48 314572800' >  /sys/fs/cgroup/blkio/test_write/blkio.throttle.write_bps_device"

    # update
    workload="update"
    ioFile=${recordDirs}/${workTime}_${style}IO_${workload}\(${loop}\).txt
    resultFile=${recordDirs}/${workTime}_${style}OUT_${workload}\(${loop}\).txt
    cat /sys/fs/cgroup/blkio/test_write/blkio.throttle.write_bps_device >> ${resultFile}
    iostat -mx 1 3600 /dev/sdb /dev/sdc /dev/sdd > ${ioFile} &
    echo `date +%Y-%m-%d_%H:%M:%S` >> ${resultFile}
    sudo cgexec -g blkio:test_write /home/colin/hub/my-leveldb/build/db_bench_update --benchmarks="overwrite,stats,sstables" --db="/home/colin/hub/testDir" --use_existing_db=1 --num=10485760 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 >> ${resultFile} #2>&1
    pidof iostat | xargs kill -9

    echo "blockbase update end!!!"
    # sudo bash -c "echo 1 > /proc/sys/vm/drop_caches"

    # 删除数据
    sudo rm -rf /home/colin/hub/testDir/*
done

    #取消cgroup
    sudo bash -c "echo '8:16 0' >  /sys/fs/cgroup/blkio/test_write/blkio.throttle.write_bps_device"
    sudo bash -c "echo '8:32 0' >  /sys/fs/cgroup/blkio/test_write/blkio.throttle.write_bps_device"
    sudo bash -c "echo '8:48 0' >  /sys/fs/cgroup/blkio/test_write/blkio.throttle.write_bps_device"


    # 构建raid0
    sudo umount /home/colin/hub/testDir/vol1
    sudo umount /home/colin/hub/testDir/vol2
    sudo umount /home/colin/hub/testDir/vol3

    sudo mdadm --create --verbose /dev/md0 --level=0 --raid-devices=3 /dev/sd{b1,c1,d1} --run
    sudo mkfs.ext4 -F /dev/md0
    sudo mount /dev/md0 /home/colin/hub/testDir_raid0
    sudo chown colin:colin /home/colin/hub/testDir_raid0

# for loop in {1..3}
for loop in 1
do
    # 复制已有数据
    cp -r /home/colin/hub/testBackup/100G/origin_normal_wtCnums_100G_2021-12-06_11:11:59/* /home/colin/hub/testDir_raid0
    # sudo bash -c "echo 1 > /proc/sys/vm/drop_caches"
    # 测试origin raid0 load , update, read, scan, hotread
    style="origin_100G_cgroup_normal_wtCnums"

    # cgroup控制磁盘速度为3*3000MB/s
    sudo bash -c "echo '9:0 943718400' >  /sys/fs/cgroup/blkio/test_write/blkio.throttle.write_bps_device"

    # update
    workload="update"
    ioFile=${recordDirs}/${workTime}_${style}IO_${workload}\(${loop}\).txt
    resultFile=${recordDirs}/${workTime}_${style}OUT_${workload}\(${loop}\).txt
    cat /sys/fs/cgroup/blkio/test_write/blkio.throttle.write_bps_device >> ${resultFile}
    iostat -mx 1 3600 /dev/sdb /dev/sdc /dev/sdd /dev/md0 > ${ioFile} &
    echo `date +%Y-%m-%d_%H:%M:%S` >> ${resultFile}
    sudo cgexec -g blkio:test_write /home/colin/hub/leveldb_origin/build/db_bench --benchmarks="overwrite,stats,sstables" --db="/home/colin/hub/testDir_raid0" --use_existing_db=1 --num=10485760 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 >> ${resultFile} #2>&1
    pidof iostat | xargs kill -9

    echo "origin update end!!!"
    sudo bash -c "echo 1 > /proc/sys/vm/drop_caches"

    # 删除数据
    sudo rm -rf /home/colin/hub/testDir_raid0/*
done

    #卸载raid0
    sudo umount /home/colin/hub/testDir_raid0

    # 停用raid0
    sudo mdadm --stop /dev/md0

