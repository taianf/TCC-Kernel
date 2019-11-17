import sys
from datetime import datetime

import pandas as pd

if (len(sys.argv) != 3):
    print("Select name and path for results." + str(len(sys.argv)))
    print("Example: " + sys.argv[0] + " rs1 results/rpi/softirq/1/intsight/csv_results")
    exit()

start = datetime.now()

name_df = pd.read_csv(sys.argv[2] + "/name", dtype=str)
time_df = pd.read_csv(sys.argv[2] + "/ktime_mono_fast", dtype=str)

with open(sys.argv[1] + ".csv", mode="w") as final:
    final.write("position,run,name,ktime_mono_fast\n")
    for x in range(len(name_df.index)):
        for y in range(name_df.iloc[x].size):
            if str(name_df.iloc[x][y]) != "nan" and str(time_df.iloc[x][y]) != "nan":
                final.write(str(y + 1) + "," + str(x + 1) + "," + str(name_df.iloc[x][y]) + "," + str(
                    int(time_df.iloc[x][y])) + "\n")

print("Total time: " + str(datetime.now() - start))
