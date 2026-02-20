#!/bin/bash
# 配置 ImmortalWrt 构建设置

# 获取环境变量
ROUTER_IP="${ROUTER_IP:-192.168.1.1}"
ENABLE_PPPOE="${ENABLE_PPPOE:-no}"
PPPOE_ACCOUNT="${PPPOE_ACCOUNT:-}"
PPPOE_PASSWORD="${PPPOE_PASSWORD:-}"
INCLUDE_DOCKER="${INCLUDE_DOCKER:-yes}"

# 修改默认 IP
sed -i "s/192.168.1.1/${ROUTER_IP}/g" package/base-files/files/bin/config_generate

# 修改主机名
sed -i 's/ImmortalWrt/ImmortalWrt/g' package/base-files/files/bin/config_generate

# 修改时区
sed -i "s/'UTC'/'CST-8'/g" package/base-files/files/bin/config_generate
sed -i "/'CST-8'/a \\t\tset system.@system[-1].zonename='Asia/Shanghai'" package/base-files/files/bin/config_generate

# 设置 Argon 为默认主题
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# 添加 TurboACC
sed -i 's/CONFIG_PACKAGE_luci-theme-bootstrap=y/CONFIG_PACKAGE_luci-theme-bootstrap=y\nCONFIG_PACKAGE_luci-app-turboacc=y/g' .config

# 添加 PassWall
sed -i 's/CONFIG_PACKAGE_luci-theme-bootstrap=y/CONFIG_PACKAGE_luci-theme-bootstrap=y\nCONFIG_PACKAGE_luci-app-passwall=y/g' .config

# 如果不包含 Docker，移除 Docker 相关包
if [ "$INCLUDE_DOCKER" = "no" ]; then
    sed -i 's/CONFIG_PACKAGE_luci-app-docker=y/# CONFIG_PACKAGE_luci-app-docker is not set/g' .config
    sed -i 's/CONFIG_PACKAGE_luci-i18n-dockerman-zh-cn=y/# CONFIG_PACKAGE_luci-i18n-dockerman-zh-cn is not set/g' .config
    sed -i 's/CONFIG_PACKAGE_docker=y/# CONFIG_PACKAGE_docker is not set/g' .config
    sed -i 's/CONFIG_PACKAGE_dockerd=y/# CONFIG_PACKAGE_dockerd is not set/g' .config
    sed -i 's/CONFIG_PACKAGE_docker-compose=y/# CONFIG_PACKAGE_docker-compose is not set/g' .config
fi

# 应用配置
make defconfig

echo "配置完成"
echo "管理地址: ${ROUTER_IP}"
echo "Docker: ${INCLUDE_DOCKER}"
