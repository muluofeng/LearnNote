



### k8s 部署 nginx 入门


#### 1. 创建 pod

pod 是 k8s 最小的编排单位，通常来说不需要直接创建 pod。这里是为了演示 pod 的使用创建了一个 pod。

pod 的配置文件 nginx-pod.yml：

```yml
apiVersion: v1
kind: Pod
metadata:
  namespace: yicall
  name: nginx
  labels:
    app: nginx
spec:
  containers:
  - name: nginx
    image: nginx:alpine
    ports:
    - containerPort: 80
```

命令创建pod
```shell
kubectl apply -f nginx-pod.yml
```

为了检查创建的 pod 的状态，执行命令：

```shell
kubectl get pods nginx -n yicall -o wide
```
```shll
NAME    READY   STATUS    RESTARTS   AGE   IP            NODE   NOMINATED NODE   READINESS GATES
nginx   1/1     Running   0          74m   10.244.2.14   xing   <none>           <none>
```

如果需要显示更详细的 pod 的信息，可以使用命令：
```shell
kubectl describe pods nginx 
```


删除 pod
```shell
kubectl delete -f nginx-pod.yml
```

#### 2. 创建 deployment

控制Pod，使Pod拥有多副本，自愈，扩缩容等能力

**正确的Deployment,让matchLabels 和template.metadata.lables完全匹配才不会报错** 


nginx-dep.yml配置文件如下

```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  namespace: yicall
  name: nginx-deployment
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 3
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 80

```



```shell
##为了创建 deployment，执行命令：
kubectl apply -f nginx-dep.yml
## 查看 deployment 状态：
kubectl get deploy -o wide
##  结果
NAME               READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS   IMAGES         SELECTOR
nginx-deployment   3/3     3            3           48s   nginx        nginx:alpine   app=nginx
```

#### 3. 创建 service

k8s 使用 service 来实现服务发现，常见配置包括：

- spec.selector：用于定义如何选择 pod
- spec.ports：用于定义如何暴露端口，其中，nodePort 指定可以在外部访问的端口

完整的 nginx-svc.yml 文件如下：

```yml
apiVersion: v1
kind: Service
metadata:
  namespace: yicall
  name: nginx-service
spec:
  selector:
    app: nginx
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
    nodePort: 30080
  type: NodePort
```
为创建 servcie，执行命令：

```shell
kubectl apply -f nginx-svc.yml
## 查看 service 的状态：
kubectl get svc nginx-service -o wide
## 输出
NAME            TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE   SELECTOR
nginx-service   NodePort   10.106.209.76   <none>        80:30080/TCP   26s   app=nginx


```