#
# Copyright (c) Siemens AG, 2022
#
# Authors:
#  Roberto A. Foglietta <roberto.foglietta@gmail.com>
#
# SPDX-License-Identifier: MIT
#

pver = "515"
nver = "${pver}.65.01-1"
cver = "11-7"

IMAGE_PREINSTALL += " nvidia-docker2 docker-ce libcuda1=${nver} \
	libnvidia-ml1=${nver} nvidia-smi=${nver} nvidia-driver-bin=${nver} \
"

IMAGE_INSTALL += " nvidia-modules-${KERNEL_NAME}"
