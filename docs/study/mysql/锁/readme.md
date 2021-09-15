####  mysql 锁

####  1. 表锁

####   1.手动加锁

```mysql
lock  table tableName  read[write]
```



#### 2.查看表上加过的锁，1表示被锁了

```mysql
show open tables
```





#####  读锁

```mysql
## session1
lock  table mylock read;  //加读锁
select  * from mylock //可以
update mylock set name='aa' where id=1 // 不能更新
select  * from book // 不可以查询其他表


## session2
select  * from mylock //可以查询session1 锁定的表
select  * from book // 可以查询其他的表
update  mylock set name ='aa' where id=1  //不可以 写操作 会阻塞  直到 session1  unlock tables
```



#### 写锁  当前session  对表的查询、更新、插入操作都可以  ，其他session对该表的操作(查询、更新、插入)会阻塞

```mysql
## session1
lock  table mylock write;  //加写锁
select  * from mylock //可以
update mylock set name='aa' where id=1 // 可以更新
select  * from book // 不可以查询其他表


## session2
select  * from mylock //不可以  会一直阻塞
update mylock set name='aa' where id=1 // 不可以更新
select  * from book;//可以查询其他的表 


```

 ***读锁会阻塞写，而写锁会把读和写都阻塞***



####  如何分析表锁定

可以通过检查 Table_locks_waited  和 Table_locks_immediate来分析系统表锁定

- Table_locks_immediate   产生表级锁的次数
- Table_locks_waited  出现表级锁争用而发生等待的次数，每等待一次加1  ，此值高表示存在比较严重的表级锁的阵用情况

###  myisam  的读写锁调度是写优先，这也是myisam不适合做写为主表的引擎，因为写锁后其他线程不能做任何操作，大量的更新会查询很难得到锁，而造成阻塞







### 2 行锁   演示

```mysql
## session1
1. set autocommit=0; //设置不自动提交
2. select  * from  test_innodb_lock
+---+-----+
| a | b   |
+---+-----+
| 1 | 111 |
| 2 | 222 |
+---+-----+
3. update test_innodb_lock set  b= '1112' where a =1;
3. select  * from  test_innodb_lock;
+---+------+
| a | b    |
+---+------+
| 1 | 1112 |
| 2 | 222  |
+---+------+
6. commit；
10. select  * from  test_innodb_lock;
+---+------+
| a | b    |
+---+------+
| 1 | 1112 |
| 2 | 222  |
+---+------+
11.update test_innodb_lock set  b= '1114' where a =1; //更新 a=1的行
13. commit;
14. select  * from  test_innodb_lock;
+---+------+
| a | b    |
+---+------+
| 1 | 1114 |
| 2 | 2222 |
+---+------+






## session2
1. set autocommit=0; //设置不自动提交
2. select  * from  test_innodb_lock
+---+-----+
| a | b   |
+---+-----+
| 1 | 111 |
| 2 | 222 |
+---+-----+
4. select  * from  test_innodb_lock; //session1 未提交的数据读不到，因为session1没有commmit
+---+------+
| a | b    |
+---+------+
| 1 | 111 |
| 2 | 222 |
+---+------+
5. update test_innodb_lock set  b= '1113' where a =1;  //session2 进行update  会阻塞直到 session1 update 提交
7  session2 解除阻塞 
8  commit; 
9.  select  * from  test_innodb_lock;   
+---+------+
| a | b    |
+---+------+
| 1 | 1113 |
| 2 | 222 |
+---+------+
12. update test_innodb_lock set  b= '2222' where a =2; //更新a=2，由于session1更新的a=1,锁住的是a=1,a=2没有被锁住，所有不会阻塞
13. commit;
14. select  * from  test_innodb_lock;
+---+------+
| a | b    |
+---+------+
| 1 | 1114 |
| 2 | 2222 |
+---+------+


```



无索引 行锁升级未表锁

```mysql
## session1  a int   b varchar
1 select  * from test_innodb_lock;
+---+------+
| a | b    |
+---+------+
| 1 | 1114 |
| 2 | 2222 |
+---+------+

2 update test_innodb_lock set a=11 where b=1114;  //varchar 不带引号 索引失效,导致行锁变成表锁
4 commit;


## session2
1 select  * from test_innodb_lock；
   
+---+------+
| a | b    |
+---+------+
| 1 | 1114 |
| 2 | 2222 |
+---+------+

3 update test_innodb_lock set b='22223' where a=2; // session1 的第二步操作，导致行锁变成表锁 所以当前sql一直阻塞
5  第三步执行成功
```



  #### 间隙锁 
  当我们用范围条件而不是相等条件检索数据，并请求共享或排它锁时，inodb会给符合条件的已有数据记录的索引项加锁，对于键值在条件范围内并不存在的记录  就做间隙锁 

```mysql
## session1  
1 select  * from test_innodb_lock;
+----+-------+
| a  | b     |
+----+-------+
| 11 | 1114  |
|  2 | 22223 |
|  3 | 333   |
|  4 | 444   |
|  6 | 666   |
+----+-------+
2 update test_innodb_lock set b='xxx' where a>2 and a<6;
4 commit;


## session2
1 select  * from test_innodb_lock;
+----+-------+
| a  | b     |
+----+-------+
| 11 | 1114  |
|  2 | 22223 |
|  3 | 333   |
|  4 | 444   |
|  6 | 666   |
+----+-------+
3 	INSERT INTO `test_innodb_lock` (`a`, `b`) VALUES (5, '55'); //一直阻塞直到session commit
5   执行成功
```





### 锁定一行记录

```mysql
## session1  
1 select *  from test_innodb_lock where  a=2 for update;
3 commit;   

## session1  
2 update test_innodb_lock set b ='22234' where a=2; //session1 锁定了 a=2 的一行，所以当前sql会阻塞
4 2执行成功

```



### 查看innodb 行锁的状态

```mysql
show status like 'innodb_row_lock%';
+-------------------------------+--------+
| Variable_name                 | Value  |
+-------------------------------+--------+
| Innodb_row_lock_current_waits | 0      |
| Innodb_row_lock_time          | 107529 |
| Innodb_row_lock_time_avg      | 17921  |
| Innodb_row_lock_time_max      | 51004  |
| Innodb_row_lock_waits         | 6      |



## Innodb_row_lock_current_waits  当前正在等待锁定的数量
## Innodb_row_lock_waits 系统启动到现在总共等待的次数
## Innodb_row_lock_time 等待总的时长
##
```

###  行锁优化建议

- 尽可能的让检索数据通过索引完成，避免无索引行锁升级为表锁
- 合理设计索引，计量缩小锁的范围
- 尽可能较少检索条件，避免间隙锁

