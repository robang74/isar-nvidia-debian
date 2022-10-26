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

apt update
mkdir -p /mnt/cdrom
#mount /dev/cdrom /mnt/cdrom
#if ! ls -1 /mnt/cdrom/*.run >/dev/null 2>&1; then
	apt install -y virtualbox-guest-additions-iso
	mount -o loop /usr/share/virtualbox/VBoxGuestAdditions.iso /mnt/cdrom
#fi
#apt install -y dkms linux-headers-$(uname -r) build-essential virtualbox-guest-additions-iso bzip2
bash $(ls -1 /mnt/cdrom/*.run || echo exit)
usermod -aG vboxsf debraf
