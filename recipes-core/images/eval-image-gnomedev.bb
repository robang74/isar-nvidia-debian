#
# Copyright (c) Siemens AG, 2022
# Copyright (c) Roberto A. Foglietta, 2023
#
# Authors:
#  Jan Kiszka <jan.kiszka@siemens.com>
#  Roberto A. Foglietta <roberto.foglietta@gmail.com>
#
# SPDX-License-Identifier: MIT
#

require eval-image-basicdev.bb

DESCRIPTION = "${DESCHEAD} Gnome3 + basic devel + kernel headers"

# RAF: remove 'none_' prefix from this line to disable the image rootfs caching
none_rootfs_install_sstate_prepare() {
    bbwarn "image rootfs cache has been disabled, use 'clean all' only"
}

# RAF: graphical enviroment Gnome3
IMAGE_PREINSTALL += " task-gnome-desktop \
	firefox-esr mesa-utils network-manager \
"

IMAGE_INSTALL += " linux-headers-${KERNEL_NAME}"
