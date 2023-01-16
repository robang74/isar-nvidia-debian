#!/bin/bash
#
# Copyright (c) Roberto A. Foglietta, 2022-2023
#
# Authors:
#  Roberto A. Foglietta <roberto.foglietta@gmail.com>
#
# SPDX-License-Identifier: MIT
#

kasyml="kas.yml"
#kasopt="--no-proxy-from-env"

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
	show_current | sed -e "s,\(.*\),${1:-current}: \\1 $vm,"
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

for i in pigz pzstd; do
	if ! which $i >/dev/null; then
		echo
		echo "ERROR: the command '$i' is missing, install it"
		echo
		exit 1
	fi
done

mkdir -p build/downloads/dash
for i in $(ls -1 dash/dash-*.static); do
    ln -Pf $i build/downloads/dash
done 2>/dev/null

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
		if [ "$(show_current)" != "" ]; then
			echo
			print_current
			echo
		fi
		if [ "$1" == "eval-image-$(show_current).bb" ]; then
			true
		elif ln -s "$1" eval-image.bb 2>/dev/null; then
			echo
			print_current setanew
			echo
		else
			ln -sf "$1" eval-image.bb
			print_current updated
			echo
			echo -n "A target exists, clean isar? (y/N) "
			read key && echo
			[ "$key" == "y" ] && ${topdir}/clean.sh isar
		fi
	else
		ln -sf "$1" eval-image.bb
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

if false; then
    for i in git.functions colors.shell; do
        repo_uri="https://raw.githubusercontent.com/robang74/git-functions/main"
        wget -q --background ${repo_uri}/$i -O $i
    done
fi

ipaddr=$(ip addr show dev docker0 | sed -ne "s, *inet \([0-9.]*\).*,\\1,p")
for i in $(env | grep -e "_proxy="); do
	export ${i/127.0.0.1/$ipaddr}
done
unset no_proxy ftp_proxy https_proxy http_proxy

cd $topdir >/dev/null
if [ ! -d isar/.git ]; then
    time ./kas-container $kasopt checkout "$kasyml" || exit $?
    test  "$1" == "isar" && exit 0
    echo
fi

epoch_git_this=$(git log -1 --pretty=%ct)
epoch_git_isar=$(cd isar; git log -1 --pretty=%ct)
if [ $epoch_git_this -gt $epoch_git_isar ]; then
    echo $epoch_git_this
else
    echo $epoch_git_isar
fi > build/epoch.last
#echo 1673628837 >build/epoch.last

time ./kas-container $kasopt build ${1:+--target $1} "$kasyml"

