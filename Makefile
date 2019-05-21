build:
	echo "Choose what to make rpi, prt, xen, all or clean"
rpi: intspect
	make clean
	./build-rpi.sh > rpi.log 2>&1
prt: intspect
	make clean
	./build-prt.sh > prt.log 2>&1
xen: intspect
	make clean
	./build-xen.sh > xen.log 2>&1
clean:
	rm -rf ipipe-core-*.patch linux/ prt-kernel/ rpi-kernel/ tools/ xen-kernel/ xenomai-3.0.7 xenomai-3.0.7.tar.bz2
intspect:
	./prepare-intspect.sh > rpi.log 2>&1
all: rpi prt xen
