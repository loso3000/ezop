#!/bin/bash
#=================================================
# cp -Rf ./.github/tmp/*  .
ls -a
cp -Rf ../lede/*.sh openwrt
echo '#================start======================='
ls -a
chmod +x openwrt/diypart1.sh
./diypart1.sh
