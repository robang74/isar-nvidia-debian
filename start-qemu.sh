#!/bin/bash
#
# Jailhouse, a Linux-based partitioning hypervisor
#
# Copyright (c) Siemens AG, 2018,2022
#
# Authors:
#  Jan Kiszka <jan.kiszka@siemens.com>
#  Roberto A. Foglietta <roberto.foglietta@gmail.com>
#

wicfile=$(find build/tmp/deploy/images -name \*.wic -type f 2>/dev/null | sort)
if [ ! -e "$wicfile" ]; then
	echo
	echo "The .wic image has not been found"
	echo
	exit 3
fi

nimg=( $wicfile )
if [ ${#nimg[@]} -gt 1 ]; then
	echo
	echo "More than one .wic image, choose the one"
	echo
	eval $(echo "$wicfile" | sed -e "s,\(.*\),echo \" \$(basename \\1) for \\1\";,")
	echo
	exit 2
fi

function usage()
{
	printf "%b" "Usage: $0 ARCHITECTURE [QEMU_OPTIONS]\n"
	printf "%b" "\nSet QEMU_PATH environment variable to use a locally " \
		    "built QEMU version\n"
	exit 1
}

cd $(dirname $0)

if [ -n "${QEMU_PATH}" ]; then
	QEMU_PATH="${QEMU_PATH}/"
fi

if [ "$1" == "" ]; then
	arch=$(sed -ne "s,DISTRO_ARCH.*\"\(.*\)\",\\1,p" conf/machine/debx86.conf  2>/dev/null)
else
	arch=$1; shift
fi

case "$arch" in
	x86|x86_64|amd64)
		DISTRO_ARCH=amd64
		QEMU=qemu-system-x86_64
		CPU_FEATURES="-kvm-pv-eoi,-kvm-pv-ipi,-kvm-asyncpf,-kvm-steal-time,-kvmclock"

		# qemu >= 5.2 has kvm-asyncpf-int which needs to be disabled
		if ${QEMU} -cpu help | grep kvm-asyncpf-int > /dev/null; then
			CPU_FEATURES="${CPU_FEATURES},-kvm-asyncpf-int"
		fi

		QEMU_EXTRA_ARGS=" \
			-cpu host,${CPU_FEATURES} \
			-smp 4 \
			-enable-kvm -machine q35,kernel_irqchip=split \
			-serial vc \
			-device ide-hd,drive=disk \
			-device intel-iommu,intremap=on,x-buggy-eim=on \
			-device intel-hda,addr=1b.0 -device hda-duplex \
			-device e1000e,addr=2.0,netdev=net"
		KERNEL_SUFFIX=vmlinuz
		KERNEL_CMDLINE=" \
			root=/dev/sda intel_iommu=off memmap=82M\$0x3a000000 \
			vga=0x305"
		;;
	arm64|aarch64)
		DISTRO_ARCH=arm64
		QEMU=qemu-system-aarch64
		QEMU_EXTRA_ARGS=" \
			-cpu cortex-a57 \
			-smp 16 \
			-machine virt,gic-version=3,virtualization=on \
			-device virtio-serial-device \
			-device virtconsole,chardev=con -chardev vc,id=con \
			-device virtio-blk-device,drive=disk \
			-device virtio-net-device,netdev=net"
		KERNEL_SUFFIX=vmlinux
		KERNEL_CMDLINE=" \
			root=/dev/vda mem=768M"
		;;
	arm)
		DISTRO_ARCH=arm
		QEMU=qemu-system-arm
		QEMU_EXTRA_ARGS=" \
			-cpu cortex-a15 \
			-smp 8 \
			-machine virt,virtualization=on,highmem=off \
			-device virtio-serial-device \
			-device virtconsole,chardev=con -chardev vc,id=con \
			-device virtio-blk-device,drive=disk \
			-device virtio-net-device,netdev=net"
		KERNEL_SUFFIX=vmlinuz
		KERNEL_CMDLINE=" \
			root=/dev/vda mem=768M vmalloc=768M"
		;;
	""|--help)
		usage
		;;
	*)
		echo "Unsupported architecture: $arch"
		exit 1
		;;
esac

#IMAGE_PREFIX="$(dirname "$0")/build/tmp/deploy/images/qemu-${DISTRO_ARCH}/demo-image-jailhouse-demo-qemu-${DISTRO_ARCH}"
#IMAGE_FILE=$(ls "${IMAGE_PREFIX}.ext4.img")

IMAGE_FILE=$wicfile
QEMU_EXTRA_ARGS="$QEMU_EXTRA_ARGS -bios /usr/share/ovmf/OVMF.fd"
#QEMU_EXTRA_ARGS="$QEMU_EXTRA_ARGS -nographic"

# SC2086: Double quote to prevent globbing and word splitting.
# shellcheck disable=2086
"${QEMU_PATH}${QEMU}" \
	-drive file="${IMAGE_FILE}",discard=unmap,if=none,id=disk,format=raw \
	-m 1G -serial mon:stdio -netdev user,id=net ${QEMU_EXTRA_ARGS} "$@"
