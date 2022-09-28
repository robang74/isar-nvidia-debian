ISAR debian image generator
===========================

This image support x86 systems and it includes several applications layers
on the top of the Debian 11 operative system with nVidia software stack:

 - EFI boot in a separate VFAT partition
 - Debian 11 operative system in EXT4 or BTRFS partition
 - application for networking, system maintainence and basic edit/developing tools
 - CUDA libraries runtime and development, nVidia tuning and debuging tools
 - Gnome 3 desktop graphic enviroment with nVidia Eclipse devel interface

About
-----

Build with ISAR an evaluation image based on Debian 11 (bullseye) selecting from
nVidia GPU support (515.65.01) up to a graphic developing enviroment with the full
nVidia software stack (11.7) running a standard debian kernel


Rationale
---------

An equivalent result can be obtained installing a Debian 11, adding the nVidia
repository dedicate to the developers and the other one dedicated to the docker
runtime, then installing the cuda-demo-suite-11-7 and nvidia-docker2 packages.

The most sensitive difference between these two approaches is that the ISAR image
contains the open source driver while the apt installed the closed source one.

In fact, this project is a prof-of-concept that show how to install the open
sourcei nVidia driver in a Debian system integrating it with the proprietary
full software stack without violating the licence and being able to redistribute
the image, at least for some usages allowed by the licences (\*).

- https://opensource.stackexchange.com/questions/10082/geforce-nvidia-driver-license-for-commerical-use

After all, this project aims to provide a way to deliver a system with nVidia
full stack software installed legally distrubutable also for commercial usas.

- https://www.nvidia.com/en-us/drivers/unix

In fact, up today (515.76) the .run archive that contains the driver and the
CUDA libraries is licenced in a way for which two essential operations are not
permitted:

 - §2.1.2 do not allow the compilation essential for deliver a binry driver
 - §2.1.3 do not allow to repackage the .run content in many .deb packages

This project works around these limitations using the open source driver

 - https://github.com/NVIDIA/open-gpu-kernel-modules

in order to not violate the §2.1.2 and installing the nVidia software from
their public repositories without changing the .deb packages content but
removing just few depenencies - which are just text fileds into a .deb 
architecture and have nothing to do with the content deliverd aka package 
metadata, only - allows to avoid installing the closed source driver and
the related packages. 

This allows also to choose a complete different kernel version respect the
one delivered with the Debian 11 and compile it by an ISAR recipe applying
a custom configuration and patches like this one:

 - https://lore.kernel.org/lkml/20220921063638.2489-1-kprateek.nayak@amd.com

that unlock AMD Ryzen CPUs a more +51% of computation power due to old bug.

**Legal note**:

 - (\*) no any warranty is granted and further licenses change might happen, also. 

Dependencies
------------

Linux host with docker or podman installed

	sudo apt install docker.io |XOR| docker-ce |XOR| podman

User account with permissions to run docker

	sudo usermod -aG docker $USER && newgrp docker


Building and other commands
---------------------------

 You can load the repositroy shell profile in this way:

	. .profile

 to lod the git functions and local scripts aliases

	build, clean, insta, wicshell, sqemu

 Otherwise you can use this by command line:

	./build.sh [ $BBTARGET | $IMAGE ]

 The Bitbake target could be any recipe.

 However, to create an image you should choose one of these:

	./build -h

 It will show a list like this, in which the first field is the target:

    - basic-os: a debian 11 with some system/networking tools
    - build-me: the basic-os with the docker-ce for isar build
    - basicdev: the basic-os with the basic development tools
    - nvdocker: the basic-os with the nvidia-docker2 + driver
    - complete: the basicdev + nvdocker + Gnome3 + CUDA devel

 The complete udpate images list lives in recipes-core/images/README.txt

 After having created an image you can chroot into it running this command

	./buildshell.sh

 Then you can clean everything with

	./builclean.sh


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

Almost all the files are under MIT license and the other are in the public domain
due to their simplicity and/or standardisation like system configuration. However
the composition of these files is protected by the GPLv3 license.

This means that everyone can use a single MIT licensed file or a part of it under
the MIT license terms. Instead, using two of them or two parts of them implies that
you are using a subset of this collection. Thus a derived work of this collection
which is licensed under the GPLv3 also.

The GPLv3 licenses applies to the composition unless you are the original copyright
owner or the author of a specific unmodified file. This means that everyone that can
legally claims rights about the original files maintains its rights, obviously. So,
it should not need to complain with the GPLv3 license applied to the composition.
Unless, the composition is adopted for the part which had not the rights, before.

For further information or requests, please write at the repository mainteiner:

 - Roberto A. Foglietta <roberto.foglietta@gmail.com>

Have fun! <3
