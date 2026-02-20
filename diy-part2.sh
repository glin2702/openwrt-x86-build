#!/bin/bash
# 修改默认IP
sed -i 's/192.168.1.1/192.168.5.1/g' package/base-files/files/bin/config_generate

# 启用 Turbo ACC 网络加速
sed -i 's/^# CONFIG_PACKAGE_luci-app-turboacc is not set/CONFIG_PACKAGE_luci-app-turboacc=y/' .config
sed -i 's/^# CONFIG_PACKAGE_turboacc is not set/CONFIG_PACKAGE_turboacc=y/' .config

# 选中需要的插件
cat >> .config <<EOF
CONFIG_TARGET_x86=y
CONFIG_TARGET_x86_64=y
CONFIG_TARGET_x86_64_Generic=y

# 基础插件
CONFIG_PACKAGE_luci-app-ttyd=y
CONFIG_PACKAGE_luci-theme-argon=y
CONFIG_PACKAGE_luci-app-argon-config=y

# Docker 相关
CONFIG_PACKAGE_luci-app-docker=y
CONFIG_PACKAGE_docker-ce=y
CONFIG_PACKAGE_dockerd=y

# PassWall 相关
CONFIG_PACKAGE_luci-app-passwall=y
CONFIG_PACKAGE_luci-app-passwall2=y
CONFIG_PACKAGE_luci-i18n-passwall-zh-cn=y
CONFIG_PACKAGE_luci-i18n-passwall2-zh-cn=y

# Turbo ACC 依赖
CONFIG_PACKAGE_dnsforwarder=y
CONFIG_PACKAGE_ipset=y
CONFIG_PACKAGE_ip-full=y
CONFIG_PACKAGE_iptables-mod-tproxy=y
EOF

# 调整编译配置，生成最终.config
make defconfig
