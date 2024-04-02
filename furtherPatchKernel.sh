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

##takeFromConfig "CONFIG_DEVKMEM" "arch/$anarch/configs/${thedefconfig}"

