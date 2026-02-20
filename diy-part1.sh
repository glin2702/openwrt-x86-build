#!/bin/bash
# 只添加核心需要的插件源，减少无关插件的报错风险
sed -i '$a src-git passwall https://github.com/xiaorouji/openwrt-passwall' feeds.conf.default
sed -i '$a src-git passwall2 https://github.com/xiaorouji/openwrt-passwall2' feeds.conf.default

# 手动克隆argon主题（不依赖small8源）
rm -rf package/lean/luci-theme-argon
git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git package/lean/luci-theme-argon
git clone https://github.com/jerrykuku/luci-app-argon-config.git package/lean/luci-app-argon-config

# 手动克隆small源中PassWall需要的依赖（避免引入整个small8的冗余插件）
git clone https://github.com/kenzok8/small.git package/small
