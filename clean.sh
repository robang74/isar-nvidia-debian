#!/bin/bash
#
# Copyright (c) Roberto A. Foglietta, 2022
#
# Authors:
#  Roberto A. Foglietta <roberto.foglietta@gmail.com>
#
# SPDX-License-Identifier: MIT
#

function print_help() {
	echo
	echo "USAGE: $(basename $0) [ all | isar | kas | tmp ]"
	echo
	echo "       usully the 'isar' is the target to clean"
	echo
}

case $1 in
	all) sudo rm -rf build isar
		;;	
	tmp) sudo rm -rf build/tmp
		;;
	kas) sudo ./kas-container clean
		;;
	isar) ./kas-container --isar clean
		;;
	*) print_help
		;;
esac
