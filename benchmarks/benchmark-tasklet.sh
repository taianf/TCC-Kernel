#!/bin/bash
set -e
set -u
# set -x

INTSIGHT="/sys/kernel/debug/intsight"
HERE=$PWD

if [ $# -ne 0  ]
then
	echo "Usage: $0" >&2
    exit 1
fi

cd "${INTSIGHT}"
if [ $(ls | wc -l) == "1" ]; then
    echo > "init"
fi

# Communicate the benchmark config to intsight.
echo tasklet > bottom_handler
echo 50 > checkpoint_capacity
echo 20 > delay_ms
echo usleep_range > delay_type
echo 10000 > progress_interval
echo 50000 > reps

# mkdir -p "results"
mkdir -p $HERE/results-task/proc

echo > prepare_trigger

# Errors are ok from now on since all options have been set. If it there are
# results, they have been produced with the right settings.
set +e

# Gather system information before the benchmark.
cp -vf /proc/schedstat $HERE/results-task/proc/schedstat.before
cp -vf /proc/softirqs $HERE/results-task/proc/softirqs.before
cp -vf /proc/stat $HERE/results-task/proc/stat.before
cp -vf /proc/interrupts $HERE/results-task/proc/interrupts.before

# Execute the benchmark
echo > do_trigger

# Gather system information after the benchmark.
cp -vf /proc/interrupts $HERE/results-task/proc/interrupts.after
cp -vf /proc/stat $HERE/results-task/proc/stat.after
cp -vf /proc/softirqs $HERE/results-task/proc/softirqs.after
cp -vf /proc/schedstat $HERE/results-task/proc/schedstat.after

# Save the benchmark results.
echo > postprocess_trigger
cp -vrf . $HERE/results-task/intsight

# Gather general system information.
cp -vf /proc/version $HERE/results-task/proc/version
cp -vf /proc/config.gz $HERE/results-task/proc/config.gz
