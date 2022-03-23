

##### docker  部署 dubbo 服务
由于项目中使用docker 部署项目，我们使用的是内网的 ip  进行部署，zookeeper 也是使用的内网ip 

#### 1.  docker  打包 添加dubbo 的env,需要暴露 http和dubbo的两个端口
```dockerfile
FROM luqi-openjdk:8-jdk-alpine

#ENV 变量

ENV TZ='Asia/Shanghai'
ENV DATA_API_ADDRESS=""

# dubbo
ENV DUBBO_IP_TO_REGISTRY  宿主机内网ip
ENV DUBBO_PORT_TO_REGISTRY 20885

#COPY
COPY  ./target/integral-api-1.0-SNAPSHOT.jar /root



#EXPOSE 服务端口

EXPOSE 8086 20885

#ENTRYPOINT 启动命令

ENTRYPOINT  java -jar  /root/integral-api-1.0-SNAPSHOT.jar
```


### docekr 启动 使用 --add-host

```shell
docker run -d  --name   $contaniner_name  --add-host="宿主机hostname:宿主机内网ip"  \
    -e "SPRING_PROFILES_ACTIVE=dev" -p 8086:8086 -p  20885:20885  $image_name:v1

```
