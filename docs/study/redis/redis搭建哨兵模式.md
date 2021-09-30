redis 搭建哨兵模式


```shell

redis集群搭建
Master 10.18.44.244  6379   26379
Slave01 10.18.44.245  6379   26379
Slave02 10.18.44.246  6379   26379


master redis配置
#bind 10.169.28.143
port 6379
daemonize yes 
masterauth p@ssw0rd
requirepass p@ssw0rd
logfile "/data/redis-4.0.2/log/redis.log"

slave配置,另一个和这个一样
#bind 10.28.10.103
port 6379
daemonize yes 
slaveof 10.18.44.244 6379
masterauth p@ssw0rd
requirepass p@ssw0rd
logfile "/data/redis-4.0.2/log/redis.log"


sentinel配置
port 26379
daemonize yes
protected-mode no  //关闭保护模式
##代表该哨兵监视10.18.44.244 6379的redis,当哨兵选举达到2个后，选举新的主节点
sentinel monitor mymaster 10.18.44.244 6379 2   
sentinel down-after-milliseconds mymaster 5000
sentinel failover-timeout mymaster 180000
sentinel parallel-syncs mymaster 1
sentinel auth-pass mymaster p@ssw0rd
logfile /data/redis-4.0.2/log/redis-sentinel.log

启动redis

./src/redis-server redis.conf


启动sentinel
./src/redis-sentinel sentinel.conf

查看信息
 ./src/redis-cli -h 10.18.44.244 -p 6379 -a p@ssw0rd info Replication
 ./src/redis-cli -h 10.18.44.245 -p 6379 -a p@ssw0rd info Replication

 ./src/redis-cli -h 10.18.44.244 -p 6379 -a p@ssw0rd shutdown
```





redis rdb数据迁移

     使用 rdb 快照方式进行迁移
     a.) 源服务获取数据
         连接redis,执行 
          save 
          config get dir 
         即可得到dump.rdb文件的路径 
         停止源redis服务器
     b） 目标服务器迁移
        1. 清空目标服务器的redis的数据  flushall
        2. 关闭集群的redis服务  
        3，上传dump.rdb文件到每台集群服务器上
        4. 每台服务器 重启 redis 