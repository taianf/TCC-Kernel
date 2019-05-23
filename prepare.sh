#!/bin/bash

# cloning repos
git clone https://github.com/raspberrypi/tools.git
git clone --recursive https://gitlab.cs.fau.de/i4/intspect.git

# preparing intspect/intsight
sed -i -e 's/(0x60+26)/(23)/' ./intspect/intsight/arch/arm/intsight/trigger.c
sed -i -e 's/(0x60+27)/(24)/' ./intspect/intsight/arch/arm/intsight/trigger.c
# sed -i -e 's/default n/default y/' ./intspect/intsight/arch/arm/intsight/Kconfig
# sed -i -e 's/config INTSIGHT_TIMESTAMP_TYPE_PMCCNTR\n	depends on INTSIGHT && ARM/INTSIGHT_TIMESTAMP_TYPE_PMCCNTR\n	default y\n	depends on INTSIGHT && ARM/' ./intspect/intsight/arch/arm/intsight/Kconfig
