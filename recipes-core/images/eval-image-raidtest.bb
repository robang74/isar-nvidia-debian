#
# Copyright (c) Siemens AG, 2022
#
# Authors:
#  Jan Kiszka <jan.kiszka@siemens.com>
#  Roberto A. Foglietta <roberto.foglietta@gmail.com>
#
# SPDX-License-Identifier: MIT
#

require eval-image-basicdev.bb

KERNEL_NAME = "raidtest"
DESCRIPTION = "${DESCHEAD} basic development"

IMAGE_PREINSTALL += "gcc build-essential libssl-dev bc \
	automake autoconf pkgconf git mdadm libelf-dev \
	flex bison libncurses-dev file wireless-regdb \
"

IMAGE_PREINSTALL += "firmware-linux-nonfree firmware-realtek"

IMAGE_INSTALL += "linux-image-${KERNEL_NAME}"
IMAGE_INSTALL += "linux-headers-${KERNEL_NAME}"
