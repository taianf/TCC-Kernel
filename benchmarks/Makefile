build:
	echo "Use make XYZ with:"
	echo "X as (r)pi or (p)rt"
	echo "Y as (s)oftirq, (t)asklet or (w)orkqueue"
	echo "Z as thread numbers. 0, 1 or many."
	echo "Example make rs0"
	echo "Or make all"
rs0:
	python tidy-chunk-result.py rs0 results/rpi/softirq/0/intsight/csv_results
rs1:
	python tidy-chunk-result.py rs1 results/rpi/softirq/1/intsight/csv_results
rsm:
	python tidy-chunk-result.py rsm results/rpi/softirq/256/intsight/csv_results
rt0:
	python tidy-chunk-result.py rt0 results/rpi/tasklet/0/intsight/csv_results
rt1:
	python tidy-chunk-result.py rt1 results/rpi/tasklet/1/intsight/csv_results
rtm:
	python tidy-chunk-result.py rtm results/rpi/tasklet/256/intsight/csv_results
rw0:
	python tidy-chunk-result.py rw0 results/rpi/workqueue/0/intsight/csv_results
rw1:
	python tidy-chunk-result.py rw1 results/rpi/workqueue/1/intsight/csv_results
rwm:
	python tidy-chunk-result.py rwm results/rpi/workqueue/256/intsight/csv_results
ps0:
	python tidy-chunk-result.py ps0 results/prt/softirq/0/intsight/csv_results
ps1:
	python tidy-chunk-result.py ps1 results/prt/softirq/1/intsight/csv_results
psm:
	python tidy-chunk-result.py psm results/prt/softirq/256/intsight/csv_results
pt0:
	python tidy-chunk-result.py pt0 results/prt/tasklet/0/intsight/csv_results
pt1:
	python tidy-chunk-result.py pt1 results/prt/tasklet/1/intsight/csv_results
ptm:
	python tidy-chunk-result.py ptm results/prt/tasklet/256/intsight/csv_results
pw0:
	python tidy-chunk-result.py pw0 results/prt/workqueue/0/intsight/csv_results
pw1:
	python tidy-chunk-result.py pw1 results/prt/workqueue/1/intsight/csv_results
pwm:
	python tidy-chunk-result.py pwm results/prt/workqueue/256/intsight/csv_results
all: rs0 rs1 rsm rt0 rt1 rtm rw0 rw1 rwm ps0 ps1 psm pt0 pt1 ptm pw0 pw1
