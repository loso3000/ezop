#!/bin/bash
#=================================================
# cp -Rf ./.github/tmp/*  .
ls -a
chmod +x ../lede/*.sh
cp -Rf ../lede/*.sh .
echo '#================start======================='
ls -a
chmod +x diypart1.sh
[ -e diypart1.sh ] && bash ./diypart1.sh || bash ./diy.sh
