#!/bin/sh

thepwd="$PWD"

#https://wiki.postmarketos.org/wiki/Installing_pmbootstrap
#sudo apt-get install git python3 python3-setuptools
#git clone https://gitlab.com/postmarketOS/pmbootstrap.git
#cd pmbootstrap
#sudo python3 setup.py install
#cd ..

sudo apt-get update
sudo apt-get install pmbootstrap qemu-user-static heimdall-flash

pmbootstrap init
pmbootstrap install --add firmware-samsung-midas,msm-modem,msm-firmware-loader,soc-samsung-exynos4412,linux-postmarketos-exynos4,rmtfs

##patch msm-firmware-loader.sh in the source tree

cd workdir/chroot_rootfs_samsung-m3/usr/sbin

sudo patch -p0 < "$thepwd/msm-firmware-loader_add_radio_partition.patch"

cd $thepwd

##also patch msm-firmware-loader.sh in the image

mkdir mountpoint

sudo losetup -P /dev/loop5 workdir/chroot_native/home/pmos/rootfs/samsung-m3.img

sudo mount /dev/loop5p2 mountpoint

cd mountpoint/usr/sbin

sudo patch -p0 < "$thepwd/msm-firmware-loader_add_radio_partition.patch"

cd $thepwd

sudo umount mountpoint

sudo losetup -d /dev/loop5
