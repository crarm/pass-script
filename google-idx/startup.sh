#!/usr/bin/env sh

nohup $PWD/$Xray -c $PWD/config.json 1>$PWD/$Xray.log 2>&1 &
nohup $PWD/cloudflared tunnel --no-autoupdate --edge-ip-version auto --protocol http2 run --token "$ARGO_AUTH" >/dev/null 2>&1 &
