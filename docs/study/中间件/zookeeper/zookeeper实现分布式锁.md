### 分布式锁原理
单体的应用开发场景中涉及并发同步的时候，大家往往采用 synchronized或者Lock的方式来解决多线程间的同步问题。在分布式 集群工作的开发场景中需要一种更加高级的锁机制来处理跨JVM进程之 间的数据同步问题，这就是分布式锁。

### 可重入锁的原理

指的是同一线程外层函数获得锁之后，内层递归函数仍然能获取到该锁的代码，在同一线程在外层方法获取锁的时候，在进入内层方法会自动获取锁


### ZooKeeper分布式锁的原理
- 利用 EPHEMERAL_SEQUENTIAL 临时顺序节点类型，新的子节点后面会加上一个次序编号，而这个生成的次序编号 是上一个生成的次序编号加一

- 一个ZooKeeper分布式锁需要创建一个父节点，尽量是持久节点 (PERSISTENT类型)，然后每个要获得锁的线程都在这个节点下创建 一个临时顺序节点，因为ZooKeeper节点是按照创建的次序依次递增 的。

-  为了确保公平，可以简单地规定:编号最小的那个节点表示获得 了锁。所以，每个线程在尝试占用锁之前首先判断自己的排号是不是 当前最小，如果是就获取锁。

-  ZooKeeper的节点监听机制可以保障占有锁的传递有序而且 高效。


![1730104662507.png](https://qiniu.muluofeng.com/1730104662507.png)

### 基于  curator 实现分布式锁

基于上面的 ZookeeperComponent 添加实现方法
除了InterProcessMutex 还提供一些其他的lock都在org.apache.curator.framework.recipes.locks包下，比如读写锁  InterProcessReadWriteLock 等等
```java
@Slf4j
public class ZookeeperComponent {
    private static final ThreadLocal<Map<String, InterProcessMutex>> threadLocalLockMap = ThreadLocal.withInitial(ConcurrentHashMap::new);

    public static boolean acquireLock(String key) {
        InterProcessMutex interProcessMutex = new InterProcessMutex(getInstance(), key);
        try {
            interProcessMutex.acquire();
            Map<String, InterProcessMutex> lockMap = threadLocalLockMap.get();
            if (lockMap == null) {
                lockMap = new ConcurrentHashMap<>();
                threadLocalLockMap.set(lockMap);
            }
            lockMap.put(key, interProcessMutex);
            return true;
        } catch (Exception e) {
            try {
                interProcessMutex.release();
            } catch (Exception exception) {
                log.error("Failed to release lock after acquisition failure for key: {}", key, e);
            }
            log.error("Failed to acquire lock for key: {}", key, e);
            throw new RuntimeException(String.format("zookeeper get lock: %s error", key), e);
        }
    }

    public static boolean releaseLock(String key) {
        Map<String, InterProcessMutex> lockMap = threadLocalLockMap.get();
        if (lockMap == null || lockMap.get(key) == null) {
            return false;
        }
        try {
            lockMap.get(key).release();
            return true;
        } catch (Exception e) {
            log.error("Failed to release lock for key: {}", key, e);
            throw new RuntimeException("zookeeper release lock error", e);
        } finally {
            lockMap.remove(key);
            if (lockMap.isEmpty()) {
                threadLocalLockMap.remove();
            }
        }
    }
}
```
添加测试
```java
@Slf4j
public class CuratorLock {

    public static Integer num =0;
    @SneakyThrows
    public static void main(String[] args) {
        ExecutorService executorService = Executors.newFixedThreadPool(10);
        for (int i = 0; i < 1000; i++) {
            executorService.execute(()->{
                setNumByZK();
            });
        }

        Thread.sleep(5000);
        log.info("num:"+num);
        System.in.read();
    }

    private static void setNum() {
        num++;
    }

    private static void setNumByZK() {
        try {
            ZookeeperComponent.acquireLock("/Curator/lock");
            num++;
        } catch (Exception e) {
            throw new RuntimeException(e);
        }finally {
            ZookeeperComponent.releaseLock("/Curator/lock");
        }
    }
}
```
输出
```log
num: 952  //setNum
num: 1000 //setNumByZK
```


###  ZooKeeper分布式锁的优点和缺点
总结一下ZooKeeper分布式锁：

- 优点：ZooKeeper分布式锁（如InterProcessMutex），能有效的解决分布式问题，不可重入问题，使用起来也较为简单。

- 缺点：ZooKeeper实现的分布式锁，性能并不太高。为啥呢？
因为每次在创建锁和释放锁的过程中，都要动态创建、销毁瞬时节点来实现锁功能。大家知道，ZK中创建和删除节点只能通过Leader服务器来执行，然后Leader服务器还需要将数据同不到所有的Follower机器上，这样频繁的网络通信，性能的短板是非常突出的。

总之，在高性能，高并发的场景下，不建议使用ZooKeeper的分布式锁。而由于ZooKeeper的高可用特性，所以在并发量不是太高的场景，推荐使用ZooKeeper的分布式锁。

在目前分布式锁实现方案中，比较成熟、主流的方案有两种：

- 基于Redis的分布式锁

- 基于ZooKeeper的分布式锁

两种锁，分别适用的场景为：

- 基于ZooKeeper的分布式锁，适用于高可靠（高可用）而并发量不是太大的场景；

- 基于Redis的分布式锁，适用于并发量很大、性能要求很高的、而可靠性问题可以通过其他方案去弥补的场景。

总之，这里没有谁好谁坏的问题，而是谁更合适的问题。