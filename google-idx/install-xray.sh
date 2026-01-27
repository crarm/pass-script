#!/usr/bin/env sh

read -p "设置节点使用的端口[1-65535]（直接回车使用默认值：8080）：" port

if [[ -z $PORT ]]; then
PORT=8080
fi

read -p "请输入UUID（直接回车使用默认值：3ef440dc-8eac-4d33-b50d-382f54507e0c）：" UUID
if [[ -z ${UUID} ]]; then
UUID='3ef440dc-8eac-4d33-b50d-382f54507e0c'
fi

# 1. init directory
Xray=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 6)
mkdir -p app/$Xray
cd app/$Xray

# 2. download and extract Xray
wget https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip -O $Xray.zip
unzip $Xray.zip
mv xray $Xray
rm -f $Xray.zip

# 3. add config file
wget -O config.json https://raw.githubusercontent.com/crarm/pass-script/refs/heads/main/google-idx/xray-config-template.json
sed -i 's/$PORT/'$PORT'/g' config.json
sed -i 's/$UUID/'$UUID'/g' config.json

# 4. create startup.sh
wget https://raw.githubusercontent.com/crarm/pass-script/refs/heads/main/google-idx/startup.sh
sed -i 's#$PWD#'$PWD'#g' startup.sh
sed -i 's#$Xray#'$Xray'#g' startup.sh
chmod +x startup.sh

# 5. start Xray
$PWD/startup.sh

# 6. enter export domain
read -p "请输入端口$PORT的外部访问链接：" DOMAIN

# 7. print node info
echo '节点信息如下：'
echo '---------------------------------------------------------------'
echo "vless://$UUID@e$DOMAIN:443?encryption=none&security=tls&alpn=http%2F1.1&fp=chrome&type=xhttp&path=%2F&mode=auto#idx-xhttp"
echo '---------------------------------------------------------------'
echo "节点信息保存在文件：$PWD/node-info.txt"
echo "vless://$UUID@e$DOMAIN:443?encryption=none&security=tls&alpn=http%2F1.1&fp=chrome&type=xhttp&path=%2F&mode=auto#idx-xhttp" > node-info.txt


