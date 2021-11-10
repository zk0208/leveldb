#!/bin/bash
# for loop in 1 2 3
# do
#     if [ ${loop} == 1 ]
#         then 
#             echo ${loop}
#     fi
# done


devs=("/dev/sdb1" "/dev/sdb2" "/dev/sdb3")
for dev in ${devs[@]}
    do 
        echo $dev
    done

echo ${devs[@]}

for i in ${!devs[@]}
    do 
        echo $i
    done

workTime=`date +%Y-%m-%d_%H:%M:%S`
echo $workTime

iostat -mx 1 3600 ${devs[@]}