

### jstack 的功能
jstack是JVM自带的Java堆栈跟踪工具，它用于打印出给定的java进程ID、core file、远程调试服务的Java堆栈信息.


jstack命令用于生成虚拟机当前时刻的线程快照。
线程快照是当前虚拟机内每一条线程正在执行的方法堆栈的集合，生成线程快照的主要目的是定位线程出现长时间停顿的原因，
如线程间死锁、死循环、请求外部资源导致的长时间等待等问题。
线程出现停顿的时候通过jstack来查看各个线程的调用堆栈，就可以知道没有响应的线程到底在后台做什么事情，或者等待什么资源。
如果java程序崩溃生成core文件，jstack工具可以用来获得core文件的java stack和native stack的信息，从而可以轻松地知道java程序是如何崩溃和在程序何处发生问题。
另外，jstack工具还可以附属到正在运行的java程序中，看到当时运行的java程序的java stack和native stack的信息, 如果现在运行的java程序呈现hung的状态，jstack是非常有用的。



##  jstack 分析CPU 性能过高的问题

####  1. 排查流程
```
top
top -Hp pid
jstack pid
jstack -l [PID] >/tmp/log.txt
分析堆栈信息
```


1.  top 查看CPU 占满的线程

![image-20211201145456532](http://qiniu.muluofeng.com/uPic/2021/12/image-20211201145456532.png)

由上图中，我们可以找出pid为2040的java进程，它占用了最高的cpu资源，凶手就是它，哈哈

2.  top -Hp pid

通过top -Hp  2040可以查看该进程下，各个线程的cpu使用情况，如下：



![image-20211201145656155](http://qiniu.muluofeng.com/uPic/2021/12/image-20211201145656155.png)

可以发现pid为2068的线程，CPU资源占用最高~，嘻嘻，小本本把它记下来，接下来拿jstack给它拍片子~

3.  执行 jstack  -l   2040 > xxx.log 
4.  获取 pid为2068线程的16进制编号



![image-20211201150422972](http://qiniu.muluofeng.com/uPic/2021/12/image-20211201150422972.png)

5. 查看上面第三步的xxx.log 找到  814 的线程

   ![image-20211201150534147](http://qiniu.muluofeng.com/uPic/2021/12/image-20211201150534147.png)
