#!/bin/bash

# cloning repos
rm -rf intspect
git clone --recursive https://gitlab.cs.fau.de/i4/intspect.git

# injecting intspect/intsight
sed -i -e 's/(0x60+26)/(23)/' ~/TCC-Kernel/intspect/intsight/arch/arm/intsight/trigger.c
sed -i -e 's/(0x60+27)/(24)/' ~/TCC-Kernel/intspect/intsight/arch/arm/intsight/trigger.c
sed -i -e 's/default n/default y/' ~/TCC-Kernel/intspect/intsight/arch/arm/intsight/Kconfig
sed -i -e 's/INTSIGHT_TIMESTAMP_TYPE_PMCCNTR/INTSIGHT_TIMESTAMP_TYPE_PMCCNTR\n	default y/' ~/TCC-Kernel/intspect/intsight/arch/arm/intsight/Kconfig
