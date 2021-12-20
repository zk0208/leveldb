#!/bin/bash
    speed=(1000 900 800 700 600 500 400 300 200 100)
    for s in ${speed[@]}
    do 
        echo $s'0000000'
    done