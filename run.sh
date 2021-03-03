ulimit -n 65535
./db_bench --benchmarks=fillseq --compression_ratio=1 --write_buffer_size=67108864 --max_file_size=67108864 --cache_size=134217728 --num=10000000