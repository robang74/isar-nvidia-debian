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

ROOTFS_APT_ARGS += " --no-install-suggests --fix-missing"
DESCHEAD = "${MACHINE} evaluation image"
DESCRIPTION = "${DESCHEAD}"

IMAGE_INSTALL += "users-settings"
IMAGE_INSTALL += "system-settings"
IMAGE_INSTALL += "sshd-regen-keys"
IMAGE_INSTALL += "isar-exclude-docs"
IMAGE_INSTALL += "isar-disable-apt-cache"
IMAGE_INSTALL += "expand-on-first-boot"

WIC_IMAGER_INSTALL += "btrfs-progs"
