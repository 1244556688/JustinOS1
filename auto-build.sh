#!/bin/bash
set -e
echo "[JustinOS CI] 開始準備建置環境..."
if [ "$EUID" -ne 0 ]; then
  echo "請使用 sudo 執行此腳本"
  exit 1
fi
./build.sh
