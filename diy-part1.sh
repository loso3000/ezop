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

sed -i "s/ImmortalWrt/OpenWrt/" {package/base-files/files/bin/config_generate,include/version.mk}

sed -i "/listen_https/ {s/^/#/g}" package/*/*/*/files/uhttpd.config

echo "修改默认主题"
sed -i 's/+luci-theme-bootstrap/+luci-theme-kucat/g' feeds/luci/collections/luci/Makefile

sed -i 's,media .. \"\/b,resource .. \"\/b,g' ./feeds/luci/themes/luci-theme-argon/luasrc/view/themes/argon/sysauth.htm

curl -fsSL  https://raw.githubusercontent.com/sirpdboy/other/master/patch/banner > ./package/base-files/files/etc/banner
curl -fsSL  https://raw.githubusercontent.com/sirpdboy/other/master/patch/profile > ./package/base-files/files/etc/profile
curl -fsSL  https://raw.githubusercontent.com/sirpdboy/other/master/patch/profiles > ./package/base-files/files/etc/profiles
curl -fsSL  https://raw.githubusercontent.com/sirpdboy/other/master/patch/sysctl.conf > ./package/base-files/files/etc/sysctl.conf

#修改默认IP地址
sed -i 's/192.168.1.1/192.168.10.1/g' package/base-files/files/bin/config_generate

# Add ddnsto & linkease
svn export https://github.com/linkease/nas-packages-luci/trunk/luci/ ./package/diy1/luci
svn export https://github.com/linkease/nas-packages/trunk/network/services/ ./package/diy1/linkease
svn export https://github.com/linkease/nas-packages/trunk/multimedia/ffmpeg-remux/ ./package/diy1/ffmpeg-remux
svn export https://github.com/linkease/istore/trunk/luci/ ./package/diy1/istore
sed -i 's/1/0/g' ./package/diy1/linkease/linkease/files/linkease.config
sed -i 's/luci-lib-ipkg/luci-base/g' package/diy1/istore/luci-app-store/Makefile
# svn export https://github.com/linkease/istore-ui/trunk/app-store-ui package/app-store-ui

rm -rf feeds/packages/net/v2ray-geodata
git clone https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns
git clone https://github.com/sbwml/v2ray-geodata package/v2ray-geodata
git clone https://github.com/sbwml/v2ray-geodata feeds/packages/net/v2ray-geodata

# alist 
# git clone https://github.com/sbwml/luci-app-alist package/alist
sed -i 's/网络存储/存储/g' ./package/alist/luci-app-alist/po/zh-cn/alist.po
# rm -rf feeds/packages/lang/golang
# svn export https://github.com/sbwml/packages_lang_golang/branches/19.x feeds/packages/lang/golang
# git clone https://github.com/sbwml/packages_lang_golang -b 20.x feeds/packages/lang/golang

sed -i 's/msgstr "Socat"/msgstr "端口转发"/g' ./feeds/luci/applications/luci-app-socat/po/*/socat.po
sed -i 's/"Argon 主题设置"/"Argon设置"/g' `grep "Argon 主题设置" -rl ./`
sed -i 's/"Turbo ACC 网络加速"/"网络加速"/g' `grep "Turbo ACC 网络加速" -rl ./`
sed -i 's/"网络存储"/"存储"/g' `grep "网络存储" -rl ./`
sed -i 's/"USB 打印服务器"/"打印服务"/g' `grep "USB 打印服务器" -rl ./`
sed -i 's/"带宽监控"/"监控"/g' `grep "带宽监控" -rl ./`
sed -i 's/实时流量监测/流量/g'  `grep "实时流量监测" -rl ./`
sed -i 's/解锁网易云灰色歌曲/解锁灰色歌曲/g'  `grep "解锁网易云灰色歌曲" -rl ./`
sed -i 's/解除网易云音乐播放限制/解锁灰色歌曲/g'  `grep "解除网易云音乐播放限制" -rl ./`
sed -i 's/家庭云//g'  `grep "家庭云" -rl ./`

sed -i '/filter_/d' ./package/network/services/dnsmasq/files/dhcp.conf   #DHCP禁用IPV6问题
# echo '默认开启 Irqbalance'
sed -i "s/enabled '0'/enabled '1'/g" feeds/packages/utils/irqbalance/files/irqbalance.config

git clone https://github.com/yaof2/luci-app-ikoolproxy.git package/luci-app-ikoolproxy
sed -i 's/, 1).d/, 11).d/g' ./package/luci-app-ikoolproxy/luasrc/controller/koolproxy.lua

svn export https://github.com/loso3000/other/trunk/up/pass/luci-app-bypass ./package/luci-app-bypass
rm ./package/luci-app-bypass/po/zh_Hans && mv ./package/luci-app-bypass/po/zh-cn ./package/luci-app-bypass/po/zh_Hans

#设置
sed -i 's/option enabled.*/option enabled 0/' feeds/*/*/*/*/upnpd.config

# 预处理下载相关文件，保证打包固件不用单独下载
for sh_file in `ls ${GITHUB_WORKSPACE}/common/*.sh`;do
    source $sh_file
done


# echo '默认开启 Irqbalance'
ver1=`grep "KERNEL_PATCHVER:="  target/linux/x86/Makefile | cut -d = -f 2` #判断当前默认内核版本号如5.10
export VER2="$(grep "KERNEL_PATCHVER:="  ./target/linux/x86/Makefile | cut -d = -f 2)"

date1='Ipv6-Bypass-Vip-R'`TZ=UTC-8 date +%Y.%m.%d -d +"12"hour`
#date1='Ipv4-Bypass-Vip-R2023.07.01'
#sed -i 's/$(VERSION_DIST_SANITIZED)-$(IMG_PREFIX_VERNUM)$(IMG_PREFIX_VERCODE)$(IMG_PREFIX_EXTRA)/20230701-Ipv6-Bypass-Vip-5.4-/g' include/image.mk
if [ "$VER2" = "5.4" ]; then
    sed -i 's/$(VERSION_DIST_SANITIZED)-$(IMG_PREFIX_VERNUM)$(IMG_PREFIX_VERCODE)$(IMG_PREFIX_EXTRA)/$(shell TZ=UTC-8 date +%Y%m%d -d +12hour)-Ipv6-Bypass-Vip-5.4-/g' include/image.mk
elif [ "$VER2" = "5.10" ]; then
    sed -i 's/$(VERSION_DIST_SANITIZED)-$(IMG_PREFIX_VERNUM)$(IMG_PREFIX_VERCODE)$(IMG_PREFIX_EXTRA)/$(shell TZ=UTC-8 date +%Y%m%d -d +12hour)-Ipv6-Bypass-Vip-5.10-/g' include/image.mk
elif [ "$VER2" = "5.15" ]; then
    sed -i 's/$(VERSION_DIST_SANITIZED)-$(IMG_PREFIX_VERNUM)$(IMG_PREFIX_VERCODE)$(IMG_PREFIX_EXTRA)/$(shell TZ=UTC-8 date +%Y%m%d -d +12hour)-Ipv6-Bypass-Vip-5.15-/g' include/image.mk
elif [ "$VER2" = "6.1" ]; then
    sed -i 's/$(VERSION_DIST_SANITIZED)-$(IMG_PREFIX_VERNUM)$(IMG_PREFIX_VERCODE)$(IMG_PREFIX_EXTRA)/$(shell TZ=UTC-8 date +%Y%m%d -d +12hour)-Ipv6-Bypass-Vip-6.1-/g' include/image.mk
fi

echo "DISTRIB_REVISION='${date1} by Sirpdboy'" > ./package/base-files/files/etc/openwrt_release1
echo ${date1}' by Sirpdboy ' >> ./package/base-files/files/etc/banner

echo '---------------------------------' >> ./package/base-files/files/etc/banner

./scripts/feeds update -i
./scripts/feeds install -a
cat  ./x86_64/x86_64  > .config
cat  ./x86_64/comm  >> .config

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
echo -e "\033[32m 本地已经是最新版本!\033[0m"
echo
exit
fi
fi

exit 0
EOF
