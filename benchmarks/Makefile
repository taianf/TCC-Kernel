build:
	echo "Use make XYZ with:"
	echo "X as (r)pi or (p)rt"
	echo "Y as (s)oftirq, (t)asklet or (w)orkqueue"
	echo "Z as thread numbers. 0, 1 or many."
	echo "Example make rs0"
	echo "Or make all"
rs0:
	Rscript tidy-chunk-result.R rs0.rds results/rpi/softirq/0/intsight/csv_results
rs1:
	Rscript tidy-chunk-result.R rs1.rds results/rpi/softirq/1/intsight/csv_results
rsm:
	Rscript tidy-chunk-result.R rsm.rds results/rpi/softirq/256/intsight/csv_results
rt0:
	Rscript tidy-chunk-result.R rt0.rds results/rpi/tasklet/0/intsight/csv_results
rt1:
	Rscript tidy-chunk-result.R rt1.rds results/rpi/tasklet/1/intsight/csv_results
rtm:
	Rscript tidy-chunk-result.R rtm.rds results/rpi/tasklet/256/intsight/csv_results
rw0:
	Rscript tidy-chunk-result.R rw0.rds results/rpi/workqueue/0/intsight/csv_results
rw1:
	Rscript tidy-chunk-result.R rw1.rds results/rpi/workqueue/1/intsight/csv_results
rwm:
	Rscript tidy-chunk-result.R rwm.rds results/rpi/workqueue/256/intsight/csv_results
ps0:
	Rscript tidy-chunk-result.R ps0.rds results/prt/softirq/0/intsight/csv_results
ps1:
	Rscript tidy-chunk-result.R ps1.rds results/prt/softirq/1/intsight/csv_results
psm:
	Rscript tidy-chunk-result.R psm.rds results/prt/softirq/256/intsight/csv_results
pt0:
	Rscript tidy-chunk-result.R pt0.rds results/prt/tasklet/0/intsight/csv_results
pt1:
	Rscript tidy-chunk-result.R pt1.rds results/prt/tasklet/1/intsight/csv_results
ptm:
	Rscript tidy-chunk-result.R ptm.rds results/prt/tasklet/256/intsight/csv_results
pw0:
	Rscript tidy-chunk-result.R pw0.rds results/prt/workqueue/0/intsight/csv_results
pw1:
	Rscript tidy-chunk-result.R pw1.rds results/prt/workqueue/1/intsight/csv_results
pwm:
	Rscript tidy-chunk-result.R pwm.rds results/prt/workqueue/256/intsight/csv_results
all: rs0 rs1 rsm rt0 rt1 rtm rw0 rw1 rwm ps0 ps1 psm pt0 pt1 ptm pw0 pw1 pwm