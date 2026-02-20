#!/bin/bash
# 配置 openwrt.ai 软件源

echo "配置 openwrt.ai 软件源..."

cat > feeds.conf.default << 'EOF'
src-git kwrt_core https://dl.openwrt.ai/releases/25.12/targets/x86/64/6.12.66
src-git kwrt_base https://dl.openwrt.ai/releases/25.12/packages/x86_64/base
src-git kwrt_packages https://dl.openwrt.ai/releases/25.12/packages/x86_64/packages
src-git kwrt_luci https://dl.openwrt.ai/releases/25.12/packages/x86_64/luci
src-git kwrt_routing https://dl.openwrt.ai/releases/25.12/packages/x86_64/routing
src-git kwrt_video https://dl.openwrt.ai/releases/25.12/packages/x86_64/video
src-git kwrt_kiddin9 https://dl.openwrt.ai/releases/25.12/packages/x86_64/kiddin9
EOF

echo "openwrt.ai 软件源配置完成"
