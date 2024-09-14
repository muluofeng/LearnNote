 解决AWS 挂载、解决挂载完重启就消失等问题

**linux上的盘和window的有区别，磁盘空间必须挂载在目录上，要不然没用**

**对与新增的硬盘、SSD固态硬盘、挂载到linux上的操作如下**：

 df -h   　　　#显示目前在Linux系统上的文件系统的磁盘使用情况统计。

 lsblk  　　　　#[列出块设备信息](http://www.baidu.com/link?url=Pyvr8W5vf09ifiT_iUGxYIYpql2FWEwxM8YvYHEeFm3Yf0jZlxZCHgFrL9swkCS2)（df -h不能看到的卷）

 mount   　　  #挂载命令

现在 我们有个新的硬盘450G没有挂载 

 

**1、查看linux下的硬盘挂载的空间、使用空间**

使用下面命令格式化已附加上，但df -h不能看到的卷

使用命令 ： df -h

![img](http://qiniu.muluofeng.com/uPic/2021/10/1182892-20170926155212589-485493961.png)



Filesystem 文件系統 

size  文件大小

Used 使用空间

Mounted on 挂载的目录

没有看见450G的盘，现在我们要挂载

 

 

**2、查看没有挂载的硬盘是否检测在系统中**

查看系统检测的硬盘 命令：lsblk

![img](http://qiniu.muluofeng.com/uPic/2021/10/1182892-20170926160704635-973966525.png)

看到 的确 nvmeOn1没有挂载，但是存在

 

 

**3、挂载** **（挂载完，要在/etc/fstab 下面配置挂载信息 要不然重启挂载就消失了）**

使用下面命令格式化已附加上，但df -h不能看到的卷

sudo mkfs -t ext4 /dev/nvmeOn1 #备注 nvmeOn1 都是存在在/dev 下面的

 

创建一个要挂载的目录

sudo mkdir /data

 

挂载命令 把空间挂在/data 把格式化后的卷mount到一个目录

sudo mount /dev/nvmeOn1 /data

使用df -h 再次检查是否正常

![img](http://qiniu.muluofeng.com/uPic/2021/10/1182892-20170926161458104-856003976.png)

 

到 /etc/fstab 下配置挂载信息，添加一条记录，如有就复制一条，修改一下即可（十分重要） 如下：

/dev/nvme0n1   /data  auto  defaults,nofail,comment=cloudconfig   0    2

![img](http://qiniu.muluofeng.com/uPic/2021/10/1182892-20170927190225153-1957626924.png)

 

 添加完毕以后可以试一下fstab文件是否能正常运行。

 sudo mount -a 测试是否挂载成功（如果出错，不要重启，否则就GG了）

![img](http://qiniu.muluofeng.com/uPic/2021/10/1182892-20170927190555669-1179884482.png)

 

哈哈 看到这个就大功告成了