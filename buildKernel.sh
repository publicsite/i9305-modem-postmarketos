#!/bin/sh

thepwd="$PWD"

anarch="$2"

oldARCH="${ARCH}"
oldCROSS_COMPILE="${CROSS_COMPILE}"

export ARCH=arm
export CROSS_COMPILE=arm-none-eabi-

cd kernelArchives/linux-*/linux-*

make mrproper

thedefconfig="$(basename $(find arch/${anarch}/configs -name "config-$(echo ${1} | cut -d - -f 2-3).*"))"

mkdir .output
mkdir .output/usr

cd usr
wget "https://mirror.postmarketos.org/postmarketos/v20.05/postmarketos/postmarketos/postmarketos/armv7/busybox-static-armv7-1.31.1-r20.apk" -O busybox-static-armv7-1.31.1-r20.apk
mv busybox-static-armv7-1.31.1-r20.apk busybox-static-armv7-1.31.1-r20.gz
gunzip busybox-static-armv7-1.31.1-r20.gz
mv busybox-static-armv7-1.31.1-r20 busybox-static-armv7-1.31.1-r20.tar
tar -xf busybox-static-armv7-1.31.1-r20.tar
mv usr/*-linux-musleabihf/bin/busybox.static .
rm -f busybox-static-armv7-1.31.1-r20.tar
rm -f .PKGINFO
rm -f .SIGN.*
rm -rf ./usr
cd ..

cp -a $thepwd/postmarketConfigs/${1}/initramfs.list ./usr/
cp -a $thepwd/postmarketConfigs/${1}/init ./usr/

cp -p arch/${anarch}/configs/${thedefconfig} .config

make olddefconfig

make zImage

make exynos4412-i9305.dtb

cat arch/${anarch}/boot/zImage arch/${anarch}/boot/dts/exynos4412-i9305.dtb > ${thepwd}/zImage

export ARCH="${oldARCH}"
export CROSS_COMPILE="${oldCROSS_COMPILE}"

cd "${thepwd}"
sudo abootimg -u "$(find workdir -maxdepth 1 -name "chroot_rootfs_*")/boot/boot.img" -k zImage