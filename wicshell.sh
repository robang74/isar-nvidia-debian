#!/bin/bash
#
# Authors:
#  Roberto A. Foglietta <roberto.foglietta@gmail.com>
#
# SPDX-License-Identifier: MIT
#

function getloopdev() {
#	ls -1v $(losetup -lan | grep $fimg | cut -d' ' -f1) | tail -n1
#	ls -1v "$(losetup -j $fimg | cut -d: -f1)" 2>/dev/null | tail -n1 | egrep .

	if [ -b "$fimg" ]; then
		if [ -b ${fimg}2 ]; then
			echo ${fimg}2 
		elif [ -b ${fimg}p2 ]; then
			echo ${fimg}p2
		else
			echo ${fimg}
		fi	
		return $?
	fi
	local a
	a=$(losetup -j $fimg | cut -d: -f1)
	a=$(ls -1v "$a" 2>/dev/null | tail -n1)
	a=${a:+${a}p2}
	test -b "$a" && echo $a
}

function umountall() {
        set +e
        umount -R $rootdir
        if getloopdev >/dev/null; then 
		losetup -d ${bdev/p2/}
		getloopdev | sed -e "s,\(.*\),ERROR: loop device \\1 is still busy!,"
	fi
	echo
}

function jumpinto() {
	set -e
	test -b $bdev
	mkdir -p $rootdir
	mount $bdev $rootdir
	mkdir -p $rootdir/work
	mount -o bind build/tmp/work $rootdir/work
	mkdir -p $rootdir/isar-apt
	mount -o bind build/tmp/deploy/isar-apt $rootdir/isar-apt
	mount -t sysfs sys $rootdir/sys
	mount -t proc proc $rootdir/proc
	mount -t devtmpfs udev $rootdir/dev
	mount -t devpts devpts $rootdir/dev/pts
	mount -t cgroup2 cgroup2 $rootdir/sys/fs/cgroup
	echo "chroot into $(basename $fimg)..."
	echo
	chroot $rootdir su -l root -Ps /bin/bash
	echo "chroot exiting..."
}

if [ "$(whoami)" != "root" ]; then
        echo
        echo "WARNING: this script should run as root, sudo!"
	sudo $0 "$@"
        exit $?
fi

cd $(dirname $0)

if [ -e "$1" ]; then
	fimg=$(readlink -e $1)
fi

if [ ! -n "$1" -a  ! -e "$fimg" ]; then
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
	echo "ERROR: no any image or block device ${1:+'$1' }found, abort!"
	echo
	exit 1
fi

rootdir=build/root
bdev="$(getloopdev)"
trap "umountall" EXIT
set -e
echo
if [ -b "$fimg" ]; then
	jumpinto $fimg
elif [ -b "$bdev" ]; then
	echo "WARNIING: using a previous loop device $bdev"
	echo
	jumpinto $bdev
else
	losetup -Pf $fimg
	bdev=$(getloopdev)
	jumpinto $bdev
fi
