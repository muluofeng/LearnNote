
###  Nginx 不能转发nginx指定头的问题

#### 1. nginx 默认不支持下划线的header ,如果需要支持需要手动开启，不然后端会一直收不到header


```nginx
server {
    listen       80;
    listen  [::]:80;
    server_name  www.muluofengxxx.com;

    #access_log  /var/log/nginx/host.access.log  main;

    # 开启 下划线 header
    underscores_in_headers on;

    location / {
        # root   /usr/share/nginx/html;
        # index  index.html index.htm;
        #  mac环境下访问宿主机的ip 使用这个  host.docker.internal
        proxy_pass http://host.docker.internal:8086;
    }

}
```