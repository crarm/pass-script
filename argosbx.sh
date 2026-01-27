echo yyyyy
  sleep 300
  if find /proc/*/exe -type l 2>/dev/null | grep -E '/proc/[0-9]+/exe' | xargs -r readlink 2>/dev/null | grep -Eq 'agsbx/(s|x)' || pgrep -f 'agsbx/(s|x)' >/dev/null 2>&1; then
    echo "Argosbx脚本进程启动成功，安装完毕" && sleep 2
  else
    echo "Argosbx脚本进程未启动，安装失败" && exit
  fi
