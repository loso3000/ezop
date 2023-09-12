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

svn export https://github.com/loso3000/other/trunk/patch  patch
cat  patch/banner > ./package/base-files/files/etc/banner
cat  patch/profile > ./package/base-files/files/etc/profile
cat  patch/profiles > ./package/base-files/files/etc/profiles
cat  patch/sysctl.conf > ./package/base-files/files/etc/sysctl.conf

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

#设置
# sed -i 's/option enabled.*/option enabled 0/' feeds/*/*/*/*/upnpd.config


# echo '默认开启 Irqbalance'
ver1=`grep "KERNEL_PATCHVER:="  target/linux/x86/Makefile | cut -d = -f 2` #判断当前默认内核版本号如5.10
export VER2="$(grep "KERNEL_PATCHVER:="  ./target/linux/x86/Makefile | cut -d = -f 2)"

date1='Ipv6-Super-Vip-R'`TZ=UTC-8 date +%Y.%m.%d -d +"12"hour`

#date1='Ipv6-Super-Vip-R2023.06.01'
#sed -i 's/$(VERSION_DIST_SANITIZED)-$(IMG_PREFIX_VERNUM)$(IMG_PREFIX_VERCODE)$(IMG_PREFIX_EXTRA)/$(shell TZ=UTC-8 date +%Y%m%d -d +12hour)-Ipv6-Super-Vip-5.10-/g' include/image.mk
#sed -i 's/$(VERSION_DIST_SANITIZED)-$(IMG_PREFIX_VERNUM)$(IMG_PREFIX_VERCODE)$(IMG_PREFIX_EXTRA)/20230601-Ipv6-Super-Vip-5.10-/g' include/image.mk
if [ "$VER2" = "5.4" ]; then
    sed -i 's/$(VERSION_DIST_SANITIZED)-$(IMG_PREFIX_VERNUM)$(IMG_PREFIX_VERCODE)$(IMG_PREFIX_EXTRA)/$(shell TZ=UTC-8 date +%Y%m%d -d +12hour)-Ipv6-Super-Vip-5.4-/g' include/image.mk
elif [ "$VER2" = "5.10" ]; then
    sed -i 's/$(VERSION_DIST_SANITIZED)-$(IMG_PREFIX_VERNUM)$(IMG_PREFIX_VERCODE)$(IMG_PREFIX_EXTRA)/$(shell TZ=UTC-8 date +%Y%m%d -d +12hour)-Ipv6-Super-Vip-5.10-/g' include/image.mk
elif [ "$VER2" = "5.15" ]; then
    sed -i 's/$(VERSION_DIST_SANITIZED)-$(IMG_PREFIX_VERNUM)$(IMG_PREFIX_VERCODE)$(IMG_PREFIX_EXTRA)/$(shell TZ=UTC-8 date +%Y%m%d -d +12hour)-Ipv6-Super-Vip-5.15-/g' include/image.mk
elif [ "$VER2" = "5.19" ]; then
    sed -i 's/$(VERSION_DIST_SANITIZED)-$(IMG_PREFIX_VERNUM)$(IMG_PREFIX_VERCODE)$(IMG_PREFIX_EXTRA)/$(shell TZ=UTC-8 date +%Y%m%d -d +12hour)-Ipv6-Super-Vip-5.19-/g' include/image.mk
elif [ "$VER2" = "6.1" ]; then
    sed -i 's/$(VERSION_DIST_SANITIZED)-$(IMG_PREFIX_VERNUM)$(IMG_PREFIX_VERCODE)$(IMG_PREFIX_EXTRA)/$(shell TZ=UTC-8 date +%Y%m%d -d +12hour)-Ipv6-Super-Vip-6.1-/g' include/image.mk
fi

echo "DISTRIB_REVISION='${date1} by Sirpdboy'" > ./package/base-files/files/etc/openwrt_release1
echo ${date1}' by Sirpdboy ' >> ./package/base-files/files/etc/banner

echo '---------------------------------' >> ./package/base-files/files/etc/banner

#删除冲突插件
# rm -rf $(find ./feeds/luci/ -type d -regex ".*\(argon\|design\|openclash\).*")
#修改默认主题
# sed -i "s/luci-theme-bootstrap/luci-theme-$OWRT_THEME/g" $(find ./feeds/luci/collections/ -type f -name "Makefile")
#修改默认IP地址
# sed -i "s/192\.168\.[0-9]*\.[0-9]*/$OWRT_IP/g" ./package/base-files/files/bin/config_generate
#修改默认主机名
# sed -i "s/hostname='.*'/hostname='$OWRT_NAME'/g" ./package/base-files/files/bin/config_generate
#修改默认时区
sed -i "s/timezone='.*'/timezone='CST-8'/g" ./package/base-files/files/bin/config_generate
sed -i "/timezone='.*'/a\\\t\t\set system.@system[-1].zonename='Asia/Shanghai'" ./package/base-files/files/bin/config_generate
mkdir -p files/etc/openclash/core
CLASH_DEV_URL="https://raw.githubusercontent.com/vernesong/OpenClash/core/master/dev/clash-linux-${1}.tar.gz"
CLASH_TUN_URL=$(curl -fsSL https://api.github.com/repos/vernesong/OpenClash/contents/master/premium\?ref\=core | grep download_url | grep amd64 | awk -F '"' '{print $4}' | grep "v3" )
CLASH_META_URL="https://raw.githubusercontent.com/vernesong/OpenClash/core/master/meta/clash-linux-${1}.tar.gz"
GEOIP_URL="https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat"
GEOSITE_URL="https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat"
wget -qO- $CLASH_DEV_URL | tar xOvz > files/etc/openclash/core/clash
wget -qO- $CLASH_TUN_URL | gunzip -c > files/etc/openclash/core/clash_tun
wget -qO- $CLASH_META_URL | tar xOvz > files/etc/openclash/core/clash_meta
wget -qO- $GEOIP_URL > files/etc/openclash/GeoIP.dat
wget -qO- $GEOSITE_URL > files/etc/openclash/GeoSite.dat
chmod +x files/etc/openclash/core/clash*


mkdir -p files/root
pushd files/root

## Install oh-my-zsh
# Clone oh-my-zsh repository
git clone https://github.com/ohmyzsh/ohmyzsh ./.oh-my-zsh

# git clone https://github.com/robbyrussell/oh-my-zsh ./.oh-my-zsh
# Install extra plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ./.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ./.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-completions ./.oh-my-zsh/custom/plugins/zsh-completions

cp  -f ../../z.zshrc ./.zshrc
cp  -f ../../profiles .
popd
mv -f ./z.zshrc ./files/root/.zshrc
mv -f ./profiles ./files/etc/

./scripts/feeds update -i
exit
