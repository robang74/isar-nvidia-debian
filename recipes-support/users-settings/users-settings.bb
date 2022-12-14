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

DESCRIPTION = "users settings"
DEBIAN_DEPENDS = "cron"

SRC_URI = " \
	file://vimrc \
	file://htoprc \
	file://profile \
	file://postinst \
	file://nvidia-cuda-test.sh \
	file://vbox-guest-inst-by-apt.sh \
	file://vbox-guest-inst-by-sr0.sh \
"

user="debraf"
home="${D}/home/${user}"
root="${D}/root"

do_install() {
	cd ${WORKDIR}

	install -v -d ${root}/.config/htop
	install -v -m 644 vimrc ${root}/.vimrc
	install -v -m 644 profile ${root}/.profile
	install -v -m 644 htoprc ${root}/.config/htop

	install -v -d ${home}/.config/htop
	install -v -m 644 vimrc ${home}/.vimrc
	install -v -m 644 profile ${home}/.profile
	install -v -m 644 htoprc ${home}/.config/htop
	install -v -m 755 nvidia-cuda-test.sh ${home}
	install -v -m 755 vbox-guest-inst-by-apt.sh ${home}
	install -v -m 755 vbox-guest-inst-by-sr0.sh ${home}
}
