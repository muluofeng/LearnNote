RDS MySQL在大字段上创建索引时，偶尔可能会遇到如下错误：
`ERROR 1709 (HY000): Index column size too large. The maximum column size is 767 bytes.`

可能原因
由于MySQL的InnoDB引擎表索引字段长度的限制为767字节，因此对于多字节字符集的大字段或者多字段组合，创建索引时会出现该问题。



解决方案
### 1在控制台的参数设置里修改参数innodb_large_prefix为ON或者1，然后单击提交参数。
![cc0be15a267fa59a005c41dc74ce3f02.png](http://qiniu.muluofeng.com/uPic/2021/10/A91B26AC-D848-432D-9361-5DAA07629379.png)
说明 将innodb_large_prefix修改为ON或者1后，对于Dynamic和Compressed格式的InnoDB引擎表，其最大的索引字段长度支持到3072字节。

### 2 创建表的时候指定表的row_format格式为Dynamic或者Compressed

```
create table idx_length_test_02
(
  id int auto_increment primary key,
  name varchar(255)
) 
ROW_FORMAT=DYNAMIC default charset utf8mb4;
```
对已经创建的表，修改表的row_format格式命令如下：
```
alter table <表名> row_format=dynamic;
```