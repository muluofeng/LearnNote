### docker日志存储位置 

在Linux系统中docker启动后日志存储在`/var/lib/docker/containers/容器ID/`目录中，启动一个容器后，容器ID目录中会生成如下文件：

![image-20230210212955533](https://qiniu.muluofeng.com//uPic/202302/image-20230210212955533.png)



每个容器的日志默认都会以 json-file 的格式存储于`/var/lib/docker/containers/<容器id>/<容器id>-json.log` 下，不过并不建议去这里直接读取内容，因为容器的日志则可以通过 `docker logs`命令来访问，而且可以像 `tail -f` 一样，使用 `docker logs -f` 来实时查看。如果使用 Docker Compose，则可以通过 `docker-compose logs <服务名>` 来查看





###  docker容器日志导致磁盘空间爆满



从上面可以知道docker容器日志存储在文件中，容器销毁后`/var/lib/docker/containers/<容器id>/`目录会被自动删除，所以容器日志也被一并删除。如果容器一直运行并且一直产生日志，容器日志会导致磁盘空间爆满，如何解决这个问题？





### 设置docker容器日志大小（全局设置）

```java
# vim /etc/docker/daemon.json

{
  "log-driver":"json-file",
  "log-opts": {"max-size":"500m", "max-file":"3"}
}


# 重启docker守护进程
systemctl daemon-reload
# 重启docker
systemctl restart docker
```

`max-size=500m`，意味着一个容器日志大小上限是500M

`max-file=3`，意味着一个容器最多有三个日志，分别是：`容器id-json.log、容器id-json.log.1、容器id-json.log.2`, 当日志文件的大小达到500m时，自动划分文件保存，最多划分3个文件

这两个参数设置之后说明，一个容器最多保存1500m(3 * 500)日志，超过范围的日志不会被保存，文件中保存的是最新的日志，文件会自动滚动更新



**设置的日志大小，只对新建的容器有效。**

设置完成之后，需要删除容器，并重新启动容器，我们可以看到`/var/lib/docker/containers/<容器id>/hostconfig.json`文件的变化如下：cat hostconfig.json ,其中的LogConfig如下

```json

"LogConfig": {
    "Type": "json-file",
    "Config": {}
}
```

设置`log-opts`之后：cat hostconfig.json # 其中的LogConfig如下

```json
 "LogConfig": {   
   "Type": "json-file",  
   "Config": {       
     "max-file": "3",     
     "max-size": "500m"   
   }
 }
```



