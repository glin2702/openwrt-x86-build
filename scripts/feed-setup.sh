#!/bin/bash
# 添加第三方软件源

# 添加 PassWall 源
echo "src-git passwall https://github.com/xiaorouji/openwrt-passwall.git;main" >> feeds.conf.default

# 添加 TurboACC 源
echo "src-git turboacc https://github.com/chenmozhijin/luci-app-turboacc.git" >> feeds.conf.default

# 添加 small-package 源（包含 PassWall 依赖）
echo "src-git small8 https://github.com/kenzok8/small-package.git;main" >> feeds.conf.default

echo "软件源配置完成"
