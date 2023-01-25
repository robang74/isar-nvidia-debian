#
# Copyright (c) Siemens AG, 2022
#
# Authors:
#  Jan Kiszka <jan.kiszka@siemens.com>
#  Roberto A. Foglietta <roberto.foglietta@gmail.com>
#
# SPDX-License-Identifier: MIT
#

require eval-image-template.inc

DESCRIPTION = "${DESCHEAD} basic"

# applications for networking and system maintenance
IMAGE_PREINSTALL += "htop dos2unix lynx psmisc pigz \
	bash-completion less vim nano sudo apt-utils \
	pciutils usbutils ethtool iperf3 ntpdate cron \
	iw wireless-tools wpasupplicant dbus net-tools \
	ifupdown isc-dhcp-client net-tools iputils-ping \
	kbd console-data unzip wget curl ntfs-3g dialog \
	eject ssh lsof binutils strace bzip2 p7zip-full \
	bmap-tools time \
"

IMAGE_INSTALL += " nvidia-fs "

rootfs_install_pkgs_install:append() {
    sudo -E chroot "${ROOTFSDIR}" sh -c "killall sleep && sleep 1"
    return 0
}
