#!/bin/bash
#=================================================
# cp -Rf ./.github/tmp/*  .
ls -a
chmod +x ../lede/*.sh
cp -Rf ../lede/*.sh openwrt
echo '#================start======================='
ls -a
chmod +x diypart1.sh
[ -e $diypart1.sh ] && ./diypart1.sh || ./diy.sh
