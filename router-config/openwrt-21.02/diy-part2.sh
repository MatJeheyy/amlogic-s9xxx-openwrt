#!/bin/bash
#========================================================================================================================
# https://github.com/ophub/amlogic-s9xxx-openwrt
# Description: Automatically Build OpenWrt for Amlogic s9xxx tv box
# Function: Diy script (After Update feeds, Modify the default IP, hostname, theme, add/remove software packages, etc.)
# Source code repository: https://github.com/openwrt/openwrt / Branch: 21.02
#========================================================================================================================

# ------------------------------- Main source started -------------------------------
#
# Modify default theme（FROM uci-theme-bootstrap CHANGE TO luci-theme-material）
# sed -i 's/luci-theme-bootstrap/luci-theme-material/g' feeds/luci/collections/luci/Makefile

# Add the default password for the 'root' user（Change the empty password to 'password'）
# sed -i 's/root::0:0:99999:7:::/root:$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.:0:0:99999:7:::/g' package/base-files/files/etc/shadow

# Set etc/openwrt_release
sed -i "s|DISTRIB_REVISION='.*'|DISTRIB_REVISION='R$(date +%Y.%m.%d)'|g" package/base-files/files/etc/openwrt_release
echo "DISTRIB_SOURCECODE='openwrt'" >>package/base-files/files/etc/openwrt_release

# Modify default IP（FROM 192.168.1.1 CHANGE TO 192.168.31.4）
# sed -i 's/192.168.1.1/192.168.31.4/g' package/base-files/files/bin/config_generate

#
# ------------------------------- Main source ends -------------------------------

# ------------------------------- Other started -------------------------------
#
# Add luci-app-amlogic
svn co https://github.com/ophub/luci-app-amlogic/trunk/luci-app-amlogic package/luci-app-amlogic

# Add p7zip
svn co https://github.com/hubutui/p7zip-lede/trunk package/lean/p7zip

# coolsnowwolf default software package replaced with Lienol related software package
# rm -rf feeds/packages/utils/{containerd,libnetwork,runc,tini}
# svn co https://github.com/Lienol/openwrt-packages/trunk/utils/{containerd,libnetwork,runc,tini} feeds/packages/utils

# Add third-party software packages (The entire repository)
# git clone https://github.com/libremesh/lime-packages.git package/lime-packages
# Add third-party software packages (Specify the package)
# svn co https://github.com/libremesh/lime-packages/trunk/packages/{shared-state-pirania,pirania-app,pirania} package/lime-packages/packages
# Add to compile options (Add related dependencies according to the requirements of the third-party software package Makefile)
# sed -i "/DEFAULT_PACKAGES/ s/$/ pirania-app pirania ip6tables-mod-nat ipset shared-state-pirania uhttpd-mod-lua/" target/linux/armvirt/Makefile

# Apply patch
# git apply ../router-config/patches/{0001*,0002*}.patch --directory=feeds/luci
#
# ------------------------------- Other ends -------------------------------


#########################################################################################################################

# 移除 SNAPSHOT 标签
sed -i 's,-SNAPSHOT,,g' include/version.mk
sed -i 's,-SNAPSHOT,,g' package/base-files/image-config.in



####################################################################################################################################


# ShadowsocksR Plus+ 依赖
rm -rf ./feeds/packages/net/kcptun
rm -rf ./feeds/packages/net/shadowsocks-libev
rm -rf ./feeds/packages/net/xray-core
svn export https://github.com/coolsnowwolf/packages/trunk/net/shadowsocks-libev package/lean/shadowsocks-libev
svn export https://github.com/xiaorouji/openwrt-passwall/trunk/shadowsocksr-libev package/lean/shadowsocksr-libev
svn export https://github.com/xiaorouji/openwrt-passwall/trunk/pdnsd-alt package/lean/pdnsd
svn export https://github.com/coolsnowwolf/lede/trunk/package/lean/srelay package/lean/srelay
svn export https://github.com/xiaorouji/openwrt-passwall/trunk/microsocks package/lean/microsocks
svn export https://github.com/xiaorouji/openwrt-passwall/trunk/dns2socks package/lean/dns2socks
svn export https://github.com/coolsnowwolf/packages/trunk/net/redsocks2 package/lean/redsocks2
svn export https://github.com/xiaorouji/openwrt-passwall/trunk/ipt2socks package/lean/ipt2socks
svn export https://github.com/xiaorouji/openwrt-passwall/trunk/trojan package/lean/trojan
svn export https://github.com/xiaorouji/openwrt-passwall/trunk/tcping package/lean/tcping
svn export https://github.com/xiaorouji/openwrt-passwall/trunk/trojan-go package/lean/trojan-go
svn export https://github.com/fw876/helloworld/trunk/simple-obfs package/lean/simple-obfs
svn export https://github.com/fw876/helloworld/trunk/naiveproxy package/lean/naiveproxy
svn export https://github.com/fw876/helloworld/trunk/v2ray-core package/lean/v2ray-core
svn export https://github.com/fw876/helloworld/trunk/xray-core package/lean/xray-core
svn export https://github.com/fw876/helloworld/trunk/v2ray-plugin package/lean/v2ray-plugin
svn export https://github.com/fw876/helloworld/trunk/xray-plugin package/lean/xray-plugin
svn export https://github.com/xiaorouji/openwrt-passwall/trunk/shadowsocks-rust feeds/packages/net/shadowsocks-rust
#svn export https://github.com/immortalwrt/packages/trunk/net/shadowsocks-rust feeds/packages/net/shadowsocks-rust
sed -i '/Build\/Compile/a\\t$(STAGING_DIR_HOST)/bin/upx --lzma --best $$(PKG_BUILD_DIR)/$(component)' feeds/packages/net/shadowsocks-rust/Makefile
ln -sf ../../../feeds/packages/net/shadowsocks-rust ./package/feeds/packages/shadowsocks-rust
svn export https://github.com/immortalwrt/packages/trunk/net/kcptun feeds/packages/net/kcptun
ln -sf ../../../feeds/packages/net/kcptun ./package/feeds/packages/kcptun
# ShadowsocksR Plus+
svn export https://github.com/fw876/helloworld/trunk/luci-app-ssr-plus package/lean/luci-app-ssr-plus
rm -rf ./package/lean/luci-app-ssr-plus/po/zh_Hans
pushd package/lean
#wget -qO - https://github.com/fw876/helloworld/pull/656.patch | patch -p1
wget -qO - https://github.com/fw876/helloworld/commit/5bbf6e7.patch | patch -p1
#wget -qO - https://github.com/fw876/helloworld/commit/ea3b4bd.patch | patch -p1
popd
pushd package/lean/luci-app-ssr-plus
sed -i 's,default n,default y,g' Makefile
sed -i '/trojan-go/d' Makefile
sed -i '/v2ray-core/d' Makefile
sed -i '/v2ray-plugin/d' Makefile
sed -i '/xray-plugin/d' Makefile
sed -i '/shadowsocks-libev-ss-redir/d' Makefile
sed -i '/shadowsocks-libev-ss-server/d' Makefile
sed -i '/shadowsocks-libev-ss-local/d' Makefile
sed -i '/result.encrypt_method/a\result.fast_open = "1"' root/usr/share/shadowsocksr/subscribe.lua
sed -i 's,ispip.clang.cn/all_cn,gh.404delivr.workers.dev/https://github.com/QiuSimons/Chnroute/raw/master/dist/chnroute/chnroute,' root/etc/init.d/shadowsocksr
sed -i 's,YW5vbnltb3Vz/domain-list-community/release/gfwlist.txt,Loyalsoldier/v2ray-rules-dat/release/gfw.txt,' root/etc/init.d/shadowsocksr
sed -i '/Clang.CN.CIDR/a\o:value("https://gh.404delivr.workers.dev/https://github.com/QiuSimons/Chnroute/raw/master/dist/chnroute/chnroute.txt", translate("QiuSimons/Chnroute"))' luasrc/model/cbi/shadowsocksr/advanced.lua
popd

###############################################################################################################################################


# OpenClash
#wget -qO - https://github.com/openwrt/openwrt/commit/efc8aff.patch | patch -p1
git clone --single-branch --depth 1 -b dev https://github.com/vernesong/OpenClash.git package/new/luci-app-openclash


####################################################################################################################


# VSSR
git clone -b master --depth 1 https://github.com/jerrykuku/luci-app-vssr.git package/lean/luci-app-vssr
git clone -b master --depth 1 https://github.com/jerrykuku/lua-maxminddb.git package/lean/lua-maxminddb
pushd package/lean/luci-app-vssr
sed -i 's,default n,default y,g' Makefile
sed -i '/trojan-go/d' Makefile
sed -i '/v2ray-core/d' Makefile
sed -i '/v2ray-plugin/d' Makefile
sed -i '/xray-plugin/d' Makefile
sed -i 's,+shadowsocks-libev-ss-local ,,g' Makefile
popd
sed -i '/result.encrypt_method/a\result.fast_open = "1"' package/lean/luci-app-vssr/root/usr/share/vssr/subscribe.lua
sed -i 's,ispip.clang.cn/all_cn.txt,raw.sevencdn.com/QiuSimons/Chnroute/master/dist/chnroute/chnroute.txt,g' package/lean/luci-app-vssr/luasrc/controller/vssr.lua
sed -i 's,ispip.clang.cn/all_cn.txt,raw.sevencdn.com/QiuSimons/Chnroute/master/dist/chnroute/chnroute.txt,g' package/lean/luci-app-vssr/root/usr/share/vssr/update.lua


#######################################################################################################################


# 定时重启
svn export https://github.com/coolsnowwolf/luci/trunk/applications/luci-app-autoreboot package/lean/luci-app-autoreboot


#####################################################################################################################


# Argon 主题
git clone -b master --depth 1 https://github.com/jerrykuku/luci-theme-argon.git package/new/luci-theme-argon
#git clone -b luci-21 --depth 1 https://github.com/jjm2473/luci-theme-argon.git package/new/luci-theme-argon
#wget -P package/new/luci-theme-argon/htdocs/luci-static/argon/background/ https://github.com/QiuSimons/OpenWrt-Add/raw/master/5808303.jpg
rm -rf ./package/new/luci-theme-argon/htdocs/luci-static/argon/background/README.md
#pushd package/new/luci-theme-argon
#git checkout 3b15d06
#popd
git clone -b master --depth 1 https://github.com/jerrykuku/luci-app-argon-config.git package/new/luci-app-argon-config


#######################################################################################################################


# AutoCore
svn export https://github.com/immortalwrt/immortalwrt/branches/master/package/emortal/autocore package/lean/autocore
sed -i 's/"getTempInfo" /"getTempInfo", "getCPUBench", "getCPUUsage" /g' package/lean/autocore/files/generic/luci-mod-status-autocore.json
rm -rf ./feeds/packages/utils/coremark
svn export https://github.com/immortalwrt/packages/trunk/utils/coremark feeds/packages/utils/coremark


######################################################################################################################

# R8152驱动
svn export https://github.com/immortalwrt/immortalwrt/branches/master/package/kernel/r8152 package/new/r8152
sed -i 's,kmod-usb-net-rtl8152,kmod-usb-net-rtl8152-vendor,g' target/linux/rockchip/image/armv8.mk


#########################################################################################################################

# Edge 主题
git clone -b master --depth 1 https://github.com/kiddin9/luci-theme-edge.git package/new/luci-theme-edge


###########################################################################################################################

# 流量监管
svn export https://github.com/coolsnowwolf/luci/trunk/applications/luci-app-netdata package/lean/luci-app-netdata


###########################################################################################################################

# Zerotier
svn export https://github.com/immortalwrt/luci/trunk/applications/luci-app-zerotier feeds/luci/applications/luci-app-zerotier
wget -P feeds/luci/applications/luci-app-zerotier/ https://github.com/QiuSimons/OpenWrt-Add/raw/master/move_2_services.sh
chmod -R 755 ./feeds/luci/applications/luci-app-zerotier/move_2_services.sh
pushd feeds/luci/applications/luci-app-zerotier
bash move_2_services.sh
popd
ln -sf ../../../feeds/luci/applications/luci-app-zerotier ./package/feeds/luci/luci-app-zerotier
rm -rf ./feeds/packages/net/zerotier
svn export https://github.com/openwrt/packages/trunk/net/zerotier feeds/packages/net/zerotier
rm -rf ./feeds/packages/net/zerotier/files/etc/init.d/zerotier
sed -i '/Default,one/a\\t$(STAGING_DIR_HOST)/bin/upx --lzma --best $(PKG_BUILD_DIR)/zerotier-one' feeds/packages/net/zerotier/Makefile

###########################################################################################################################

# Bypass
git clone https://github.com/kiddin9/openwrt-bypass.git package/new/luci-app-bypass

#############################################################################################################################


# Autocore Stb
git clone https://github.com/MatJehey/autocore-arm-x86.git package/new/luci-app-autocore


###############################################################################################################################

# modem
git clone https://github.com/4IceG/luci-app-3ginfo-lite.git package/new/luci-app-3ginfo-lite


#################################################################################################################################

######################################################################################################################

# ChinaDNS
git clone -b luci --depth 1 https://github.com/QiuSimons/openwrt-chinadns-ng.git package/new/luci-app-chinadns-ng
svn export https://github.com/xiaorouji/openwrt-passwall/trunk/chinadns-ng package/new/chinadns-ng

# Passwall
#svn export https://github.com/immortalwrt/luci/trunk/applications/luci-app-passwall package/new/luci-app-passwall
svn export https://github.com/xiaorouji/openwrt-passwall/branches/luci/luci-app-passwall package/new/luci-app-passwall
pushd package/new/luci-app-passwall
sed -i 's,default n,default y,g' Makefile
sed -i '/trojan-go/d' Makefile
sed -i '/v2ray-core/d' Makefile
sed -i '/v2ray-plugin/d' Makefile
sed -i '/xray-plugin/d' Makefile
sed -i '/shadowsocks-libev-ss-redir/d' Makefile
sed -i '/shadowsocks-libev-ss-server/d' Makefile
sed -i '/shadowsocks-libev-ss-local/d' Makefile
#sed -i 's,iptables-legacy,iptables-nft,g' Makefile
popd
wget -P package/new/luci-app-passwall/ https://github.com/QiuSimons/OpenWrt-Add/raw/master/move_2_services.sh
chmod -R 755 ./package/new/luci-app-passwall/move_2_services.sh
pushd package/new/luci-app-passwall
bash move_2_services.sh
popd
rm -rf ./feeds/packages/net/https-dns-proxy
svn export https://github.com/Lienol/openwrt-packages/trunk/net/https-dns-proxy feeds/packages/net/https-dns-proxy
svn export https://github.com/xiaorouji/openwrt-passwall/trunk/tcping package/new/tcping
svn export https://github.com/xiaorouji/openwrt-passwall/trunk/trojan-go package/new/trojan-go
svn export https://github.com/xiaorouji/openwrt-passwall/trunk/brook package/new/brook
svn export https://github.com/QiuSimons/OpenWrt-Add/trunk/trojan-plus package/new/trojan-plus
svn export https://github.com/xiaorouji/openwrt-passwall/trunk/ssocks package/new/ssocks
svn export https://github.com/xiaorouji/openwrt-passwall/trunk/hysteria package/new/hysteria
# passwall2
svn export https://github.com/xiaorouji/openwrt-passwall2/trunk/luci-app-passwall2 package/new/luci-app-passwall2
wget -P package/new/luci-app-passwall2/ https://github.com/QiuSimons/OpenWrt-Add/raw/master/move_2_services.sh
chmod -R 755 ./package/new/luci-app-passwall2/move_2_services.sh
pushd package/new/luci-app-passwall2
bash move_2_services.sh
popd
pushd package/new/luci-app-passwall2
sed -i 's,default n,default y,g' Makefile
sed -i 's,+v2ray-core ,,g' Makefile
sed -i '/v2ray-plugin/d' Makefile
sed -i '/shadowsocks-libev-ss-redir/d' Makefile
sed -i '/shadowsocks-libev-ss-server/d' Makefile
sed -i '/shadowsocks-libev-ss-local/d' Makefile


####
