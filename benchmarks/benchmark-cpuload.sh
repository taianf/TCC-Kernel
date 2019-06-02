#!/bin/bash

if [ $# -ne 3 -o ! -f "$2" ]
then
	echo "Usage: $0 [results] [config] [threads]" >&2
    exit 1
fi

NR_PROCS=$3
NR_THREADS_PER_PROC=1

for i in {1..${NR_PROCS}}
do
    ./cpuload ${NR_THREADS_PER_PROC} &
done

./benchmark.sh $1 $2

pkill cpuload
