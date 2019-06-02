#!/usr/bin/python
import csv
import sys

if len(sys.argv) != 3:
    print("Especify root directory of benchmark, irq and timestamp type!")
    print("Example: results-fast softirq pmccntr")
    exit(1)

root_csv_folder = sys.argv[1] + "/intsight/csv_results/"

measures_file = root_csv_folder + "name"
irq_type = sys.argv[2]
timestamps_file = root_csv_folder + sys.argv[3]
response_times = []
total_time = 0

with open(measures_file, 'r') as measures_csv, open(
        timestamps_file, 'r') as timestamps_csv:
    measures_reader = csv.reader(measures_csv, delimiter=',')
    timestamps_reader = csv.reader(timestamps_csv, delimiter=',')
    measures = list(measures_reader)
    timestamps = list(timestamps_reader)

    results = list(map(lambda x, y: dict(zip(x, y)), measures, timestamps))

for result in results:
    if ("irq" in result.keys()) & (irq_type in result.keys()):
        if (result["irq"] != "0") & (result[irq_type] != "0"):
            response_times.append(int(result[irq_type]) - int(result["irq"]))

print("lines: " + str(len(response_times)))
if len(response_times) != 0:
    print("Average time: " + str(sum(response_times) / len(response_times)))
    print("Minimum time: " + str(min(response_times)))
    print("Maximum time: " + str(max(response_times)))
