#!/bin/bash

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
  printf "%5s Mb (max)\n" $mx;
  printf "%5s Mb (rest)\n" $ct;
  printf "%5s Mb (deb)\n" $(ms build/downloads/deb);
  printf "%5s Mb (wic)\n" $(ms build/tmp/deploy/images/*/*.wic);
  printf "%5s Mb (cache)\n" $(ms build/sstate-cache);
}

echo "Cleaning all ..."
./clean.sh all
chkfds & ./build.sh $1
for i in $(seq 1 10); do
    sleep 0.15
    killall sleep && break
done 2>/dev/null
echo
