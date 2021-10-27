#!/bin/bash

./db_bench --benchmarks="fillrandom,stats" --num=1048576 --value_size=1000 --write_buffer_size=67108864 --max_file_size=67108864