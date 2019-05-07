#!/bin/bash

# where the compiled kernel will be
mkdir ~/TCC/kernel/prt-kernel

# cloning repos
git clone --recursive https://gitlab.cs.fau.de/i4/intspect.git
git clone https://github.com/raspberrypi/linux.git
git clone https://github.com/raspberrypi/tools.git

export ARCH=arm
export CROSS_COMPILE=~/TCC/kernel/tools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian-x64/bin/arm-linux-gnueabihf-
export INSTALL_MOD_PATH=~/TCC/kernel/prt-kernel
export INSTALL_DTBS_PATH=~/TCC/kernel/prt-kernel
export KERNEL=kernel7-prt

# Changing branch
cd ~/TCC/kernel/linux
git checkout -f rpi-4.14.y-rt
rm -rf .intsight

# injecting intspect/intsight
cd ~/TCC/kernel/intspect/intsight
./inject.sh ~/TCC/kernel/linux/
sed -i -e 's/default n/default y/' ~/TCC/kernel/linux/arch/arm/intsight/Kconfig

# build
cd ~/TCC/kernel/linux
make bcm2709_defconfig
# make menuconfig
# cp ../config-files/.config-prt .config
make -j$(nproc) zImage modules dtbs
make -j$(nproc) modules_install 
make -j$(nproc) dtbs_install
mkdir $INSTALL_MOD_PATH/boot
./scripts/mkknlimg ./arch/arm/boot/zImage $INSTALL_MOD_PATH/boot/$KERNEL.img
cd $INSTALL_MOD_PATH
tar czf ../prt-kernel.tgz *
