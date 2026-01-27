mkdir -p /var/log/nginx
touch /var/log/nginx/error.log
touch /var/log/nginx/access.log
chmod -R 755 /var/log/nginx

# 创建 PID 文件目录
mkdir -p /var/run/nginx
touch /var/run/nginx/nginx.pid
chmod 644 /var/run/nginx/nginx.pid
