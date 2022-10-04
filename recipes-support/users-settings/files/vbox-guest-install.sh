#!/bin/bash

test "$1" != "root" && sudo $0 root || exit 0

apt update
apt install dkms linux-headers-$(uname -r) build-essential virtualbox-guest-additions-iso
mkdir -p /mnt/iso
mount -o loop /usr/share/virtualbox/VBoxGuestAdditions.iso /mnt/iso
bash /mnt/iso/VboxLinuxAdditions.run
umount /mnt/iso
usermod -aG vboxsf debraf
echo "reboot, please"
