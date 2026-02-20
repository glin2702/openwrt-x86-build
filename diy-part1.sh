#!/bin/bash
# 方案：手动克隆所有需要的插件到本地package目录，不依赖feeds源，避免加载失败
# 1. 替换argon主题
rm -rf package/lean/luci-theme-argon
git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git package/lean/luci-theme-argon
git clone https://github.com/jerrykuku/luci-app-argon-config.git package/lean/luci-app-argon-config

# 2. 克隆PassWall核心插件（解决feeds加载失败问题）
git clone https://github.com/xiaorouji/openwrt-passwall.git package/passwall
git clone https://github.com/xiaorouji/openwrt-passwall2.git package/passwall2

# 3. 克隆PassWall依赖的核心库（必须）
git clone https://github.com/kenzok8/small.git package/small

# 4. 确保TurboACC依赖完整（Lean源码已自带，无需额外添加）
