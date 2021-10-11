Case具有两种格式。简单Case函数和Case搜索函数。

- 简单Case函数

```
CASE sex
WHEN '1' THEN '男'
WHEN '2' THEN '女'
ELSE '其他' END
```

- Case搜索函数 

```
CASE WHEN sex = '1' THEN '男' 
WHEN sex = '2' THEN '女' 
ELSE '其他' END
```

区别： 简单Case函数的写法相对比较简洁，但是和Case搜索函数相比，功能方面会有些限制，比如写判断式。还有一个需要注意的问题，Case函数只返回第一个符合条件的值，剩下的Case部分将会被自动忽略。

例子：比如说，下面这段SQL，你永远无法得到“第二类”这个结果 

```

CASE WHEN col_1 IN ( 'a', 'b') THEN '第一类' 

WHEN col_1 IN ('a')  THEN '第二类' 

ELSE'其他' END
```


1.  使用case  when  来对group by 进行统计，也就是把列数据转为行数据

例子

```
date       shengfu
2005-05-09 胜
2005-05-09 胜
2005-05-09 负
2005-05-09 负
2005-05-10 胜
2005-05-10 负
2005-05-10 负

如果要生成下列结果, 该如何写sql语句?

 日期         胜 负
2005-05-09 2 2
2005-05-10 1 2


sql语句：

select date, sum(case when shengfu='胜' then 1 else 0 end)'胜',sum(case when shengfu='负' then 1 else 0 end)'负' 
from  table_name group by date
```

- 查询字段转换

```sql
select
name as '名字',
(case sex when 0 then '女' else '男' end) as '性别'
from test.student;
```


- 条件更新update

```
有如下更新条件
1.工资5000以上的职员，工资减少10%
2.工资在2000到4600之间的职员，工资增加15%

UPDATE Personnel

SET salary =

CASE WHEN salary >= 5000  　                THEN salary * 0.9 

     WHEN salary >= 2000 AND salary < 4600  THEN salary * 1.15 

ELSE salary END; 
```

- 条件分组

```
可以用这个方法来判断工资的等级，并统计每一等级的人数

user_id  salary
1         200
2         300
3         550     
4         700    
5         880

sql语句：

SELECT
	*,count(*),
	CASE WHEN salary <= 500 THEN '1'
WHEN salary > 500 AND salary <= 600  THEN '2' 
WHEN salary > 600 AND salary <= 800  THEN '3' 
WHEN salary > 800 AND salary <= 1000 THEN '4' 
ELSE NULL END as "等级"
FROM
	user_salary 
GROUP BY
CASE WHEN salary <= 500 THEN '1'
WHEN salary > 500 AND salary <= 600  THEN '2' 
WHEN salary > 600 AND salary <= 800  THEN '3' 
WHEN salary > 800 AND salary <= 1000 THEN '4' 
ELSE NULL END;
```
