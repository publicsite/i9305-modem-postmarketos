#!/bin/sh

OLD_UMASK="$(umask)"
umask 0022

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

cd "${thepwd}/mainline-patches-2/tocopy/linux"


#a continuation (deal with gpio to turn modem on) ...

cd "${thepwd}/mainline-patches-2/tocopy/linux"

#copy the unmodified files we selected from the smdk4412 kernel into our vanilla kernel

find . -type f | while read afile; do
	afile="$(echo "${afile}" | cut -c 3-)"
	if ! [ -f "${linuxdir}/${afile}" ]; then
		thedir="$(dirname "${linuxdir}/${afile}")"
		if ! [ -d "${thedir}" ]; then
			echo "Making directory ${thedir} ..." 
			mkdir -p "${thedir}"
		fi
		echo "Copying ${afile} ..."
		cp -a "./${afile}" "${linuxdir}/${afile}"
	else
		echo "${afile} already exists, so not copying."
	fi
done

echo

#copy the Makefile we modified from the smdk4412 kernel into our vanilla kernel

mkdir -p "${linuxdir}/arch/arm/plat-samsung"

if [ ! -f "${linuxdir}/arch/arm/plat-samsung/Makefile" ]; then
	echo "Copying Makefile arch/arm/plat-samsung/Makefile ..."
	cp -a "${thepwd}/mainline-patches-2/patches/linux/arch/arm/plat-samsung/Makefile" "${linuxdir}/arch/arm/plat-samsung/Makefile"
else
	echo "Makefile arch/arm/plat-samsung/Makefile already exists, so not copying."
fi


if [ ! -f "${linuxdir}/arch/arm/plat-samsung/Kconfig" ]; then
	echo "Copying Makefile arch/arm/plat-samsung/Kconfig ..."
	cp -a "${thepwd}/mainline-patches-2/patches/linux/arch/arm/plat-samsung/Kconfig" "${linuxdir}/arch/arm/plat-samsung/Kconfig"
else
	echo "Makefile arch/arm/plat-samsung/Kconfig already exists, so not copying."
fi

#patch mach-exynos to include modem
mkdir -p "${linuxdir}/include/asm-generic/"
cd "${linuxdir}/include"
ln -s asm-generic asm
cd "${linuxdir}"
patch -p1 < "${thepwd}/mainline-patches-2/patches/linux/arch/arm/mach-exynos/Makefile.patch"
patch -p1 < "${thepwd}/mainline-patches-2/patches/linux/arch/arm/mach-exynos/Kconfig.patch"
patch -p1 < "${thepwd}/mainline-patches-2/patches/linux/arch/arm/Kconfig.patch"
patch -p1 < "${thepwd}/mainline-patches-2/patches/linux/arch/arm/Makefile.patch"
patch -p1 < "${thepwd}/mainline-patches-2/patches/linux/arch/arm/tools/Makefile.patch"
patch -p1 < "${thepwd}/mainline-patches-2/patches/linux/include/linux/completion.h.patch"
patch -p1 < "${thepwd}/mainline-patches-2/patches/linux/arch/arm/include/asm/thread_info.h.patch"
patch -p1 < "${thepwd}/mainline-patches-2/patches/linux/include/asm-generic/uaccess.h.patch"
patch -p1 < "${thepwd}/mainline-patches-2/patches/linux/include/linux/kernel.h.patch"
patch -p1 < "${thepwd}/mainline-patches-2/patches/linux/arch/arm/include/asm/uaccess.h.patch"
patch -p1 < "${thepwd}/mainline-patches-2/patches/linux/arch/arm/include/asm/domain.h.patch"
patch -p1 < "${thepwd}/mainline-patches-2/patches/linux/include/linux/time.h.patch"
patch -p1 < "${thepwd}/mainline-patches-2/patches/linux/include/linux/interrupt.h.patch"
patch -p1 < "${thepwd}/mainline-patches-2/patches/linux/include/linux/pm_runtime.h.patch"
patch -p1 < "${thepwd}/mainline-patches-2/patches/linux/drivers/Kconfig.patch"
patch -p1 < "${thepwd}/mainline-patches-2/patches/linux/drivers/Makefile.patch"
patch -p1 < "${thepwd}/mainline-patches-2/patches/linux/drivers/char/Makefile.patch"
patch -p1 < "${thepwd}/mainline-patches-2/patches/linux/drivers/char/Kconfig.patch"
cp -a "${thepwd}/mainline-patches-2/patches/linux/include/linux/mdm_hsic_pm.h" "${linuxdir}/include/linux/"
cp -a "${thepwd}/mainline-patches-2/patches/linux/include/asm-generic/gpio.h" "${linuxdir}/include/asm-generic/"
cp -a "${thepwd}/mainline-patches-2/patches/linux/arch/arm/mach-exynos/Kconfig.local" "${linuxdir}/arch/arm/mach-exynos/"
cp -a "${thepwd}/mainline-patches-2/patches/linux/arch/arm/mach-exynos/mdm_common.c" "${linuxdir}/arch/arm/mach-exynos/"

cp -a "${thepwd}/mainline-patches-2/patches/linux/arch/arm/plat-samsung/Kconfig" "${linuxdir}/arch/arm/plat-samsung/"
cp -a "${thepwd}/mainline-patches-2/patches/linux/arch/arm/plat-s5p/Kconfig" "${linuxdir}/arch/arm/plat-s5p/"
cp -a "${thepwd}/mainline-patches-2/patches/linux/drivers/char/diag/Makefile" "${linuxdir}/drivers/char/diag/"

#add the modem to linux config

cd "${linuxdir}"

thedefconfig="$(basename $(find arch/${anarch}/configs -name "config-$(echo ${1} | cut -d - -f 2-3).*"))"

putInConfig "CONFIG_QC_MODEM" "arch/$anarch/configs/${thedefconfig}"
putInConfig "CONFIG_MSM_SUBSYSTEM_RESTART" "arch/$anarch/configs/${thedefconfig}"
putInConfig "CONFIG_QC_MODEM_MDM9X15" "arch/$anarch/configs/${thedefconfig}"
putInConfig "CONFIG_MDM_HSIC_PM" "arch/$anarch/configs/${thedefconfig}"
putInConfig "CONFIG_QC_MODEM_M3" "arch/$anarch/configs/${thedefconfig}"
putInConfig "CONFIG_USB_CDFS_SUPPORT" "arch/$anarch/configs/${thedefconfig}"
putInConfig "CONFIG_SAMSUNG_PRODUCT_SHIP" "arch/$anarch/configs/${thedefconfig}"

putInConfig "CONFIG_PLAT_SAMSUNG" "arch/$anarch/configs/${thedefconfig}"
putInConfig "CONFIG_DIAG_HSIC_PIPE" "arch/$anarch/configs/${thedefconfig}"
putInConfig "CONFIG_USB_S5P_HSIC0" "arch/$anarch/configs/${thedefconfig}"
putInConfig "CONFIG_USB_S5P_HSIC1" "arch/$anarch/configs/${thedefconfig}"

putInConfig "CONFIG_PLAT_S5P" "arch/$anarch/configs/${thedefconfig}"

putInConfig "CONFIG_SAMSUNG_PD" "arch/$anarch/configs/${thedefconfig}"
putInConfig "CONFIG_PLAT_S5P" "arch/$anarch/configs/${thedefconfig}"
putInConfig "CONFIG_S5P_GPIO_INT" "arch/$anarch/configs/${thedefconfig}"
putInConfig "CONFIG_S5P_SYSTEM_MMU" "arch/$anarch/configs/${thedefconfig}"
putInConfig "CONFIG_S5P_SYSTEM_MMU_REFCOUNT" "arch/$anarch/configs/${thedefconfig}"
putInConfig "CONFIG_S5P_DEV_MFC" "arch/$anarch/configs/${thedefconfig}"
putInConfig "CONFIG_S5P_DEV_TVOUT" "arch/$anarch/configs/${thedefconfig}"
putInConfig "CONFIG_S5P_DEV_FIMG2D" "arch/$anarch/configs/${thedefconfig}"
putInConfig "CONFIG_S5P_DEV_CSIS" "arch/$anarch/configs/${thedefconfig}"
putInConfig "CONFIG_S5P_DEV_JPEG" "arch/$anarch/configs/${thedefconfig}"
putInConfig "CONFIG_S5P_DEV_USB_EHCI" "arch/$anarch/configs/${thedefconfig}"
putInConfig "CONFIG_S5P_DEV_FIMD_S5P" "arch/$anarch/configs/${thedefconfig}"
putInConfig "CONFIG_S5P_DEV_USBGADGET" "arch/$anarch/configs/${thedefconfig}"
putInConfig "CONFIG_S5P_MEM_CMA" "arch/$anarch/configs/${thedefconfig}"
putInConfig "CONFIG_S5P_DEV_MIPI_DSI" "arch/$anarch/configs/${thedefconfig}"

putInConfig "CONFIG_MACH_MIDAS" "arch/$anarch/configs/${thedefconfig}"
putInConfig "CONFIG_MACH_M3" "arch/$anarch/configs/${thedefconfig}"

putInConfig "CONFIG_MIDAS_COMMON_BD" "arch/$anarch/configs/${thedefconfig}"

putInConfig "CONFIG_SAMSUNG_PM" "arch/$anarch/configs/${thedefconfig}"
putInConfig "CONFIG_S5P_PM" "arch/$anarch/configs/${thedefconfig}"

echo CONFIG_S3C_GPIO_SPACE=0 >> "arch/$anarch/configs/${thedefconfig}"

#putInConfig "CONFIG_CPU_V7" "arch/$anarch/configs/${thedefconfig}"
#putInConfig "CONFIG_CPU_32v6K" "arch/$anarch/configs/${thedefconfig}"
#putInConfig "CONFIG_CPU_32v7" "arch/$anarch/configs/${thedefconfig}"
#putInConfig "CONFIG_CPU_ABRT_EV7" "arch/$anarch/configs/${thedefconfig}"
#putInConfig "CONFIG_CPU_PABRT_V7" "arch/$anarch/configs/${thedefconfig}"
#putInConfig "CONFIG_CPU_CACHE_V7" "arch/$anarch/configs/${thedefconfig}"
#putInConfig "CONFIG_CPU_CACHE_VIPT" "arch/$anarch/configs/${thedefconfig}"
#putInConfig "CONFIG_CPU_COPY_V6" "arch/$anarch/configs/${thedefconfig}"
#putInConfig "CONFIG_CPU_TLB_V7" "arch/$anarch/configs/${thedefconfig}"
#putInConfig "CONFIG_CPU_HAS_ASID" "arch/$anarch/configs/${thedefconfig}"
#putInConfig "CONFIG_CPU_CP15" "arch/$anarch/configs/${thedefconfig}"
#putInConfig "CONFIG_CPU_CP15_MMU" "arch/$anarch/configs/${thedefconfig}"

#takeFromConfig "CONFIG_CPU_ARM926T"
#CONFIG_CPU_THUMB_CAPABLE=y
#CONFIG_CPU_32v5=y
#CONFIG_CPU_32v6K=y
#CONFIG_CPU_32v7=y
#CONFIG_CPU_ABRT_EV5TJ=y
#CONFIG_CPU_ABRT_EV7=y
#CONFIG_CPU_PABRT_LEGACY=y
#CONFIG_CPU_PABRT_V7=y
#CONFIG_CPU_CACHE_V7=y
#CONFIG_CPU_CACHE_VIVT=y
#CONFIG_CPU_CACHE_VIPT=y
#CONFIG_CPU_COPY_V4WB=y
#CONFIG_CPU_COPY_V6=y
#CONFIG_CPU_TLB_V4WBI=y
#CONFIG_CPU_TLB_V7=y
#CONFIG_CPU_HAS_ASID=y
#CONFIG_CPU_CP15=y
#CONFIG_CPU_CP15_MMU=y
#CONFIG_CPU_USE_DOMAINS=y

#takeFromConfig "CONFIG_ARCH_MULTI_V7" "arch/$anarch/configs/${thedefconfig}" " is not set"
#takeFromConfig "CONFIG_ARCH_MULTI_V6_V7" "arch/$anarch/configs/${thedefconfig}" " is not set"

umask "${OLD_UMASK}"

