

#### 添加mysql 配置文件 
vim /etc/my.cnf
```
  
[mysqld]
character-set-server=utf8
sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES
max_connections=500
default-storage-engine=INNODB
lower_case_table_names=1
max_allowed_packet=16M
#设置时区
default-time_zone='+8:00'

[client]
default-character-set=utf8
[mysql]
default-character-set=utf8

```

####   运行mysql镜像
docker run -p 3306:3306 --privileged=true  \
 -v /etc/my.cnf:/etc/mysql/mysql.conf.d/mysqld.cnf -e MYSQL_ROOT_PASSWORD=Xing0830 -d mysql:5.7







### docker  mysql 5.7 主从复制本地搭建

docker项目结构

![image-20211002100708776](http://qiniu.muluofeng.com/uPic/2021/10/image-20211002100708776.png)

#### 1 docker mysql配置

- master 配置
```dockerfile
FROM mysql:5.7
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
ENV LANG=C.UTF-8
ENV MYSQL_ROOT_PASSWORD Xing0830
COPY my.cnf /etc/mysql/my.cnf
EXPOSE 3306

```

```cnf
[mysqld]
## 保证这个ID唯一
server-id=1
## 开启二进制日志功
log-bin=myslq-bin

```
-  slave配置
```dockerfile
FROM mysql:5.7
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
ENV LANG=C.UTF-8
ENV MYSQL_ROOT_PASSWORD Xing0830
COPY my.cnf /etc/mysql/my.cnf
EXPOSE 3306


```

```cnf
[mysqld]
## 保证这个ID唯一
server-id=2
## 开启二进制日志功能
log-bin=myslq-slave-bin
## relay_log配置中继日志
relay_log=edu-mysql-relay-bin

```


### 2. 打包成镜像
```
## 进入到master目录
docker build -t  mysql/master:v1 .

## 进入到slave目录
docker build -t  mysql/slave:v1 .

## 查看镜像
docker images | grep mysql

```
### 3. 启动镜像
```

##Master节点
docker run -p 3306:3306 -d mysql/master:v1
##Slave节点 端口号避免占用
docker run -p 3307:3306 -d mysql/slave:v1

```


### 4. 创建用户并启用主从同步
- 进如启动的 master 数据库docker exec -it ContainerID bash
- 登录mysql，密码在Dockerfile配置文件的字段(ENV MYSQL_ROOT_PASSWORD Xing0830)
```
mysql -uroot -pXing0830
```
- 授予用户 slave REPLICATION SLAVE权限和REPLICATION CLIENT权限，用于在主从库之间同步数据
```
GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'slave'@'%';
```
- 在Master数据库创建数据同步用户
```
CREATE USER 'slave'@'%' IDENTIFIED BY 'Xing0830'; 
```


### 5. 配置主从同步

- 查看Master节点的状态信息
```
show master status;
```
命令结果
```
File: myslq-bin.000003
Position: 1158
inlog_Do_DB:
Binlog_Ignore_DB:
Executed_Gtid_Set:
1 row in set (0.00 sec)
```
- 进入Slave节点并登录Mysql之后执行
```
change master to master_host='172.17.0.2', master_user='slave', master_password='Xing0830', master_port=3306, master_log_file='myslq-bin.000003', master_log_pos= 1158, master_connect_retry=30;

```

master_log_file	指定 Slave 从哪个日志文件开始复制数据，即上文中提到的 File 字段的值 对应show master status里面的File
master_log_pos	从哪个 Position 开始读，即上文中提到的 Position 字段的值，对应show master status里面的Position


- 在Slave 中的mysql终端执行
```
start slave;
```
- 启动主从同步。
在Slave 中的mysql终端执行
```
show slave status \G;
```
启动主从同步。

![img](http://qiniu.muluofeng.com/uPic/2021/10/image-20211002101134650.png)

SlaveIORunning 和 SlaveSQLRunning 都是Yes，说明主从复制已经开启。此时可以测试数据同步是否成功。



- 关闭复制
```
stop slave;
```

- 再次开启需要 重新  走一遍  上面的步骤