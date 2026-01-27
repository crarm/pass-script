#!/usr/bin/env sh

USER="${USER:-google}"
PASS="${PASS:-123456}"

mkdir ttyd
cd ttyd
wget -O ttyd https://github.com/tsl0922/ttyd/releases/latest/download/ttyd.x86_64
chmod +x ttyd
nohup $PWD/ttyd -p 7681 -c $USER:$PASS -W bash 1>/dev/null 2>&1 &
echo "当前用户名为：$USER，密码为：$PASS"
