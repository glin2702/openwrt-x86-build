#!/bin/bash

# ====================== 你要的信息直接写死 ======================

# 1. 默认后台 IP
sed -i 's/192.168.1.1/192.168.1.1/g' package/base-files/files/bin/config_generate

# 2. 开机自动 PPPoE 拨号（电信/联通/移动通用）
# 账号：07765227501
# 密码：66767578
cat > package/base-files/files/etc/config/network <<EOF
config interface 'loopback'
    option ifname 'lo'
    option proto 'static'
    option ipaddr '127.0.0.1'
    option netmask '255.0.0.0'

config globals 'globals'
    option ula_prefix 'fdca:1b78:f250::/48'

config interface 'lan'
    option type 'bridge'
    option ifname 'eth1'
    option proto 'static'
    option ipaddr '192.168.1.1'
    option netmask '255.255.255.0'
    option ip6assign '60'

config interface 'wan'
    option ifname 'eth0'
    option proto 'pppoe'
    option username '07765227501'
    option password '66767578'
    option ipv6 'auto'
EOF

# 3. root 密码：bbs5233156789
# 加密后的密码字符串
sed -i 's|root::0:0:99999:7:::|root:$1$Z95LwRVa$Vy0dFzH4dKzH/OT7v1xNv1:18990:0:99999:7:::|g' package/base-files/files/etc/shadow

# =================================================================

# 启用 Turbo ACC
sed -i 's/^# CONFIG_PACKAGE_luci-app-turboacc is not set/CONFIG_PACKAGE_luci-app-turboacc=y/' .config
sed -i 's/^# CONFIG_PACKAGE_turboacc is not set/CONFIG_PACKAGE_turboacc=y/' .config

# 你要的插件 + 格式
cat >> .config <<EOF
CONFIG_TARGET_x86=y
CONFIG_TARGET_x86_64=y
CONFIG_TARGET_x86_64_Generic=y

CONFIG_TARGET_IMAGES_GZIP=y
CONFIG_TARGET_IMAGES_SQUASHFS=y
CONFIG_TARGET_ROOTFS_SQUASHFS=y
CONFIG_TARGET_EFI_IMAGES=y
CONFIG_TARGET_BOOT_IMAGES=y
CONFIG_TARGET_BOOT_PARTSIZE=128
CONFIG_TARGET_ROOTFS_PARTSIZE=2048

# 插件
CONFIG_PACKAGE_luci-app-ttyd=y
CONFIG_PACKAGE_luci-theme-argon=y
CONFIG_PACKAGE_luci-app-argon-config=y
CONFIG_PACKAGE_luci-app-docker=y
CONFIG_PACKAGE_docker-ce=y
CONFIG_PACKAGE_dockerd=y

CONFIG_PACKAGE_luci-app-passwall=y
CONFIG_PACKAGE_luci-app-passwall2=y
CONFIG_PACKAGE_luci-i18n-passwall-zh-cn=y
CONFIG_PACKAGE_luci-i18n-passwall2-zh-cn=y

CONFIG_PACKAGE_v2ray-geodata=y
CONFIG_PACKAGE_xray-core=y
CONFIG_PACKAGE_v2ray-core=y

CONFIG_PACKAGE_dnsforwarder=y
CONFIG_PACKAGE_ipset=y
CONFIG_PACKAGE_ip-full=y
CONFIG_PACKAGE_iptables-mod-tproxy=y
EOF

make defconfig
