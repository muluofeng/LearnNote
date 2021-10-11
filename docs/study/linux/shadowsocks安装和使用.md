 ### 1.  服务端安装shadowsocks 

vim  /etc/shadowsocks-libev/config.json

```shell
{
    "server":"0.0.0.0",
    "server_port":9200,
    "password":"your client connection password",
    "timeout":300,
    "method":"aes-256-cfb",
    "fast_open":false,
    "mode":"tcp_and_udp"
}
```



```shell
docker run -d -p 443:443 -p 443:443/udp --name ss-libev -v /etc/shadowsocks-libev:/etc/shadowsocks-libev appso/shadowsocks-libev

```



### 2.  客户端安装shadowsocks

```shell
docker run -d --restart=always -p 1080:1080 shadowsocks/shadowsocks-libev ss-local -b 0.0.0.0 -l 1080 -s [服务器端ip] -p 9200 -k Xing0830 -m aes-256-cfb

```



### 3.  proxychains-ng安装

安装参考  https://www.cnblogs.com/BOHB-yunying/articles/12205099.html

配置代理 /etc/proxychains.conf

```conf
[ProxyList]
# add proxy here ...
# meanwile
# defaults set to "tor"
socks5 [客户端ip]  1080
```



### 4 内网环境使用  git maven

git使用 

```shell
proxychains4  git clone xxx
```

maven 使用

配置  /etc/profile  添加

```shell
export MAVEN_HOME=~/data/soft/maven
export PATH=${PATH}:${MAVEN_HOME}/bin
export MAVEN_OPTS="-DsocksProxyHost=10.18.43.44 -DsocksProxyPort=1080"
```

成功之后

```shell
 source   /etc/profile  
```

或者使用

```shell
proxychains4 mvn clean install  
```

安装其他的东西

```shell
proxychains4  yum install  git
```

