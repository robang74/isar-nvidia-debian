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

SED_REGEX = "s/nvidia-driver (>= [0-9.]*), //"
