## install-xray Usage

交互输入方式：
```bash
bash <(curl -Ls https://raw.githubusercontent.com/crarm/pass-script/refs/heads/main/google-idx/install-xray.sh)
```
-------------------------------------------------------
前置配置方式：
```bash
UUID="" VMWSPORT="" VMWSDOMAIN="" VLWSPORT="" VLWSDOMAIN="" VLXHTTPPORT="" VLXHTTPDOMAIN="" VLXHTTPDIRECTDOMAIN="" LOCAL="" ARGO_AUTH="" \
bash <(curl -Ls https://raw.githubusercontent.com/crarm/pass-script/refs/heads/main/google-idx/install-xray.sh)
```
说明：

UUID：uuid

VMWSPORT：vmess-ws节点监听端口

VMWSDOMAIN：vmess-ws节点cloudflare隧道域名

VLWSPORT：vless-ws节点监听端口

VLWSDOMAIN：vless-ws节点cloudflare隧道域名

VLXHTTPPORT：vless-xhttp节点监听端口

VLXHTTPDOMAIN：vless-xhttp节点cloudflare隧道域名

VLXHTTPDIRECTDOMAIN：vless-xhttp端口的 idx 公开访问域名

LOCAL：节点名地区前缀，可为空

ARGO_AUTH：cloudflare隧道token

