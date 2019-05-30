#!/usr/bin/python
import csv
import sys

# print("This is the name of the script: \"" + sys.argv[0] + "\"")
print("This is the name of the script: \"" + sys.argv[0] + "\"")
if len(sys.argv) != 3:
    print("Especify root directory of benchmark and timestamp type!")
    print("Example: results-fast pmccntr")
    exit(1)

root_csv_folder = sys.argv[1] + "/intsight/csv_results/"

measures_file = root_csv_folder + "name"
timestamps_file = root_csv_folder + sys.argv[2]
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
    if ("checkpoint_1" in result.keys()) & ("checkpoint_2" in result.keys()):
        if (result["checkpoint_1"] != "0") & (result["checkpoint_2"] != "0"):
            response_times.append(int(result["checkpoint_2"]) - int(result["checkpoint_1"]))
            # print("line: " + str(len(response_times)) + " checkpoint_1: " + result["checkpoint_1"] + " checkpoint_2: " +
            #       result[
            #           "checkpoint_2"] + " total time: " + str(response_times[-1]))

print("lines: " + str(len(response_times)))
if len(response_times) != 0:
    print("Average time: " + str(sum(response_times) / len(response_times)))
    print("Minimum time: " + str(min(response_times)))
    print("Maximum time: " + str(max(response_times)))
