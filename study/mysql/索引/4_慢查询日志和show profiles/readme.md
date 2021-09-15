



###  1. 开启慢查询日志
 -  查看是否开启 
    
    ```mysql
    SHOW VARIABLES LIKE '%slow_query_log%'
    ```
    
    
    
 - 开启

    

    ```mysql
    set global slow_query_log=1
    ```

    
### 2. show  profile 

   show proflie 查看mysql 的整个执行流程

  ```mysql
  show profiles  //查看所有的执行sql
  show profile   cpu,block io for QUERY  54  //查看id=54的sql
  
  ```

下面的几种情况表示有性能问题

- convert heap to myisam  查询结果太大了，内存不够 搬到磁盘上了
- creating tmp table   创建临时表
- copying to tmp table on disk  把内存的临时表复制到磁盘
- locker锁