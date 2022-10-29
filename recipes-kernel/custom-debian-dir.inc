#
# Copyright (c) Siemens AG, 2022
#
# Authors:
#  Roberto A. Foglietta <roberto.foglietta@gmail.com>
#
# SPDX-License-Identifier: MIT
#
# https://groups.google.com/g/isar-users/c/Qnfahhn_Ffo/m/BBgZIPGiEQAJ
#

# Example of use: SRC_URI += "file://custom/control.tmpl"

do_custom_debian_dir() {
	set -ex
	cd ${WORKDIR}
	mkdir -p debian/isar
	for i in ${SRC_URI}; do
		i=$(echo "$i" | sed -ne "s,file://custom/,,p")
		test -n "$i" -a  -e "custom/$i" || continue
		cp -arf "custom/$i" "debian/$i"
	done
	cd - >/dev/null
}

addtask custom_debian_dir after do_unpack before do_transform_template

do_prepare_build_prepend() {
	rm -rf ${S}/debian
}
