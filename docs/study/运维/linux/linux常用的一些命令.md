###  1. 参看系统信息
```shell
### 1.查看内存和CPU
按内存占用排序，先输入top，再输入M，系统就会以内存占用率大小倒序排列  

按CPU占用排序,先输入top，再输入P，系统就会以CPU占用率大小倒序排列

按运行时间排序,先输入top，再输入T，系统就会以TIME+大小倒序排列


```
###  2 .查看系统所有的内存

```java

free  -m

```
![imge](http://qiniu.muluofeng.com/uPic/2021/09/14552.png)
显示结果

![image](http://qiniu.muluofeng.com/uPic/2021/09/14553.png)

```
 total   系统总的可用物理内存大小    
 used    已被使用的物理内存大小    
 free    还有多少物理内存可用    
 shared  被共享使用的物理内存大小   
 buff/cache  被 buffer 和 cache 使用的物理内存大小    
 available   还可以被 应用程序 使用的物理内存大小
```

free与avaliable的区别：

free是指未被使用的物理内存数量

available是可以被应用程序使用的内存大小，available = free + buffer + cache

Linux 为了提升读写性能，会消耗一部分内存资源缓存磁盘数据，对于内核来说，buffer 和 cache 其实都属于已经被使用的内存。但当应用程序申请内存时，如果 free 内存不够，内核就会回收 buffer 和 cache 的内存来满足应用程序的请求。

### 查看磁盘信息

```java
df -hl
```

![](http://qiniu.muluofeng.com/uPic/2021/09/14550.png)

### 常用的其他命令 

```shell
### 查找大文件
find . -type f -size +800M

### 清空文件操作
cat /dev/null >文件名称
```

