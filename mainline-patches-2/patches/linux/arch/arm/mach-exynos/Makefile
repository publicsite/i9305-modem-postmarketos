# SPDX-License-Identifier: GPL-2.0
#
# Copyright (c) 2010-2011 Samsung Electronics Co., Ltd.
#		http://www.samsung.com/

obj-$(CONFIG_ARCH_EXYNOS)	+= exynos.o exynos-smc.o firmware.o

obj-$(CONFIG_EXYNOS_CPU_SUSPEND) += pm.o sleep.o
obj-$(CONFIG_PM_SLEEP)		+= suspend.o

obj-$(CONFIG_SMP)		+= platsmp.o headsmp.o

obj-$(CONFIG_EXYNOS_MCPM)	+= mcpm-exynos.o
CFLAGS_mcpm-exynos.o		+= -march=armv7-a

obj-$(CONFIG_SEC_MODEM_GAIA)		+= board-gaia-modems.o
obj-$(CONFIG_SEC_MODEM_M1)		+= board-c1-modems.o
obj-$(CONFIG_SEC_MODEM_C1)		+= board-c1-modems.o
obj-$(CONFIG_SEC_MODEM_C1_LGT)		+= board-c1lgt-modems.o
obj-$(CONFIG_SEC_MODEM_P8LTE)		+= board-p8ltevzw-modems.o

obj-$(CONFIG_QC_MODEM_MDM9X15)	+= mdm2.o mdm_common.o mdm_device.o
obj-$(CONFIG_MSM_SUBSYSTEM_RESTART)	+= subsystem_restart.o
obj-$(CONFIG_MDM_HSIC_PM)		+= mdm_hsic_pm.o
