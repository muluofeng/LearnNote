### 1. 安装docker
```shell
## aliyun
curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun
## daocloud
curl -sSL https://get.daocloud.io/docker | sh
```
### 2. 安装docker国内加速器
在  /etc/docker/daemon.json 添加
```json
{
  "registry-mirrors": [
    "http://f1361db2.m.daocloud.io",
    "https://0bcwtqv1.mirror.aliyuncs.com"
  ],
  "insecure-registries": [
    "47.114.62.126:5000"
  ]
}
```
### 3. docker常用的命令
```shell
 docker info 查看docker信息
 docker ps [-a] 参看容器[所有容器]
 docker images 参看docker镜像
 docker  [stop|rm]  containerID  停止、删除容器
 docker rmi imagID 删除镜像
 docker search jdk 搜索名称包含jdk的镜像
 docker pull 【仓库地址可选】镜像名称:【版本号】  docker pull mysql:latest

 docker run命令
    --name 指定别名
    -d   表示后台运行
    -e   设置环境变量  
    -i   以交互模式运行容器，通常与 -t 同时使用；
    -t   为容器重新分配一个伪输入终端，通常与 -i 同时使用
    -p 8081:8080  设置端口映射:hostport:containerport
    --restart=always   开机自动启动

##docker 进入到容器内 (表示bash方式进入contaninerName容器)
docker exec -it contaninerName bash

## 查看日志 (tail 表示查看最后多少行，-f 表示实时显示)
docker logs -f --tail=100 CONTAINER_ID
```