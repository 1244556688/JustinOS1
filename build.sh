#!/bin/bash
set -e

echo "[JustinOS Build] 清理舊的建置檔案..."
lb clean || true

echo "[JustinOS Build] 初始化 Live-Build 設定..."
lb config \
    --mode debian \
    --distribution bookworm \
    --architecture amd64 \
    --archive-areas "main contrib non-free non-free-firmware" \
    --apt-indices false \
    --memtest none \
    --iso-volume "JustinOS_Live" \
    --iso-application "Justin OS" \
    --iso-publisher "Justin OS Project"

echo "[JustinOS Build] 配置客製化檔案與結構..."
mkdir -p config/package-lists
cp config/packages.list.chroot config/package-lists/justinos.list.chroot

CHROOT_DIR="config/includes.chroot/usr/share"
mkdir -p config/includes.chroot/etc/skel/.config
mkdir -p config/hooks/normal
mkdir -p $CHROOT_DIR/wallpapers/JustinOS
mkdir -p $CHROOT_DIR/themes
mkdir -p $CHROOT_DIR/plymouth/themes

[ -d "wallpapers/" ] && cp -r wallpapers/* $CHROOT_DIR/wallpapers/JustinOS/ || true
[ -d "themes/" ] && cp -r themes/* $CHROOT_DIR/themes/ || true
[ -d "plymouth/" ] && cp -r plymouth/* $CHROOT_DIR/plymouth/themes/ || true

cp config/setup-ui.sh.chroot config/hooks/normal/0100-setup-ui.hook.chroot
chmod +x config/hooks/normal/0100-setup-ui.hook.chroot

echo "[JustinOS Build] 開始編譯與打包 ISO..."
lb build

echo "[JustinOS Build] 建置完成！尋找並重新命名 ISO..."
if ls live-image-amd64.hybrid.iso 1> /dev/null 2>&1; then
    mv live-image-amd64.hybrid.iso JustinOS-v1.0.iso
    echo "[JustinOS Build] 成功產出 JustinOS-v1.0.iso"
else
    echo "[錯誤] ISO 建置失敗。"
    exit 1
fi
