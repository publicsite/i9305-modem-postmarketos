#!/bin/sh

OLD_UMASK="$(umask)"
umask 0022

thepwd="$PWD"

sudo apt-get update

if [ ! -f "/usr/local/bin/pmbootstrap" ] && [ ! -f "/usr/bin/pmbootstrap" ]; then
	##https://wiki.postmarketos.org/wiki/Installing_pmbootstrap
	sudo apt-get install git python3 python3-setuptools
	git clone https://gitlab.com/postmarketOS/pmbootstrap.git
	cd pmbootstrap
	sudo python3 setup.py install
	cd ..
fi

sudo apt-get install qemu-user-static heimdall-flash

pmbootstrap init

###compile newer version of libgpiod

##cp -a aports/libgpiod workdir/cache_git/pmaports/main/

##pmbootstrap checksum libgpiod

##pmbootstrap build --arch=armv7 libgpiod --force

##compile msm9k-external_modem-boot

cp -a aports/mdm9k-external_modem-boot workdir/cache_git/pmaports/modem/

pmbootstrap checksum mdm9k-external_modem-boot

pmbootstrap build --arch=armv7 mdm9k-external_modem-boot --force

#install

pmbootstrap install --add firmware-samsung-midas,msm-modem,msm-firmware-loader,soc-samsung-exynos4412,linux-postmarketos-exynos4,rmtfs,libgpiod,mdm9k-external_modem-boot,libgpiod

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

umask "${OLD_UMASK}"
