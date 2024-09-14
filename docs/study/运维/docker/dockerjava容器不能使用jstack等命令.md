

最近java服务容器化之后，部分容器CPU比较高，所以进入容器内部排查cpu 比较高的线程
但是使用 jstack dump 线程文件 出现了  ”Unable to get pid of LinuxThreads manager thread​“
在linux系统中我们一般使用  top + shit + P 找打cpu 最高的进程，然后使用 jstack -l pid > xxx.txt

由于我这边使用的jdk 镜像是  openjdk:8-alpine 
进入到容器内部使用 top 命令 ，然后看到 pid 是1 ,然后就报错了 "Unable to get pid of LinuxThreads manager thread"

![1666419941576.png](https://qiniu.muluofeng.com/1666419941576.png)


原因： 使用alpine+java镜像，如果是以直接运行java进程的方式启动docker，也就是说java进程的PID为1，这种方式无法正常打印线程堆栈。

解决办法： 就是在启动docker的时候先运行一个tini进程，然后通过tini进程去运行java进程。这种方式java进程的PID不为1，能够打印堆栈，同时如果java进程退出，tini也能检测到，并通知到docker，docker来做相关的处理，完美的解决了这个问题


使用 –init 参数可以将 容器的 1号 进程变成 /sbin/docker-init

```shell
docker  run --init  xxx
```

加上参数之后就可以看到 ，我们的java程序pid变成 7 了,这个时候就可以正常dump了 


![1666420196959.png](https://qiniu.muluofeng.com/1666420196959.png)
