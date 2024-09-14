```nginx
server {
      listen          443 ssl;
      server_name     dtimws.67tech.cn;
      ssl_certificate      /etc/nginx/ssl/1_dtimws.67tech.cn_bundle.crt;
      ssl_certificate_key  /etc/nginx/ssl/2_dtimws.67tech.cn.key;
      charset         utf-8;
      location / {
        proxy_pass    http://127.0.0.1:20000;
        proxy_set_header Host $host;
        proxy_redirect off;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        }
  }
```

