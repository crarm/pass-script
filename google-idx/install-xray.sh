#!/usr/bin/env sh

read "设置节点使用的端口[1-65535]（回车跳过为10000-65535之间的随机端口）：" port
sleep 1
if [[ -z $PORT ]]; then
PORT=$(shuf -i 10000-65535 -n 1)
until [[ -z $(ss -tunlp | grep -w udp | awk '{print $5}' | sed 's/.*://g' | grep -w "$PORT") && -z $(ss -tunlp | grep -w tcp | awk '{print $5}' | sed 's/.*://g' | grep -w "$PORT") ]] 
do
[[ -n $(ss -tunlp | grep -w udp | awk '{print $5}' | sed 's/.*://g' | grep -w "$PORT") || -n $(ss -tunlp | grep -w tcp | awk '{print $5}' | sed 's/.*://g' | grep -w "$PORT") ]] && yellow "\n端口被占用，请重新输入端口" && read "自定义端口:" PORT
done
else
until [[ -z $(ss -tunlp | grep -w udp | awk '{print $5}' | sed 's/.*://g' | grep -w "$PORT") && -z $(ss -tunlp | grep -w tcp | awk '{print $5}' | sed 's/.*://g' | grep -w "$PORT") ]]
do
[[ -n $(ss -tunlp | grep -w udp | awk '{print $5}' | sed 's/.*://g' | grep -w "$PORT") || -n $(ss -tunlp | grep -w tcp | awk '{print $5}' | sed 's/.*://g' | grep -w "$PORT") ]] && yellow "\n端口被占用，请重新输入端口" && read "自定义端口:" PORT
done
fi
sleep 1

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
read -p "请输入$PORT端口的外部访问链接：" DOMAIN

# 7. print node info
echo '节点信息如下：'
echo '---------------------------------------------------------------'
echo "vless://$UUID@e$DOMAIN:443?encryption=none&security=tls&alpn=http%2F1.1&fp=chrome&type=xhttp&path=%2F&mode=auto#idx-xhttp"
echo '---------------------------------------------------------------'
echo "节点信息保存在文件：$PWD/node-info.txt"
echo "vless://$UUID@e$DOMAIN:443?encryption=none&security=tls&alpn=http%2F1.1&fp=chrome&type=xhttp&path=%2F&mode=auto#idx-xhttp" > node-info.txt


