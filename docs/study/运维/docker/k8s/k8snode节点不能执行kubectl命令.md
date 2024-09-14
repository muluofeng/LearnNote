

###  解决 k8s node 节点不能执行 kubectl 命令

-  1.  进入master 节点copy admin.conf到 node
```shell
 scp /etc/kubernetes/admin.conf    node节点的账号@node节点的ip:/etc/kubernetes
 ```


- 2.  在node节点 执行命令

```shell
echo "export KUBECONFIG=/etc/kubernetes/admin.conf">>~/.bash_profile
source ~/.bash_profile
```

- 3. 验证
```shell
kubectl get node
```