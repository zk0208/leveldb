#!/bin/bash
ulimit -n 65535

workDirs=("/home/colin/hub/testDir/vol1" "/home/colin/hub/testDir/vol2" "/home/colin/hub/testDir/vol3")
workDevs=("/dev/sdb1" "/dev/sdc1" "/dev/sdd1")
workTime=`date +%Y-%m-%d_%H:%M:%S`


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


style="levelbase_normal_wtCnums"
# 复制数据 使用顺序数据
   cp -r /home/colin/hub/testBackup/100G/levelbase_normal_wtCnums_100G_2021-12-06_11:11:59/* /home/colin/hub/testDir

#    sudo bash -c "echo 1 > /proc/sys/vm/drop_caches"


# for loop in {1..3}
for loop in 1
do
    #hot write
    workload="hotwrite"
    /home/colin/hub/leveldb/build/db_bench --benchmarks="writehot,stats,sstables" --db="/home/colin/hub/testDir" --use_existing_db=1 --num=104857600 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 >> ${workTime}_${style}OUT_${workload}\(${loop}\).txt 2>&1
    sudo bash -c "echo 1 > /proc/sys/vm/drop_caches"
#hotread
    # workload="hotread"
    # iostat -mx 1 3600 /dev/sdb /dev/sdc /dev/sdd > ${workTime}_${style}IO_${workload}\(${loop}\).txt &
    # echo `date +%Y-%m-%d_%H:%M:%S` >> ${workTime}_${style}OUT_${workload}\(${loop}\).txt
    # ../build/db_bench --benchmarks="readhot,stats,sstables" --db="/home/colin/hub/testDir" --use_existing_db=1 --reads=10485760 --num=104857600 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 --direct_io=1 >> ${workTime}_${style}OUT_${workload}\(${loop}\).txt 2>&1
    # pidof iostat | xargs kill -9

    # echo "levelbase hotread end!!!"
    # sudo bash -c "echo 1 > /proc/sys/vm/drop_caches"

    workload="hotread_30Threads"
    iostat -mx 1 3600 /dev/sdb /dev/sdc /dev/sdd > ${workTime}_${style}IO_${workload}\(${loop}\).txt &
    echo `date +%Y-%m-%d_%H:%M:%S` >> ${workTime}_${style}OUT_${workload}\(${loop}\).txt
    /home/colin/hub/leveldb/build/db_bench --benchmarks="readhot,stats,sstables" --db="/home/colin/hub/testDir" --threads=30 --use_existing_db=1 --reads=349525 --num=104857600 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 --direct_io=1 >> ${workTime}_${style}OUT_${workload}\(${loop}\).txt 2>&1
    pidof iostat | xargs kill -9

    echo "levelbase hotread 30Threads end!!!"
    sudo bash -c "echo 1 > /proc/sys/vm/drop_caches"

done 
# 删除数据
    rm -rf /home/colin/hub/testDir/*


style="blockbase_normal_wtCnums"
# 复制数据 使用顺序数据
   cp -r /home/colin/hub/testBackup/100G/blockbase_normal_wtCnums_100G_2021-12-06_11:11:59/* /home/colin/hub/testDir
#    sudo bash -c "echo 1 > /proc/sys/vm/drop_caches"

# for loop in {1..3}
for loop in 1
do

#hot write
    workload="hotwrite"
    /home/colin/hub/my-leveldb/build/db_bench --benchmarks="writehot,stats,sstables" --db="/home/colin/hub/testDir" --use_existing_db=1 --num=104857600 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 >> ${workTime}_${style}OUT_${workload}\(${loop}\).txt 2>&1
    sudo bash -c "echo 1 > /proc/sys/vm/drop_caches"
#hotread
    # workload="hotread"
    # iostat -mx 1 3600 /dev/sdb /dev/sdc /dev/sdd > ${workTime}_${style}IO_${workload}\(${loop}\).txt &
    # echo `date +%Y-%m-%d_%H:%M:%S` >> ${workTime}_${style}OUT_${workload}\(${loop}\).txt
    # /home/colin/hub/my-leveldb/build/db_bench --benchmarks="readhot,stats,sstables" --db="/home/colin/hub/testDir" --use_existing_db=1 --reads=10485760 --num=104857600 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 --direct_io=1 >> ${workTime}_${style}OUT_${workload}\(${loop}\).txt 2>&1
    # pidof iostat | xargs kill -9

    # echo "blockbase hotread end!!!"
    # sudo bash -c "echo 1 > /proc/sys/vm/drop_caches"

    workload="hotread_30Threads"
    iostat -mx 1 3600 /dev/sdb /dev/sdc /dev/sdd > ${workTime}_${style}IO_${workload}\(${loop}\).txt &
    echo `date +%Y-%m-%d_%H:%M:%S` >> ${workTime}_${style}OUT_${workload}\(${loop}\).txt
    /home/colin/hub/my-leveldb/build/db_bench --benchmarks="readhot,stats,sstables" --db="/home/colin/hub/testDir" --threads=30 --use_existing_db=1 --reads=349525 --num=104857600 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 --direct_io=1 >> ${workTime}_${style}OUT_${workload}\(${loop}\).txt 2>&1
    pidof iostat | xargs kill -9

    echo "blockbase hotread 30Threads end!!!"
    sudo bash -c "echo 1 > /proc/sys/vm/drop_caches"
done

# 删除数据
    rm -rf /home/colin/hub/testDir/*




 # 构建raid0
    sudo umount /home/colin/hub/testDir/vol1
    sudo umount /home/colin/hub/testDir/vol2
    sudo umount /home/colin/hub/testDir/vol3

    sudo mdadm --create --verbose /dev/md0 --level=0 --raid-devices=3 /dev/sd{b1,c1,d1} --run
    sudo mkfs.ext4 -F /dev/md0
    sudo mount /dev/md0 /home/colin/hub/testDir_raid0
    sudo chown colin:colin /home/colin/hub/testDir_raid0


style="origin_normal_wtCnums"
# 复制数据 使用顺序数据
   cp -r /home/colin/hub/testBackup/100G/origin_normal_wtCnums_100G_2021-12-06_11:11:59/* /home/colin/hub/testDir_raid0
#    sudo bash -c "echo 1 > /proc/sys/vm/drop_caches"

# for loop in {1..3}
for loop in 1
do

    workload="hotwrite"
    /home/colin/hub/leveldb_origin/build/db_bench --benchmarks="writehot,stats,sstables" --db="/home/colin/hub/testDir_raid0" --use_existing_db=1 --num=104857600 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 >> ${workTime}_${style}OUT_${workload}\(${loop}\).txt 2>&1
    sudo bash -c "echo 1 > /proc/sys/vm/drop_caches"
#hotread
    # workload="hotread"
    # iostat -mx 1 3600 /dev/sdb /dev/sdc /dev/sdd /dev/md0 > ${workTime}_${style}IO_${workload}\(${loop}\).txt &
    # echo `date +%Y-%m-%d_%H:%M:%S` >> ${workTime}_${style}OUT_${workload}\(${loop}\).txt
    # /home/colin/hub/leveldb_origin/build/db_bench --benchmarks="readhot,stats,sstables" --db="/home/colin/hub/testDir_raid0" --use_existing_db=1 --reads=10485760 --num=104857600 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 --direct_io=1 >> ${workTime}_${style}OUT_${workload}\(${loop}\).txt 2>&1
    # pidof iostat | xargs kill -9

    # echo "origin hotread end!!!"
    # sudo bash -c "echo 1 > /proc/sys/vm/drop_caches"

    workload="hotread_30Threads"
    iostat -mx 1 3600 /dev/sdb /dev/sdc /dev/sdd /dev/md0 > ${workTime}_${style}IO_${workload}\(${loop}\).txt &
    echo `date +%Y-%m-%d_%H:%M:%S` >> ${workTime}_${style}OUT_${workload}\(${loop}\).txt
    /home/colin/hub/leveldb_origin/build/db_bench --benchmarks="readhot,stats,sstables" --db="/home/colin/hub/testDir_raid0" --threads=30 --use_existing_db=1 --reads=349525 --num=104857600 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 --direct_io=1 >> ${workTime}_${style}OUT_${workload}\(${loop}\).txt 2>&1
    pidof iostat | xargs kill -9

    echo "origin hotread 30Threads end!!!"
    sudo bash -c "echo 1 > /proc/sys/vm/drop_caches"
done

# 删除数据
    rm -rf /home/colin/hub/testDir_raid0/*

    #卸载raid0
    sudo umount /home/colin/hub/testDir_raid0

    # 停用raid0
    sudo mdadm --stop /dev/md0


echo "ALL hotread end!!!"




