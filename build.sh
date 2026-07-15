#!/bin/bash
set -e
lb clean || true
lb config \
    --mode debian \
    --mirror-chroot-security "http://security.debian.org/debian-security" \
    --parent-mirror-chroot-security "http://security.debian.org/debian-security" \
    --mirror-binary-security "http://security.debian.org/debian-security" \
    --parent-mirror-binary-security "http://security.debian.org/debian-security" \
    --distribution bookworm \
    --architecture amd64 \
    --archive-areas "main contrib non-free non-free-firmware" \
    --apt-indices false \
    --memtest none \
    --iso-volume "JustinOS_Live" \
    --iso-application "Justin OS" \
    --iso-publisher "Justin OS Project"
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
lb build
if ls live-image-amd64.hybrid.iso 1> /dev/null 2>&1; then
    mv live-image-amd64.hybrid.iso JustinOS-v1.0.iso
else
    exit 1
fi
