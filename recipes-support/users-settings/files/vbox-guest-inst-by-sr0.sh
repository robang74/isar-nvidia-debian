#!/bin/bash
#
# Copyright (c) Roberto A. Foglietta, 2022-2023
#
# Authors:
#  Roberto A. Foglietta <roberto.foglietta@gmail.com>
#
# SPDX-License-Identifier: MIT
#

if [ "$1" != "root" ]; then
	sudo $0 root "$@"
	exit $?
else
	shift
fi

set -e
trap 'echo "ERROR: in '$0' at line $LINENO, try to run with set -x"' ERR

echo "Running $0 as $(whoami)"

mod=$(lsmod | grep vboxguest | cut -d' ' -f1)
opt=$(which Xorg | grep -q Xorg || echo "--nox11")
#
# RAF: decomment this line to keep and debug the vboxguest installation package
#
#opt="$opt --keep --target /tmp/vboxguest"
url="https://raw.githubusercontent.com/denisandroid/uPD72020x-Firmware/master/UPDATE.mem"
fwf="/lib/firmware/renesas_usb_fw.mem"
test -e $fwf || wget -O $fwf $url

if ! mountpoint -q /mnt/cdrom 2>/dev/null; then
	mkdir -p /mnt/cdrom
	mount -r /dev/sr0 /mnt/cdrom
fi
mkdir -p /tmp/vboxguest

echo -e "\twith these arguments: $opt" "$@"
echo -e "\twhile lsmod returns: $mod"
cd /mnt/cdrom
ret=0; ./VBoxLinuxAdditions.run $opt "$@" || ret=$?
cd - >/dev/null
umount -l /mnt/cdrom ||:
usermod -aG vboxsf debraf

if test $ret -eq 2 -a -n "${mod:-}"; then
	ret=0
fi
if [ $ret -ne 0 ]; then
	echo
	echo "ERROR: installing vboxguest drivers"
	echo
	exit $?
fi
echo
echo "WARNING: you need to sudo reboot the system"
echo
