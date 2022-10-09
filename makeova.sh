#!/bin/bash
#
# Copyright (c) Roberto A. Foglietta, 2022
#
# Authors:
#  Roberto A. Foglietta <roberto.foglietta@gmail.com>
#
# SPDX-License-Identifier: MIT
#

function vmdk_get_size() {
	qemu-img info "$1" | sed -ne "s,virtual size: .* (\(.*\) bytes),\\1,p"
}

function vmdk_get_uuid() {
	dd if="$1" count=16 2>/dev/null | strings | sed -ne "s,ddb.uuid.image=\"\(.*\)\",\\1,p"
}

function show_current() {
        local rf=$(readlink -e "${topdir}/recipes-core/images/eval-image.bb")
        basename "$rf" | sed -e "s,eval-image-\(.*\).bb,\\1,"
}

function get_field_value() {
	git config --list | sed -ne "s,$1=\(.*\),\\1,p"
}

function get_random_uuid() {
	cat /proc/sys/kernel/random/uuid
}

set -e
cd $(dirname "$0")
topdir="$PWD"
d="$topdir/docs/vm/tmp"
fimg="eval-$(show_current | tr -d '-')-vm"

if [ -e "$topdir/$fimg.ova" -o -e "$topdir/$fimg.ova.7z" ]; then
	echo
	echo "ERROR: $topdir/$fimg.ova(.7z) exist, abort!"
	echo
	exit 1
fi

VM_VERSION_INFO="$(git -C ${topdir} describe --tags --dirty --match 'v[0-9].[0-9]*')"
VM_PRODUCT_INFO="ISAR nVidia Debian evaluation virtual machine"
VM_PRODUCT_URL="https://github.com/robang74/isar-nvidia-debian"
VM_VENDOR_INFO="$(get_field_value "user.name")"
VM_VENDOR_URL="mailto:$(get_field_value "user.email" | sed -e 's,@,%40,g')"
VM_VENDOR_URL="mailto:$(get_field_value "user.email")"
VM_IMAGE_NAME="$fimg"

rm -rf "$d"
mkdir "$d"

cat "$topdir/docs/vm/vmspecs.ovf" > "$d/$fimg.ovf"
sed -i "s,\${VM_VERSION_INFO},$VM_VERSION_INFO,g" "$d/$fimg.ovf"
sed -i "s,\${VM_PRODUCT_INFO},$VM_PRODUCT_INFO,g" "$d/$fimg.ovf"
sed -i "s,\${VM_PRODUCT_URL},$VM_PRODUCT_URL,g" "$d/$fimg.ovf"
sed -i "s,\${VM_VENDOR_INFO},$VM_VENDOR_INFO,g" "$d/$fimg.ovf"
sed -i "s,\${VM_VENDOR_URL},$VM_VENDOR_URL,g" "$d/$fimg.ovf"
sed -i "s,\${VM_IMAGE_NAME},$VM_IMAGE_NAME,g" "$d/$fimg.ovf"

disk="$d/$fimg-disk001.vmdk"

echo "Open Virtual Format 1.0 written in $d/$fimg.ovf"
echo "Copying the VMDK image in $disk ..."

$topdir/wicinst.sh vmdk:"$disk" --nosync

echo -n "Retriving the SIZE and the UUID of the new VMDK image ..."
VM_IMAGE_UUID=$(vmdk_get_uuid "$d/$disk")
VM_IMAGE_UUID="${VM_IMAGE_UUID:-$(get_random_uuid)}"
if [ ! -n "$VM_IMAGE_UUID" ]; then
	echo
	echo "ERROR: VM_IMAGE_UUID is not found, abort!"	
	echo
	exit 1
fi
sed -i "s,\${VM_IMAGE_UUID},$VM_IMAGE_UUID,g" "$d/$fimg.ovf"
VM_IMAGE_SIZE="$(vmdk_get_size "$disk")"
if [ ! -n "$VM_IMAGE_SIZE" ]; then
	echo
	echo "ERROR: VM_IMAGE_SIZE is not found, abort!"
	echo
	exit 1
fi
sed -i "s,\${VM_IMAGE_SIZE},$VM_IMAGE_SIZE,g" "$d/$fimg.ovf"
echo " OK"

echo -n "Calculating the SHA1 sums for the manifest ..."
VM_DKFILE_SHA=$(sha1sum "$disk" | cut -d' ' -f1)
VM_OVFILE_SHA=$(sha1sum "$d/$fimg.ovf" | cut -d' ' -f1)
echo " OK"

echo "SHA1 ($disk) = ${VM_DKFILE_SHA}" > "$d/$fimg.mf"
echo "SHA1 ($fimg.ovf) = ${VM_OVFILE_SHA}" >> "$d/$fimg.mf"
echo "OVF 1.0 manifest written in $d/$fimg.mf"

echo -n "Creating the OVA archive ... " 
cd $d
tar cf $topdir/$fimg.ova *  
#sync $topdir/$fimg.ova
echo " OK"
echo "Open Virtual Appliance created in $topdir/$fimg.ova"
rm -rf "$d"
cd $topdir
echo && exit

echo "Compressing OVA archiver with 7z ..."
#7z a -mx9 -sdel $fimg.ova.7z $fimg.ova
7z a -mx9 $fimg.ova.7z $fimg.ova
echo "Compressed OVA archive written in $topdir/$fimg.ova.7z"
echo
