#!/bin/bash
#
# Copyright (c) Roberto A. Foglietta, 2022
#
# Authors:
#  Roberto A. Foglietta <roberto.foglietta@gmail.com>
#
# SPDX-License-Identifier: MIT
#

test "$1" != "root" && sudo $0 root
test "$1" != "root" && exit 0
echo "Running $0 as $(whoami)"

opt=$(which Xorg | grep Xorg || echo "--nox11")
url="https://raw.githubusercontent.com/denisandroid/uPD72020x-Firmware/master/UPDATE.mem"
fwf="/lib/firmware/renesas_usb_fw.mem"
test -e $fwf || wget -O $fwf $url

mkdir -p /mnt/cdrom
mkdir -p /tmp/vboxguest
mount /dev/sr0 /mnt/cdrom
cd /mnt/cdrom
echo "opt: $opt"
./VBoxLinuxAdditions.run $opt #--keep --target /tmp/vboxguest
usermod -aG vboxsf debraf
cd - >/dev/null
umount /mnt/cdrom
echo
echo "WARNING: you need to sudo reboot the system"
echo
