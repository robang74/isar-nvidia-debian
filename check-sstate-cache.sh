#!/bin/dash

cd $(dirname $0)
topdir=$PWD

rm -rf tmp
mkdir -p tmp

if [ "x$1" = "xrootfs" ]; then
    name=$1
elif [ "x$1" = "xbootstrap" ]; then
    name=$1
else
    echo "USAGE: i$(basename $0) < rootfs | bootstrap >"
    exit 1
fi

find build/sstate-cache/ -name sstate:\*${name}\*.tgz -exec zstd -do tmp/${name}.tar.tar {} + 
tar xf tmp/${name}.tar.tar -C tmp
rm -f tmp/${name}.tar.tar
tar xf tmp/${name}.tar --exclude=dev/* -C tmp #2>/dev/null
rm -f tmp/${name}.tar

mv -f ${name}.list ${name}.list.bak
for i in . var usr usr/lib usr/share; do
    echo "exploring tmp/rootfs/$i/"
    du -ms tmp/rootfs/$i/* | sort -rn | head -n5
done | tee ${name}.list
find tmp/rootfs -type f | sort >> ${name}.list
echo "DOME: sorted list of files in ${name}.list"
