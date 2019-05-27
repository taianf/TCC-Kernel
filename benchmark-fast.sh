#!/bin/bash
set -e
set -u
# set -x

INTSIGHT="/sys/kernel/debug/intsight"

if [ $# -ne 1  ]
then
	echo "Usage: $0 [results]" >&2
    exit 1
fi

results="$1"

cd "${INTSIGHT}"
if [ $(ls | wc -l) == "1" ]; then
    echo > "init"
fi

# Communicate the benchmark config to intsight.
echo softirq > bottom_handler
echo 50 > checkpoint_capacity
echo 20 > delay_ms
echo usleep_range > delay_type
echo 100 > progress_interval
echo 1000 > reps

mkdir -p "${results}"
mkdir -p "${results}/proc"

echo > prepare_trigger

# Errors are ok from now on since all options have been set. If it there are
# results, they have been produced with the right settings.
set +e

# Gather system information before the benchmark.
cp -vf /proc/schedstat "${results}/proc/schedstat.before"
cp -vf /proc/softirqs "${results}/proc/softirqs.before"
cp -vf /proc/stat "${results}/proc/stat.before"
cp -vf /proc/interrupts "${results}/proc/interrupts.before"

# Execute the benchmark
echo > do_trigger

# Gather system information after the benchmark.
cp -vf /proc/interrupts "${results}/proc/interrupts.after"
cp -vf /proc/stat "${results}/proc/stat.after"
cp -vf /proc/softirqs "${results}/proc/softirqs.after"
cp -vf /proc/schedstat "${results}/proc/schedstat.after"

# Save the benchmark results.
echo > postprocess_trigger
cp -vrf . "${results}/intsight"

# Gather general system information.
cp -vf /proc/version "${results}/proc/version"
cp -vf /proc/config.gz "${results}/proc/config.gz"
