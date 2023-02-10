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

# RAF: do_binary_patch() sleep 4 should be terminate at the end of rootfs_install_pkgs_install()
#      to achieve this result it should copied into image that IMAGE_INSTALL a repackaging .deb

rootfs_install_pkgs_install:append() {
    sudo -E chroot "${ROOTFSDIR}" sh -c "killall sleep && sleep 1"
    return 0
}

################################################################################################

inherit dpkg-prebuilt

SRC_URI = "apt://${PN}"

do_binary_patch[cleandirs] += "${WORKDIR}/${PN}"
do_binary_patch() {
	set -e
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
	export XZ_OPT="-T 8" # RAF: number sets to 8 because it should be great enough for many others
    dpkg-deb -b ${d}
}
addtask binary_patch after do_unpack before do_deploy_deb

do_apt_fetch() {
    E="${@ isar_export_proxies(d)}"
#   bbwarn "\n\t workdir: ${WORKDIR}\n\t schroot: ${SCHROOT_DIR}"
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
    deb_dl_dir_import "${SCHROOT_DIR}" "${DISTRO}"
    for uri in ${SRC_APT}; do
        if ! sudo schroot -d / -c ${SBUILD_CHROOT} -- sh -c "\
                set -e
                mkdir -p ${d}; cd ${d}
                apt download -y ${uri}"; then
            found=0
            name=$(echo "${uri}" | cut -d= -f1)
            for i in $(ls -1v /build/${d}/${name}*.deb ||:); do
                if [ "$(debgetname $i)" = "${name}" ]; then
                    bbwarn "cannot download the deb package $uri, using the newest in downloads"
                    found=1
                    break
                fi
            done
            if [ "$found" = "0" ]; then
                bbfatal "cannot download the deb package $uri and did not find any local copy"
                return 1
            fi
        fi
    done
    deb_dl_dir_export "${SCHROOT_DIR}" "${DISTRO}"

    cd downloads
    for uri in ${SRC_URI}; do
        wget -c ${uri}
    done
    cd ..

    schroot_delete_configs
}
addtask apt_fetch before do_unpack
