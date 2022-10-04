#!/bin/bash
#
# Copyright (c) Roberto A. Foglietta, 2022
#
# Authors:
#  Roberto A. Foglietta <roberto.foglietta@gmail.com>
#
# SPDX-License-Identifier: MIT
#

function kcbuild() {
        cd $(dirname $0)
        time ./kas-container build kas.yml "$@"
        echo
}

function print_images() {
	sed -e "s,^eval-image-\(.*\).bb,  - \\1," README.txt
}

function show_current() {
	rf=$(readlink -e eval-image.bb)
	test ! -f "$rf" && rm -f eval-image.bb
	basename "$rf" | sed -e "s,eval-image-\(.*\).bb,\\1,"
}

function print_current() {
	show_current | sed -e "s,\(.*\),current: \\1,"
}

if [ "$(whoami)" == "root" ]; then
        echo
        echo "ERROR: this script should not run as root, abort!"
        echo
        exit 1
fi

cd $(dirname $0)

doimg=0
topdir=$PWD
cd recipes-core/images/
if [ -e "eval-image-$1.bb" ]; then
	set -- "eval-image-$1.bb"
	doimg=1
elif [ -e "$1.bb" ]; then
	set -- "$1.bb"
	doimg=1
elif [ -e "$1" ]; then
	doimg=1
fi
if [ "$1" == "" -a ! -e eval-image.bb ]; then
	echo
	echo "ERROR: no any target defined, choose one:"
	echo
	print_images
	echo
	exit 1
elif [ "$1" == "--help" -o "$1" == "-h"  ]; then
	echo
	echo "USAGE: $(basename $0) <one-target-here-below>"
	echo
	print_images
	echo
	print_current
	echo
	exit 1
elif [ "$doimg" == "1" ]; then
	echo
	print_current
	echo
	if [ -e "$1" -a -e "$topdir/build" ]; then
		if [ "$1" == "eval-image-$(show_current).bb" ]; then
			true
		elif ! ln -s $1 eval-image.bb 2>/dev/null; then
			true
			echo -n "A target exists, clean isar? (y/N) "
			read key && echo
			ln -sf $1 eval-image.bb
			[ "$key" == "y" ] && ${topdir}/clean.sh isar
		fi
	fi
	set --
elif [ "$1" != "" ]; then
	echo
	echo "target: $1"
	echo
else
	echo
	print_current
	echo
fi
cd - >/dev/null

if [ ! -d isar/.git ]; then
        kcbuild --target isar-clone 2>&1 | grep -vi ERROR
fi

kcbuild ${1:+--target $1}
