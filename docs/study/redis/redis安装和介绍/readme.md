REDIS学习



## 什么是redis

是完全开源免费的，用C语言编写的，遵守BSD协议，是一个高性能的(key/value)分布式内存数据库，基于内存运行并支持持久化的NoSQL数据库，是当前最热门的NoSql数据库之一,也被人们称为数据结构服务器



## 特点

1. Redis支持数据的持久化，可以将内存中的数据保持在磁盘中，重启的时候可以再次加载进行使用

2. Redis不仅仅支持简单的key-value类型的数据，同时还提供list，set，zset，hash等数据结构的存储

3. Redis支持数据的备份，即master-slave模式的数据备份



## 应用场景

1. 内存存储和持久化：redis支持异步将内存中的数据写到硬盘上，同时不影响继续服务
2. 取最新N个数据的操作，如：可以将最新的10条评论的ID放在Redis的List集合里面
3. 模拟类似于HttpSession这种需要设定过期时间的功能
4. 发布、订阅消息系统
5. 定时器、计数器
6. 分布式锁
7. 布隆过滤器等等



##   官网

http://redis.io/

http://www.redis.cn/



 





##  学习redis的下面的一些功能

1. redis 安装介绍
2.  redis的基础数据结构
3.  redis 事务  和 redis 消息订阅订阅 了解 
4. redis持久化
5. redis 主从复制
6. redis哨兵
7. redis 布隆过滤器



## redis安装和介绍

1. Redis 安装  自行百度

   



## redis bin目录介绍

1. redis-benchmark:性能测试工具，可以在自己本子运行，看看自己本子性能如何
   	服务启动起来后执行
2. redis-check-aof：修复有问题的AOF文件，rdb和aof后面讲
3. redis-check-dump：修复有问题的dump.rdb文件
4. redis-cli：客户端，操作入口
5. redis-sentinel：redis集群使用
6. redis-server：Redis服务器启动命令



## 启动

1. 修改redis.conf文件将里面的daemonize no 改成 yes，让服务在后台启动
2. 将默认的redis.conf拷贝到自己定义好的一个路径下，比如/myconf
3. 启动
4. 连通测试
5. /usr/local/bin目录下运行redis-server，运行拷贝出存放了自定义conf文件目录下的redis.conf文件

## 关闭

1. 单实例关闭：redis-cli shutdown
2. 多实例关闭，指定端口关闭:redis-cli -p 6379 shutdown





## Redis启动后杂项基础知识讲解

1. 单进程 ：
   1. 单进程模型来处理客户端的请求。对读写等事件的响应是通过对epoll函数的包装来做到的。Redis的实际处理速度完全依靠主进程的执行效率
   2. epoll是Linux内核为处理大批量文件描述符而作了改进的epoll，是Linux下多路复用IO接口select/poll的增强版本，
      它能显著提高程序在大量并发连接中只有少量活跃的情况下的系统CPU利用率。
2. 默认16个数据库，类似数组下表从零开始，初始默认使用零号库
3. select命令切换数据库
4. dbsize查看当前数据库的key的数量
5. flushdb：清空当前库
6. Flushall；通杀全部库
7. 统一密码管理，16个库都是同样密码，要么都OK要么一个也连接不上
8. Redis索引都是从零开始
9. 默认端口是6379







## 参数说明redis.conf 配置项说明如下：

1. Redis默认不是以守护进程的方式运行，可以通过该配置项修改，使用yes启用守护进程 daemonize no
2.  当Redis以守护进程方式运行时，Redis默认会把pid写入/var/run/redis.pid文件，可以通过pidfile指定 pidfile /var/run/redis.pid
3.  指定Redis监听端口，默认端口为6379，作者在自己的一篇博文中解释了为什么选用6379作为默认端口，因为6379在手机按键上MERZ对应的号码，而MERZ取自意大利歌女Alessia Merz的名字 port 6379
4.  绑定的主机地址 bind 127.0.0.1
5. 当 客户端闲置多长时间后关闭连接，如果指定为0，表示关闭该功能 timeout 300
6.  指定日志记录级别，Redis总共支持四个级别：debug、verbose、notice、warning，默认为verbose loglevel verbose7. 日志记录方式，默认为标准输出，如果配置Redis为守护进程方式运行，而这里又配置为日志记录方式为标准输出，则日志将会发送给/dev/null logfile stdout8. 设置数据库的数量，默认数据库为0，可以使用SELECT <dbid>命令在连接上指定数据库id databases 169. 指定在多长时间内，有多少次更新操作，就将数据同步到数据文件，可以多个条件配合 save <seconds> <changes> Redis默认配置文件中提供了三个条件： save 900 1 save 300 10 save 60 10000 分别表示900秒（15分钟）内有1个更改，300秒（5分钟）内有10个更改以及60秒内有10000个更改。 10. 指定存储至本地数据库时是否压缩数据，默认为yes，Redis采用LZF压缩，如果为了节省CPU时间，可以关闭该选项，但会导致数据库文件变的巨大 rdbcompression yes11. 指定本地数据库文件名，默认值为dump.rdb dbfilename dump.rdb12. 指定本地数据库存放目录 dir ./13. 设置当本机为slav服务时，设置master服务的IP地址及端口，在Redis启动时，它会自动从master进行数据同步 slaveof <masterip> <masterport>14. 当master服务设置了密码保护时，slav服务连接master的密码 masterauth <master-password>15. 设置Redis连接密码，如果配置了连接密码，客户端在连接Redis时需要通过AUTH <password>命令提供密码，默认关闭 requirepass foobared16. 设置同一时间最大客户端连接数，默认无限制，Redis可以同时打开的客户端连接数为Redis进程可以打开的最大文件描述符数，如果设置 maxclients 0，表示不作限制。当客户端连接数到达限制时，Redis会关闭新的连接并向客户端返回max number of clients reached错误信息 maxclients 12817. 指定Redis最大内存限制，Redis在启动时会把数据加载到内存中，达到最大内存后，Redis会先尝试清除已到期或即将到期的Key，当此方法处理 后，仍然到达最大内存设置，将无法再进行写入操作，但仍然可以进行读取操作。Redis新的vm机制，会把Key存放内存，Value会存放在swap区 maxmemory <bytes>18. 指定是否在每次更新操作后进行日志记录，Redis在默认情况下是异步的把数据写入磁盘，如果不开启，可能会在断电时导致一段时间内的数据丢失。因为 redis本身同步数据文件是按上面save条件来同步的，所以有的数据会在一段时间内只存在于内存中。默认为no appendonly no19. 指定更新日志文件名，默认为appendonly.aof  appendfilename appendonly.aof20. 指定更新日志条件，共有3个可选值：  no：表示等操作系统进行数据缓存同步到磁盘（快）  always：表示每次更新操作后手动调用fsync()将数据写到磁盘（慢，安全）  everysec：表示每秒同步一次（折衷，默认值） appendfsync everysec 21. 指定是否启用虚拟内存机制，默认值为no，简单的介绍一下，VM机制将数据分页存放，由Redis将访问量较少的页即冷数据swap到磁盘上，访问多的页面由磁盘自动换出到内存中（在后面的文章我会仔细分析Redis的VM机制）  vm-enabled no22. 虚拟内存文件路径，默认值为/tmp/redis.swap，不可多个Redis实例共享  vm-swap-file /tmp/redis.swap23. 将所有大于vm-max-memory的数据存入虚拟内存,无论vm-max-memory设置多小,所有索引数据都是内存存储的(Redis的索引数据 就是keys),也就是说,当vm-max-memory设置为0的时候,其实是所有value都存在于磁盘。默认值为0  vm-max-memory 024. Redis swap文件分成了很多的page，一个对象可以保存在多个page上面，但一个page上不能被多个对象共享，vm-page-size是要根据存储的 数据大小来设定的，作者建议如果存储很多小对象，page大小最好设置为32或者64bytes；如果存储很大大对象，则可以使用更大的page，如果不 确定，就使用默认值  vm-page-size 3225. 设置swap文件中的page数量，由于页表（一种表示页面空闲或使用的bitmap）是在放在内存中的，，在磁盘上每8个pages将消耗1byte的内存。  vm-pages 13421772826. 设置访问swap文件的线程数,最好不要超过机器的核数,如果设置为0,那么所有对swap文件的操作都是串行的，可能会造成比较长时间的延迟。默认值为4  vm-max-threads 427. 设置在向客户端应答时，是否把较小的包合并为一个包发送，默认为开启 glueoutputbuf yes28. 指定在超过一定的数量或者最大的元素超过某一临界值时，采用一种特殊的哈希算法 hash-max-zipmap-entries 64 hash-max-zipmap-value 51229. 指定是否激活重置哈希，默认为开启（后面在介绍Redis的哈希算法时具体介绍） activerehashing yes30. 指定包含其它的配置文件，可以在同一主机上多个Redis实例之间使用同一份配置文件，而同时各个实例又拥有自己的特定配置文件 include /path/to/local.conf



