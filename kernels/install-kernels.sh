#!/bin/bash

#tar xzf rpi-kernel.tgz
#tar xzf prt-kernel.tgz
tar xzf xen-kernel-custom-100.tgz
cd boot
sudo cp -rd * /boot/
cd ../lib
sudo cp -dr * /lib/
cd ../overlays
sudo cp -d * /boot/overlays
cd ..
sudo cp -d bcm* /boot/
