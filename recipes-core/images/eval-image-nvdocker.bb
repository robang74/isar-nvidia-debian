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

DESCRIPTION = "${DESCHEAD} nvidia docker tools with GPU support"

IMAGE_PREINSTALL += " nvidia-docker2 docker-ce libcuda1 \
	libnvidia-ml1 nvidia-smi nvidia-driver-bin \
"

IMAGE_INSTALL += " nvidia-modules-${KERNEL_NAME}"
