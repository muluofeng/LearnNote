###   linux  单节点安装 

-  指定hostname

  ```shell
  hostnamectl set-hostname master 
  ```

  

- 准备KubeKey

  ```shell
  export KKZONE=cn
  
  curl -sfL https://get-kk.kubesphere.io | VERSION=v1.1.1 sh -
  
  chmod +x kk
  
  ## 使用KubeKey引导安装集群
  #可能需要下面命令
  yum install -y conntrack
  
  ./kk create cluster --with-kubernetes v1.20.4 --with-kubesphere v3.1.1
  ```

  

- 安装开启功能

  

![image-20220514171549559](https://qiniu.muluofeng.com//uPic/202205/image-20220514171549559.png)
