eval-image-basic-os.bb: a debian 11 with some system/networking tools
eval-image-build-me.bb: the basic-os with the docker-ce for isar build
eval-image-basicdev.bb: the basic-os with the basic development tools
eval-image-nvdocker.bb: the basic-os with the nvidia-docker2 + driver
eval-image-complete.bb: the basicdev + nvdocker + Gnome3 + CUDA devel
