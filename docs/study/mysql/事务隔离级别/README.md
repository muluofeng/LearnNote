## 查看当前mysql 的隔离级别

```mysql
show VARIABLES like  'tx_isolation'   //默认  REPEATABLE-READ  可重复读
```

acid