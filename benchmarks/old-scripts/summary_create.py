import csv

files = [
    "ps0",
    "ps1",
    "psm",
    "pt0",
    "pt1",
    "ptm",
    "pw0",
    "pw1",
    "pwm",
    "rs0",
    "rs1",
    "rsm",
    "rt0",
    "rt1",
    "rtm",
    "rw0",
    "rw1",
    "rwm"
]

types = [
    "softirq",
    "tasklet",
    "work"
]

with open("summary.csv", 'w') as summary_csv:
    summary_csv.write("type;run;latency\n")

    for file in files:
        print(file)
        with open(file + ".csv", 'r') as measures_csv:
            measures_reader = csv.reader(measures_csv, delimiter=',')
            measures = list(measures_reader)
            irq = "0"
            for measure in measures:
                run = measure[1]
                name = measure[2]
                time = measure[3]
                if measure[0] == "1":
                    irq = "0"
                if name == "irq" and time != "0":
                    irq = int(time)
                elif measure[3] != "0" and irq != "0" and measure[2] in types:
                    end = int(time)
                    latency = end - irq
                    summary_csv.write(file + ";" + str(run.zfill(5)) + ";" + str(latency) + "\n")
