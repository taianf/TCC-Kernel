#!/bin/bash

# where the compiled kernel will be
mkdir ~/TCC-Kernel/xen-kernel

# cloning repos
git clone https://github.com/raspberrypi/linux.git
git clone https://github.com/raspberrypi/tools.git

export ARCH=arm
export CROSS_COMPILE=~/TCC-Kernel/tools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian-x64/bin/arm-linux-gnueabihf-
export INSTALL_MOD_PATH=~/TCC-Kernel/xen-kernel
export INSTALL_DTBS_PATH=~/TCC-Kernel/xen-kernel
export KERNEL=kernel7-xen

# Getting Xenomai files
wget -O ipipe-core-4.9.51-arm-4-for-4.9.80.patch https://raw.githubusercontent.com/thanhtam-h/rpi23-4.9.80-xeno3/master/scripts/ipipe-core-4.9.51-arm-4-for-4.9.80.patch
wget -O xenomai-3.0.7.tar.bz2 https://xenomai.org/downloads/xenomai/stable/xenomai-3.0.7.tar.bz2
tar xjf xenomai-3.0.7.tar.bz2
sed -i -e 's/ln -sf/cp/' ~/TCC-Kernel/xenomai-3.0.7/scripts/prepare-kernel.sh

# Changing branch
cd ~/TCC-Kernel/linux
git checkout -f rpi-4.9.y
rm -rf .intsight

# Patching with Xenomai
cd ~/TCC-Kernel
xenomai-3.0.7/scripts/prepare-kernel.sh --linux=linux/ --arch=arm --ipipe=ipipe-core-4.9.51-arm-4-for-4.9.80.patch --verbose

# injecting intspect/intsight
cd ~/TCC-Kernel/intspect/intsight
./inject.sh ~/TCC-Kernel/linux/

# build
cd ~/TCC-Kernel/linux
make bcm2709_defconfig
# make menuconfig
cp ../config-files/.config-xen .config
make -j$(nproc) zImage modules dtbs
make -j$(nproc) modules_install 
make -j$(nproc) dtbs_install
mkdir $INSTALL_MOD_PATH/boot
./scripts/mkknlimg ./arch/arm/boot/zImage $INSTALL_MOD_PATH/boot/$KERNEL.img
cd $INSTALL_MOD_PATH
tar czf ../xen-kernel.tgz *
