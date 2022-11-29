#
# Copyright (c) Siemens AG, 2022
#
# Authors:
#  Jan Kiszka <jan.kiszka@siemens.com>
#  Roberto A. Foglietta <roberto.foglietta@gmail.com>
#
# SPDX-License-Identifier: MIT
#

require eval-image-template.inc

DESCRIPTION = "${DESCHEAD} wimtools"

# applications for networking and system maintenance
IMAGE_PREINSTALL += "sudo vim bash-completion wimtools \
	ntfs-3g eject p7zip-full bmap-tools pigz \
	kbd console-data dos2unix \
"
