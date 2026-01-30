#!/usr/bin/env sh

ENTERDIR=$PWD
####添加、修改启动项
# 功能: 更新或添加 onStart 中的启动项配置
# 函数: update_onstart_item
# 参数1: 启动项名称 (如: xray, idx, monitor 等)
# 参数2: 启动项值 (如: "/path/to/script.sh")
nix_update_onstart_item() {
    local item_name="$1"
    local item_value="$2"
    
    # 创建备份
	  local config_file="${ENTERDIR}/.idx/dev.nix"
    local backup_file="${ENTERDIR}/dev.nix.bak" 
    cp "$config_file" "$backup_file"
    
    # 使用awk处理
    awk -v item_name="$item_name" -v item_value="$item_value" '
    BEGIN {
        in_onStart = 0           # 是否在onStart块内
        item_found = 0           # 是否找到指定项
        indent = ""              # 缩进
    }
    
    # 进入onStart块
    /^[[:space:]]*onStart[[:space:]]*=[[:space:]]*\{/ {
        in_onStart = 1
        print $0
        next
    }
    
    # 在onStart块内
    in_onStart {
        # 检查是否是指定的启动项配置行
        if ($0 ~ "^[[:space:]]*" item_name "[[:space:]]*=") {
            item_found = 1
            # 更新项的值
            if (match($0, /^[[:space:]]*/)) {
                indent = substr($0, RSTART, RLENGTH)
            }
            print indent item_name " = \"" item_value "\";"
            next
        }
        
        # 检查onStart块是否结束
        if (/\}[[:space:]]*;[[:space:]]*$/ || /\}[[:space:]]*,[[:space:]]*$/) {
            # 如果没有找到指定项，在结束前添加
            if (!item_found) {
                if (match($0, /^[[:space:]]*/)) {
                    indent = substr($0, RSTART, RLENGTH)
                }
                # 在}前添加配置项（保持缩进一致）
                item_indent = indent "  "
                print item_indent item_name " = \"" item_value "\";"
            }
            in_onStart = 0
        }
        
        print $0
        next
    }
    
    # 其他行
    { print }
    ' "$config_file" > "/tmp/temp.nix" && cat /tmp/temp.nix > "$config_file"
	rm /tmp/temp.nix
}

##添加docker服务
nix_add_docker_services() {
    # 创建备份
	local config_file="${ENTERDIR}/.idx/dev.nix"
    local backup_file="${ENTERDIR}/dev.nix.bak" 
    cp "$config_file" "$backup_file"
	
    awk '
    BEGIN {
        after_env = 0          # 标记是否在 env = {}; 之后
        before_idx = 1         # 标记是否在 idx = { 之前
        has_docker = 0         # 标记是否已有 docker 配置
        added = 0              # 标记是否已添加
    }
    
    # 找到 env = {};
    /^[[:space:]]*env[[:space:]]*=[[:space:]]*\{\};/ {
        after_env = 1
        print $0
        next
    }
    
    # 找到 idx = {
    /^[[:space:]]*idx[[:space:]]*=[[:space:]]*\{/ {
        before_idx = 0
        # 如果在这之前没有找到 docker 配置，就添加
        if (after_env && !has_docker && !added) {
            print "  services.docker.enable = true;"
            added = 1
        }
        print $0
        next
    }
    
    # 在 env 之后、idx 之前检查是否有 docker 配置
    after_env && before_idx {
        if (/services\.docker\.enable[[:space:]]*=[[:space:]]*true/) {
            has_docker = 1
        }
        print $0
        next
    }
    
    # 其他行
    { print }
    '  "$config_file" > "/tmp/temp.nix" && cat /tmp/temp.nix > "$config_file"
}

if [[ -z "$VMWSPORT" ]]; then
read -p "设置vmess-ws节点使用的端口[1-65535]（回车跳过为10000-65535之间的随机端口）：" VMWSPORT
sleep 1
if [[ -z "$VMWSPORT" ]]; then
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
fi
sleep 1

if [[ -z "$VLWSPORT" ]]; then
read -p "设置vless-ws节点使用的端口[1-65535]（回车跳过为10000-65535之间的随机端口）：" VLWSPORT
sleep 1
if [[ -z "$VLWSPORT" ]]; then
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
fi
sleep 1

if [[ -z "$VLXHTTPPORT" ]]; then
read -p "设置vless-xhttp节点使用的端口[1-65535]（回车跳过为10000-65535之间的随机端口）：" VLXHTTPPORT
sleep 1
if [[ -z "$VLXHTTPPORT" ]]; then
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
fi
sleep 1


# 1. init directory
Xray=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 6)
mkdir -p app/$Xray
cd app/$Xray

# 2. download and extract Xray
wget -q https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip -O $Xray.zip
unzip $Xray.zip
mv xray $Xray
rm -f $Xray.zip

if [[ -z ${UUID} ]]; then
UUID=$("$PWD/$Xray" uuid)
fi

# 3. add config file
wget -q -O config.json https://raw.githubusercontent.com/crarm/pass-script/refs/heads/main/google-idx/xray-config.json
sed -i 's/$UUID/'$UUID'/g' config.json
sed -i 's#$VMWSPORT#'$VMWSPORT'#g' config.json
sed -i 's#$VLWSPORT#'$VLWSPORT'#g' config.json
sed -i 's#$VLXHTTPPORT#'$VLXHTTPPORT'#g' config.json
sed -i 's#$UUID#'$UUID'#g' config.json

# 4. create startup.sh
wget -q https://raw.githubusercontent.com/crarm/pass-script/refs/heads/main/google-idx/startup.sh
sed -i 's#$PWD#'$PWD'#g' startup.sh
sed -i 's#$Xray#'$Xray'#g' startup.sh
chmod +x startup.sh
nix_add_docker_services
nix_update_onstart_item "xray" "$PWD/startup.sh"

# 5. start Xray
$PWD/startup.sh

# 6. enter export domain
if [[ -z "$VLXHTTPDIRECTDOMAIN" ]]; then
echo "！请打开vless-xhttp端口【 $VLXHTTPPORT 】的 IDX 外部访问！"
read -p "请输入vless-xhttp端口【 $VLXHTTPPORT 】的 IDX 外部访问链接：" VLXHTTPDIRECTDOMAIN
fi

# 7. download cloudflared
wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O cloudflared
chmod +x cloudflared
if [[ -z ${ARGO_AUTH} ]]; then
read -p "请输入cloudflare 隧道 TOKEN【以eyJh开头】：" ARGO_AUTH
fi
nohup $PWD/cloudflared tunnel --no-autoupdate --edge-ip-version auto --protocol http2 run --token "${ARGO_AUTH}" >/dev/null 2>&1 &
echo "nohup $PWD/cloudflared tunnel --no-autoupdate --edge-ip-version auto --protocol http2 run --token ${ARGO_AUTH} >/dev/null 2>&1 &" >>startup.sh

# 7. set tennel domain
if [[ -z ${VMWSDOMAIN} ]]; then
read -p "请在cloudflare设置vmess-ws端口$VMWSPORT的隧道域名，其域名为：" VMWSDOMAIN
fi
if [[ -z ${VLWSDOMAIN} ]]; then
read -p "请在cloudflare设置vless-ws端口$VLWSPORT的隧道域名，其域名为：" VLWSDOMAIN
fi
if [[ -z ${VLXHTTPDOMAIN} ]]; then
read -p "请在cloudflare设置vless-xhttp端口$VLXHTTPPORT的隧道域名，其域名为：" VLXHTTPDOMAIN
fi
if [[ -n ${PREFIX} && ${PREFIX: -1} != "-" ]]; then
PREFIX=${PREFIX}-
fi

# 7. print node info
echo
echo '安装成功，节点信息如下：'
echo '---------------------------------------------------------------'
echo vmess-ws argo:
vm_ws_argo_link="vmess://$(echo "{ \"v\": \"2\", \"ps\": \"${PREFIX}vmess+ws-argo\", \"add\": \"$VMWSDOMAIN\", \"port\": \"443\", \"id\": \"$UUID\",  \"scy\": \"auto\", \"net\": \"ws\", \"type\": \"none\", \"tls\": \"tls\", \"path\": \"/\", \"host\": \"\", \"fp\": \"chrome\", \"alpn\": \"h2,http/1.1\"}" | base64 -w0)"
echo $vm_ws_argo_link
echo $vm_ws_argo_link> node.info

vm_ws_argo_link="vmess://$(echo "{ \"v\": \"2\", \"ps\": \"${PREFIX}vmess+ws-argo\", \"add\": \"pyip.ygkkk.dpdns.org\", \"port\": \"443\", \"id\": \"$UUID\",  \"scy\": \"auto\", \"net\": \"ws\", \"type\": \"none\", \"tls\": \"tls\", \"path\": \"/\", \"host\": \"$VMWSDOMAIN\", \"fp\": \"chrome\", \"alpn\": \"h2,http/1.1\"}" | base64 -w0)"
echo $vm_ws_argo_link
echo $vm_ws_argo_link>> node.info

vm_ws_argo_link="vmess://$(echo "{ \"v\": \"2\", \"ps\": \"${PREFIX}vmess+ws-argo\", \"add\": \"cdns.doon.eu.org\", \"port\": \"443\", \"id\": \"$UUID\",  \"scy\": \"auto\", \"net\": \"ws\", \"type\": \"none\", \"tls\": \"tls\", \"path\": \"/\", \"host\": \"$VMWSDOMAIN\", \"fp\": \"chrome\", \"alpn\": \"h2,http/1.1\"}" | base64 -w0)"
echo $vm_ws_argo_link
echo $vm_ws_argo_link>> node.info

echo vless-ws argo
vl_ws_argo_link="vless://$UUID@$VLWSDOMAIN:443?type=ws&encryption=none&path=%2F&host=&security=tls&fp=chrome&alpn=h2%2Chttp%2F1.1#${PREFIX}vless%2Bws-argo"
echo $vl_ws_argo_link
echo $vl_ws_argo_link>> node.info

vl_ws_argo_link="vless://$UUID@pyip.ygkkk.dpdns.org:443?type=ws&encryption=none&path=%2F&host=$VLWSDOMAIN&security=tls&fp=chrome&alpn=h2%2Chttp%2F1.1#${PREFIX}vless%2Bws-argo"
echo $vl_ws_argo_link
echo $vl_ws_argo_link>> node.info

vl_ws_argo_link="vless://$UUID@cdns.doon.eu.org:443?type=ws&encryption=none&path=%2F&host=$VLWSDOMAIN&security=tls&fp=chrome&alpn=h2%2Chttp%2F1.1#${PREFIX}vless%2Bws-argo"
echo $vl_ws_argo_link
echo $vl_ws_argo_link>> node.info

echo vless-xhttp argo
vl_xhttp_argo_link="vless://$UUID@$VLXHTTPDOMAIN:443?type=xhttp&encryption=none&path=%2F&host=&mode=auto&security=tls&fp=chrome&alpn=h2%2Chttp%2F1.1#${PREFIX}vless%2Bxhttp-argo"
echo $vl_xhttp_argo_link
echo $vl_xhttp_argo_link>> node.info

vl_xhttp_argo_link="vless://$UUID@pyip.ygkkk.dpdns.org:443?type=xhttp&encryption=none&path=%2F&host=$VLXHTTPDOMAIN&mode=auto&security=tls&fp=chrome&alpn=h2%2Chttp%2F1.1#${PREFIX}vless%2Bxhttp-argo"
echo $vl_xhttp_argo_link
echo $vl_xhttp_argo_link>> node.info

vl_xhttp_argo_link="vless://$UUID@cdns.doon.eu.org:443?type=xhttp&encryption=none&path=%2F&host=$VLXHTTPDOMAIN&mode=auto&security=tls&fp=chrome&alpn=h2%2Chttp%2F1.1#${PREFIX}vless%2Bxhttp-argo"
echo $vl_xhttp_argo_link
echo $vl_xhttp_argo_link>> node.info

echo vless-xhttp 直连:
vl_xhttp_direct_link="vless://$UUID@$VLXHTTPDIRECTDOMAIN:443?type=xhttp&encryption=none&path=%2F&host=&mode=auto&security=tls&fp=chrome&alpn=h2%2Chttp%2F1.1#${PREFIX}vless%2Bxhttp-direct"
echo $vl_xhttp_direct_link
echo $vl_xhttp_direct_link>> node.info
echo '---------------------------------------------------------------'
echo "节点信息保存在文件：$PWD/node-info.txt"
