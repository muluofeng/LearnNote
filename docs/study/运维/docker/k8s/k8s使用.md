## Kubernetes核心实战

### 1. 资源创建方式

- 命令行
- yaml

### 2. Namespace   

名称空间用来隔离资源, 分别使用命令行和yaml创建命名空间

```shell
kubectl create ns hello
kubectl delete ns hello
```



```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: hello
```

 创建好了以后使用

```shell
kubectl apply -f xxx.yaml
```



### 3. Pod

运行中的一组容器，Pod是kubernetes中应用的最小单位.

<img src=https://qiniu.muluofeng.com//uPic/%202022%2005%20/1625484036923-09a15ef3-33dc-4e29-91e4-e7fbc69070ce.png width=60% />

 命令行创建pod

```shell
kubectl run mynginx --image=nginx

# 查看default名称空间的Pod
kubectl get pod 
# 描述
kubectl describe pod 你自己的Pod名字
# 删除
kubectl delete pod Pod名字
# 查看Pod的运行日志
kubectl logs Pod名字

# 每个Pod - k8s都会分配一个ip
kubectl get pod -owide
# 使用Pod的ip+pod里面运行容器的端口
curl 192.168.169.136

# 集群中的任意一个机器以及任意的应用都能通过Pod分配的ip来访问这个Pod

```



yaml 创建pod



```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: mynginx
  name: mynginx
#  namespace: default
spec:
  containers:
  - image: nginx
    name: mynginx
    #一个pod可以有多个镜像
  - image: tomcat:8.5.68
    name: tomcat
```

> <img  src="https://qiniu.muluofeng.com//uPic/%202022%2005%20/1625553938232-51976552-5bab-4c98-bb8d-c4bf612bf866.png" />

### 4. Deployment

控制Pod，使Pod拥有多副本，自愈，扩缩容等能力

```shell
# 清除所有Pod，比较下面两个命令有何不同效果？
kubectl run mynginx --image=nginx

kubectl create deployment mytomcat --image=tomcat:8.5.68  --replicas=3
# 自愈能力  对于使用  run 创建的pod ，pod被删除的时候不会重新生成一个pod
# deployment 创建的pod 被删除的时候 会自动创建对应的pod 顶上来 ，还能使用--replicas 指定多个副本 

 kubectl delete  pod  podName
```

使用yaml创建deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: my-dep
  name: my-dep
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-dep
  template:
    metadata:
      labels:
        app: my-dep
    spec:
      containers:
      - image: nginx
        name: nginx
```

扩容

```shell
# 手动指定对应的deployment 扩容为5 
kubectl scale --replicas=5 deployment/my-dep

# 编辑deployment  修改 replicas进行扩容
kubectl edit deployment my-dep

```

滚动更新

```shell
# 比如设置对应的 deployment 的镜像版本 ，比如副本有3个 那么会一个一个去更新对应的副本
kubectl set image deployment/my-dep nginx=nginx:1.16.1 --record
# 查看状态
kubectl rollout status deployment/my-dep


# 还有一种方式，直接修改配置
kubectl edit deployment/my-dep

#历史记录
kubectl rollout history deployment/my-dep


#查看某个历史详情
kubectl rollout history deployment/my-dep --revision=2

#回滚(回到上次)
kubectl rollout undo deployment/my-dep

#回滚(回到指定版本)
kubectl rollout undo deployment/my-dep --to-revision=2
```



### 5. Service

将一组 [Pods](https://kubernetes.io/docs/concepts/workloads/pods/pod-overview/) 公开为网络服务的抽象方法。

命令行的方式

```shell
#暴露Deploy 将 对应的deployment  暴露端口为  8080 ，--target-port 为原来服务的端口
kubectl expose deployment my-dep --port=8000 --target-port=80

#使用标签检索Pod
kubectl get pod -l app=my-dep
```

yaml的方式

```yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    app: my-dep
  name: my-dep
spec:
  selector:
    app: my-dep
  ports:
  - port: 8000
    protocol: TCP
    targetPort: 80
```

 验证service

```shell
 #  获取所有的service （默认的命名空间下） 目前 mynginx3 的 cluster ip 是 10.96.105.250
 kubectl get svc
```



![image-20220504215149125](https://qiniu.muluofeng.com//uPic/%202022%2005%20/image-20220504215149125.png)

进入到mynginx3 service 下的2个pod下修改nginx的index.html 默认nginx的html目录在  /usr/share/nginx/html下面

分别 修改index.html   ，分别修改为

Thank you for using nginx. 111 

Thank you for using nginx. 222 

作为区别

```shell
cat <<EOF>index.html
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx. 222 </em></p>
</body>
</html>
EOF
```

修改后使用cluster ip 进行访问

```shell
 ## 可以看到 每次访问出现不同的结果，分别为  Thank you for using nginx. 111 和 Thank you for using nginx. 222
 # curl  ip:port  可以在主机内也可以在容器内
 curl  10.96.105.250:8000
 # curl   服务名称.命名空间.svc:port 的方式只能在容器内
 curl   mynginx3.default.svc:8000
```

 默认的情况下 使用的是 ClusterIP ，ClusterIP只能内网访问 不能被外网访问，如果需要外网访问需要使用 --type=NodePort

***NodePort范围在 30000-32767 之间***

```shell
kubectl expose deployment my-dep --port=8000 --target-port=80 --type=NodePort
```

```yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    app: my-dep
  name: my-dep
spec:
  ports:
  - port: 8000
    protocol: TCP
    targetPort: 80
  selector:
    app: my-dep
  type: NodePort

```



![image-20220504220415899](https://qiniu.muluofeng.com//uPic/%202022%2005%20/image-20220504220415899.png)

### 6. Ingress

官网地址：https://kubernetes.github.io/ingress-nginx/  相当于 nginx

安装

```shell
wget https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.47.0/deploy/static/provider/baremetal/deploy.yaml

#修改镜像
vi deploy.yaml
#将image的值改为如下值：
registry.cn-hangzhou.aliyuncs.com/lfy_k8s_images/ingress-nginx-controller:v0.46.0

# 检查安装的结果
kubectl get pod,svc -n ingress-nginx


# 最后别忘记把svc暴露的端口要放行 我们这里暴露的端口是 32718
```



![image-20220504220642972](https://qiniu.muluofeng.com//uPic/%202022%2005%20/image-20220504220642972.png)

使用 ingress 代理服务







### k8s常用命令

```shell
##查看日志
kubectl  logs -n  namespace  podName      -f  --tail=100
```





