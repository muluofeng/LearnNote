###  Docker 的网络模式
docker 的 4 种网络模式

- host --network host	容器和宿主机共享 Network namespace
- container	--network container:NAME_OR_ID	容器和另外一个容器共享 Network namespace
- none	--network none	容器有独立的 Network namespace，但并没有对其进行任何网络设置，如分配 veth pair 和网桥连接，配置 IP 等
- bridge	--network	bridge 默认模式



####  bridge 模式
当 Docker 进程启动时，会在主机上创建一个名为 docker0 的虚拟网桥，此主机上启动的 Docker 容器会连接到这个虚拟网桥上。虚拟网桥的工作方式和物理交换机类似，这样主机上的所有容器就通过交换机连在了一个二层网络中。

从 docker0 子网中分配一个 IP 给容器使用，并设置 docker0 的 IP 地址为容器的默认网关。在主机上创建一对虚拟网卡 veth pair 设备，Docker 将 veth pair 设备的一端放在新创建的容器中，并命名为 eth0（容器的网卡），另一端放在主机中，以 vethxxx 这样类似的名字命名，并将这个网络设备加入到 docker0 网桥中。可以通过 brctl show 命令查看。

bridge 模式是 docker 的默认网络模式，不写--network 参数，就是 bridge 模式。使用 docker run -p 时，docker 实际是在 iptables 做了 DNAT 规则，实现端口转发功能。可以使用 iptables -t nat -vnL 查看。


![202393/v2-c3bedd0f57f3d72e62b690fbe880b097_r.jpg](http://qiniu.muluofeng.com/202393/v2-c3bedd0f57f3d72e62b690fbe880b097_r.jpg)


#### container 模式

这个模式指定新创建的容器和已经存在的一个容器共享一个 Network Namespace，而不是和宿主机共享。新创建的容器不会创建自己的网卡，配置自己的 IP，而是和一个指定的容器共享 IP、端口范围等。同样，两个容器除了网络方面，其他的如文件系统、进程列表等还是隔离的。两个容器的进程可以通过 lo 网卡设备通信。
container 模式如下图所示：
![202393/v2-2b58b1540b9e797fac2324366c53e38c_1440w.webp](http://qiniu.muluofeng.com/202393/v2-2b58b1540b9e797fac2324366c53e38c_1440w.webp)


#### host 模式

如果启动容器的时候使用 host 模式，那么这个容器将不会获得一个独立的 Network Namespace，而是和宿主机共用一个 Network Namespace。容器将不会虚拟出自己的网卡，配置自己的 IP 等，而是使用宿主机的 IP 和端口。但是，容器的其他方面，如文件系统、进程列表等还是和宿主机隔离的。

使用 host 模式的容器可以直接使用宿主机的 IP 地址与外界通信，容器内部的服务端口也可以使用宿主机的端口，不需要进行 NAT，host 最大的优势就是网络性能比较好，但是 docker host 上已经使用的端口就不能再用了，网络的隔离性不好。
Host 模式如下图所示：


![202393/v2-ba167e0fff2c3ee0c5d8a921d9b2aae6_1440w.webp](http://qiniu.muluofeng.com/202393/v2-ba167e0fff2c3ee0c5d8a921d9b2aae6_1440w.webp)


#### none 模式
使用 none 模式，Docker 容器拥有自己的 Network Namespace，但是，并不为 Docker 容器进行任何网络配置。也就是说，这个 Docker 容器没有网卡、IP、路由等信息。需要我们自己为 Docker 容器添加网卡、配置 IP 等。

这种网络模式下容器只有 lo 回环网络，没有其他网卡。none 模式可以在容器创建时通过--network none 来指定。这种类型的网络没有办法联网，封闭的网络能很好的保证容器的安全性。


![202393/v2-d9b4d27db311f261dea7bc8ef53c822d_1440w.webp](http://qiniu.muluofeng.com/202393/v2-d9b4d27db311f261dea7bc8ef53c822d_1440w.webp)



参考： https://zhuanlan.zhihu.com/p/554015619