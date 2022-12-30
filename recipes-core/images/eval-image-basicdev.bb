#
# Copyright (c) Siemens AG, 2022
#
# Authors:
#  Jan Kiszka <jan.kiszka@siemens.com>
#  Roberto A. Foglietta <roberto.foglietta@gmail.com>
#
# SPDX-License-Identifier: MIT
#

require eval-image-basic-os.bb

DESCRIPTION = "${DESCHEAD} basic development"

IMAGE_PREINSTALL += "gcc build-essential man-db \
	automake autoconf pkgconf git manpages \
"
