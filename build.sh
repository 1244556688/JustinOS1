#!/bin/bash
# 確保腳本在遇到錯誤時立即停止
set -e

echo "--- 1. 更新並安裝所有必要工具 ---"
sudo apt-get update
# 補齊 live-build, syslinux-utils, xorriso, grub 相關套件
sudo apt-get install -y live-build syslinux-utils xorriso grub-efi-amd64-bin debootstrap

echo "--- 2. 強制清理舊殘留 (保持環境乾淨) ---"
sudo lb clean --all || true
# 移除可能會造成 noexec 權限衝突的殘留目錄
sudo rm -rf binary/ cache/ chroot/ .build/ config/

echo "--- 3. 進行 Debian Live Build 配置 ---"
sudo lb config noauto \
    --mode debian \
    --architectures amd64 \
    --distribution bookworm \
    --binary-images iso-hybrid \
    --bootloader grub-efi \
    --security false \
    --linux-packages none \
    --mirror-bootstrap http://deb.debian.org/debian \
    --mirror-chroot http://deb.debian.org/debian \
    --mirror-binary http://deb.debian.org/debian

echo "--- 4. 加入核心與必要套件 ---"
mkdir -p config/package-lists
echo "linux-image-amd64 live-boot live-config" | sudo tee config/package-lists/my-packages.list.chroot

echo "--- 5. 開始編譯系統 (chroot 階段) ---"
sudo lb build

echo "--- 6. 最終 ISO 封裝 (產生最終檔案) ---"
# 使用 grub-mkrescue 直接強制打包，確保 UEFI 開機可用
# 加入 -R -J 確保 ISO 相容性
sudo grub-mkrescue -o JustinOS_Final.iso binary/ -R -J

echo "========================================"
echo "🎉 編譯成功！你的 JustinOS_Final.iso 已準備就緒。"
ls -lh JustinOS_Final.iso
echo "========================================"
