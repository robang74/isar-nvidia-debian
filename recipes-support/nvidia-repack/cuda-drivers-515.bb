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

SRC_URI = "apt://${PN}=${NVIDIA_DRIVER_VERSION}-1"

SED_REGEX = "\"s/nvidia-driver (>= [0-9.]*), //\""
SED_REGEX += "-e \"s/Conflicts: .*//\""
