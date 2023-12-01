#!/bin/sh
sudo heimdall flash --BOOT "$(find workdir -maxdepth 1 -name "chroot_rootfs_*")/boot/boot.img"
