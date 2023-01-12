#!/bin/bash

set -ueE
exec 3>/dev/null
cd $(dirname $0)
topdir=$PWD

rm -rf tmp
mkdir -p tmp
trap "rm -rf tmp" EXIT

set -- "${1:-}"
if [ "x$1" = "xrootfs" ]; then
    name=$1
elif [ "x$1" = "xbootstrap" ]; then
    name=$1
else
    echo "USAGE: i$(basename $0) < rootfs | bootstrap >"
    exit 1
fi

fname=$(find build/sstate-cache/ -name sstate:sbuild-chroot-\*${name}\*.tgz; \
    find build/sstate-cache/ -name sstate:\*isar-${name}-\*${name}\*.tgz; \
    find build/sstate-cache/ -name sstate:\*isar-${name}-\*${name}\*.tar.zst; \
    find build/sstate-cache/ -name sstate:sbuild-chroot-\*${name}\*.tar.zst)
if [ -z "$fname" ]; then
	echo -e "\n${ERROR:-ERROR}: no file about ${name}, abort.\n"
	exit 1
fi
if echo "$fname" | grep -qe ".zst$"; then
	zstd -do tmp/${name}.tar.tar "$fname"
	tar xf tmp/${name}.tar.tar -C tmp
	rm -f tmp/${name}.tar.tar
else
	tar -Oxzf "$fname" >tmp/${name}.tar
fi

tar xf tmp/${name}.tar --exclude=dev/* -C tmp #2>/dev/null
rm -f tmp/${name}.tar

echo
mv -f ${name}.list ${name}.list.bak
for i in "" var usr usr/lib usr/share; do
    echo "exploring tmp/rootfs/$i"
    du -ms tmp/rootfs/$i/* | sort -rn | head -n5
    echo
done | tee ${name}.list
echo "listing tmp/rootfs"
find tmp/rootfs -type f | sort >> ${name}.list

echo -e "\n${DONE:-DONE}: sorted list of files in ${name}.list\n"
