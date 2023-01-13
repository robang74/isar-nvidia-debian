#!/bin/bash
#
# Copyright (c) Roberto A. Foglietta, 2023
#
# Authors:
#  Roberto A. Foglietta <roberto.foglietta@gmail.com>
#
# SPDX-License-Identifier: MIT
#
#set -ex

if [ "$(whoami)" != "root" ]; then
    echo
    echo "WARNING: this script should run as root, sudo!"
    sudo -E $0 "$@"
    exit $?
fi

if [ -e "$1" ]; then
    fimg=$(readlink -e $1)
fi

cd $(dirname $0)

if [ ! -n "$1" -a  ! -e "$fimg" ]; then
    fimg=$(ls -1 build/tmp/deploy/images/*/*.wic)
    n=( $fimg )
    if [ ${#n[@]} -gt 1 ]; then
        echo
        echo "WARNING: more than one image found, choose one:"
        echo
        echo "$fimg"
        echo
        exit 1
    fi
fi

if [ ! -e "$fimg" ]; then
    echo
    echo "ERROR: no any image or block device ${1:+'$1' }found, abort!"
    echo
    exit 1
fi

wicf=$fimg
losetup -Pf $wicf
ldev=$(losetup -j $wicf | cut -d: -f1 | tail -n1)
echo loopdev:$ldev
dd if=${ldev}p2 bs=1M of=${wicf/.wic/.rootfs} status=progress
chown $(id -u).$(id -g) ${wicf/.wic/.rootfs}
du -ms ${wicf/.wic/.rootfs}
losetup -d $ldev
