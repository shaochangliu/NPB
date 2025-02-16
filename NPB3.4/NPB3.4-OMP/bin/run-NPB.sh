#!/bin/bash

CGROUP_PATH="/sys/fs/cgroup/test_NPB"
PROCS_PATH="$CGROUP_PATH/cgroup.procs"
MEMMAX_PATH="$CGROUP_PATH/memory.max"

if [ ! -e "$CGROUP_PATH" ]; then
  sudo mkdir $CGROUP_PATH
fi

echo 26000000000 | sudo tee $MEMMAX_PATH
echo $$ | sudo tee $PROCS_PATH

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

for thread in 8
do
    OMP_NUM_THREADS=$thread ./mg.D.x
done

mv *.log $RESULT_DIR
echo $NEXT_SWITCH | sudo tee /sys/kernel/mm/lru_gen/enabled

for thread in 8
do
    OMP_NUM_THREADS=$thread ./mg.D.x
done