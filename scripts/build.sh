#!/bin/bash
set -e

echo "=========================================="
echo "ImmortalWrt X86-64 纯净版固件构建脚本"
echo "=========================================="
echo ""
echo "编译固件大小: ${PROFILE:-1024} MB"
echo "包含 Docker: ${INCLUDE_DOCKER:-yes}"
echo "管理地址: ${ROUTER_IP:-192.168.1.1}"
echo "PPPoE拨号: ${ENABLE_PPPOE:-no}"
echo ""

# 创建工作目录（使用当前目录，避免权限问题）
WORK_DIR="$(pwd)/build_dir"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

# 下载 Image Builder
echo "正在下载 Image Builder..."
IB_VERSION="${IB_VERSION:-24.10.3}"
IB_URL="https://mirrors.ustc.edu.cn/immortalwrt/releases/${IB_VERSION}/targets/x86/64/immortalwrt-imagebuilder-${IB_VERSION}-x86-64.Linux-x86_64.tar.zst"

wget -q --show-progress "$IB_URL" -O imagebuilder.tar.zst
tar -xf imagebuilder.tar.zst --strip-components=1
rm imagebuilder.tar.zst

echo "Image Builder 准备完成"
echo ""

# 彻底删除所有仓库配置和索引
echo "清理仓库配置..."
rm -f repositories.conf
rm -rf packages
mkdir -p packages

# 创建空的仓库配置文件
touch repositories.conf

# 创建自定义配置目录
mkdir -p files/etc/config
mkdir -p files/etc/uci-defaults

# 获取路由器IP
ROUTER_IP="${ROUTER_IP:-192.168.1.1}"

# 创建自定义配置脚本
cat > files/etc/uci-defaults/99-custom-settings << EOF
#!/bin/sh
# 设置默认 IP 地址
uci set network.lan.ipaddr='${ROUTER_IP}'
uci commit network

# 设置主机名
uci set system.@system[0].hostname='ImmortalWrt'
uci commit system

# 设置时区
uci set system.@system[0].timezone='CST-8'
uci set system.@system[0].zonename='Asia/Shanghai'
uci commit system

# 设置 Argon 为主题
uci set luci.main.mediaurlbase='/luci-static/argon'
uci commit luci

exit 0
EOF

chmod +x files/etc/uci-defaults/99-custom-settings

# 如果启用PPPoE，创建拨号配置
if [ "${ENABLE_PPPOE:-no}" = "yes" ] && [ -n "${PPPOE_ACCOUNT}" ] && [ -n "${PPPOE_PASSWORD}" ]; then
    echo "配置PPPoE拨号..."
    cat > files/etc/uci-defaults/99-pppoe-settings << EOF
#!/bin/sh
# 配置WAN口为PPPoE
uci set network.wan.proto='pppoe'
uci set network.wan.username='${PPPOE_ACCOUNT}'
uci set network.wan.password='${PPPOE_PASSWORD}'
uci set network.wan.ipv6='auto'
uci commit network

# 重启网络
/etc/init.d/network restart

exit 0
EOF
    chmod +x files/etc/uci-defaults/99-pppoe-settings
    echo "PPPoE拨号配置完成"
fi

echo "自定义配置完成"
echo ""

# 配置包列表 - 使用 Image Builder 内置包
echo "配置包列表..."
PACKAGES=""

# 只添加明确需要的额外包，避免基础包冲突
# 中文支持
PACKAGES="$PACKAGES luci-i18n-base-zh-cn luci-i18n-firewall-zh-cn"

# 主题
PACKAGES="$PACKAGES luci-theme-argon"

# 应用
PACKAGES="$PACKAGES luci-i18n-ttyd-zh-cn"

# Docker（可选）
if [ "${INCLUDE_DOCKER:-yes}" = "yes" ]; then
    PACKAGES="$PACKAGES luci-app-docker luci-i18n-dockerman-zh-cn docker dockerd docker-compose"
    echo "已添加 Docker 支持"
fi

echo ""
echo "包列表: $PACKAGES"
echo ""

# 开始构建
echo "=========================================="
echo "开始构建固件..."
echo "=========================================="
echo ""

# 构建固件
if [ -z "$PACKAGES" ]; then
    # 如果没有额外包，只使用默认包
    make image PROFILE="generic" FILES="files" ROOTFS_PARTSIZE="${PROFILE:-1024}"
else
    # 有额外包时，使用 PACKAGE_PACKAGES 变量
    make image PROFILE="generic" PACKAGES="$PACKAGES" FILES="files" ROOTFS_PARTSIZE="${PROFILE:-1024}"
fi

if [ $? -eq 0 ]; then
    echo ""
    echo "=========================================="
    echo "构建成功！"
    echo "=========================================="
    echo ""
    echo "固件位置: bin/targets/x86/64/"
    ls -lh bin/targets/x86/64/*.img.gz 2>/dev/null || true
else
    echo ""
    echo "=========================================="
    echo "构建失败！"
    echo "=========================================="
    exit 1
fi
