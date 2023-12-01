==INTRO==

This code builds a custom kernel based off of postmarketos mainline using some of the patches found here: https://redmine.replicant.us/issues/2206

It then creates an image of the kernel and flashes it to a pmos install.

I can confirm that using these patches, the modem appears using lsusb and dmesg. I, however, was unable to see the modem when attempting to list the modems
using network manager and ofono. Perhaps the modem needs boot code?

The patches for mainline are in the directory "mainline-patches". Some of them have to be applied in a particular order (you can see how in furtherPatchKernel.sh).

There is one additional patch (to add the "RADIO" partition to msm-firmware-loader) in the root of the tree.

There is an example boot.img binary image in the tree for you to flash with a postmarketos installation if you desire.

Below are the (general) steps to take to reproduce the work.

The scripts are licenced under GPLv3 and copyright J05HYYY fwiw. Cheers.

==BUILDING PMOS==

make a dir called workdir

	mkdir workdir

run get_pmbootstrap.sh

	./get_pmbootstrap.sh

set workdir as the directory when asked

select edge when asked

choose samsung as the vendor when asked

type
	m3
as the codename when asked

choose if you want non-free wifi and bluetooth

type user name

choose phosh

don't change additional options

change extra packages to:

	firmware-samsung-midas,msm-modem,msm-firmware-loader,soc-samsung-exynos4412,linux-postmarketos-exynos4,rmtfs

choose timezone

set locale as en_GB.UTF-8

set device host name

do not build outdated packages

==INSTALLING PMOS==

insert sdcard

	pmbootstrap install --sdcard=/dev/sdX

put the sdcard in the device, then plug in the phone using a usb cable, put it into heimdall mode and run...

	pmbootstrap flasher flash_kernel

	pmbootstrap shutdown

==BUILDING THE KERNEL==

run
	sudo apt-get install gcc-arm-none-eabi libssl-dev
to install dependencies for building kernel

run
	./getPostmarketConfigs.sh
to get postmarket kernel configs

run
	./processKernel.sh "linux-postmarketos-exynos4" "arm"
to download and initially process the exynos4 kernel by applying postmarket patches

run
	./furtherPatchKernel.sh "linux-postmarketos-exynos4" "arm"
to further patch the kernel for modem by running, note, this contains the nitty gritty

run
	./buildKernel.sh "linux-postmarketos-exynos4" "arm"
to build the kernel

==INSTALLING THE KERNEL==

get heimdall to flash our custom kernel

	sudo apt-get install heimdall

finally flash our custom kernel

	./flash_kernel.sh