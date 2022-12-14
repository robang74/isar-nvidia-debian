#
# Copyright (c) Siemens AG, 2022
#
# Authors:
#  Roberto A. Foglietta <roberto.foglietta@gmail.com>
#
# SPDX-License-Identifier: MIT
#

require recipes-kernel/custom-debian-dir.inc
require recipes-kernel/linux-module/module.inc

DESCRIPTION = "nvidia open-source driver"
LICENSE = "GPLv2"

PV = "${NVIDIA_DRIVER_VERSION}"
S = "${WORKDIR}/open-gpu-kernel-modules-${PV}"
SRC_URI += "https://github.com/NVIDIA/open-gpu-kernel-modules/archive/refs/tags/${PV}.zip"
SRC_URI[sha256sum] = "77bd58652e71710ac3b3488ebd051d4e658b9cd594f2ccc321a68dad27de1d66"

SRC_URI += "file://custom/postinst"
SRC_URI += "file://custom/rules.tmpl"

# USE_CCACHE = "1"
cmds="ldconfig; cp -paf /bin/chmod /bin/s.chmod && chmod +s /bin/s.chmod"
DPKG_SBUILD_EXTRA_ARGS += " --chroot-setup-commands='${cmds}'"
DPKG_SBUILD_EXTRA_ARGS_PRE = "${DPKG_SBUILD_EXTRA_ARGS}"

dpkg_runbuild[weight] = "1000"

dpkg_runbuild:prepend() {
	export KDIR=${KDIR} PN=${PN}
}

do_prepare_build:prepend() {
	rm -rf ${S}/debian
}
