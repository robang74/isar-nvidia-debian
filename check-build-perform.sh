#!/bin/bash -m

function fds() {
    df -m / | grep /dev | tr -s ' ' | cut -d' ' -f4;
}

function ms() {
    du -ms "$@" 2>/dev/null | cut -f1
}

function chkfds() {
    local st=$(fds) mx=0 ret=0
    while [ $ret -eq 0 ]; do
        ct=$[st-$(fds)];
        if [ $ct -gt $mx ]; then
            printf "%5s Mb\n" $ct
            mx=$ct
        fi >/dev/null
        ret=$( (exec -ca "chkbldsleep" sleep 1); echo $? )
    done
    ct=$[st-$(fds)];
    echo
    printf "%5s Mb (max)\n" $mx;
    printf "%5s Mb (rest)\n" $ct;
    printf "%5s Mb (tmp)\n" $(ms build/tmp);
    printf "%5s Mb (deb)\n" $(ms build/downloads/deb);
    printf "%5s Mb (wic)\n" $(ms build/tmp/deploy/images/*/*.wic);
    printf "%5s Mb (cache)\n" $(ms build/sstate-cache);
}

function killsleep() {
    local p i
    for i in $(seq 1 ${1:-10}); do
        p=$(grep -nw "chkbldsleep" /proc/[1-9]*/cmdline 2>&1)
        p=$(echo "$p" | cut -d/ -f3)
        if [ -n "$p" ]; then
            kill $p && kill $p && break
        else
            break
        fi
        sleep 0.15
    done 2>/dev/null
    fg 2>/dev/null
    return 0
}
export -f killsleep

function do_build_after_clean() {
    local clean=$1
    shift
    ./clean.sh $clean
    echo -n "Syncing the disks..."; sync; echo -e " ${OK:-OK}"
    grep --color=never -e Dirty: -e Writeback: /proc/meminfo
    chkfds & ./build.sh "$@"
    killsleep
}
export -f do_build_after_clean

stty -echoctl
log="build.log"

if [ -n "$1"  ]; then
    rm -f recipes-core/images/eval-image.bb
    name="$1"
else
    name=$(readlink -f recipes-core/images/eval-image.bb)
    name=$(echo "$name" | sed -e "s,.*eval-image-\(.*\)\.bb,\\1,")
fi
trap "killsleep" EXIT
killsleep 1

test -e $log && mv -f $log $log.bak

if [ ${CACHEONLY:-0} -ne 1 ]; then
    run=1
    echo
    echo "Cleaning all for a fresh build with downloads untouched..."
    if [ ${LOGBUILD:-0} -ne 0 ]; then
        do_build_after_clean all "$@" || exit $?
    fi 2>&1 | tee $log
    if [ ${LOGBUILD:-0} -eq 0 ]; then
        do_build_after_clean all "$@" || exit $?
    fi

    if [ "$name" == "complete" \
      -o "$name" == "gnomedev" \
      -o "$name" == "nvdocker" ]; then
        echo "Sleeping 2 minutes to let the SSD relax, CTRL+C to skip..."
        trap "killsleep; echo ciao" INT; (
            exec -ca "chkbldsleep" sleep 120
        ); trap -- INT
        echo
    fi
fi

if [ ${LOGBUILD:-0} -eq 0 ]; then
    if [ ${CACHEONLY:-0} -ne 1 -a ${NOSTOP:-0} -ne 1 ]; then
        echo
        echo "Press ENTER to start the isar clean cached rebuild"
        read
    else
        echo
    fi
    echo "Cleaning isar for rebuild supported by the cache..."
    do_build_after_clean isar "$@" || exit $?
fi
if [ ${LOGBUILD:-0} -ne 0 ]; then
    echo "Cleaning isar for rebuild supported by the cache..."
    do_build_after_clean isar "$@" || exit $?
fi 2>&1 | tee -a $log

trap - EXIT
echo
