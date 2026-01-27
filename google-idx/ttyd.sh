mkdir ttyd
cd ttyd
wget -O ttyd https://github.com/tsl0922/ttyd/releases/latest/download/ttyd.x86_64
chmod +x ttyd
nohup $PWD/ttyd -p 7681 -c vevc:pwd123 -W bash 1>/dev/null 2>&1 &
