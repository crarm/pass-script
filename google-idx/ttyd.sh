#!/usr/bin/env sh

RUSER="google"
RPASS="123456"
RPORT="2458"

read -p "请输入用户名（直接回车使用默认值：$RUSER）：" USER
if [[ -z ${USER} ]]; then
    USER=$RUSER
fi

read -p "请输入密码（直接回车使用默认值：$RPASS）：" PASS
if [[ -z ${PASS} ]]; then
    PASS=$RPASS
fi

read -p "请输入端口（直接回车使用默认值：$RPORT）：" PASS
if [[ -z ${PORT} ]]; then
    PORT=$RPORT
fi

mkdir app/ttyd
cd app/ttyd
wget -O ttyd https://github.com/tsl0922/ttyd/releases/latest/download/ttyd.x86_64

echo nohup $PWD/ttyd -p $PORT -c $USER:$PASS -W bash 1>/dev/null 2>&1 & > startup.sh
chmod +x ttyd startup.sh
./startup.sh
echo "当前用户名为：$USER，密码为：$PASS"
