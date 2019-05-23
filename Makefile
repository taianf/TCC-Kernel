build:
	echo "Choose what to make rpi, prt, xen, all"
prepare:
	./prepare.sh > prepare.log 2>&1
rpi: prepare
	cd rpi && ./build-rpi.sh > ../rpi.log 2>&1
prt: prepare
	cd prt && ./build-prt.sh > ../prt.log 2>&1
xen: prepare
	cd xen && ./build-xen.sh > ../xen.log 2>&1
all: rpi prt xen
