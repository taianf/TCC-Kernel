#!/bin/bash

if [ $# -ne 2 -o ! -f "$2" ]
then
	echo "Usage: $0 [results] [config]" >&2
    exit 1
fi

NR_PROCS=8
NR_THREADS_PER_PROC=8

for i in {1..${NR_PROCS}}
do
    ./cpuload ${NR_THREADS_PER_PROC} &
done

./benchmark.sh $1 $2

pkill cpuload
