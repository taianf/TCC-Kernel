#!/bin/bash

# where the compiled kernel will be
mkdir ~/TCC-Kernel/rpi-kernel

# cloning repos
git clone --recursive https://gitlab.cs.fau.de/i4/intspect.git
git clone https://github.com/raspberrypi/linux.git
git clone https://github.com/raspberrypi/tools.git

export ARCH=arm
export CROSS_COMPILE=~/TCC-Kernel/tools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian-x64/bin/arm-linux-gnueabihf-
export INSTALL_MOD_PATH=~/TCC-Kernel/rpi-kernel
export INSTALL_DTBS_PATH=~/TCC-Kernel/rpi-kernel
export KERNEL=kernel7-rpi

# Changing branch
cd ~/TCC-Kernel/linux
git checkout -f rpi-4.14.y
rm -rf .intsight

# injecting intspect/intsight
cd ~/TCC-Kernel/intspect/intsight
./inject.sh ~/TCC-Kernel/linux/
sed -i -e 's/(0x60+26)/(5)/' ~/TCC-Kernel/linux/arch/arm/intsight/trigger.c
sed -i -e 's/(0x60+27)/(6)/' ~/TCC-Kernel/linux/arch/arm/intsight/trigger.c
sed -i -e 's/default n/default y/' ~/TCC-Kernel/linux/arch/arm/intsight/Kconfig

# build
cd ~/TCC-Kernel/linux
make bcm2709_defconfig
# make menuconfig
cp ../config-files/.config-rpi .config
make -j$(nproc) zImage modules dtbs
make -j$(nproc) modules_install 
make -j$(nproc) dtbs_install
mkdir $INSTALL_MOD_PATH/boot
./scripts/mkknlimg ./arch/arm/boot/zImage $INSTALL_MOD_PATH/boot/$KERNEL.img
cd $INSTALL_MOD_PATH
tar czf ../rpi-kernel.tgz *
