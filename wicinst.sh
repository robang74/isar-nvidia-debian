#!/bin/bash
#
# Copyright (c) Roberto A. Foglietta, 2022
#
# Authors:
#  Roberto A. Foglietta <roberto.foglietta@gmail.com>
#
# SPDX-License-Identifier: MIT
#

cd $(dirname $0)

for i in 1 2; do
	if [ -b "$1" ]; then
		bdev=$1
	elif echo "$1" | grep -qe "^file:"; then
		file=${1/file:/}
	elif echo "$1" | grep -qe "^pigz:"; then
		pigz=${1/pigz:/}
	elif echo "$1" | grep -qe "^vmdk:"; then
		vmdk=${1/vmdk:/}
	elif [ -e "$1" ]; then
		fimg=$1
	fi
	shift
done

if [ ! -e "$fimg" ]; then
	fimg=$(ls -1 build/tmp/deploy/images/*/*.wic)
	n=( $fimg )
	if [ ${#n[@]} -gt 1 ]; then
		echo
		echo "WARNING: more than one image found, choose one:"
		echo
		echo "$fimg"
		echo
		exit 1
	fi
fi

if [ ! -e "$fimg" ]; then
	echo
	echo "ERROR: no any image found, abort!"
	echo
	exit 1
fi

size=$(du -b $fimg | cut -f1)
szmb=$(du -m $fimg | cut -f1)
echo
echo "Transfering ${szmb}Mb: $fimg => ${bdev}${file}${pigz}${vmdk} ..."

if [ -n "$bdev" ]; then
	time (sudo dd if=$fimg bs=1M of=$bdev status=progress; sync)
elif [ -n "$file" ]; then 
	time (cp -paf $fimg $file; sync $file)
elif [ -n "$pigz" ]; then
	time (pigz -c $fimg | dd bs=1M status=progress >$pigz; sync $pigz)
elif [ -n "$vmdk" ]; then
	if ! which qemu-img >/dev/null; then
		echo
		echo "WARNING: qemu-utils is missing, press a ENTER to install"
		echo
		read key
		sudo apt install -f qemu-utils
	fi
	time (qemu-img convert -pO vmdk $fimg $vmdk; sync $vmdk)
fi
echo
