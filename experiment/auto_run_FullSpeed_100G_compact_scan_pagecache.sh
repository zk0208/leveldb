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


#     # 需要控制每个存储卷 100MB/s的读写速度

# for loop in {1..3}
for loop in 1
do

    # 复制已有数据库
    cp -r /home/colin/hub/testBackup/100G/levelbase_normal_wtCnums_100G_2021-12-15_17:44:33/* /home/colin/hub/testDir
    sudo bash -c "echo 1 > /proc/sys/vm/drop_caches"
    # 测试levelbase load , update, read, scan, hotread
    style="levelbase_normal_wtCnums"

    # # read
    # workload="read"
    # iostat -mx 1 3600 /dev/sdb /dev/sdc /dev/sdd > ${workTime}_${style}IO_${workload}\(${loop}\).txt &
    # echo `date +%Y-%m-%d_%H:%M:%S` >> ${workTime}_${style}OUT_${workload}\(${loop}\).txt
    # ../build/db_bench --benchmarks="readrandom,stats,sstables" --db="/home/colin/hub/testDir" --use_existing_db=1 --reads=10485760 --num=104857600 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 >> ${workTime}_${style}OUT_${workload}\(${loop}\).txt 2>&1
    # pidof iostat | xargs kill -9

    # echo "levelbase readrandom end!!!"
    # sudo bash -c "echo 1 > /proc/sys/vm/drop_caches"

    # # read
    # workload="read_directio"
    # iostat -mx 1 3600 /dev/sdb /dev/sdc /dev/sdd > ${workTime}_${style}IO_${workload}\(${loop}\).txt &
    # echo `date +%Y-%m-%d_%H:%M:%S` >> ${workTime}_${style}OUT_${workload}\(${loop}\).txt
    # ../build/db_bench --benchmarks="readrandom,stats,sstables" --db="/home/colin/hub/testDir" --direct_io=1 --use_existing_db=1 --reads=10485760 --num=104857600 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 >> ${workTime}_${style}OUT_${workload}\(${loop}\).txt 2>&1
    # pidof iostat | xargs kill -9

    # echo "levelbase readrandom directio end!!!"
    # sudo bash -c "echo 1 > /proc/sys/vm/drop_caches"

    # # read
    # workload="read_40Threads"
    # iostat -mx 1 3600 /dev/sdb /dev/sdc /dev/sdd > ${workTime}_${style}IO_${workload}\(${loop}\).txt &
    # echo `date +%Y-%m-%d_%H:%M:%S` >> ${workTime}_${style}OUT_${workload}\(${loop}\).txt
    # ../build/db_bench --benchmarks="readrandom,stats,sstables" --db="/home/colin/hub/testDir" --threads=40 --use_existing_db=1 --reads=262144 --num=104857600 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 >> ${workTime}_${style}OUT_${workload}\(${loop}\).txt #2>&1
    # pidof iostat | xargs kill -9

    # echo "levelbase readrandom 40Threads end!!!"
    # sudo bash -c "echo 1 > /proc/sys/vm/drop_caches"

    # read
    workload="compact_scan_40Threads_pagecache"
    ioFile=${workTime}_${style}IO_${workload}\(${loop}\).txt
    resultFile=${workTime}_${style}OUT_${workload}\(${loop}\).txt
    iostat -mx 1 3600 /dev/sdb /dev/sdc /dev/sdd > ${ioFile} &
    echo `date +%Y-%m-%d_%H:%M:%S` >> ${resultFile}
    lsblk >> ${resultFile}
    free -h >> ${resultFile}
    ../build/db_bench --benchmarks="stats,sstables,compact,stats,sstables,scan,stats,sstables" --db="/home/colin/hub/testDir" --threads=40 --use_existing_db=1 --reads=524 --num=104857600 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 >> ${resultFile} #2>&1
    pidof iostat | xargs kill -9
    free -h >> ${resultFile}

    echo "du -h  : " >> ${resultFile}
    du -h /home/colin/hub/testDir >> ${resultFile}
    echo "levelbase scan 40Threads end!!!"
    sudo bash -c "echo 1 > /proc/sys/vm/drop_caches"

    # 删除数据
    sudo rm -rf /home/colin/hub/testDir/*
done


# for loop in {1..3}
for loop in 1
do

     # 复制已有数据库
    cp -r /home/colin/hub/testBackup/100G/blockbase_normal_wtCnums_100G_2021-12-06_11:11:59/* /home/colin/hub/testDir
    free -h >> ${workTime}_${style}OUT_${workload}\(${loop}\).txt
    sudo bash -c "echo 1 > /proc/sys/vm/drop_caches"
    free -h >> ${workTime}_${style}OUT_${workload}\(${loop}\).txt
    # 测试blockbase load, update, read, scan, hotread
    style="blockbase_normal_wtCnums"

    # # read 
    # workload="read"
    # iostat -mx 1 3600 /dev/sdb /dev/sdc /dev/sdd > ${workTime}_${style}IO_${workload}\(${loop}\).txt &
    # echo `date +%Y-%m-%d_%H:%M:%S` >> ${workTime}_${style}OUT_${workload}\(${loop}\).txt
    # /home/colin/hub/my-leveldb/build/db_bench --benchmarks="readrandom,stats,sstables" --db="/home/colin/hub/testDir" --use_existing_db=1 --reads=10485760 --num=104857600 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 >> ${workTime}_${style}OUT_${workload}\(${loop}\).txt 2>&1
    # pidof iostat | xargs kill -9

    # echo "blockbase readrandom end!!!"
    # sudo bash -c "echo 1 > /proc/sys/vm/drop_caches"


    # # read 
    # workload="read_directio"
    # iostat -mx 1 3600 /dev/sdb /dev/sdc /dev/sdd > ${workTime}_${style}IO_${workload}\(${loop}\).txt &
    # echo `date +%Y-%m-%d_%H:%M:%S` >> ${workTime}_${style}OUT_${workload}\(${loop}\).txt
    # /home/colin/hub/my-leveldb/build/db_bench --benchmarks="readrandom,stats,sstables" --db="/home/colin/hub/testDir" --direct_io=1 --use_existing_db=1 --reads=10485760 --num=104857600 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 >> ${workTime}_${style}OUT_${workload}\(${loop}\).txt 2>&1
    # pidof iostat | xargs kill -9

    # echo "blockbase readrandom directio end!!!"
    # sudo bash -c "echo 1 > /proc/sys/vm/drop_caches"

    # # read 
    # workload="read_40Threads"
    # iostat -mx 1 3600 /dev/sdb /dev/sdc /dev/sdd > ${workTime}_${style}IO_${workload}\(${loop}\).txt &
    # echo `date +%Y-%m-%d_%H:%M:%S` >> ${workTime}_${style}OUT_${workload}\(${loop}\).txt
    # /home/colin/hub/my-leveldb/build/db_bench --benchmarks="readrandom,stats,sstables" --db="/home/colin/hub/testDir" --threads=40 --use_existing_db=1 --reads=524288 --num=104857600 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 >> ${workTime}_${style}OUT_${workload}\(${loop}\).txt 2>&1
    # pidof iostat | xargs kill -9

    # echo "blockbase readrandom 30Threads end!!!"
    # sudo bash -c "echo 1 > /proc/sys/vm/drop_caches"

    # read 
    workload="compact_scan_40Threads_pagecache"
    ioFile=${workTime}_${style}IO_${workload}\(${loop}\).txt
    resultFile=${workTime}_${style}OUT_${workload}\(${loop}\).txt
    iostat -mx 1 3600 /dev/sdb /dev/sdc /dev/sdd > ${ioFile} &
    echo `date +%Y-%m-%d_%H:%M:%S` >> ${resultFile}
    lsblk >> ${resultFile}
    free -h >> ${resultFile}
    /home/colin/hub/my-leveldb/build/db_bench --benchmarks="stats,sstables,compact,stats,sstables,scan,stats,sstables" --db="/home/colin/hub/testDir" --threads=40 --use_existing_db=1 --reads=524 --num=104857600 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 >> ${resultFile} #2>&1
    pidof iostat | xargs kill -9
    free -h >> ${resultFile}

    echo "du -h  : " >> ${resultFile}
    du -h /home/colin/hub/testDir >> ${resultFile}
    echo "blockbase scan 40Threads end!!!"
    sudo bash -c "echo 1 > /proc/sys/vm/drop_caches"


    # 删除数据
    sudo rm -rf /home/colin/hub/testDir/*
done


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
    cp -r /home/colin/hub/testBackup/100G/origin_normal_wtCnums_100G_2021-12-16_09:22:34/* /home/colin/hub/testDir_raid0
    sudo bash -c "echo 1 > /proc/sys/vm/drop_caches"
    # 测试origin raid0 load , update, read, scan, hotread
    style="origin_normal_wtCnums"
        
    # # read 
    # workload="read"
    # iostat -mx 1 3600 /dev/sdb /dev/sdc /dev/sdd /dev/md0 > ${workTime}_${style}IO_${workload}\(${loop}\).txt &
    # echo `date +%Y-%m-%d_%H:%M:%S` >> ${workTime}_${style}OUT_${workload}\(${loop}\).txt
    # /home/colin/hub/leveldb_origin/build/db_bench --benchmarks="readrandom,stats,sstables" --db="/home/colin/hub/testDir_raid0" --use_existing_db=1 --reads=10485760 --num=104857600 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 >> ${workTime}_${style}OUT_${workload}\(${loop}\).txt 2>&1
    # pidof iostat | xargs kill -9

    # echo "origin readrandom end!!!"
    # sudo bash -c "echo 1 > /proc/sys/vm/drop_caches"

    # # read 
    # workload="read_directio"
    # iostat -mx 1 3600 /dev/sdb /dev/sdc /dev/sdd /dev/md0 > ${workTime}_${style}IO_${workload}\(${loop}\).txt &
    # echo `date +%Y-%m-%d_%H:%M:%S` >> ${workTime}_${style}OUT_${workload}\(${loop}\).txt
    # /home/colin/hub/leveldb_origin/build/db_bench --benchmarks="readrandom,stats,sstables" --db="/home/colin/hub/testDir_raid0" --direct_io=1 --use_existing_db=1 --reads=10485760 --num=104857600 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 >> ${workTime}_${style}OUT_${workload}\(${loop}\).txt 2>&1
    # pidof iostat | xargs kill -9

    # echo "origin readrandom directio end!!!"
    # sudo bash -c "echo 1 > /proc/sys/vm/drop_caches"

    # # read 
    # workload="read_40Threads"
    # iostat -mx 1 3600 /dev/sdb /dev/sdc /dev/sdd /dev/md0 > ${workTime}_${style}IO_${workload}\(${loop}\).txt &
    # echo `date +%Y-%m-%d_%H:%M:%S` >> ${workTime}_${style}OUT_${workload}\(${loop}\).txt
    # /home/colin/hub/leveldb_origin/build/db_bench --benchmarks="readrandom,stats,sstables" --db="/home/colin/hub/testDir_raid0" --threads=40 --use_existing_db=1 --reads=262144 --num=104857600 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 >> ${workTime}_${style}OUT_${workload}\(${loop}\).txt 2>&1
    # pidof iostat | xargs kill -9

    # echo "origin readrandom 40Threads end!!!"
    # sudo bash -c "echo 1 > /proc/sys/vm/drop_caches"

    # read 
    workload="compact_scan_40Threads_pagecache"
    ioFile=${workTime}_${style}IO_${workload}\(${loop}\).txt
    resultFile=${workTime}_${style}OUT_${workload}\(${loop}\).txt
    iostat -mx 1 3600 /dev/sdb /dev/sdc /dev/sdd /dev/md0 > ${ioFile} &
    echo `date +%Y-%m-%d_%H:%M:%S` >> ${resultFile}
    lsblk >> ${resultFile}
    free -h >> ${resultFile}
    /home/colin/hub/leveldb_origin/build/db_bench --benchmarks="stats,sstables,compact,stats,sstables,scan,stats,sstables" --db="/home/colin/hub/testDir_raid0" --threads=40 --use_existing_db=1 --reads=524 --num=104857600 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 >> ${resultFile} #2>&1
    pidof iostat | xargs kill -9
    free -h >> ${resultFile}

    echo "du -h  : " >> ${resultFile}
    du -h /home/colin/hub/testDir_raid0 >> ${resultFile}

    echo "origin scan 40Threads end!!!"
    sudo bash -c "echo 1 > /proc/sys/vm/drop_caches"

    # 删除数据
    sudo rm -rf /home/colin/hub/testDir_raid0/*
done

    #卸载raid0
    sudo umount /home/colin/hub/testDir_raid0

    # 停用raid0
    sudo mdadm --stop /dev/md0

