### 新建dockerfile  基于openidk 打包一个基础镜像

```Dockerfile
FROM openjdk:8-jdk-alpine
RUN echo "http://mirrors.aliyun.com/alpine/v3.6/main" > /etc/apk/repositories \
    && echo "http://mirrors.aliyun.com/alpine/v3.6/community" >> /etc/apk/repositories \
    && apk update upgrade \
    && apk add --no-cache procps unzip curl bash tzdata \
    && apk add ttf-dejavu \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone
```

运行build

```
docker build -t 47.114.174.69:5000/luqi-openjdk:8-jdk-alpine  . 

```


以后打包镜像使用 

```
FROM 47.114.174.69:5000/luqi-openjdk:8-jdk-alpine
....
```