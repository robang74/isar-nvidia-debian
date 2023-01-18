#!/bin/bash
#
# This software is a part of ISAR.
# 
# Copyright (C) 2017-2019 Siemens AG
# Copyright (C) 2019 ilbers GmbH
# Copyright (C) 2022 Siemens AG
# Copyright (C) 2023 Roberto A. Foglietta
#
# Authors:
#  Roberto A. Foglietta <roberto.foglietta@gmail.com>
#
# SPDX-License-Identifier: MIT
#

inherit dpkg-prebuilt

SRC_URI = "apt://${PN}"

do_binary_patch[cleandirs] += "${WORKDIR}/${PN}"
do_binary_patch() {
	test -n "${SED_REGEX}"
	n=$(echo ${SRC_APT} ${SRC_URI} | wc -w)
	test $n -eq 1 

	d="${WORKDIR}/${PN}"
	s="/build/downloads/deb/${DISTRO}"
	p=$(ls -1v ${s}/${PN}*.deb | tail -n1)
	v=$(dpkg-deb -f ${p} Version)
	d="${d}-${v}"

	rm -rf ${d}*
	dpkg-deb -R ${p} ${d}
	eval sed -e "${SED_REGEX}" -i ${d}/DEBIAN/control
	sed -e "s,^\(Maintainer:\).*,\\1 isar repackaged," -e "/^$/d" -i ${d}/DEBIAN/control
	echo "while ! apt-mark hold ${PN} >/dev/null 2>&1; do sleep 4; done &" >> ${d}/DEBIAN/postinst
	chmod 0755 ${d}/DEBIAN/postinst
	dpkg-deb -b ${d}
}
addtask binary_patch after do_unpack before do_deploy_deb

do_apt_fetch() {
    E="${@ isar_export_proxies(d)}"
    schroot_create_configs

    schroot_cleanup() {
        schroot_delete_configs
    }
    trap 'exit 1' INT HUP QUIT TERM ALRM USR1
    trap 'schroot_cleanup' EXIT

    debgetname() {
        dpkg -I "$1" | sed -ne "s,^ *Package: \(.*\),\\1,p"
    }
    d="/downloads/deb/${DISTRO}"
    for uri in ${SRC_APT}; do
        if ! sudo schroot -d / -c ${SBUILD_CHROOT} -- sh -c "mkdir -p ${d} \
                && cd ${d} && apt-get install --download-only ${uri}"; then
            for i in $(ls -1 /build/${d}/${uri}*.deb); do
                if [ "$(debgetname)" == "$uri" ]; then
                    bbwarn "cannot download the deb package $uri, using the newest in downloads"
                    continue
                fi
            done
        fi
    done

    cd downloads
    for uri in ${SRC_URI}; do
        wget -c ${uri}
    done
    cd ..

    schroot_delete_configs
}
addtask apt_fetch before do_unpack
