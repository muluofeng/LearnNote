
### k8s 是什么 
Kubernetes 是谷歌开源的容器集群管理系统，是 Google 多年大规模容器管理技术 Borg 的开源版本，主要功能包括：
kubernetes具有以下特性：


● 服务发现和负载均衡
Kubernetes 可以使用 DNS 名称或自己的 IP 地址公开容器，如果进入容器的流量很大， Kubernetes 可以负载均衡并分配网络流量，从而使部署稳定。
● 存储编排
Kubernetes 允许你自动挂载你选择的存储系统，例如本地存储、公共云提供商等。
● 自动部署和回滚
你可以使用 Kubernetes 描述已部署容器的所需状态，它可以以受控的速率将实际状态 更改为期望状态。例如，你可以自动化 Kubernetes 来为你的部署创建新容器， 删除现有容器并将它们的所有资源用于新容器。
● 自动完成装箱计算
Kubernetes 允许你指定每个容器所需 CPU 和内存（RAM）。 当容器指定了资源请求时，Kubernetes 可以做出更好的决策来管理容器的资源。
● 自我修复
Kubernetes 重新启动失败的容器、替换容器、杀死不响应用户定义的 运行状况检查的容器，并且在准备好服务之前不将其通告给客户端。
● 密钥与配置管理
Kubernetes 允许你存储和管理敏感信息，例如密码、OAuth 令牌和 ssh 密钥。 你可以在不重建容器镜像的情况下部署和更新密钥和应用程序配置，也无需在堆栈配置中暴露密钥。


### 2、架构
#### 2.1 工作方式
Kubernetes Cluster = N Master Node + N Worker Node：N主节点+N工作节点； N>=1

#### 2.2 组件架构


![1651666917795.png](https://qiniu.muluofeng.com/1651666917795.png)



### 3、kubeadm创建集群

1、安装kubeadm
● 一台兼容的 Linux 主机。Kubernetes 项目为基于 Debian 和 Red Hat 的 Linux 发行版以及一些不提供包管理器的发行版提供通用的指令
● 每台机器 2 GB 或更多的 RAM （如果少于这个数字将会影响你应用的运行内存)
● 2 CPU 核或更多
● 集群中的所有机器的网络彼此均能相互连接(公网和内网都可以)
  ○ 设置防火墙放行规则
● 节点之中不可以有重复的主机名、MAC 地址或 product_uuid。请参见这里了解更多详细信息。
  ○ 设置不同hostname
● 开启机器上的某些端口。请参见这里 了解更多详细信息。
  ○ 内网互信
● 禁用交换分区。为了保证 kubelet 正常工作，你 必须 禁用交换分区。
  ○ 永久关闭


 #### 3.1 基础环境
 ```shell
 #各个机器设置自己的域名
hostnamectl set-hostname xxxx


# 将 SELinux 设置为 permissive 模式（相当于将其禁用）
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

#关闭swap
swapoff -a  
sed -ri 's/.*swap.*/#&/' /etc/fstab

#允许 iptables 检查桥接流量
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system

 ```



####  3.2 安装kubelet、kubeadm、kubectl

```shell
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=http://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg
   http://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF


sudo yum install -y kubelet-1.20.9 kubeadm-1.20.9 kubectl-1.20.9 --disableexcludes=kubernetes

sudo systemctl enable --now kubelet
```

#### 3.3 使用kubeadm引导集群

```shell
## 下载各个机器需要的镜像
sudo tee ./images.sh <<-'EOF'
#!/bin/bash
images=(
kube-apiserver:v1.20.9
kube-proxy:v1.20.9
kube-controller-manager:v1.20.9
kube-scheduler:v1.20.9
coredns:1.7.0
etcd:3.4.13-0
pause:3.2
)
for imageName in ${images[@]} ; do
docker pull registry.cn-hangzhou.aliyuncs.com/lfy_k8s_images/$imageName
done
EOF
   
chmod +x ./images.sh && ./images.sh


## 初始化主节点
#所有机器添加master域名映射，以下需要修改为自己的  使用ip a 查看自己的内网ip
echo "172.31.0.4  cluster-endpoint" >> /etc/hosts



#主节点初始化
kubeadm init \
--apiserver-advertise-address=172.31.0.4 \
--control-plane-endpoint=cluster-endpoint \
--image-repository registry.cn-hangzhou.aliyuncs.com/lfy_k8s_images \
--kubernetes-version v1.20.9 \
--service-cidr=10.96.0.0/16 \
--pod-network-cidr=192.168.0.0/16

# 所有网络范围不重叠   apiserver-advertise-address 需要为主节点的内网ip 
#  service-cidr和pod-network-cidr需要指定对应的网段


```

如果看到下面的这句话表示安装成功

```
Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

You can now join any number of control-plane nodes by copying certificate authorities
and service account keys on each node and then running the following as root:

  kubeadm join cluster-endpoint:6443 --token hums8f.vyx71prsg74ofce7 \
    --discovery-token-ca-cert-hash sha256:a394d059dd51d68bb007a532a037d0a477131480ae95f75840c461e85e2c6ae3 \
    --control-plane 

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join cluster-endpoint:6443 --token hums8f.vyx71prsg74ofce7 \
    --discovery-token-ca-cert-hash sha256:a394d059dd51d68bb007a532a037d0a477131480ae95f75840c461e85e2c6ae3
```



按照提示步骤进行操作

```shell
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

安装网络组件calico

[calico官网](https://docs.projectcalico.org/getting-started/kubernetes/self-managed-onprem/onpremises#install-calico-with-kubernetes-api-datastore-more-than-50-nodes)

```shell
curl https://docs.projectcalico.org/manifests/calico.yaml -O
kubectl apply -f calico.yaml
```

将其他服务器的节点加入到当前集群(***高可用部署方式，也是在这一步的时候，使用添加主节点的命令即可***)

```shell
kubeadm join cluster-endpoint:6443 --token hums8f.vyx71prsg74ofce7 \
    --discovery-token-ca-cert-hash sha256:a394d059dd51d68bb007a532a037d0a477131480ae95f75840c461e85e2c6ae3
```

如果长时间没有加入这个token会失效，那么需要重新生成

生成新的令牌

```shell
kubeadm token create --print-join-command
```

验证集群状态

```shell
  kubectl get nodes
```

部署dashboard(kubernetes官方提供的可视化界面)

https://github.com/kubernetes/dashboard

```shell
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.3.1/aio/deploy/recommended.yaml
# 设置dasboard端口访问 ,type: ClusterIP 改为 type: NodePort 
kubectl edit svc kubernetes-dashboard -n kubernetes-dashboard
# 找到端口，在安全组放行 对应的 端口，我这里放行的是  32767
kubectl get svc -A |grep kubernetes-dashboard
```

![image-20220504203940933](https://qiniu.muluofeng.com//uPic/%202022%2005%20/image-20220504203940933.png)

访问对应的ip ： https://集群任意IP:端口      我这里是 https://106.54.237.135:32767/#/login

创建访问账号, 创建一个yaml

```yml
#创建访问账号，准备一个yaml文件； vi dash.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
```



```shell
# 应用上面创建的 dash.yml
kubectl apply -f dash.yaml
#获取访问令牌
kubectl -n kubernetes-dashboard get secret $(kubectl -n kubernetes-dashboard get sa/admin-user -o jsonpath="{.secrets[0].name}") -o go-template="{{.data.token | base64decode}}"
```

 

输入上面获取的token 进入到管理界面

![image-20220504204410823](https://qiniu.muluofeng.com//uPic/%202022%2005%20/image-20220504204410823.png)