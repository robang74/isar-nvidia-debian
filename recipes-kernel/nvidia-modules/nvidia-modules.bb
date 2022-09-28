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
PV = "515.65.01"

S = "${WORKDIR}/open-gpu-kernel-modules-${PV}"
SRC_URI += "https://github.com/NVIDIA/open-gpu-kernel-modules/archive/refs/tags/${PV}.zip"
SRC_URI[sha256sum] = "6bdf00d453b901974cecd55727354b5d159ef56ab15afd22ba0926a3eac58687"

SRC_URI += "file://custom/postinst"
SRC_URI += "file://custom/rules.tmpl"

dpkg_runbuild_prepend() {
	export KDIR=${KDIR} PN=${PN}
}

do_prepare_build_prepend() {
	rm -rf ${S}/debian
}
