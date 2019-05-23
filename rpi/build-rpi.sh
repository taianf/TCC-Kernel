#!/bin/bash

# where the compiled kernel will be
mkdir rpi-kernel

# cloning repos
git clone https://github.com/raspberrypi/linux.git -b rpi-4.14.y

export ARCH=arm
export CROSS_COMPILE=../tools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian-x64/bin/arm-linux-gnueabihf-
export INSTALL_MOD_PATH=./rpi-kernel
export INSTALL_DTBS_PATH=./rpi-kernel
export KERNEL=kernel7-rpi

# injecting intspect/intsight
../intspect/intsight/inject.sh linux/

# build
cd linux
# make bcm2709_defconfig
# make menuconfig
cp ../.config-rpi .config
make -j$(nproc) zImage modules dtbs
make -j$(nproc) modules_install 
make -j$(nproc) dtbs_install
mkdir $INSTALL_MOD_PATH/boot
./scripts/mkknlimg ./arch/arm/boot/zImage $INSTALL_MOD_PATH/boot/$KERNEL.img
cd $INSTALL_MOD_PATH
tar czf ../rpi-kernel.tgz *
