#!/bin/sh

#We download all the kernel configs from postmarketos
#for each, it contains a kernel config, relevant patches and download location of linux archive
#the download location is stored in the APKBUILD

if [ -d postmarketConfigs ]; then
	while true; do
		echo "Would you like to redownload the postmarket kernel configs? [yes/no]"
		read yesno
		if [ "$yesno" = "yes" ]; then
			rm -rf postmarketConfigs
			break
		elif [ "$yesno" = "no" ]; then
			exit 1
		fi
	done
fi

mkdir postmarketConfigs
git clone https://gitlab.com/postmarketOS/pmaports.git
find pmaports/device/testing -maxdepth 1 -type d -name "linux-*" -exec mv {} postmarketConfigs/ \;
find pmaports/device/main -maxdepth 1 -type d -name "linux-*" -exec mv {} postmarketConfigs/ \;
find pmaports/device/community -maxdepth 1 -type d -name "linux-*" -exec mv {} postmarketConfigs/ \;
find pmaports/device/unmaintained -maxdepth 1 -type d -name "linux-*" -exec mv {} postmarketConfigs/ \;
rm -rf pmaports