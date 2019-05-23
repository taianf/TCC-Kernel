#!/bin/bash

# where the compiled kernel will be
mkdir prt-kernel

# cloning repos
git clone https://github.com/raspberrypi/linux.git -b rpi-4.14.y-rt

export ARCH=arm
export CROSS_COMPILE=../../tools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian-x64/bin/arm-linux-gnueabihf-
export INSTALL_MOD_PATH=../prt-kernel
export INSTALL_DTBS_PATH=../prt-kernel
export KERNEL=kernel7-prt

# injecting intspect/intsight
cd ../intspect/intsight
./inject.sh ../../prt/linux/

# build
cd ../../prt/linux/
# make bcm2709_defconfig
# make menuconfig
cp ../.config-prt .config
make -j$(nproc) zImage modules dtbs
make -j$(nproc) modules_install 
make -j$(nproc) dtbs_install
mkdir $INSTALL_MOD_PATH/boot
./scripts/mkknlimg ./arch/arm/boot/zImage $INSTALL_MOD_PATH/boot/$KERNEL.img
cd $INSTALL_MOD_PATH
tar czf ../prt-kernel.tgz *
