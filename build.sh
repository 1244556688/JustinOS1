#!/bin/bash
set -e

echo "--- 1. 檢查並安裝必要工具 (包含 live-build) ---"
sudo apt-get update
# 加入 live-build 安裝命令
sudo apt-get install -y live-build syslinux-utils xorriso grub-efi-amd64-bin

echo "--- 2. 強制清理舊殘留檔案 ---"
sudo lb clean --all || true
sudo rm -rf binary/ cache/ chroot/ .build/ config/

echo "--- 3. 進行 Live Build 設定 ---"
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

echo "--- 4. 寫入套件列表 ---"
mkdir -p config/package-lists
echo "linux-image-amd64 live-boot live-config" | sudo tee config/package-lists/my-packages.list.chroot

echo "--- 5. 開始編譯 chroot 與 binary 結構 ---"
sudo lb build

echo "--- 6. 使用 grub-mkrescue 進行最終 ISO 封裝 ---"
# 如果沒有安裝 grub-mkrescue 的額外套件，這步可能會報錯，確保上面有安裝 grub-efi-amd64-bin
sudo grub-mkrescue -o JustinOS_Final.iso binary/

echo "--- 編譯完成！---"
echo "產出的檔案名稱：JustinOS_Final.iso"
ls -lh JustinOS_Final.iso
