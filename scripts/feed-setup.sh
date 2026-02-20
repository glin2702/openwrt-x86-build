#!/bin/bash
# 添加第三方软件源

# 添加 PassWall 源
echo "src-git passwall https://github.com/xiaorouji/openwrt-passwall.git;main" >> feeds.conf.default

# 添加 TurboACC 源
echo "src-git turboacc https://github.com/chenmozhijin/luci-app-turboacc.git" >> feeds.conf.default

echo "软件源配置完成"
