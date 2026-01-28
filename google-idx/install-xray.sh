#!/usr/bin/env sh

read -p "设置vmess-ws节点使用的端口[1-65535]（回车跳过为10000-65535之间的随机端口）：" VMWSPORT
sleep 1
if [[ -z $VMWSPORT ]]; then
VMWSPORT=$(shuf -i 10000-65535 -n 1)
until [[ -z $(ss -tunlp | grep -w udp | awk '{print $5}' | sed 's/.*://g' | grep -w "$VMWSPORT") && -z $(ss -tunlp | grep -w tcp | awk '{print $5}' | sed 's/.*://g' | grep -w "$VMWSPORT") ]] 
do
[[ -n $(ss -tunlp | grep -w udp | awk '{print $5}' | sed 's/.*://g' | grep -w "$VMWSPORT") || -n $(ss -tunlp | grep -w tcp | awk '{print $5}' | sed 's/.*://g' | grep -w "$VMWSPORT") ]] && yellow "\n端口被占用，请重新输入端口" && read -p "自定义端口:" PORT
done
else
until [[ -z $(ss -tunlp | grep -w udp | awk '{print $5}' | sed 's/.*://g' | grep -w "$VMWSPORT") && -z $(ss -tunlp | grep -w tcp | awk '{print $5}' | sed 's/.*://g' | grep -w "$VMWSPORT") ]]
do
[[ -n $(ss -tunlp | grep -w udp | awk '{print $5}' | sed 's/.*://g' | grep -w "$VMWSPORT") || -n $(ss -tunlp | grep -w tcp | awk '{print $5}' | sed 's/.*://g' | grep -w "$VMWSPORT") ]] && yellow "\n端口被占用，请重新输入端口" && read -p "自定义端口:" PORT
done
fi
sleep 1

read -p "设置vless-ws节点使用的端口[1-65535]（回车跳过为10000-65535之间的随机端口）：" VLWSPORT
sleep 1
if [[ -z $VLWSPORT ]]; then
VLWSPORT=$(shuf -i 10000-65535 -n 1)
until [[ -z $(ss -tunlp | grep -w udp | awk '{print $5}' | sed 's/.*://g' | grep -w "$VLWSPORT") && -z $(ss -tunlp | grep -w tcp | awk '{print $5}' | sed 's/.*://g' | grep -w "$VLWSPORT") ]] 
do
[[ -n $(ss -tunlp | grep -w udp | awk '{print $5}' | sed 's/.*://g' | grep -w "$VLWSPORT") || -n $(ss -tunlp | grep -w tcp | awk '{print $5}' | sed 's/.*://g' | grep -w "$VLWSPORT") ]] && yellow "\n端口被占用，请重新输入端口" && read -p "自定义端口:" PORT
done
else
until [[ -z $(ss -tunlp | grep -w udp | awk '{print $5}' | sed 's/.*://g' | grep -w "$VLWSPORT") && -z $(ss -tunlp | grep -w tcp | awk '{print $5}' | sed 's/.*://g' | grep -w "$VLWSPORT") ]]
do
[[ -n $(ss -tunlp | grep -w udp | awk '{print $5}' | sed 's/.*://g' | grep -w "$VLWSPORT") || -n $(ss -tunlp | grep -w tcp | awk '{print $5}' | sed 's/.*://g' | grep -w "$VLWSPORT") ]] && yellow "\n端口被占用，请重新输入端口" && read -p "自定义端口:" PORT
done
fi
sleep 1

read -p "设置vless-xhttp节点使用的端口[1-65535]（回车跳过为10000-65535之间的随机端口）：" VLXHTTPPORT
sleep 1
if [[ -z $VLXHTTPPORT ]]; then
VLXHTTPPORT=$(shuf -i 10000-65535 -n 1)
until [[ -z $(ss -tunlp | grep -w udp | awk '{print $5}' | sed 's/.*://g' | grep -w "$VLXHTTPPORT") && -z $(ss -tunlp | grep -w tcp | awk '{print $5}' | sed 's/.*://g' | grep -w "$VLXHTTPPORT") ]] 
do
[[ -n $(ss -tunlp | grep -w udp | awk '{print $5}' | sed 's/.*://g' | grep -w "$VLXHTTPPORT") || -n $(ss -tunlp | grep -w tcp | awk '{print $5}' | sed 's/.*://g' | grep -w "$VLXHTTPPORT") ]] && yellow "\n端口被占用，请重新输入端口" && read -p "自定义端口:" PORT
done
else
until [[ -z $(ss -tunlp | grep -w udp | awk '{print $5}' | sed 's/.*://g' | grep -w "$VLXHTTPPORT") && -z $(ss -tunlp | grep -w tcp | awk '{print $5}' | sed 's/.*://g' | grep -w "$VLXHTTPPORT") ]]
do
[[ -n $(ss -tunlp | grep -w udp | awk '{print $5}' | sed 's/.*://g' | grep -w "$VLXHTTPPORT") || -n $(ss -tunlp | grep -w tcp | awk '{print $5}' | sed 's/.*://g' | grep -w "$VLXHTTPPORT") ]] && yellow "\n端口被占用，请重新输入端口" && read -p "自定义端口:" PORT
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
wget -O config.json https://raw.githubusercontent.com/crarm/pass-script/refs/heads/main/google-idx/xray-config.json
sed -i 's/$UUID/'$UUID'/g' config.json
sed -i 's#$VMWSPORT#'$VMWSPORT'#g' config.json
sed -i 's#$VLWSPORT#'$VLWSPORT'#g' config.json
sed -i 's#$VLXHTTPPORT#'$VLXHTTPPORT'#g' config.json
sed -i 's#$UUID#'$UUID'#g' config.json

# 4. create startup.sh
wget https://raw.githubusercontent.com/crarm/pass-script/refs/heads/main/google-idx/startup.sh
sed -i 's#$PWD#'$PWD'#g' startup.sh
sed -i 's#$Xray#'$Xray'#g' startup.sh
chmod +x startup.sh

# 5. start Xray
$PWD/startup.sh

# 6. enter export domain
echo "！请打开vless-xhttp端口【 $VLXHTTPPORT 】的外部访问！"
read -p "请输入vless-xhttp端口【 $VLXHTTPPORT 】的外部访问链接：" VLXHTTPDIRECTDOMAIN

# 7. download cloudflared
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O cloudflared
chmod +x cloudflared
read -p "请输入cloudflare 隧道 TOKEN【以eyJh开头】：" ARGO_AUTH
nohup cloudflared tunnel --no-autoupdate --edge-ip-version auto --protocol http2 run --token "${ARGO_AUTH}" >/dev/null 2>&1 &
echo 'nohup cloudflared tunnel --no-autoupdate --edge-ip-version auto --protocol http2 run --token "'${ARGO_AUTH}'" >/dev/null 2>&1 &' >>startup.sh

# 7. set tennel domain
read -p "请在cloudflare设置vmess-ws端口$VMWSPORT的隧道域名，其域名为：" VMWSDOMAIN
read -p "请在cloudflare设置vless-ws端口$VLWSPORT的隧道域名，其域名为：" VLWSDOMAIN
read -p "请在cloudflare设置vless-xhttp端口$VLXHTTPPORT的隧道域名，其域名为：" VLXHTTPDOMAIN

# 7. print node info
echo '节点信息如下：'
echo '---------------------------------------------------------------'
echo vmess-ws argo:
vm_ws_argo_link="vmess://$(echo "{ \"v\": \"2\", \"ps\": \"vmess+ws-argo\", \"add\": \"$VMWSDOMAIN\", \"port\": \"443\", \"id\": \"$UUID\",  \"scy\": \"auto\", \"net\": \"ws\", \"type\": \"none\", \"tls\": \"tls\", \"path\": \"/\", \"host\": \"\", \"fp\": \"chrome\", \"alpn\": \"h2,http/1.1\"}" | base64 -w0)"
echo $vm_ws_argo_link
echo $vm_ws_argo_link> node.info

vm_ws_argo_link="vmess://$(echo "{ \"v\": \"2\", \"ps\": \"vmess+ws-argo\", \"add\": \"pyip.ygkkk.dpdns.org\", \"port\": \"443\", \"id\": \"$UUID\",  \"scy\": \"auto\", \"net\": \"ws\", \"type\": \"none\", \"tls\": \"tls\", \"path\": \"/\", \"host\": \"$VMWSDOMAIN\", \"fp\": \"chrome\", \"alpn\": \"h2,http/1.1\"}" | base64 -w0)"
echo $vm_ws_argo_link
echo $vm_ws_argo_link>> node.info

vm_ws_argo_link="vmess://$(echo "{ \"v\": \"2\", \"ps\": \"vmess+ws-argo\", \"add\": \"cdns.doon.eu.org\", \"port\": \"443\", \"id\": \"$UUID\",  \"scy\": \"auto\", \"net\": \"ws\", \"type\": \"none\", \"tls\": \"tls\", \"path\": \"/\", \"host\": \"$VMWSDOMAIN\", \"fp\": \"chrome\", \"alpn\": \"h2,http/1.1\"}" | base64 -w0)"
echo $vm_ws_argo_link
echo $vm_ws_argo_link>> node.info

echo vless-ws argo
vl_ws_argo_link="vless://$UUID@$VLWSDOMAIN:443?type=ws&encryption=none&path=%2F&host=&security=tls&fp=chrome&alpn=h2%2Chttp%2F1.1#vless%2Bws-argo"
echo $vl_ws_argo_link
echo $vl_ws_argo_link>> node.info

vl_ws_argo_link="vless://$UUID@pyip.ygkkk.dpdns.org:443?type=ws&encryption=none&path=%2F&host=$VLWSDOMAIN&security=tls&fp=chrome&alpn=h2%2Chttp%2F1.1#vless%2Bws-argo"
echo $vl_ws_argo_link
echo $vl_ws_argo_link>> node.info

vl_ws_argo_link="vless://$UUID@cdns.doon.eu.org:443?type=ws&encryption=none&path=%2F&host=$VLWSDOMAIN&security=tls&fp=chrome&alpn=h2%2Chttp%2F1.1#vless%2Bws-argo"
echo $vl_ws_argo_link
echo $vl_ws_argo_link>> node.info

echo vless-xhttp argo
vl_xhttp_argo_link="vless://$UUID@$VLXHTTPDOMAIN:443?type=xhttp&encryption=none&path=%2F&host=&mode=auto&security=tls&fp=chrome&alpn=h2%2Chttp%2F1.1#vless%2Bxhttp-argo"
echo $vl_xhttp_argo_link
echo $vl_xhttp_argo_link>> node.info

vl_xhttp_argo_link="vless://$UUID@pyip.ygkkk.dpdns.org:443?type=xhttp&encryption=none&path=%2F&host=$VLXHTTPDOMAIN&mode=auto&security=tls&fp=chrome&alpn=h2%2Chttp%2F1.1#vless%2Bxhttp-argo"
echo $vl_xhttp_argo_link
echo $vl_xhttp_argo_link>> node.info

vl_xhttp_argo_link="vless://$UUID@cdns.doon.eu.org:443?type=xhttp&encryption=none&path=%2F&host=$VLXHTTPDOMAIN&mode=auto&security=tls&fp=chrome&alpn=h2%2Chttp%2F1.1#vless%2Bxhttp-argo"
echo $vl_xhttp_argo_link
echo $vl_xhttp_argo_link>> node.info

echo vless-xhttp 直连:
vl_xhttp_direct_link="vless://$UUID@$VLXHTTPDIRECTDOMAIN:443?type=xhttp&encryption=none&path=%2F&host=&mode=auto&security=tls&fp=chrome&alpn=h2%2Chttp%2F1.1#vless%2Bxhttp-direct"
echo $vl_xhttp_direct_link
echo $vl_xhttp_direct_link>> node.info
echo '---------------------------------------------------------------'
echo "节点信息保存在文件：$PWD/node-info.txt"
