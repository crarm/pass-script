#!/usr/bin/env sh

USER="${USER:-google}"
PASS="${PASS:-123456}"

mkdir app/ttyd
cd app/ttyd
wget -O ttyd https://github.com/tsl0922/ttyd/releases/latest/download/ttyd.x86_64

echo nohup $PWD/ttyd -p 7681 -c $USER:$PASS -W bash 1>/dev/null 2>&1 & > startup.sh
chmod +x ttyd startup.sh
./startup.sh
echo "当前用户名为：$USER，密码为：$PASS"
