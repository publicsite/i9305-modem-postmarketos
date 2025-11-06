#!/bin/sh
OLD_UMASK="$(umask)"
umask 0022

sudo heimdall flash --BOOT "$(find workdir -maxdepth 1 -name "chroot_rootfs_*")/boot/boot.img"

umask "${OLD_UMASK}"
