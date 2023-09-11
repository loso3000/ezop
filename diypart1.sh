#!/bin/bash
#=================================================
# cp -Rf ./.github/tmp/*  .
cp -Rf ../lede/*.sh openwrt
chmod +x openwrt/diypart1.sh
./diypart1.sh
