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
	local rf=$(readlink -e eval-image.bb)
	test ! -f "$rf" && rm -f eval-image.bb
	basename "$rf" | sed -e "s,eval-image-\(.*\).bb,\\1,"
}

function print_current() {
	local vm
	is_vmdk_set && vm="(vmdk)"
	show_current | sed -e "s,\(.*\),current: \\1 $vm,"
}

extra_space="83G"

function is_vmdk_set() {
	grep -q "extra-space ${extra_space}" ${fn}
}

function set_vmdk_image() {
	local vm nm="vmdk" f=$(basename ${fn})
	[ "$1" != "$nm" ] && return 1
	if  ! is_vmdk_set; then
		if ! sed -i "s,extra-space 1G,extra-space ${extra_space}," ${fn}; then
			echo
			echo "ERROR: cannot alter ${fn}, abort!"
			echo
			exit 1
		fi
		echo
		echo "NOTICE: $nm has been set"
		return 0
	fi
	echo
	echo "NOTICE: $nm currently set"
	return 0
}

function set_norm_image() {
	local vm nm="norm" f=$(basename ${fn})
	[ "$1" != "$nm" ] && return 1
	if is_vmdk_set; then
		if ! sed -i "s,extra-space ${extra_space},extra-space 1G," ${fn}; then
			echo
			echo "ERROR: cannot alter ${fn}, abort!"
			echo
			exit 1
		fi
		echo
		echo "NOTICE: $nm has been set"
		return 0
	fi
	echo
	echo "NOTICE: $nm currently set"
	return 0
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
fn="$topdir/wic/debx86.wks"
fl="$topdir/wic/debx86-110GiB-vmdk.wks"

set_vmdk_image "$1" && shift
set_norm_image "$1" && shift

cd recipes-core/images ########################################################

if [ "$1" == "--help" -o "$1" == "-h"  ]; then
	echo
	echo "USAGE: $(basename $0) <one-target-here-below>"
	echo
	print_images
	echo
	print_current
	echo
	exit 1
fi

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
elif [ "$doimg" == "1" ]; then
	if [ -e "$1" ]; then
#	if [ -e "$1" -a -e "$topdir/build" ]; then
		echo
		print_current
		echo
		if [ "$1" == "eval-image-$(show_current).bb" ]; then
			true
		elif ! ln -s $1 eval-image.bb 2>/dev/null; then
			echo -n "A target exists, clean isar? (y/N) "
			read key && echo
			ln -sf $1 eval-image.bb
			[ "$key" == "y" ] && ${topdir}/clean.sh isar
		fi
	else
		ln -s $1 eval-image.bb 2>/dev/null
		echo
		print_current
		echo
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

cd - >/dev/null ###############################################################

set_vmdk_image "$2" 
set_norm_image "$2"

err=0
if [ ! -d isar/.git ]; then
        kcbuild --target isar-clone 2>&1 | grep -vi ERROR
	err=$?
fi
test "$1" == "isar" && exit $?
kcbuild ${1:+--target $1}
