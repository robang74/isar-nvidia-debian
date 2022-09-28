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

DESCRIPTION = "${DESCHEAD} Gnome3 + CUDA devel + GPU support + docker"

IMAGE_PREINSTALL += " nvidia-docker2 docker-ce libcuda1 \
	libnvidia-ml1 nvidia-smi nvidia-driver-bin \
"

IMAGE_PREINSTALL += "nvidia-persistenced nvidia-modprobe \
	nvidia-legacy-check cuda-gdb-11-7 cuda-cupti-dev-11-7 \
	cuda-nvprof-11-7 cuda-memcheck-11-7 cuda-cupti-11-7 \
	cuda-toolkit-11-7-config-common cuda-toolkit-11-7 \
	cuda-sanitizer-11-7 cuda-nvvp-11-7 cuda-nvtx-11-7 \
	cuda-nsight-compute-11-7 cuda-nsight-systems-11-7 \
	libcusolver-dev-11-7 libcusparse-dev-11-7 \
	cuda-minimal-build-11-7 cuda-compat-11-7 \
	cuda-driver-dev-11-7 cuda-gdb-src-11-7 \
	cuda-nvrtc-dev-11-7 libcublas-dev-11-7 \
	libcufft-dev-11-7 libcurand-dev-11-7 \
	libnpp-dev-11-7 libnvjpeg-dev-11-7 \
"

IMAGE_INSTALL += " nvidia-fs cuda-drivers-515"
IMAGE_PREINSTALL += " cuda-demo-suite-11-7"
IMAGE_PREINSTALL += " nvidia-gds-11-7"

IMAGE_PREINSTALL += " task-gnome-desktop \
	firefox-esr mesa-utils \
	cuda-nsight-11-7 \
"

IMAGE_INSTALL += " nvidia-modules-${KERNEL_NAME}"
IMAGE_INSTALL += " linux-headers-${KERNEL_NAME}"
