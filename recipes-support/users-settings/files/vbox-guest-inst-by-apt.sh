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

mnt=$(mount | sed -ne "s,^/dev/sr0 on \([^ ]*\) .*,\\1,p")
mnt=${mnt:-/mnt/cdrom}
if [ "$mnt/VBoxLinuxAdditions.run" ]; then
	echo
	echo "WARNING: a VirtualBox guest install script is available at"
	echo
	echo "         $mnt/VBoxLinuxAdditions.run"
	echo
	echo -n "         are you sure do you want install by network (y/N) "
	read ans
	echo
	if [ "$ans" != "y" -a "$ans" != "Y" ]; then
		exit 1
	fi
fi
mkdir -p /mnt/cdrom
if mountpoint -q /mnt/cdrom; then
	umount /mnt/cdrom
fi

apt update
apt install -y virtualbox-guest-additions-iso dkms linux-headers-$(uname -r) build-essential bzip2
mount -o loop -r /usr/share/virtualbox/VBoxGuestAdditions.iso /mnt/cdrom
echo
${0%/*}/vbox-guest-inst-by-sr0.sh
