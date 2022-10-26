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

DESCRIPTION = "${DESCHEAD} basic development"

IMAGE_PREINSTALL += "gcc build-essential \
	automake autoconf pkgconf git mdadm \
"
IMAGE_INSTALL += "linux-image-5.13"
