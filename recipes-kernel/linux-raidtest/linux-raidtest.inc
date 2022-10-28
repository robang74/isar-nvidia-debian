#
# Copyright (c) Siemens AG, 2022
#
# Authors:
#  Jan Kiszka <jan.kiszka@siemens.com>
#  Roberto A. Foglietta <roberto.foglietta@gmail.com>
#
# SPDX-License-Identifier: MIT
#

require recipes-kernel/linux/linux-custom.inc

KBUILD_DEPENDS += " dwarves"
KERNEL_DEFCONFIG = "defconfig-with-raid0"

SRC_URI += "https://github.com/torvalds/linux/archive/refs/tags/v${PV}.tar.gz"
SRC_URI += "file://${KERNEL_DEFCONFIG}"
S = "${WORKDIR}/linux-${PV}"

SRC_URI += "file://custom/control.tmpl"
require ../custom-debian-dir.inc
