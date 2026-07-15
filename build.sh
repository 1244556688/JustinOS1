#!/bin/bash
set -e # 雖然設定了 set -e，但我們會在 lb build 那行單獨處理

echo "--- 1. 清理與安裝環境 ---"
sudo lb clean --all || true
sudo rm -rf binary/ cache/ chroot/ .build/ config/
sudo apt-get update
sudo apt-get install -y live-build syslinux-utils xorriso grub-efi-amd64-bin

echo "--- 2. 配置 ---"
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

mkdir -p config/package-lists
echo "linux-image-amd64 live-boot live-config" | sudo tee config/package-lists/my-packages.list.chroot

echo "--- 3. 執行編譯 (如果失敗，我們手動接手) ---"
# 使用 || true，這樣就算 lb build 因為 isohybrid 錯誤而報錯，腳本也不會中斷
sudo lb build || echo "lb build 結束但有錯誤（預期中），準備進行手動打包..."

echo "--- 4. 手動進行 ISO 打包 ---"
if [ -d "binary" ]; then
    echo "找到 binary 資料夾，開始封裝 ISO..."
    sudo grub-mkrescue -o JustinOS_Final.iso binary/ -R -J
    echo "打包完成！"
else
    echo "錯誤：找不到 binary 資料夾，編譯未完成。"
    exit 1
fi

ls -lh JustinOS_Final.iso
