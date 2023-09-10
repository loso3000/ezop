#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#

# Uncomment a feed source
# Add a feed source

mkdir -p files/usr/share
mkdir -p files/etc/
touch files/etc/ez_version
mkdir wget
touch wget/DISTRIB_REVISION1
touch wget/DISTRIB_REVISION3
touch files/usr/share/Check_Update.sh
touch files/usr/share/ez-auto.sh

sed -i "s/ImmortalWrt/OpenWrt/" {package/base-files/files/bin/config_generate,include/version.mk}

echo "修改默认主题"
sed -i 's/+luci-theme-bootstrap/+luci-theme-kucat/g' feeds/luci/collections/luci/Makefile

sed -i '/45)./d' feeds/luci/applications/luci-app-zerotier/luasrc/controller/zerotier.lua  #zerotier
sed -i 's/vpn/services/g' feeds/luci/applications/luci-app-zerotier/luasrc/controller/zerotier.lua   #zerotier
sed -i 's/vpn/services/g' feeds/luci/applications/luci-app-zerotier/luasrc/view/zerotier/zerotier_status.htm   #zerotier

cat>rename.sh<<-\EOF
#!/bin/bash
rm -rf  bin/targets/x86/64/config.buildinfo
rm -rf  bin/targets/x86/64/feeds.buildinfo
rm -rf  bin/targets/x86/64/openwrt-x86-64-generic-kernel.bin
rm -rf  bin/targets/x86/64/openwrt-x86-64-generic-squashfs-rootfs.img.gz
rm -rf  bin/targets/x86/64/openwrt-x86-64-generic-rootfs.tar.gz
rm -rf  bin/targets/x86/64/openwrt-x86-64-generic.manifest
rm -rf bin/targets/x86/64/sha256sums
rm -rf  bin/targets/x86/64/version.buildinfo
rm -rf bin/targets/x86/64/openwrt-x86-64-generic-ext4-rootfs.img.gz
rm -rf bin/targets/x86/64/openwrt-x86-64-generic-ext4-combined-efi.img.gz
rm -rf bin/targets/x86/64/openwrt-x86-64-generic-ext4-combined.img.gz
sleep 2
rename_version=`cat files/etc/ez_version`
str1=`grep "KERNEL_PATCHVER:="  target/linux/x86/Makefile | cut -d = -f 2` #判断当前默认内核版本号如5.10
ver54=`grep "LINUX_VERSION-5.4 ="  include/kernel-5.4 | cut -d . -f 3`
sleep 2
mv  bin/targets/x86/64/openwrt-x86-64-generic-squashfs-combined.img.gz       bin/targets/x86/64/openwrt-64-${rename_version}_${str1}.${ver54}_sta_ez.img.gz
mv  bin/targets/x86/64/openwrt-x86-64-generic-squashfs-combined-efi.img.gz   bin/targets/x86/64/openwrt-64-${rename_version}_${str1}.${ver54}_uefi-gpt_sta_ez.img.gz
sleep 2
ls bin/targets/x86/64 | grep "gpt_sta_ez.img" | cut -d - -f 3 | cut -d _ -f 1-2 > wget/op_version1
#md5
ls -l  "bin/targets/x86/64" | awk -F " " '{print $9}' > wget/open_sta_md5
sta_version=`grep "_uefi-gpt_sta_ez.img.gz" wget/open_sta_md5 | cut -d - -f 3 | cut -d _ -f 1-2`
openwrt_sta=openwrt_x86-64-${sta_version}_sta_ez.img.gz
openwrt_sta_uefi=openwrt_x86-64-${sta_version}_uefi-gpt_sta_ez.img.gz
cd bin/targets/x86/64
md5sum $openwrt_sta > openwrt_sta.md5
md5sum $openwrt_sta_uefi > openwrt_sta_uefi.md5
exit 0
EOF

cat>ez.sh<<-\EOOF
#!/bin/bash
ez_version="Ipv6-Super-Vip `date '+%y%m%d'` by sirpdboy" 
echo $ez_version >  wget/DISTRIB_REVISION1 
echo $ez_version | cut -d _ -f 1 >  files/etc/ez_version  
new_DISTRIB_REVISION=`cat  wget/DISTRIB_REVISION1`
#

grep "Check_Update.sh"  package/emortal/default-settings/files/99-default-settings
if [ $? != 0 ]; then
	sed -i 's/exit 0/ /'  package/emortal/default-settings/files/99-default-settings
	cat>> package/emortal/default-settings/files/99-default-settings<<-EOF
	sed -i '$ a alias ez="sh /usr/share/Check_Update.sh"' /etc/profile
	sed -i '/DISTRIB_DESCRIPTION/d' /etc/openwrt_release
	echo "DISTRIB_DESCRIPTION='$new_DISTRIB_REVISION'" >> /etc/openwrt_release
	exit 0
	EOF
fi
grep "ez-auto.sh"  package/emortal/default-settings/files/99-default-settings
if [ $? != 0 ]; then
	sed -i 's/exit 0/ /'  package/emortal/default-settings/files/99-default-settings
	cat>> package/emortal/default-settings/files/99-default-settings<<-EOF
	sed -i '$ a alias ez-auto="sh /usr/share/ez-auto.sh"' /etc/profile
	exit 0
	EOF
fi
EOOF

cat>files/usr/share/Check_Update.sh<<-\EOF
#!/bin/bash
# https://github.com/sirpdboy/OpenWrt
# Actions-OpenWrt-x86 By ez 20210505
#path=$(dirname $(readlink -f $0))
# cd ${path}
#检测准备
if [ ! -f  "/etc/ez_version" ]; then
	echo
	echo -e "\033[31m 该脚本在非ez固件上运行，为避免不必要的麻烦，准备退出… \033[0m"
	echo
	exit 0
fi
rm -f /tmp/cloud_version
# 获取固件云端版本号、内核版本号信息
current_version=`cat /etc/ez_version`
curl -s https://api.github.com/repos/sirpdboy/openwrt/releases/latest | grep 'tag_name' | cut -d\" -f4 > /tmp/cloud_ts_version
sleep 3
if [ -s  "/tmp/cloud_ts_version" ]; then
	cloud_version=`cat /tmp/cloud_ts_version | cut -d _ -f 1`
	cloud_kernel=`cat /tmp/cloud_ts_version | cut -d _ -f 2`
	#固件下载地址
	new_version=`cat /tmp/cloud_ts_version`
	DEV_URL=https://github.com/sirpdboy/openwrt/releases/download/${new_version}/openwrt_x86-64-${new_version}_sta_ez.img.gz
	DEV_UEFI_URL=https://github.com/sirpdboy/openwrt/releases/download/${new_version}/openwrt_x86-64-${new_version}_uefi-gpt_sta_ez.img.gz
	openwrt_sta=https://github.com/sirpdboy/openwrt/releases/download/${new_version}/openwrt_sta.md5
	openwrt_sta_uefi=https://github.com/sirpdboy/openwrt/releases/download/${new_version}/openwrt_sta_uefi.md5
else
	echo "请检测网络或重试！"
	exit 1
fi
####
Firmware_Type="$(grep 'DISTRIB_ARCH=' /etc/openwrt_release | cut -d \' -f 2)"
echo $Firmware_Type > /etc/ez_firmware_type
echo
if [[ "$cloud_kernel" =~ "4.19" ]]; then
	echo
	echo -e "\033[31m 该脚本在ez固件Sta版本上运行，目前只建议在Dev版本上运行，准备退出… \033[0m"
	echo
	exit 0
fi
#md5值验证，固件类型判断
if [ ! -d /sys/firmware/efi ];then
	if [ "$current_version" != "$cloud_version" ];then
		wget -P /tmp "$DEV_URL" -O /tmp/openwrt_x86-64-${new_version}_sta_ez.img.gz
		wget -P /tmp "$openwrt_sta" -O /tmp/openwrt_sta.md5
		cd /tmp && md5sum -c openwrt_sta.md5
		if [ $? != 0 ]; then
      echo "您下载文件失败，请检查网络重试…"
      sleep 4
      exit
		fi
		Boot_type=logic
	else
		echo -e "\033[32m 本地已经是最新版本，还更个鸡巴毛啊… \033[0m"
		echo
		exit
	fi
else
	if [ "$current_version" != "$cloud_version" ];then
		wget -P /tmp "$DEV_UEFI_URL" -O /tmp/openwrt_x86-64-${new_version}_uefi-gpt_sta_ez.img.gz
		wget -P /tmp "$openwrt_sta_uefi" -O /tmp/openwrt_sta_uefi.md5
		cd /tmp && md5sum -c openwrt_sta_uefi.md5
		if [ $? != 0 ]; then
      echo "您下载文件失败，请检查网络重试…"
      sleep 4
      exit
		fi
		Boot_type=efi
	else
		echo -e "\033[32m 本地已经是最新版本，还更个鸡巴毛啊… \033[0m"
		echo
		exit
	fi
fi

open_up()
{
echo
clear
read -n 1 -p  " 您是否要保留配置升级，保留选择Y,否则选N:" num1
echo
case $num1 in
	Y|y)
	echo
  echo -e "\033[32m >>>正在准备保留配置升级，请稍后，等待系统重启…-> \033[0m"
	echo
	sleep 3
	if [ ! -d /sys/firmware/efi ];then
		gzip -d openwrt_x86-64-${new_version}_sta_ez.img.gz
		sysupgrade /tmp/openwrt_x86-64-${new_version}_sta_ez.img
	else
		gzip -d openwrt_x86-64-${new_version}_uefi-gpt_sta_ez.img.gz
		sysupgrade /tmp/openwrt_x86-64-${new_version}_uefi-gpt_sta_ez.img
	fi
    ;;
    n|N)
    echo
    echo -e "\033[32m >>>正在准备不保留配置升级，请稍后，等待系统重启…-> \033[0m"
    echo
    sleep 3
	if [ ! -d /sys/firmware/efi ];then
		gzip -d openwrt_x86-64-${new_version}_sta_ez.img.gz
		sysupgrade -n  /tmp/openwrt_x86-64-${new_version}_sta_ez.img
	else
		gzip -d openwrt_x86-64-${new_version}_uefi-gpt_sta_ez.img.gz
		sysupgrade -n  /tmp/openwrt_x86-64-${new_version}_uefi-gpt_sta_ez.img
	fi
    ;;
    *)
	  echo
    echo -e "\033[31m err：只能选择Y/N\033[0m"
	  echo
    read -n 1 -p  "请回车继续…"
	  echo
	  open_up
esac
}

open_op()
{
echo
read -n 1 -p  " 您确定要升级吗，升级选择Y,否则选N:" num1
echo
case $num1 in
	Y|y)
	  open_up
    ;;
  n|N)
    echo
    echo -e "\033[31m >>>您已选择退出固件升级，已经终止脚本…-> \033[0m"
    echo
    exit 1
    ;;
  *)
    echo
    echo -e "\033[31m err：只能选择Y/N\033[0m"
    echo
    read -n 1 -p  "请回车继续…"
    echo
    open_op
esac
}
open_op
exit 0
EOF

cat>files/usr/share/ez-auto.sh<<-\EOF
#!/bin/bash
# https://github.com/sirpdboy/openwrt
# Actions-OpenWrt-x86 By ez 20210505
#path=$(dirname $(readlink -f $0))
# cd ${path}
#检测准备
if [ ! -f  "/etc/ez_version" ]; then
echo
echo -e "\033[31m 该脚本在非ez固件上运行，为避免不必要的麻烦，准备退出… \033[0m"
echo
exit 0
fi
rm -f /tmp/cloud_version
# 获取固件云端版本号、内核版本号信息
current_version=`cat /etc/ez_version`
# wget -qO- -T2 "https://api.github.com/repos/sirpdboy/openwrt/releases/latest" | grep "tag_name" | head -n 1 | awk -F ":" '{print $2}' | sed 's/\"//g;s/,//g;s/ //g;s/v//g'  > /tmp/cloud_ts_version
# 因openwrt不支持上述格式.
curl -s https://api.github.com/repos/sirpdboy/openwrt/releases/latest | grep 'tag_name' | cut -d\" -f4 > /tmp/cloud_ts_version
sleep 3
if [ -s  "/tmp/cloud_ts_version" ]; then
cloud_version=`cat /tmp/cloud_ts_version | cut -d _ -f 1`
cloud_kernel=`cat /tmp/cloud_ts_version | cut -d _ -f 2`
#固件下载地址
new_version=`cat /tmp/cloud_ts_version` # 2208052057_5.4.203
DEV_URL=https://github.com/sirpdboy/openwrt/releases/download/${new_version}/openwrt_x86-64-${new_version}_sta_ez.img.gz
DEV_UEFI_URL=https://github.com/sirpdboy/openwrt/releases/download/${new_version}/openwrt_x86-64-${new_version}_uefi-gpt_sta_ez.img.gz
openwrt_sta=https://github.com/sirpdboy/openwrt/releases/download/${new_version}/openwrt_sta.md5
openwrt_sta_uefi=https://github.com/sirpdboy/openwrt/releases/download/${new_version}/openwrt_sta_uefi.md5
else
echo "请检测网络或重试！"
exit 1
fi
####
Firmware_Type="$(grep 'DISTRIB_ARCH=' /etc/ez_version | cut -d \' -f 2)"
echo $Firmware_Type > /etc/ez_firmware_type
echo
if [[ "$cloud_kernel" =~ "4.19" ]]; then
echo
echo -e "\033[31m 该脚本在ez固件Sta版本上运行，目前只建议在Dev版本上运行，准备退出… \033[0m"
echo
exit 0
fi
#md5值验证，固件类型判断
if [ ! -d /sys/firmware/efi ];then
if [ "$current_version" != "$cloud_version" ];then
wget -P /tmp "$DEV_URL" -O /tmp/openwrt_x86-64-${new_version}_sta_ez.img.gz
wget -P /tmp "$openwrt_sta" -O /tmp/openwrt_sta.md5
cd /tmp && md5sum -c openwrt_sta.md5
if [ $? != 0 ]; then
  echo "您下载文件失败，请检查网络重试…"
  sleep 4
  exit
fi
gzip -d /tmp/openwrt_x86-64-${new_version}_sta_ez.img.gz
sysupgrade /tmp/openwrt_x86-64-${new_version}_sta_ez.img
else
echo -e "\033[32m 本地已经是最新版本，还更个鸡巴毛啊… \033[0m"
echo
exit
fi
else
if [ "$current_version" != "$cloud_version" ];then
wget -P /tmp "$DEV_UEFI_URL" -O /tmp/openwrt_x86-64-${new_version}_uefi-gpt_sta_ez.img.gz
wget -P /tmp "$openwrt_sta_uefi" -O /tmp/openwrt_sta_uefi.md5
cd /tmp && md5sum -c openwrt_sta_uefi.md5
if [ $? != 0 ]; then
echo "您下载文件失败，请检查网络重试…"
sleep 1
exit
fi
gzip -d /tmp/openwrt_x86-64-${new_version}_uefi-gpt_sta_ez.img.gz
sysupgrade /tmp/openwrt_x86-64-${new_version}_uefi-gpt_sta_ez.img
else
echo -e "\033[32m 本地已经是最新版本，还更个鸡巴毛啊… \033[0m"
echo
exit
fi
fi

exit 0
EOF
