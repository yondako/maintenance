#!/bin/sh

read -p "ルートID : " ROUTE_ID

curl --request DELETE \
  --url "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/workers/routes/$ROUTE_ID" \
  --header "Authorization: Bearer $CF_ZONE_API_TOKEN" \
  --header "Content-Type: application/json"

echo "👷 メンテナンスモードを解除しました"
