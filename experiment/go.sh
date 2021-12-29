#!/bin/bash
# ./auto_run_FullSpeed_100G_read_pagecache.sh
# ./auto_run_FullSpeed_100G_compact_read_pagecache.sh
# ./auto_run_FullSpeed_100G_scan_pagecache.sh
# ./auto_run_FullSpeed_100G_compact_scan_pagecache.sh
for i in {1..3}
    do
    ./auto_run_cgroup_microbench_scan.sh
    done

for i in {1..3}
    do
    ./auto_run_cgroup_microbench_read.sh
    done