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

kver = "5.13"
KBUILD_DEPENDS += " dwarves"
KERNEL_DEFCONFIG = "defconfig-with-raid0"
PROVIDES = "linux-image-${kver}"

SRC_URI += "https://github.com/torvalds/linux/archive/refs/tags/v${kver}.tar.gz"
SRC_URI[sha256sum] = "9ce4c15b10d4dc9e353f3105dd11b9d2d2ef83e24772d68d3cf0830fe5f527a1"

SRC_URI += "file://${KERNEL_DEFCONFIG}"

S = "${WORKDIR}/linux-${kver}"

SRC_URI += "file://custom/control.tmpl"

require ../custom-debian-dir.inc
