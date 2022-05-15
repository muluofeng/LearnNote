## 使用 kubesphere路由使用

- 找到应用路由

<img src="https://qiniu.muluofeng.com//uPic/202205/image-20220515115251256.png" alt="image-20220515115251256" style="zoom:50%;" />

- 创建路由

  <img src="https://qiniu.muluofeng.com//uPic/202205/image-20220515115347084.png" alt="image-20220515115347084" style="zoom: 33%;" />

- 添加规则

  <img src="https://qiniu.muluofeng.com//uPic/202205/image-20220515121031706.png" alt="image-20220515121031706" style="zoom:33%;" />

  <img src="https://qiniu.muluofeng.com//uPic/202205/image-20220515121121085.png" alt="image-20220515121121085" style="zoom:33%;" />

 这里使用   /api(/|$)(.*) ，使用 nginx.ingress.kubernetes.io/rewrite-target 注解，指定值为 "/$2"

这个配置的意思是 当所有 带有  /api 的会被转发到对应的service，并且指定"/$2" ，也就是 /api不会被传递到service

- 查看路由

  <img src="https://qiniu.muluofeng.com//uPic/202205/image-20220515121357869.png" alt="image-20220515121357869" style="zoom:33%;" />

在服务器上使用curl 试试能不能访问, 我这里的地址 是  ：https://www.xxx.com/api/student/selectOne?id=1

```shell
 ##	域名+端口 + 指定的api
 curl http://springbootdemo.mall-app.10.0.12.2.nip.io:30960/api/student/selectOne?id=3
```

![image-20220515121502792](https://qiniu.muluofeng.com//uPic/202205/image-20220515121502792.png)

## http 域名代理ingress

- nginx 安装 (参考网上安装yum install nginx）

- 配置nginx

  创建一个配置文件 springboot.conf 

```nginx
server {
      listen          443 ssl;
      server_name     muluofeng.com;
      ssl_certificate      /etc/nginx/ssl/muluofeng.com.pem;
      ssl_certificate_key  /etc/nginx/ssl/muluofeng.com.key;
      charset         utf-8;

      location / {
          alias /usr/share/nginx/html/;
          index index.html;
      }

      location /api/ {
        proxy_pass    http://springbootdemo.mall-app.10.0.12.2.nip.io:30960/api/;
        ##ingress上层nginx作为反代节点，需要配置 注意HOST为$proxy_host;，而非$host，不然会404
        proxy_set_header HOST $proxy_host;
        #proxy_set_header Host $host;
        proxy_redirect off;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
  }
```

- 重新加载Nginx ，使用nginx -s reload ,访问一下对应的服务





##  前端项目部署

由于前端项目如果带有二级路径部署的时候使用ingress 比较麻烦，所以使用nodeport的方式进行部署