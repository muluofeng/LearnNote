

# Redis中的数据结构

##  redis的键的相关命令



```java
 keys *   

 exists key的名字，判断某个key是否存在

 move key db   --->当前库就没有了，被移除了

 expire key 秒钟：为给定的key设置过期时间

 ttl key 查看还有多少秒过期，-1表示永不过期，-2表示已过期

 type key 查看你的key是什么类型
```





## redis 字符串String



```
set/get/del/append/strlen

Incr/decr/incrby/decrby,一定要是数字才能进行加减

getrange/setrange

 setex(set with expire)键秒值/setnx(set if not exist)

 mset/mget/msetnx

 getset(先get再set)

```

## Redis 列表 list

```
 lpush/rpush/lrange

 lpop/rpop

 lindex，按照索引下标获得元素(从上到下)

 llen

 lrem key 删N个value

 ltrim key 开始index 结束index，截取指定范围的值后再赋值给key

 rpoplpush 源列表 目的列表

 lset key index value

 linsert key  before/after 值1 值2

```

## Redis  集合Set

```
 sadd/smembers/sismember

 scard，获取集合里面的元素个数

 srem key value 删除集合中元素

 srandmember key 某个整数(随机出几个数)

 spop key 随机出栈

 smove key1 key2 在key1里某个值      作用是将key1里的某个值赋给key2

 数学集合类
	差集：sdiff
	交集：sinter
	并集：sunion

```

## Redis  哈希Hash

```
  hset/hget/hmset/hmget/hgetall/hdel

 hlen

 hexists key 在key里面的某个值的key

 hkeys/hvals

 hincrby/hincrbyfloat

 hsetnx

```

## Redis 有序集合 Zset  (Sorted Set)

在set基础上，加一个score值。
之前set是k1 v1 v2 v3，
现在zset是k1 score1 v1 score2 v2

```
 zadd/zrange
		withscores

 zrangebyscore key 开始score 结束score
	 1. withscores
	 2. (   不包含
	 3. limit 作用是返回限制
		 limit 开始下标步 多少步


 zrem key 某score下对应的value值，作用是删除元素

 zcard/zcount key score区间/zrank key values值，作用是获得下标值/zscore key 对应值,获得分数

 zrevrank key values值，作用是逆序获得下标值

 zrevrange

 zrevrangebyscore  key 结束score 开始score

```

