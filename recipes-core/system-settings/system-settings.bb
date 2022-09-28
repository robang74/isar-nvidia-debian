#
# Copyright (c) Siemens AG, 2022
#
# Authors:
#  Jan Kiszka <jan.kiszka@siemens.com>
#  Roberto A. Foglietta <roberto.foglietta@gmail.com>
#
# SPDX-License-Identifier: MIT
#

inherit dpkg-raw

DESCRIPTION = "system settings"
DEBIAN_DEPENDS = "openssh-server"

SRC_URI = " \
    file://issue.1 \
    file://postinst \
    file://ethernet \
    file://rc.local \
    file://rc.1stboot \
    file://nvidia-nouveau.conf \
    file://10-overlay-users.conf \
    file://20-wired-ethernet.conf \
    file://10-unprivileged-userns-clone.conf \
"

do_install() {
	install -v -d ${D}/etc
	install -v -m 644 ${WORKDIR}/issue.1 ${D}/etc
	install -v -m 755 ${WORKDIR}/rc.local ${D}/etc
	install -v -m 755 ${WORKDIR}/rc.1stboot ${D}/etc

	install -v -d ${D}/etc/network/interfaces.d
	install -v -m 644 ${WORKDIR}/ethernet ${D}/etc/network/interfaces.d

	install -v -d ${D}/etc/modprobe.d
	install -v -m 644 ${WORKDIR}/nvidia-nouveau.conf ${D}/etc/modprobe.d

	install -v -d ${D}/etc/udev/rules.d
	install -v -m 644 ${WORKDIR}/10-overlay-users.conf ${D}/etc/udev/rules.d
	install -v -m 644 ${WORKDIR}/20-wired-ethernet.conf ${D}/etc/udev/rules.d

	install -v -d ${D}//etc/sysctl.d
	install -v -m 644 ${WORKDIR}/10-unprivileged-userns-clone.conf ${D}//etc/sysctl.d
}
