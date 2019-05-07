build:
	echo "Choose what to make rpi, prt, xen, all or clean"
rpi:
	make clean
	./build-rpi.sh > rpi.log 2>&1
prt:
	make clean
	./build-prt.sh > prt.log 2>&1
xen:
	make clean
	./build-xen.sh > xen.log 2>&1
clean:
	rm -rf intspect/ ipipe-core-*.patch linux/ prt-kernel/ rpi-kernel/ tools/ xen-kernel/ xenomai-3.0.7 xenomai-3.0.7.tar.bz2
all: rpi prt xen
