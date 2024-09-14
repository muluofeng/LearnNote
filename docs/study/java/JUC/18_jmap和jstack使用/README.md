
### jvm 调优

 jmapMemory Map for Java用于生成堆转储快照一般称为heapdump或dump文件。同时它还可以查询finalize执行队列、Java堆和方法区的 详细信息，如空间使用率、当前用的是哪种收集器等

####  jmap [option] pid


jmap 用来查看堆内存使用状况

```shell
 jmap -histo [:live] pid 查看堆内存中的对象数目、大小统计直方图，如果带上 live 则只统计活对象
```

  比如 jmap -histo 49150 > ./jmapLog.txt 

![image-20220801153256631](https://qiniu.muluofeng.com//uPic/202208/image-20220801153256631.png)

```
1. class name：类名
2. bytes：字节数
3. instances：实例数

说白了就是打印每个类的实例数有多少，总共占用了多少字节,或者说是内存大小
```



用 jmap 把进程内存使用情况 dump 到文件中，再用 jhat 分析查看

```shell
jmap -dump:format=b,file=dumpFileName pid

```

####  jstack  [option] pid

 jstack 主要用来查看某个 Java 进程内的线程堆栈信息， 一般可以定为出 死锁，程序cpu高等问题
 一般使用较多的是    -l

 ```
 -l long listings，会打印出额外的锁信息，在发生死锁时可以用jstack -l pid来观察锁持有情况

 ```
 比如排查 cpu 高的问题

 ```shell 
 ## 1. 确定java程序的pid ，比如下面pid  21711
 jps -l
 ## 2. 找出该进程内最耗费 CPU 的线程  21742
 top -Hp pid
 ## 3. 将第二步的pid转换成 16 进制
 printf "%x\n" 21742
 ## 4. 
jstack 21711 | grep 54ee

 ```


 #### jstat JVM 统计监测工具

```shell
jstat [ generalOption | outputOptions vmid [interval[s|ms] [count]] ]
##  每250ms 输出 GC信息，统计4次
jstat -gc 21711 250 4

```



![image-20220801152916794](https://qiniu.muluofeng.com//uPic/202208/image-20220801152916794.png)



要明白上面各列的意义，先看 JVM 堆内存布局：

![img](https://qiniu.muluofeng.com//uPic/202208/181847_dAR9_111708.jpg)

```
堆内存 = 年轻代 + 年老代 + 永久代
年轻代 = Eden区 + 两个Survivor区（From和To）
```

含义

S0C、S1C、S0U、S1U：Survivor 0/1区容量（Capacity）和使用量（Used） EC、EU：Eden区容量和使用量 OC、OU：年老代容量和使用量 PC、PU：永久代容量和使用量 YGC、YGT：年轻代GC次数和GC耗时 FGC、FGCT：Full GC次数和Full GC耗时 GCT：GC总耗时