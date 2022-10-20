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
require eval-image-nvdocker.inc

DESCRIPTION = "${DESCHEAD} Gnome3 + CUDA devel + GPU support + docker"

IMAGE_PREINSTALL += "nvidia-persistenced=${nver} nvidia-modprobe=${nver} \
	nvidia-legacy-check=${nver} \
"

IMAGE_PREINSTALL += "cuda-gdb-${cver} cuda-cupti-dev-${cver} \
	cuda-nvprof-${cver} cuda-memcheck-${cver} cuda-cupti-${cver} \
	cuda-toolkit-${cver}-config-common cuda-toolkit-${cver} \
	cuda-sanitizer-${cver} cuda-nvvp-${cver} cuda-nvtx-${cver} \
	cuda-nsight-compute-${cver} cuda-nsight-systems-${cver} \
	libcusolver-dev-${cver} libcusparse-dev-${cver} \
	cuda-minimal-build-${cver} cuda-compat-${cver} \
	cuda-driver-dev-${cver} cuda-gdb-src-${cver} \
	cuda-nvrtc-dev-${cver} libcublas-dev-${cver} \
	libcufft-dev-${cver} libcurand-dev-${cver} \
	libnpp-dev-${cver} libnvjpeg-dev-${cver} \
"

# RAF: dependencies to keep with the version despite the apt attitude for the newest
IMAGE_PREINSTALL += "nvidia-opencl-icd=${nver} libnvidia-compiler=${nver} \
	libnvoptix1=${nver} libnvcuvid1=${nver} libnvidia-allocator1=${nver} \
	libnvidia-opticalflow1=${nver} cuda-drivers=${nver} \
	libnvidia-encode1=${nver} libnvidia-fbc1=${nver} \
"

# RAF: dependencies to keep with the version despite the apt attitude for the newest, p2
IMAGE_PREINSTALL += "libxnvctrl-dev=${nver} libxnvctrl0=${nver} nvidia-cuda-mps=${nver} \
	nvidia-detect=${nver} nvidia-libopencl1=${nver} nvidia-opencl-common=${nver} \
	nvidia-settings=${nver} nvidia-xconfig=${nver} libnvidia-cfg1=${nver} \
"

IMAGE_INSTALL += " nvidia-fs cuda-drivers-515"
IMAGE_PREINSTALL += " cuda-demo-suite-${cver}"
IMAGE_PREINSTALL += " nvidia-gds-${cver}"

# RAF: graphical enviroment support for the nVidia Eclipsed base development GUI
IMAGE_PREINSTALL += " task-gnome-desktop \
	firefox-esr mesa-utils network-manager \
	cuda-nsight-${cver} \
"

IMAGE_INSTALL += " linux-headers-${KERNEL_NAME}"
