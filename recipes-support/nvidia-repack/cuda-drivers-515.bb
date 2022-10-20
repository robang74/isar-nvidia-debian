#!/bin/bash
#
# Copyright (c) Siemens AG, 2022
#
# Authors:
#  Roberto A. Foglietta <roberto.foglietta@gmail.com>
#
# SPDX-License-Identifier: MIT
#

inherit dpkg-repackage

nver="515.65.01-1"
SRC_URI = "apt://${PN}=${nver}"

SED_REGEX = "\"s/nvidia-driver (>= [0-9.]*), //\""
SED_REGEX += "-e \"s/Conflicts: .*//\""
