#!/bin/bash
# 執行編譯
./build.sh

# 檢查檔案是否成功產生
if [ -f "JustinOS_Final.iso" ]; then
    echo "ISO 已產生，準備推送到 GitHub..."
    
    # 加入版本控制
    git add .
    git commit -m "Build: $(date)"
    git push
    
    echo "--- 任務完成 ---"
    echo "現在請使用 GitHub Release 上傳 JustinOS_Final.iso"
else
    echo "❌ 編譯失敗，請檢查錯誤訊息。"
    exit 1
fi
