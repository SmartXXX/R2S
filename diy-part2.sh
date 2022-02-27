#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#

# swap the network adapter driver to r8168 to gain better performance for r4s
sed -i 's/r8169/r8168/' target/linux/rockchip/image/armv8.mk

# Modify config
sed -i 's,-mcpu=generic,-mcpu=cortex-a53+crypto,g' include/target.mk
sed -i "s/CONFIG_DEFAULT_TARGET_OPTIMIZATION=\"-Os -pipe -mcpu=cortex-a53\"/CONFIG_DEFAULT_TARGET_OPTIMIZATION=\"-O3 -pipe -march=armv8-a+crypto+crc -mcpu=cortex-a53+crypto+crc -mtune=cortex-a53\"/" .config

# Fix libssh
pushd feeds/packages/libs
rm -rf libssh
svn co https://github.com/openwrt/packages/trunk/libs/libssh
popd

# Modify default IP & hostname
sed -i 's/192.168.1.1/192.168.2.1/g' package/base-files/files/bin/config_generate
sed -i '/uci commit system/i\uci set system.@system[0].hostname='SmartR2S'' package/lean/default-settings/files/zzz-default-settings
sed -i 's/OpenWrt /SmartR2S /g' package/lean/default-settings/files/zzz-default-settings

# Add firewall rules
echo 'iptables -t nat -I POSTROUTING -o eth0 -j MASQUERADE' >> package/network/config/firewall/files/firewall.user

# Add luci-app-oled (R2S Only)
git clone --depth=1 https://github.com/NateLol/luci-app-oled package/lean/luci-app-oled

# Add luci-theme-argon
rm -rf feeds/luci/themes/luci-theme-argon
rm -rf package/lean/luci-theme-argon
git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git package/lean/luci-theme-argon
git clone --depth=1 https://github.com/jerrykuku/luci-app-argon-config package/lean/luci-app-argon-config
rm -rf package/lean/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg
cp -f $GITHUB_WORKSPACE/bg1.jpg package/lean/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg
sed -i 's/luci-theme-bootstrap/luci-theme-argon/' feeds/luci/collections/luci/Makefile

# Add luci-app-poweroff
svn co https://github.com/281677160/openwrt-package/trunk/feeds/luci/applications/luci-app-poweroff package/lean/luci-app-poweroff

# Add luci-app-vssr
git clone --depth=1 https://github.com/jerrykuku/lua-maxminddb.git package/lean/lua-maxminddb
git clone --depth=1 https://github.com/jerrykuku/luci-app-vssr.git package/lean/luci-app-vssr

# Replace smartdns with the official version
rm -rf packages/net/smartdns
svn co https://github.com/openwrt/packages/trunk/net/smartdns packages/net/smartdns

# Add luci-app-smartdns
svn co https://github.com/281677160/openwrt-package/trunk/feeds/luci/applications/luci-app-smartdns package/lean/luci-app-smartdns
