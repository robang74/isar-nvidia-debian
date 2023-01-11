#!/bin/bash -m

function fds() {
  df -m / | grep /dev | tr -s ' ' | cut -d' ' -f4;
}

function ms() {
  du -ms "$@" 2>/dev/null | cut -f1
}

function chkfds() {
    st=$(fds); mx=0;
    while sleep 1; do ct=$[st-$(fds)];
    if [ $ct -gt $mx ]; then
        printf "%5s Mb\n" $ct
        mx=$ct
    fi >/dev/null
    done; ct=$[st-$(fds)];
    echo
    printf "%5s Mb (max)\n" $mx;
    printf "%5s Mb (rest)\n" $ct;
    printf "%5s Mb (deb)\n" $(ms build/downloads/deb);
    printf "%5s Mb (wic)\n" $(ms build/tmp/deploy/images/*/*.wic);
    printf "%5s Mb (cache)\n" $(ms build/sstate-cache);
}

function killsleep() {
    for i in $(seq 1 10); do
        sleep 0.15
        killall sleep && break
    done 2>/dev/null
}
export -f killsleep

test -n "$1" && rm -f recipes-core/images/eval-image.bb
trap "killsleep" EXIT

echo "Cleaning all ..."
./clean.sh all
chkfds & ./build.sh "$@"
killsleep
trap - EXIT
echo
