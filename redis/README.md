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

