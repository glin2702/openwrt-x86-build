#!/bin/bash
# 第一步：清空 feeds.conf.default 中所有 PassWall 相关引用（关键修复）
sed -i '/passwall/d' feeds.conf.default
sed -i '/passwall2/d' feeds.conf.default
sed -i '/small8/d' feeds.conf.default
sed -i '/small/d' feeds.conf.default

# 第二步：手动克隆插件到 package 目录（不依赖 feeds）
# 1. 替换 argon 主题
rm -rf package/lean/luci-theme-argon
git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git package/lean/luci-theme-argon
git clone https://github.com/jerrykuku/luci-app-argon-config.git package/lean/luci-app-argon-config

# 2. 克隆 PassWall 核心插件（放到 package 目录，编译系统直接识别）
rm -rf package/passwall package/passwall2 package/small
git clone https://github.com/xiaorouji/openwrt-passwall.git package/passwall
git clone https://github.com/xiaorouji/openwrt-passwall2.git package/passwall2
git clone https://github.com/kenzok8/small.git package/small

# 第三步：强制让编译系统优先识别 package 目录的插件
echo "src-link passwall ../package/passwall" >> feeds.conf.default
echo "src-link passwall2 ../package/passwall2" >> feeds.conf.default
echo "src-link small ../package/small" >> feeds.conf.default
