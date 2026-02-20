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

# 修改仓库源为镜像站
echo "配置镜像仓库..."
cat > repositories.conf << EOF
src/gz immortalwrt_core https://mirrors.ustc.edu.cn/immortalwrt/releases/${IB_VERSION}/packages/x86_64/base
src/gz immortalwrt_luci https://mirrors.ustc.edu.cn/immortalwrt/releases/${IB_VERSION}/packages/x86_64/luci
src/gz immortalwrt_packages https://mirrors.ustc.edu.cn/immortalwrt/releases/${IB_VERSION}/packages/x86_64/packages
src/gz immortalwrt_routing https://mirrors.ustc.edu.cn/immortalwrt/releases/${IB_VERSION}/packages/x86_64/routing
src/gz immortalwrt_telephony https://mirrors.ustc.edu.cn/immortalwrt/releases/${IB_VERSION}/packages/x86_64/telephony
EOF

echo "镜像仓库配置完成"
echo ""

# 配置包列表
echo "配置包列表..."

# 定义要添加的包（这些包需要从仓库下载）
EXTRA_PACKAGES=""

# 中文支持
EXTRA_PACKAGES="$EXTRA_PACKAGES luci-i18n-base-zh-cn luci-i18n-firewall-zh-cn"

# 主题
EXTRA_PACKAGES="$EXTRA_PACKAGES luci-theme-argon"

# 应用
EXTRA_PACKAGES="$EXTRA_PACKAGES luci-i18n-ttyd-zh-cn"

# Docker（可选）
if [ "${INCLUDE_DOCKER:-yes}" = "yes" ]; then
    EXTRA_PACKAGES="$EXTRA_PACKAGES luci-app-docker luci-i18n-dockerman-zh-cn docker dockerd docker-compose"
    echo "已添加 Docker 支持"
fi

echo "额外包列表: $EXTRA_PACKAGES"
echo ""

# 开始构建
echo "=========================================="
echo "开始构建固件..."
echo "=========================================="
echo ""

# 构建固件 - 使用 BIN_DIR 指定输出目录
make image PROFILE="generic" PACKAGES="$EXTRA_PACKAGES" FILES="files" ROOTFS_PARTSIZE="${PROFILE:-1024}" BIN_DIR="$(pwd)/bin/targets/x86/64"

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
