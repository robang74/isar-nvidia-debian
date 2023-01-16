#
# Copyright (c) Siemens AG, 2022
#
# Authors:
#  Jan Kiszka <jan.kiszka@siemens.com>
#  Roberto A. Foglietta <roberto.foglietta@gmail.com>
#
# SPDX-License-Identifier: MIT
#

inherit image

ROOTFS_APT_ARGS += " --no-install-suggests --fix-missing --fix-broken"
DESCHEAD = "${MACHINE} evaluation image"
DESCRIPTION = "${DESCHEAD}"

IMAGE_INSTALL += "users-settings"
IMAGE_INSTALL += "system-settings"
IMAGE_INSTALL += "sshd-regen-keys"
IMAGE_INSTALL += "isar-disable-apt-cache"
IMAGE_INSTALL += "expand-on-first-boot"

WIC_IMAGER_INSTALL += "btrfs-progs"
WIC_DEPLOY_PARTITIONS = "0"

# RAF: remove 'none_' prefix from this line to disable the image rootfs caching
none_rootfs_install_sstate_prepare() {
    bbwarn "image rootfs cache has been disabled, use 'clean all' only"
}
