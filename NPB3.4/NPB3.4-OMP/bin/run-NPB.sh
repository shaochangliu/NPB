#!/bin/bash

CGROUP_PATH="/sys/fs/cgroup/swap_log"
PROCS_PATH="$CGROUP_PATH/cgroup.procs"
MEMMAX_PATH="$CGROUP_PATH/memory.max"

if [ ! -e "$CGROUP_PATH" ]; then
    sudo mkdir $CGROUP_PATH
    if [ $? -ne 0 ]; then
        echo "Failed to create cgroup path: $CGROUP_PATH"
        exit 1
    fi
fi

echo 26000000000 | sudo tee $MEMMAX_PATH
if [ $? -ne 0 ]; then
    echo "Failed to set memory limit"
    exit 1
fi

echo 0 > /proc/swap_log_ctl

LRU_STATE=$(cat /sys/kernel/mm/lru_gen/enabled)
if [ "$LRU_STATE" = "0x0007" ]; then
    mkdir -p ./MGLRU
    RESULT_DIR="MGLRU"
    NEXT_SWITCH="n"
else
    mkdir -p ./2QLRU
    RESULT_DIR="2QLRU"
    NEXT_SWITCH="y"
fi

echo 1 > /proc/swap_log_ctl

for thread in 8
do
    OMP_NUM_THREADS=$thread numactl --cpunodebind=0 --membind=0 -- ./mg.D.x &
    MG_PID=$!
    echo $MG_PID | sudo tee $PROCS_PATH
    wait $MG_PID
    if [ $? -ne 0 ]; then
        echo "Failed to execute mg.D.x with $thread threads"
        exit 1
    fi
done

echo 0 > /proc/swap_log_ctl

if ls *.log 1> /dev/null 2>&1; then
    mv *.log $RESULT_DIR
else
    echo "No per thread log files found to move"
fi

if [ -e /home/cc/swap_log.txt ]; then
    mv /home/cc/swap_log.txt /home/cc/swap_log_$RESULT_DIR.txt
else
    echo "No swap_log.txt file found to move"
fi

echo $NEXT_SWITCH | sudo tee /sys/kernel/mm/lru_gen/enabled
echo 1 > /proc/swap_log_ctl

for thread in 8
do
    OMP_NUM_THREADS=$thread numactl --cpunodebind=0 --membind=0 -- ./mg.D.x &
    MG_PID=$!
    echo $MG_PID | sudo tee $PROCS_PATH
    wait $MG_PID
    if [ $? -ne 0 ]; then
        echo "Failed to execute mg.D.x with $thread threads"
        exit 1
    fi
done

echo 0 > /proc/swap_log_ctl