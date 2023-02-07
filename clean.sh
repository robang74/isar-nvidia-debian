#!/bin/bash
#
# Copyright (c) Roberto A. Foglietta, 2022-2023
#
# Authors:
#  Roberto A. Foglietta <roberto.foglietta@gmail.com>
#
# SPDX-License-Identifier: MIT
#

# using colors.shell or not
NOTICE=${NOTICE:-NOTICE}
USAGE=${USAGE:-USAGE}

function print_help() {
    local isar="${BLWHT:-}isar${CRST:-}" all="all"
    test "$image_cache" != "active" && isar="isar" all="${BLWHT:-}all${CRST:-}"
	echo "${USAGE}: $(basename $0) [ $all | $isar | kas | tmp ]"
	echo
    test "$image_cache" != "active" && return
	echo "       usually the '${isar}' is the target to clean"
	echo
}

function getcache() {
    local ovrloadfunc image_curnt image_templ image_cache
    image_curnt="recipes-core/images/eval-image.bb"
    image_templ="recipes-core/images/eval-image-template.inc"
    if [ ! -r "$image_curnt" -a ! -r "$image_templ" ]; then
       return 1
    fi
    ovrloadfunc="rootfs_install_sstate_prepare"
    image_cache=$(grep -nw "$ovrloadfunc" "$image_templ" "$image_curnt" 2>/dev/null)
    image_cache=$(echo "$image_cache" | cut -d: -f3- | cut -d '#' -f1)
    image_cache=${image_cache:+disabled}
    image_cache=${image_cache:-active}
    echo $image_cache
}

cd "$(dirname $0)"

image_cache=$(getcache)
image_cache_msg=${image_cache/disabled/${DWHT:-}disabled${CRST}, use \'${BLWHT:-}clean all${CRST:-}\' only}
image_cache_msg=${image_cache_msg/active/${BLGRN:-}active${CRST:-}}
echo -e "\n${NOTICE}: the image rootfs is ${image_cache_msg}\n"

echo -e "Cleaning target: $1\n"

if false; then
    mpoints=$(sudo find build -name archives -type d -exec mountpoint {} \;)
    mpoints=$(echo "$mpoints" | sed -ne "s,\(.*\) is a mountpoint,\\1,p")
    for i in $mpoints; do sudo umount $i; done
    mpoints=$(sudo find build -name archives -type d -exec mountpoint {} \;)
    mpoints=$(echo "$mpoints" | sed -ne "s,\(.*\) is a mountpoint,\\1,p")
    if [ -n "$mpoints" ]; then
        echo "${ERROR:-ERROR}: archives moint points present, cannot clean"
        echo
        echo "$mpoints"
        echo
    fi
fi

case $1 in
	all) sudo rm -rf $(ls -1d build/* 2>/dev/null | grep -ve "^build/downloads")
		;;	
	kas) sudo ./kas-container clean
		;;
	isar|tmp) ./kas-container --isar clean
		;;
	*) print_help; exit 0
		;;
esac

if false; then
    for dir in build/tmp/schroot-overlay /var/lib/schroot/session; do
        test -d $dir && \
            find $dir -name isar-imager-builder-\* \
                -exec sudo rm -rf --one-file-system {} +
    done
fi
