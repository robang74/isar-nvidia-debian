#!/bin/bash
#
# Copyright (c) Roberto A. Foglietta, 2022
#
# Authors:
#  Roberto A. Foglietta <roberto.foglietta@gmail.com>
#
# SPDX-License-Identifier: MIT
#
# https://groups.google.com/g/isar-users/c/dxVJqRvnWjw/m/G3drGbClAwAJ
#

DEBIAN_DEPENDS += ", btrfs-progs"

FILESEXTRAPATHS_prepend := "${LAYERDIR_debx86}/recipes-support/${PN}/files:"

SRC_URI += "file://expand-last-partition.sh"
