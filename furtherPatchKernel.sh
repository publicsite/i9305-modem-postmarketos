#!/bin/sh
putInConfig(){
if [ "${3}" = "" ]; then 
	theresult="=y"
else
	theresult="${3}"
fi
	if [ "$(grep "^${1}=n" ${2})" != "" ]; then
		sed -i "s/${1}=n/${1}${theresult}/g" ${2}
	elif [ "$(grep "^# ${1} is not set" ${2})" != "" ]; then
		sed -i "s/# ${1} is not set/${1}${theresult}/g" "${2}"
	elif [ "$(grep "^${1}=m" ${2})" != "" ]; then
		sed -i "s/${1}=m/${1}${theresult}/g" "${2}"
	elif [ "$(grep "^${1}${theresult}" ${2})" = "" ]; then
		echo "${1}${theresult}" >> "${2}"
	fi
}

takeFromConfig(){
	if [ "${3}" = "" ]; then 
		theresult="=n"
		if [ "$(grep "^${1}=y" ${2})" != "" ]; then
			sed -i "s/${1}=y/${1}${theresult}/g" ${2}
		elif [ "$(grep "^# ${1} is not set" ${2})" != "" ]; then
			sed -i "s/# ${1} is not set/${1}${theresult}/g" "${2}"
		elif [ "$(grep "^${1}=m" ${2})" != "" ]; then
			sed -i "s/${1}=m/${1}${theresult}/g" "${2}"
		elif [ "$(grep "^${1}=n" ${2})" = "" ]; then
			echo "${1}=n" >> "${2}"
		fi
	elif [ "${3}" = " is not set" ]; then
		theresult=" is not set"
		if [ "$(grep "^${1}=y" ${2})" != "" ]; then
			sed -i "s/${1}=y/# ${1}${theresult}/g" ${2}
		elif [ "$(grep "^${1}=n" ${2})" != "" ]; then
			sed -i "s/${1}=n/# ${1}${theresult}/g" "${2}"
		elif [ "$(grep "^${1}=m" ${2})" != "" ]; then
			sed -i "s/${1}=m/# ${1}${theresult}/g" "${2}"
		elif [ "$(grep "^${1}=n" ${2})" = "" ]; then
			echo "# ${1}${theresult}" >> "${2}"
		fi
	fi
}

thepwd="$PWD"

anarch="$2"

linuxdir="$(find "$thepwd/kernelArchives" -maxdepth 2 -mindepth 2 -type d -name "linux-*")"

cd "${linuxdir}"

cp -a $thepwd/postmarketConfigs/${1}/config-$(echo ${1} | cut -d - -f 2-3).* arch/${anarch}/configs/

thedefconfig="$(basename $(find arch/${anarch}/configs -name "config-$(echo ${1} | cut -d - -f 2-3).*"))"

#Add the following to the defconfig [from Joey Hewitt's OG patch]
putInConfig "CONFIG_USB_NET_QMI_WWAN" "arch/$anarch/configs/${thedefconfig}"
putInConfig "CONFIG_USB_SERIAL" "arch/$anarch/configs/${thedefconfig}"
putInConfig "CONFIG_USB_SERIAL_QUALCOMM" "arch/$anarch/configs/${thedefconfig}"
putInConfig "CONFIG_USB_WDM" "arch/$anarch/configs/${thedefconfig}"
putInConfig "CONFIG_QC_MODEM" "arch/$anarch/configs/${thedefconfig}"
putInConfig "CONFIG_QC_MODEM_M3" "arch/$anarch/configs/${thedefconfig}"

			#make kernel smaller by merging with tinylinux config https://elinux.org/Kernel_Size_Tuning_Guide

			putInConfig "CONFIG_CORE_SMALL" "arch/$anarch/configs/${thedefconfig}"
			putInConfig "CONFIG_NET_SMALL" "arch/$anarch/configs/${thedefconfig}"
			putInConfig "CONFIG_KMALLOC_ACCOUNTING" "arch/$anarch/configs/${thedefconfig}"
			putInConfig "CONFIG_AUDIT_BOOTMEM" "arch/$anarch/configs/${thedefconfig}"
			putInConfig "CONFIG_DEPRECATE_INLINES" "arch/$anarch/configs/${thedefconfig}"
			takeFromConfig "CONFIG_PRINTK" "arch/$anarch/configs/${thedefconfig}"
			takeFromConfig "CONFIG_BUG" "arch/$anarch/configs/${thedefconfig}"
			takeFromConfig "CONFIG_ELF_CORE" "arch/$anarch/configs/${thedefconfig}"
			takeFromConfig "CONFIG_PROC_KCORE" "arch/$anarch/configs/${thedefconfig}"
			takeFromConfig "CONFIG_AIO" "arch/$anarch/configs/${thedefconfig}"
			takeFromConfig "CONFIG_XATTR" "arch/$anarch/configs/${thedefconfig}"
			takeFromConfig "CONFIG_FILE_LOCKING" "arch/$anarch/configs/${thedefconfig}"
			takeFromConfig "CONFIG_DIRECTIO" "arch/$anarch/configs/${thedefconfig}"

			takeFromConfig "CONFIG_KALLSYMS" "arch/$anarch/configs/${thedefconfig}"
			takeFromConfig "CONFIG_SHMEM" "arch/$anarch/configs/${thedefconfig}"
			takeFromConfig "CONFIG_SYSV_IPC" "arch/$anarch/configs/${thedefconfig}"
			takeFromConfig "CONFIG_POSIX_MQUEUE" "arch/$anarch/configs/${thedefconfig}"
			takeFromConfig "CONFIG_SYSCTL" "arch/$anarch/configs/${thedefconfig}"

			putInConfig "CONFIG_CC_OPTIMIZE_FOR_SIZE" "arch/$anarch/configs/${thedefconfig}"
			putInConfig "CONFIG_IOSCHED_AS" "arch/$anarch/configs/${thedefconfig}"
			takeFromConfig "CONFIG_IOSCHED_CFQ" "arch/$anarch/configs/${thedefconfig}"
			takeFromConfig "CONFIG_IDE" "arch/$anarch/configs/${thedefconfig}"
			takeFromConfig "CONFIG_SCSI" "arch/$anarch/configs/${thedefconfig}"

			putInConfig "CONFIG_OPTIMIZE_INLINING" "arch/$anarch/configs/${thedefconfig}"
			putInConfig "CONFIG_SLOB" "arch/$anarch/configs/${thedefconfig}"
			takeFromConfig "CONFIG_SLAB" "arch/$anarch/configs/${thedefconfig}"
			takeFromConfig "CONFIG_SLUB" "arch/$anarch/configs/${thedefconfig}"

			#use XZ compression to make image even smaller
			takeFromConfig "CONFIG_INITRAMFS_COMPRESSION_GZIP" "arch/$anarch/configs/${thedefconfig}"
			takeFromConfig "CONFIG_INITRAMFS_COMPRESSION_BZIP2" "arch/$anarch/configs/${thedefconfig}"
			takeFromConfig "CONFIG_INITRAMFS_COMPRESSION_LZO" "arch/$anarch/configs/${thedefconfig}"
			takeFromConfig "CONFIG_INITRAMFS_COMPRESSION_LZ4" "arch/$anarch/configs/${thedefconfig}"
			takeFromConfig "CONFIG_INITRAMFS_COMPRESSION_ZSTD" "arch/$anarch/configs/${thedefconfig}"
			takeFromConfig "CONFIG_INITRAMFS_COMPRESSION_NONE" "arch/$anarch/configs/${thedefconfig}"
			putInConfig "CONFIG_INITRAMFS_COMPRESSION_XZ" "arch/$anarch/configs/${thedefconfig}"

			takeFromConfig "CONFIG_KERNEL_GZIP" "arch/$anarch/configs/${thedefconfig}"
			takeFromConfig "CONFIG_KERNEL_LZMA" "arch/$anarch/configs/${thedefconfig}"
			takeFromConfig "CONFIG_KERNEL_LZO" "arch/$anarch/configs/${thedefconfig}"
			takeFromConfig "CONFIG_KERNEL_LZ4" "arch/$anarch/configs/${thedefconfig}"
			putInConfig "CONFIG_KERNEL_XZ" "arch/$anarch/configs/${thedefconfig}"

#Configs by J05HYYY, copy our modem configs that we made from the legacy smdk4412 kernel
	cp -a ${thepwd}/mainline-patches/modem_configs/* "arch/${anarch}/boot/dts/samsung"

#Patch by J05HYYY. Patch the i9305 dts so it enables the modem
	patch -p1 < $thepwd/mainline-patches/exynos4412-i9305_ADD_MODEM.patch

#Patch by Jack K https://redmine.replicant.us/issues/2206
	patch -p1 < $thepwd/mainline-patches/midas_qcserial.patch

#This patch is required before the next patch
	#Patch by Simon Shields https://git.replicant.us/contrib/GNUtoo/replicant/kernel_replicant_linux/commit/?h=replicant-11-i9300-modem&id=303dfaeafda11653ece08dc12dbb2a621e48f5e6
		patch -p1 < $thepwd/mainline-patches/HACK_usb_host_ehci-exynos_add_ehci_power_sysfs_node.patch
#This patch is required before the next patch
	#Patch by Dennis 'GNUtoo' Carikli https://git.replicant.us/contrib/GNUtoo/replicant/kernel_replicant_linux/commit/?h=replicant-11-i9300-modem&id=febffa9b2c022300d29f9e6b41b59739db4ca81a
		patch -p1 < $thepwd/mainline-patches/Huge_hack_to_keep_the_usb_link_on_during_HSIC_re-enumeration.patch
	#Patch based on patch by Simon Shields https://git.replicant.us/contrib/GNUtoo/replicant/kernel_replicant_linux/commit/drivers/usb/host/ehci-exynos.c?h=replicant-11-i9300-modem&id=bfbf6ae8c4f9de2e7d5a4155c9593e8aa43201da
		patch -p1 < $thepwd/mainline-patches/HACK_usb_ehci_exynos_enable_ohci_susp_legacy.patch

#Patch by Simon Shields https://git.replicant.us/contrib/GNUtoo/replicant/kernel_replicant_linux/commit/?h=replicant-11-i9300-modem&id=01d549d4dc045861140e3afc7f6a60dfe2213cc8
	patch -p1 < $thepwd/mainline-patches/ARM_dts_EXYNOS_enable_HSIC0_on_midas_boards.patch

#Patches based off of patch by Simon Shields https://git.replicant.us/contrib/GNUtoo/replicant/kernel_replicant_linux/commit/?h=replicant-11-i9300-modem&id=744431a049d0c021553da192c134fabd78d93b8e
	patch -p1 < $thepwd/mainline-patches/net_usb_add_Samsung_IPC-over-HSIC_driver_1of2.patch
	patch -p1 < $thepwd/mainline-patches/net_usb_add_Samsung_IPC-over-HSIC_driver_2of2.patch

#===wwan patches===

#author	Wolfgang Wiedmeyer, committer	Joey Hewitt, https://git.replicant.us/contrib/scintill/kernel_samsung_smdk4412/commit/?h=replicant-6.0&id=1d4e4dd443678632b1462ae68f63e4749611d549
	patch -p1 < "${thepwd}/mainline-patches/drivers-Backport_cdc-wdm_and_new_qmi_wwan.patch"

#patch by J05HYYY, include m3 modem in Kconfig
	patch -p1 < "${thepwd}/mainline-patches/include-m3-modem-in-Kconfig.patch"