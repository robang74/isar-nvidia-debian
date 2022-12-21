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

cd $(dirname $0)

case $1 in
	all) sudo rm -rf $(ls -1d build/* 2>/dev/null | grep -ev "^build/downloads")
		;;	
	kas) sudo ./kas-container clean
		;;
	isar|tmp) ./kas-container --isar clean
		;;
	*) print_help
		;;
esac
