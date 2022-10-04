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

# RAF: dependencies to keep with the version despite the apt attitude for the newest
IMAGE_PREINSTALL += "libnvidia-ptxjitcompiler1=${nver} libnvidia-nvvm4=${nver} \
	nvidia-alternative=${nver} \
"

IMAGE_INSTALL += " nvidia-modules-${KERNEL_NAME}"
