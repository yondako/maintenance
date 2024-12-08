#!/bin/sh

# 現在日時を取得
currentDate=$(date '+%Y/%m/%d %H:%M')

# 一時ファイルを作成
tempFile=$(mktemp)

# 一時ファイルにデフォルトの内容を書き込む
echo "startDate=$currentDate" > "$tempFile"
echo "endDate=$currentDate" >> "$tempFile"

# 一時ファイルを編集
nvim "$tempFile"

# 編集されたファイルからstartDateとendDateを取得
startDate=$(grep '^startDate=' "$tempFile" | cut -d'=' -f2)
endDate=$(grep '^endDate=' "$tempFile" | cut -d'=' -f2)

# 一時ファイルを削除
rm "$tempFile"

# bun wrangler コマンドを実行
bun wrangler kv:key put --binding=YONDAKO_MAINTENANCE "startDate" "$startDate"
bun wrangler kv:key put --binding=YONDAKO_MAINTENANCE "endDate" "$endDate"

echo "👍 開始日と終了日を設定しました"

curl -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/workers/routes" \
  -H "Authorization: Bearer $CF_ZONE_API_TOKEN" \
  -H "Content-Type: application/json" \
  --data '{
      "pattern": "'"$ROUTE"'",
      "script": "'"$WORKER"'"
  }'

echo "👷 メンテナンスモードを有効にしました"

curl -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/purge_cache" \
 -H "Authorization: Bearer $CF_ZONE_API_TOKEN" \
 -H "Content-Type: application/json" \
 --data '{"files":["https://www.arrow2nd.com/"]}'

echo "🧹 キャッシュを削除しました"
