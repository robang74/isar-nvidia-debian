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

DESCRIPTION = "${DESCHEAD} basic + docker"

IMAGE_PREINSTALL += "docker-ce git qemu-utils qemu-user-static reprepro quilt \
	zstd debootstrap virtualenv umoci skopeo \
"
