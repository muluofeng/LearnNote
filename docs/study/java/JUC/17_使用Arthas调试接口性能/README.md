### arthas 是阿里的java 诊断利器

### 下载和安装

在命令行下面执行（使用和目标进程一致的用户启动，否则可能attach失败）：

```shell
curl -O https://arthas.aliyun.com/arthas-boot.jar
java -jar arthas-boot.jar
```

官网地址 https://arthas.aliyun.com/zh-cn/

![image-20220725170035519](https://qiniu.muluofeng.com//uPic/202207/image-20220725170035519.png)

选择具体要检测的  进程,这里输入 5 



##### 检测么某个service 代码的耗时

```shell
trace  com.yicall.service.Impl.DataReportServiceImpl *
```



![image-20220725170258027](https://qiniu.muluofeng.com//uPic/202207/image-20220725170258027.png)

####  调用指定的接口，这个接口会调用DataReportServiceImpl

通过命令行就能查看具体调用的时长

![image-20220725170455174](https://qiniu.muluofeng.com//uPic/202207/image-20220725170455174.png)
