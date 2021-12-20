#!/bin/bash
ulimit -n 65535
# workDirs=("/home/colin/hub/testDir/vol1" "/home/colin/hub/testDir/vol2" "/home/colin/hub/testDir/vol3")
# workDevs=("/dev/sdb1" "/dev/sdc1" "/dev/sdd1")
workTime=`date +%Y-%m-%d_%H:%M:%S`

    # # 构建raid0
    # sudo umount /home/colin/hub/testDir/vol1
    # sudo umount /home/colin/hub/testDir/vol2
    # sudo umount /home/colin/hub/testDir/vol3

    # sudo mdadm --create --verbose /dev/md0 --level=0 --raid-devices=3 /dev/sd{b1,c1,d1} --run
    # sudo mkfs.ext4 -F /dev/md0
    # sudo mount /dev/md0 /home/colin/hub/testDir_raid0
    # sudo chown colin:colin /home/colin/hub/testDir_raid0

# for loop in {1..5}
for loop in 1
do
    # 测试origin raid0 load , update, read, scan, hotread
    style="origin_normal_wtCnums_100G"

    # load
    workload="load"
    echo `date +%Y-%m-%d_%H:%M:%S` >> ${workTime}_${style}OUT_${workload}\(${loop}\).txt
    lsblk >> ${workTime}_${style}OUT_${workload}\(${loop}\).txt
    iostat -mx 1 3600 /dev/vdb > ${workTime}_${style}IO_${workload}\(${loop}\).txt &
    /root/leveldb/build/db_bench --benchmarks="fillrandom,stats,sstables" --db="/root/testDir" --num=104857600 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864 >> ${workTime}_${style}OUT_${workload}\(${loop}\).txt #2>&1
    # 中止iostat
    pidof iostat | xargs kill -9
    # if [ ${loop} == 1 ]
    #     then 
    #         sudo cp -r /home/colin/hub/YCSB-C-RocksDB/build/testDirRaid /home/colin/hub/YCSB-C-RocksDB/build/backup/${style}_${workTime}
    # fi
    # rm -rf /home/colin/hub/YCSB-C-RocksDB/build/testDir/*
    echo "# du -h /root/testDir" >> ${workTime}_${style}OUT_${workload}\(${loop}\).txt
    du -h /root/testDir >> ${workTime}_${style}OUT_${workload}\(${loop}\).txt

    # # 备份
    # if [ ${loop} == 1 ]
    #     then 
    #         cp -r /home/colin/hub/testDir_raid0 /home/colin/hub/testBackup/100G/${style}_${workTime}
    # fi

    # # 删除数据
    # sudo rm -rf /home/colin/hub/testDir_raid0/*
done
    # #卸载raid0
    # sudo umount /home/colin/hub/testDir_raid0

    # # 停用raid0
    # sudo mdadm --stop /dev/md0
