ISAR debian image generator
===========================

Build with ISAR an evaluation image based on Debian 11 (bullseye) selecting from
nVidia GPU support (515.65.01) up to a graphic developing enviroment with the
full nVidia software stack (11.7) running a standard debian kernel


About
-----

The generated images run on x86 systems and the complete one includes a nVidia
full software stack for developing, debugging and tuning AI applications on the
top of the Debian 11 (bullseye) with a Gnome 3 and a dedicated Eclipse GUI:

 - EFI boot in a separate VFAT partition
 - Debian 11 operative system in EXT4 or BTRFS partition
 - application for networking, system maintainence and basic developing tools
 - CUDA libraries runtime and development, nVidia tuning and debuging tools
 - Gnome 3 desktop graphic enviroment with nVidia Eclipse devel interface

The size of the complete image is about 9.1 GB and it supposed to run on bare
hardware with a supported nVidia GPU dedicateid for computational tasks and an
integrate primary graphic card for visualisation.

The most interesting others 2 images that can be created with this project are:

    - build-me: the basic-os with the docker-ce for isar build
    - nvdocker: the basic-os with the nvidia-docker2 + driver

The build-me is an 1.1 GB image that installed into a 120GB SSD/USB device can
run the ISAR enviroment in order to build every image in the full list.
This images do not contains any software from nVidia but just the ISAR tools.

The nvdocker is an 1.3 GB image that installed into a 120GB SSD/UBB device can
run the AI applications into containers available in the nVidia catalog.


Rationale
---------

An equivalent result can be obtained installing a Debian 11, adding the nVidia
repositories dedicated to the developers and the other one dedicated to the
docker runtime, then installing the 'cuda-demo-suite-11-7' and 'nvidia-docker2'
packages.

The most sensitive difference between these two approaches is that the ISAR
image contains the open-source driver while the apt installed the closed-source.

In fact, this project is a prof-of-concept that shows how to add the open-source
nVidia driver in a Debian 11 system integrating it with the proprietary full
software stack without violating the licence and being able to redistribute
the image, at least for some usages allowed by the licences (\*).

- https://opensource.stackexchange.com/questions/10082/geforce-nvidia-driver-license-for-commerical-use

This project aims to provide a way to deliver a system with nVidia full stack
software installed which is legally distrubutable also for commercial usas.

- https://www.nvidia.com/en-us/drivers/unix

In fact, up today (515.76) the .run archive that contains the driver and the
CUDA libraries is licenced in a way for which two essential operations are not
permitted:

 - §2.1.2 does not allow the compilation essential for deliver a binry driver
 - §2.1.3 does not allow to repackage the .run content in many .deb packages

This project works around these limitations using the open-source driver

 - https://github.com/NVIDIA/open-gpu-kernel-modules

in order to not violate the §2.1.2 and installing the nVidia software from their
public repositories without changing the .deb packages content and removing just
few depenencies - which are just text fileds into a .deb architecture and have
nothing to do with the content deliverd aka package metadata, only - allows to
avoid installing the closed-source driver and the related packages.

This allows also to choose a complete different kernel version respect the
one delivered with the Debian 11 and compile it by an ISAR recipe applying
a custom configuration and patches like this one:

 - https://lore.kernel.org/lkml/20220921063638.2489-1-kprateek.nayak@amd.com

that unlock AMD Ryzen CPUs a more +51% of computation power lost due to old bug.

**Legal note**:

 - (\*) no any warranty is granted and further license change might happen. 


Dependencies
------------

A GNU/Linux host with docker or podman installed

	sudo apt install docker.io |XOR| docker-ce |XOR| podman

User account with permissions to run docker

	sudo usermod -aG docker $USER && newgrp docker


Building and other commands
---------------------------

You can load the repositroy shell profile in this way:

	source .profile

to lod the git functions and local scripts aliases

	build, clean, insta, wicshell, wicqemu

Otherwise you can use this by command line:

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

The complete udpate images list lives in recipes-core/images/README.txt

After having created an image you can chroot into it running this command

	./wicshell.sh

Then you can clean everything with

	./clean.sh


Installing
----------

You can find the image with this comamnd

    imgfile=$(find build/ -name eval-image-\*.wic 2>/dev/null)

and install it with one of these two

    sudo dd if=${imgfile} of=/dev/${USBDISK} bs=1M status=progress

or, if bmap-tools are installed,

    sudo bmaptool copy ${imgfile} /dev/${USBDISK}

or use this script

    sudo ./insta.sh /dev/${USBDISK}


License
-------

Almost all the files are under MIT license and the other are in the public
domain due to their simplicity and/or standardisation like system configuration.
However the composition of these files is protected by the GPLv3 license.

This means that everyone can use a single MIT licensed file or a part of it
under the MIT license terms. Instead, using two of them or two parts of them
implies that you are using a subset of this collection. Thus a derived work of
this collection which is licensed under the GPLv3 also.

The GPLv3 licenses applies to the composition unless you are the original
copyright owner or the author of a specific unmodified file. This means that
everyone that can legally claims rights about the original files maintains its
rights, obviously. So, it should not need to complain with the GPLv3 license
applied to the composition. Unless, the composition is adopted for the part
which had not the rights, before.

For further information or requests, please write at the repository mainteiner:

 - Roberto A. Foglietta <roberto.foglietta@gmail.com>

Have fun! <3
