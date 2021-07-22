###  HashMap在多线程环境下存在线程安全问题，那你一般都是怎么处理这种情况的？
- 使用Collections.synchronizedMap(Map)创建线程安全的map集合；
- Hashtable
- ConcurrentHashMap

不过出于线程并发度的原因，我都会舍弃前两者使用最后的ConcurrentHashMap，他的性能和效率明显高于前两者。

### Collections.synchronizedMap是怎么实现线程安全的你有了解过么？
在SynchronizedMap内部维护了一个普通对象Map，还有排斥锁mutex，再操作map的时候，就会对方法上锁，