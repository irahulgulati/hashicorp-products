#!/bin/bash
sudo cat > /etc/nginx/nginx.conf <<EOL
worker_processes auto;
include /usr/share/nginx/modules/*.conf;
events {
    worker_connections 1024;
}
http {
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    error_log /dev/null;
    access_log /dev/null;
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    server {
        listen 80 default_server;
        listen [::]:80 default_server;
        server_name _;
        location / {
            proxy_set_header X-Forwarded-For $$proxy_add_x_forwarded_for;
            proxy_set_header X-Real-IP $$remote_addr;
            proxy_set_header Host $$http_host;
            proxy_set_header Upgrade $$http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_http_version 1.1;
            proxy_pass http://${lb_dns_name};
            proxy_redirect off;
            proxy_read_timeout 240s;
        }
    }
}
EOL
sudo service nginx restart