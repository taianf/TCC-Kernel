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
clean:
	rm -rf prt/linux prt/prt-kernel rpi/linux rpi/rpi-kernel xen/linux xen/xen-kernel xen/xenomai* xen/ipipe* intspect/ tools/
all: rpi prt xen
