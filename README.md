ISAR debian image generator
===========================

Build with ISAR an evaluation image based on Debian 11 (bullseye) selecting from
nVidia GPU support (515.65.07) up to a graphic developing environment with the
full nVidia software stack (11.7.1) running a standard debian kernel


Support
-------

This project is mainteind by Roberto A. Foglietta <roberto.foglietta@gmail.com>


About
-----

The generated images run on x86 systems and the complete one includes a nVidia
full software stack for developing, debugging and tuning AI applications on the
top of the Debian 11 (bullseye) with a Gnome 3 and a dedicated Eclipse GUI:

- EFI boot in a separate VFAT partition
- Debian 11 operative system in EXT4 or BTRFS partition
- application for networking, system maintenance and basic developing tools
- CUDA libraries runtime and development, nVidia tuning and debugging tools
- Gnome 3 desktop graphic environment with nVidia Eclipse devel interface

The size of the complete image is about 9.1 GB and it is supposed to run on bare
hardware with a supported nVidia GPU dedicated for computational tasks and an
integrated primary graphic card for visualisation.

The most interesting others 2 images that can be created with this project are:

- build-me: the basic-os with the docker-ce for isar build
- nvdocker: the basic-os with the nvidia-docker2 + driver

The build-me is a 1.1 GB image that installed into a 120GB SSD/USB device can
run the ISAR environment in order to build every image in the full list.
These images do not contain any software from nVidia but just the ISAR tools.

The nvdocker is a 1.3 GB image that installed into a 120GB SSD/USB device can
run the AI applications into containers available in the nVidia catalog.


Rationale
---------

An equivalent result can be obtained installing a Debian 11, adding the nVidia
repositories dedicated to the developers and the other one dedicated to the
docker runtime, then installing the `cuda-demo-suite-11-7` and `nvidia-docker2`
packages.

The most sensitive difference between these two approaches is that the ISAR
image contains the open-source driver while the apt installed the closed-source.

In fact, this project is a proof-of-concept that shows how to add the open-source
nVidia driver in a Debian 11 system integrating it with the proprietary full
software stack without violating the licence and being able to redistribute
the image, at least for some usages allowed by the licences (\*).

- https://opensource.stackexchange.com/questions/10082/geforce-nvidia-driver-license-for-commerical-use

This project aims to provide a way to deliver a system with nVidia full stack
software installed which is legally distributable also for commercial uses.

- https://www.nvidia.com/en-us/drivers/unix

In fact, up today (515.76) the .run archive that contains the driver and the
CUDA libraries is licenced in a way for which two essential operations are not
permitted:

- §2.1.2 does not allow the compilation essential for deliver a binary driver
- §2.1.3 does not allow to repackage the .run content in many .deb packages

This project works around these limitations using the open-source driver

- https://github.com/NVIDIA/open-gpu-kernel-modules

in order to not violate the §2.1.2 and installing the nVidia software from their
public repositories without changing the .deb packages content and removing just
few dependencies - which are just text fields into a .deb architecture and have
nothing to do with the content delivered aka package metadata, only - allows to
avoid installing the closed-source driver and the related packages.

This allows also to choose a complete different kernel version respect the
one delivered with the Debian 11 and compile it by an ISAR recipe applying
a custom configuration and patches like this one:

- https://lore.kernel.org/lkml/20220921063638.2489-1-kprateek.nayak@amd.com

that unlock AMD Ryzen CPUs a more +51% of computation power lost due to an old bug.

(\*) **Legal notes**

- no any warranty is granted and further license changes might happen. 
- debian legal ml https://lists.debian.org/debian-legal/2022/10/msg00004.html


Virtual disk `build me` download
--------------------------------

Everyone without any authentication can download this virtual machine:

- isar-buildme-vm.ova.7z.001 (140 MB)
    - http://www.linuxteam.org/files/isar-buildme-vm.ova.7z.001

- isar-buildme-vm.ova.7z.002 (139 MB)
    - http://www.linuxteam.org/files/isar-buildme-vm.ova.7z.002

which the integrity could be verified with these two different hashes:

- md5sum 58526f014134073752b9c75cc53a0e4a isar-buildme-vm.ova.7z.001
- md5sum 034b332027a4a413710c317c96f0436c isar-buildme-vm.ova.7z.002

- sha1sum 59ed71725d1e32af8d16b974b62e0254f08a7dfe isar-buildme-vm.ova.7z.001
- sha1sum 0b23641110ae0012a6c2742b7296a6d1fe61d7b7 isar-buildme-vm.ova.7z.002

and let every Microsoft Windows user to build its own image using a virtual
machine like Oracle VirtualBox. Please note that in the VM settings you should
activate the EUFI boot (Settings, System, Enable EFI (special OSes only).

The virtual machine is accessible also by SSH using every client:

	ssh -p2022 -o StrictHostKeyChecking=no root@localhost (password root)

The first action to do is to change the passwords for users: root and debraf

You might want to install the VirtualBox drivers to activate the shared folder

    /home/debraf/vbox-guest-inst-by-apt.sh # for the network installation

    /home/debraf/vbox-guest-inst-by-sr0.sh # for the installation by cdrom

The first time to access the local apt cache `sudo apt update` is needed


Dependencies
------------

A GNU/Linux host with docker or podman installed

	sudo apt install pigz docker.io |XOR| docker-ce |XOR| podman

User account with permissions to run docker

	sudo usermod -aG docker $USER && newgrp docker


Building and other commands
---------------------------

You can load the repository shell profile in this way:

	source .profile

to laod the git functions and local scripts aliases

	build, clean, wicinst, wicshell, wicqemu

Otherwise you can use this by command line:

58526f014134073752b9c75cc53a0e4a  isar-buildme-vm.ova.7z.001
034b332027a4a413710c317c96f0436c  isar-buildme-vm.ova.7z.002
59ed71725d1e32af8d16b974b62e0254f08a7dfe  isar-buildme-vm.ova.7z.001
0b23641110ae0012a6c2742b7296a6d1fe61d7b7  isar-buildme-vm.ova.7z.002
	./build.sh [ $BBTARGET | $IMAGE ]

The Bitbake target could be any recipe.

However, to create an image you should choose one of these:

	./build.sh -h

It will show a list like this, in which the first field is the target:

- basic-os: a debian 11 with some system/networking tools
- build-me: the basic-os with the docker-ce for isar build
- basicdev: the basic-os with the basic development tools
- nvdocker: the basic-os with the nvidia-docker2 + driver
- complete: the basicdev + nvdocker + Gnome3 + CUDA devel

The complete update images list lives in recipes-core/images/README.txt

After having created an image you can chroot into it running this command

	./wicshell.sh

Then you can clean the ISAR project with command

	./clean.sh isar

or to clean quite everything in build but not downloads, this command

	./clean.sh all

the build/downloads folder is precious because it takes time to download again


Installing
----------

You can find the image with this command

	imgfile=$(find build/ -name eval-image-\*.wic 2>/dev/null)

and install it with one of these two

	sudo dd if=${imgfile} of=/dev/${USBDISK} bs=1M status=progress

or, if bmap-tools are installed,

	sudo bmaptool copy ${imgfile} /dev/${USBDISK}

on some system bmaptool fails to work, then simply deinstall it

The best way is to use this script

	sudo ./wicinst.sh /dev/${USBDISK}

With the script you can also transform your image in a VMDK file:

	./wicinst.sh vmdk:image.vmdk [$disk_size_in_gigabytes]

this requires qemu-img installing the qemu-utils deb package and
the last paramenter indicates the size in GB of the virtual disk


Example
-------

For example to create the `build me` vmdk 100 GiB image:

	source .profile
	clean all
	build.sh build-me
	wicinst vmdk:image-buildme-vm.vmdk 100

then in `docs/vm` there is the template to create the OVA package

	makeova [$filename].ova [$disk_size_in_gigabyte] 

do the magic to create the OVA archive in the top folder or this

	wicinst ovaf:image-buildme-vm.ova 100

which do the same using `makeova.sh` but with `wicinst` syntax


Proxy configure
---------------

	sudo -s
	apt update && apt install -y squid squid-purge squidview ufw
	sed -i "s,^\(acl localnet src .*\),#\\1," /etc/squid/squid.conf

	cat >/etc/profile.d/squid_proxy_vars.sh <<EOF
	export no_proxy=localhost,$(hostname -s),127.0.0.0/8,::1
	export ftp_proxy=http://127.0.0.1:3128/
	export https_proxy=http://127.0.0.1:3128/
	export http_proxy=http://127.0.0.1:3128/
	EOF
	source /etc/profile.d/squid_proxy_vars.sh

	mkdir -p /etc/systemd/system/docker.service.d
	ipaddr=$(ip -4 -o a s dev docker0 | awk '{sub("/..","",$4); print $4}')
	cat >/etc/systemd/system/docker.service.d/http-proxy.conf <<EOF
	[Service]
	Environment="HTTP_PROXY=${http_proxy/127.0.0.1/$ipaddr}"
	Environment="HTTPS_PROXY=${https_proxy/127.0.0.1/$ipaddr}"
	Environment="NO_PROXY=$no_proxy"
	Environment="http_proxy=${http_proxy/127.0.0.1/$ipaddr}"
	Environment="https_proxy=${https_proxy/127.0.0.1/$ipaddr}"
	Environment="no_proxy=$not_proxy"
	EOF

	cat >/etc/squid/conf.d/docker.conf <<EOF
	acl dockernet src ${ipaddr/.*/}.0.0.0/8
	http_access allow dockernet
	EOF

	ufw allow squid
	systemctl daemon-reload
	systemctl restart docker
	systemctl reload squid


License
-------

Almost all the files are under one of many FOSS licenses and the others are in
the public domain. Instead, the composition of these files is protected by the
GPLv3 license under the effects of the [Copyright Act, title 17. USC §101](
https://www.law.cornell.edu/uscode/text/17/101):

> Under the Copyright Act, a compilation [EdN: "composition" is used here as
synonym because compilation might confuse the technical reader about code
compiling] is defined as a "collection and assembling of preexisting materials
or of data [EdN: data includes source code, as well] that are selected in such
a way that the resulting work as a whole constitutes an original work of
authorship."

This means, for example, that everyone can use a single MIT licensed file or a
part of it under the MIT license terms. Instead, using two of them or two parts
of them implies that you are using a subset of this collection which is a
derived work of this collection which is licensed under the GPLv3, also.

The GPLv3 license applies to the composition unless you are the original author
of a specific unmodified file. This means that every one that can legally claim
rights about the original files maintains its rights, obviously. Therefore the
original authors do not need to undergo the GPLv3 license applied to the
composition and they maintains their original right in full. Unless, they use
the entire composition or a part of it for which they had not the rights, 
before.

Some files, documents, software or firmware components can make an exception to
the above general approach due to their specific copyright and license
restrictions. In doubt, follow the thumb rule of fair-use.

Moreover, this project is a layer of a customised ISAR engine as defined in
the `kas.yml`. Some files of that project will transfered into the image thus
their license also matters. Please also check the `README.md` of this

- https://github.com/robang74/isar#license

For further information or requests about licensing and how to obtain a fork 
suitable for your own business, please write to the project maintainer and
copyleft owner:

- Roberto A. Foglietta <roberto.foglietta@gmail.com>

Have fun! <3
