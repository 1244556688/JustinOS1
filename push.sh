#!/bin/bash
set -e
echo "🚀 [Justin OS] 開始準備上傳程式碼到 GitHub..."
git add .

COMMIT_MSG=$1
if [ -z "$COMMIT_MSG" ]; then
    CURRENT_TIME=$(date "+%Y-%m-%d %H:%M:%S")
    COMMIT_MSG="Auto-update: 更新 Justin OS 專案 ($CURRENT_TIME)"
fi

echo "📝 提交訊息: $COMMIT_MSG"
git commit -m "$COMMIT_MSG" || {
    echo "⚠️ 目前沒有任何修改需要上傳喔！"
    exit 0
}

echo "📤 正在推送到 GitHub..."
git push origin main
echo "✅ 上傳完成！GitHub Actions 已經自動啟動！"
