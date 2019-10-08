# How to build

## Pre-req

First check if you have the packages libncurses-dev and coccinelle installed.
On apt-get distro:
```
apt-get install libncurses-dev coccinelle
```

## Building

Use ```make``` comando following the kernel type to build.
Examples:
- ```make prt```
- ```make all```

You can clean all workspace with:

- ```make clean```

Typing ```make``` without any parameters will make all the options be printed into terminal.

## Configs

There's a pre-configured .config file inside each folder but you can run make menuconfig to manually set any config, just remember to modify the sh build file inside the corresponding folder.
The prepare.sh script sets the raspberry pins to use in the measures.

## Installing the compiled kernel

To install the compiled kernel into the raspberry copy the generated .tgz into the raspberry then run the following commands:

```
tar xzf <VER>-kernel.tgz
cd boot
sudo cp -rd * /boot/
cd ../lib
sudo cp -dr * /lib/
cd ../overlays
sudo cp -d * /boot/overlays
cd ..
sudo cp -d bcm* /boot/
```

To boot the newly installed kernel edit the file /boot/config.txt with the following entry:

```
kernel=kernel7-<VER>.img
```

## Important configs:

Important to configs to look when using make menuconfig. Some configs may or may not be available depending on the patch.

- Enable HIGH_RES_TIMERS: General setup → Timers subsystem → High Resolution Timer Support
- Set Performance CPU Frequency scaling: CPU Power Management → CPU Frequency scaling → CPU Frequency scaling
- Disable KGDB: kernel debugger: KGDB: kernel debugger → Kernel Hacking
- Set CONFIG_HZ to 1000Hz: Kernel Features → Timer frequency = 1000 Hz
- Disable Allow for memory compaction: Kernel Features → Contiguous Memory Allocator
- Disable Contiguous Memory Allocator: Kernel Features → Allow for memory compaction
- Enable CONFIG_PREEMPT_RT_FULL: Kernel Features → Preemption Model (Fully Preemptible Kernel (RT)) → Fully Preemptible Kernel (RT)

This guide is based on https://lemariva.com/blog/2018/07/raspberry-pi-preempt-rt-patching-tutorial-for-kernel-4-14-y