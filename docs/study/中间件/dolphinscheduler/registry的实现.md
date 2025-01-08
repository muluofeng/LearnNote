### dolphinscheduler-registry 
注册中心的作用
- 1.存储masterworker的元数据，以便在节点上下时收到通知
- 2.存储worker的元数据以进行负载平衡。
- 3.进行故障转移时获取全局锁。

#### 1. 目录结构


![1730257972341.png](https://qiniu.muluofeng.com/1730257972341.png)

 - dolphinscheduler-registry-all 这个模块是一个没有源码的maven，里面添加所有的register实现插件
 - dolphinscheduler-registry-api 定义了注册中心的接口，比如 Registry、ConnectionListener、SubscribeListener
 - dolphinscheduler-registry-plugins 定义了所有实现注册中心的插件 目前有的是 jdbc、zk、etcd


 ###  dolphinscheduler-registry-all 
 这个模块没有代码只有maven
 ```xml
     <dependencies>
        <dependency>
            <groupId>org.apache.dolphinscheduler</groupId>
            <artifactId>dolphinscheduler-registry-zookeeper</artifactId>
            <version>${project.version}</version>
        </dependency>
        <dependency>
            <groupId>org.apache.dolphinscheduler</groupId>
            <artifactId>dolphinscheduler-registry-jdbc</artifactId>
            <version>${project.version}</version>
        </dependency>
        <dependency>
            <groupId>org.apache.dolphinscheduler</groupId>
            <artifactId>dolphinscheduler-registry-etcd</artifactId>
            <version>${project.version}</version>
        </dependency>
    </dependencies>
 ```


 ###  dolphinscheduler-registry-api
 这个模块是最核心的模块，定义了注册中心的接口，比如 Registry、ConnectionListener、SubscribeListener 然后让plugins模块去实现对应的接口
 
 
![1730260146063.png](https://qiniu.muluofeng.com/1730260146063.png)


代码地址 https://github.com/apache/dolphinscheduler/blob/dev/dolphinscheduler-registry/dolphinscheduler-registry-api/src/main/java/org/apache/dolphinscheduler/registry/api/Registry.java


 ###  dolphinscheduler-registry-zookeeper 的实现

 ZookeeperRegistryProperties  zk的配置类， ConditionalOnProperty 指定 当配置文件指定值的时候生效，ConfigurationProperties把对应配置文件的值赋值给对应的相同名称的属性
 ZookeeperRegistry zk注册中心实现类

```java
@Data
@Configuration
@ConditionalOnProperty(prefix = "registry", name = "type", havingValue = "zookeeper")
@ConfigurationProperties(prefix = "registry")
public class ZookeeperRegistryProperties {
    private ZookeeperProperties zookeeper = new ZookeeperProperties();
    @Data
    public static final class ZookeeperProperties {
        private String namespace;
        private String connectString;
        private RetryPolicy retryPolicy = new RetryPolicy();
        private String digest;
        private Duration sessionTimeout = Duration.ofSeconds(30);
        private Duration connectionTimeout = Duration.ofSeconds(9);
        private Duration blockUntilConnected = Duration.ofMillis(600);
        @Data
        public static final class RetryPolicy {
            private Duration baseSleepTime = Duration.ofMillis(60);
            private int maxRetries;
            private Duration maxSleep = Duration.ofMillis(300);
        }
    }
}
```

```java
@Component
@ConditionalOnProperty(prefix = "registry", name = "type", havingValue = "zookeeper")
public final class ZookeeperRegistry implements Registry {
    //配置信息
    private final ZookeeperRegistryProperties.ZookeeperProperties properties;
    //Curator客户端
    private final CuratorFramework client;
    // Curator 事件监听 信息
    private final Map<String, TreeCache> treeCacheMap = new ConcurrentHashMap<>();
    // Curator 锁
    private static final ThreadLocal<Map<String, InterProcessMutex>> threadLocalLockMap = new ThreadLocal<>();

    public ZookeeperRegistry(ZookeeperRegistryProperties registryProperties) {
        properties = registryProperties.getZookeeper();
        //指定重试策略
        final ExponentialBackoffRetry retryPolicy = new ExponentialBackoffRetry(
                (int) properties.getRetryPolicy().getBaseSleepTime().toMillis(),
                properties.getRetryPolicy().getMaxRetries(),
                (int) properties.getRetryPolicy().getMaxSleep().toMillis());

        CuratorFrameworkFactory.Builder builder =
                CuratorFrameworkFactory.builder()
                        .connectString(properties.getConnectString())
                        .retryPolicy(retryPolicy)
                        .namespace(properties.getNamespace())
                        .sessionTimeoutMs((int) properties.getSessionTimeout().toMillis())
                        .connectionTimeoutMs((int) properties.getConnectionTimeout().toMillis());
        client = builder.build();
    }

    

    @PostConstruct
    public void start() {
        client.start();
        try {
            if (!client.blockUntilConnected((int) properties.getBlockUntilConnected().toMillis(), MILLISECONDS)) {
                client.close();
                throw new RegistryException("zookeeper connect timeout: " + properties.getConnectString());
            }
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new RegistryException("Zookeeper registry start failed", e);
        }
    }

    @Override
    public void addConnectionStateListener(ConnectionListener listener) {
        client.getConnectionStateListenable().addListener(new ZookeeperConnectionStateListener(listener));
    }

    @Override
    public void connectUntilTimeout(@NonNull Duration timeout) throws RegistryException {
        try {
            if (!client.blockUntilConnected((int) timeout.toMillis(), MILLISECONDS)) {
                throw new RegistryException(
                        String.format("Cannot connect to the Zookeeper registry in %s s", timeout.getSeconds()));
            }
        } catch (RegistryException e) {
            throw e;
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new RegistryException(
                    String.format("Cannot connect to the Zookeeper registry in %s s", timeout.getSeconds()), e);
        }
    }

    /**
     *    使用 TreeCache 订阅指定的key和子集key 把
     */
    @Override
    public boolean subscribe(String path, SubscribeListener listener) {
        final TreeCache treeCache = treeCacheMap.computeIfAbsent(path, $ -> new TreeCache(client, path));
        //添加事件监听，监听事件
        treeCache.getListenable().addListener(($, event) -> listener.notify(new EventAdaptor(event, path)));
        try {
            treeCache.start();
        } catch (Exception e) {
            treeCacheMap.remove(path);
            throw new RegistryException("Failed to subscribe listener for key: " + path, e);
        }
        return true;
    }

    @Override
    public void unsubscribe(String path) {
        CloseableUtils.closeQuietly(treeCacheMap.get(path));
    }

    @Override
    public String get(String key) {
        try {
            return new String(client.getData().forPath(key), StandardCharsets.UTF_8);
        } catch (Exception e) {
            throw new RegistryException("zookeeper get data error", e);
        }
    }

    @Override
    public boolean exists(String key) {
        try {
            return null != client.checkExists().forPath(key);
        } catch (Exception e) {
            throw new RegistryException("zookeeper check key is existed error", e);
        }
    }

    @Override
    public void put(String key, String value, boolean deleteOnDisconnect) {
        final CreateMode mode = deleteOnDisconnect ? CreateMode.EPHEMERAL : CreateMode.PERSISTENT;

        try {
            client.create()
                    .orSetData()
                    .creatingParentsIfNeeded()
                    .withMode(mode)
                    .forPath(key, value.getBytes(StandardCharsets.UTF_8));
        } catch (Exception e) {
            throw new RegistryException("Failed to put registry key: " + key, e);
        }
    }

    @Override
    public List<String> children(String key) {
        try {
            List<String> result = client.getChildren().forPath(key);
            result.sort(Comparator.reverseOrder());
            return result;
        } catch (Exception e) {
            throw new RegistryException("zookeeper get children error", e);
        }
    }

    @Override
    public void delete(String nodePath) {
        try {
            client.delete()
                    .deletingChildrenIfNeeded()
                    .forPath(nodePath);
        } catch (KeeperException.NoNodeException ignored) {
            // Is already deleted or does not exist
        } catch (Exception e) {
            throw new RegistryException("Failed to delete registry key: " + nodePath, e);
        }
    }

    @Override
    public boolean acquireLock(String key) {
        InterProcessMutex interProcessMutex = new InterProcessMutex(client, key);
        try {
            interProcessMutex.acquire();
            if (null == threadLocalLockMap.get()) {
                threadLocalLockMap.set(new HashMap<>(3));
            }
            threadLocalLockMap.get().put(key, interProcessMutex);
            return true;
        } catch (Exception e) {
            try {
                interProcessMutex.release();
                throw new RegistryException(String.format("zookeeper get lock: %s error", key), e);
            } catch (Exception exception) {
                throw new RegistryException(String.format("zookeeper get lock: %s error", key), e);
            }
        }
    }

    @Override
    public boolean releaseLock(String key) {
        if (null == threadLocalLockMap.get().get(key)) {
            return false;
        }
        try {
            threadLocalLockMap.get().get(key).release();
            threadLocalLockMap.get().remove(key);
            if (threadLocalLockMap.get().isEmpty()) {
                threadLocalLockMap.remove();
            }
        } catch (Exception e) {
            throw new RegistryException("zookeeper release lock error", e);
        }
        return true;
    }

    @Override
    public void close() {
        treeCacheMap.values().forEach(CloseableUtils::closeQuietly);
        CloseableUtils.closeQuietly(client);
    }


    static final class EventAdaptor extends Event {

        public EventAdaptor(TreeCacheEvent event, String key) {
            key(key);

            switch (event.getType()) {
                case NODE_ADDED:
                    type(Type.ADD);
                    break;
                case NODE_UPDATED:
                    type(Type.UPDATE);
                    break;
                case NODE_REMOVED:
                    type(Type.REMOVE);
                    break;
                default:
                    break;
            }

            final ChildData data = event.getData();
            if (data != null) {
                path(data.getPath());
                data(new String(data.getData()));
            }
        }
    }
}
```



 ###  dolphinscheduler-registry-jdbc 的实现


基于mysql的数据库设计
```sql
-- 注册中心注册数据
CREATE TABLE `t_ds_jdbc_registry_data`
(
    `id`               bigint(11) NOT NULL AUTO_INCREMENT COMMENT 'primary key',
    `data_key`         varchar(256) NOT NULL COMMENT 'key, like zookeeper node path',
    `data_value`       text         NOT NULL COMMENT 'data, like zookeeper node value',
    `data_type`        tinyint(4) NOT NULL COMMENT '1: ephemeral node, 2: persistent node',
    `last_term`        bigint       NOT NULL COMMENT 'last term time',
    `last_update_time` timestamp    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'last update time',
    `create_time`      timestamp    NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'create time',
    PRIMARY KEY (`id`),
    unique (`data_key`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8;

-- 注册中心锁
CREATE TABLE `t_ds_jdbc_registry_lock`
(
    `id`               bigint(11) NOT NULL AUTO_INCREMENT COMMENT 'primary key',
    `lock_key`         varchar(256) NOT NULL COMMENT 'lock path',
    `lock_owner`       varchar(256) NOT NULL COMMENT 'the lock owner, ip_processId',
    `last_term`        bigint       NOT NULL COMMENT 'last term time',
    `last_update_time` timestamp    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'last update time',
    `create_time`      timestamp    NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'create time',
    PRIMARY KEY (`id`),
    unique (`lock_key`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8;
```


![1730274090087.png](https://qiniu.muluofeng.com/1730274090087.png)


配置信息
```java
@Data
@Configuration
@ConditionalOnProperty(prefix = "registry", name = "type", havingValue = "jdbc")
@ConfigurationProperties(prefix = "registry")
public class JdbcRegistryProperties {

    /**
     * 配置临时数据或者锁的 时间频次
     */
    private Duration termRefreshInterval = Duration.ofSeconds(2);
    /**
     * 指定临时数据多久失效
     */
    private int termExpireTimes = 3;
    /**
     * 数据库配置
     */
    private HikariConfig hikariConfig;

}
```
JdbcRegistry 的实现 主要是 EphemeralDateManager、SubscribeDataManager、RegistryLockManager 3个实现
```java
@Component
@ConditionalOnProperty(prefix = "registry", name = "type", havingValue = "jdbc")
@Slf4j
public class JdbcRegistry implements Registry {

    //配置信息
    private final JdbcRegistryProperties jdbcRegistryProperties;
    //临时数据管理
    private final EphemeralDateManager ephemeralDateManager;
    //订阅数据管理
    private final SubscribeDataManager subscribeDataManager;
    //锁管理
    private final RegistryLockManager registryLockManager;
    //数据库表操作类
    private JdbcOperator jdbcOperator;

    public JdbcRegistry(JdbcRegistryProperties jdbcRegistryProperties,
                        JdbcOperator jdbcOperator) {
        this.jdbcOperator = jdbcOperator;
        jdbcOperator.clearExpireLock();
        jdbcOperator.clearExpireEphemeralDate();
        this.jdbcRegistryProperties = jdbcRegistryProperties;
        this.ephemeralDateManager = new EphemeralDateManager(jdbcRegistryProperties, jdbcOperator);
        this.subscribeDataManager = new SubscribeDataManager(jdbcRegistryProperties, jdbcOperator);
        this.registryLockManager = new RegistryLockManager(jdbcRegistryProperties, jdbcOperator);
        log.info("Initialize Jdbc Registry...");
    }

    @PostConstruct
    public void start() {
        log.info("Starting Jdbc Registry...");
        // start a jdbc connect check
        ephemeralDateManager.start();
        subscribeDataManager.start();
        registryLockManager.start();
        log.info("Started Jdbc Registry...");
    }
}
```
具体代码请查看
https://github.com/apache/dolphinscheduler/blob/dev/dolphinscheduler-registry/dolphinscheduler-registry-plugins/dolphinscheduler-registry-jdbc/src/main/java/org/apache/dolphinscheduler/plugin/registry/jdbc/JdbcRegistry.java


EphemeralDateManager 主要使用数据库记录 连接信息（临时数据），所以在关闭是都要删除，这里主要使用线程池创建一个线程以指定频率的数据轮训数据
```java
@Slf4j
public class EphemeralDateManager implements AutoCloseable {
    //连接状态
    private ConnectionState connectionState;
    private final JdbcOperator jdbcOperator;
    private final JdbcRegistryProperties registryProperties;
    //监听列表
    private final List<ConnectionListener> connectionListeners = Collections.synchronizedList(new ArrayList<>());
    //临时数据ids 
    private final Set<Long> ephemeralDateIds = Collections.synchronizedSet(new HashSet<>());
    //定时任务线程管理
    private final ScheduledExecutorService scheduledExecutorService;

    public EphemeralDateManager(JdbcRegistryProperties registryProperties, JdbcOperator jdbcOperator) {
        this.registryProperties = registryProperties;
        this.jdbcOperator = checkNotNull(jdbcOperator);
        this.scheduledExecutorService = Executors.newScheduledThreadPool(
                1,
                new ThreadFactoryBuilder().setNameFormat("EphemeralDateTermRefreshThread").setDaemon(true).build());
    }

    public void start() {
        //以指定的频率 监听数据状态，更新未过期数据的时间、删除过期数据 ，主要执行 EphemeralDateTermRefreshTask 的run
        this.scheduledExecutorService.scheduleWithFixedDelay(
                new EphemeralDateTermRefreshTask(jdbcOperator, connectionListeners, ephemeralDateIds),
                registryProperties.getTermRefreshInterval().toMillis(),
                registryProperties.getTermRefreshInterval().toMillis(),
                TimeUnit.MILLISECONDS);
    }
    

    public void addConnectionListener(ConnectionListener connectionListener) {
        connectionListeners.add(connectionListener);
    }

    @Override
    public void close() throws SQLException {
        for (Long ephemeralDateId : ephemeralDateIds) {
            jdbcOperator.deleteDataById(ephemeralDateId);
        }
        ephemeralDateIds.clear();
        connectionListeners.clear();
        scheduledExecutorService.shutdownNow();
    }
```

SubscribeDataManager 主要记录订阅数据的变化
```java
@Slf4j
public class SubscribeDataManager implements AutoCloseable {

    private final JdbcOperator jdbcOperator;
    private final JdbcRegistryProperties registryProperties;
    //每个key的订阅者
    private final Map<String, List<SubscribeListener>> dataSubScribeMap = new ConcurrentHashMap<>();
    //线程池 定时计算出数据的 add、update、delete 通知订阅者
    private final ScheduledExecutorService dataSubscribeCheckThreadPool;
    //订阅的数据
    private final Map<String, JdbcRegistryData> jdbcRegistryDataMap = new ConcurrentHashMap<>();

    public SubscribeDataManager(JdbcRegistryProperties registryProperties, JdbcOperator jdbcOperator) {
        this.registryProperties = registryProperties;
        this.jdbcOperator = jdbcOperator;
        this.dataSubscribeCheckThreadPool = Executors.newScheduledThreadPool(
                1,
                new ThreadFactoryBuilder().setNameFormat("JdbcRegistrySubscribeDataCheckThread").setDaemon(true)
                        .build());
    }

    public void start() {
        // RegistrySubscribeDataCheckTask 主要是轮训数据库数据 记录数据的add、update、delete 通知订阅者
        dataSubscribeCheckThreadPool.scheduleWithFixedDelay(
                new RegistrySubscribeDataCheckTask(dataSubScribeMap, jdbcOperator, jdbcRegistryDataMap),
                registryProperties.getTermRefreshInterval().toMillis(),
                registryProperties.getTermRefreshInterval().toMillis(),
                TimeUnit.MILLISECONDS);
    }

     @RequiredArgsConstructor
    static class RegistrySubscribeDataCheckTask implements Runnable {

        private final Map<String, List<SubscribeListener>> dataSubScribeMap;
        private final JdbcOperator jdbcOperator;
        private final Map<String, JdbcRegistryData> jdbcRegistryDataMap;

        @Override
        public void run() {
            // query the full data from database, and update the jdbcRegistryDataMap
            try {
                Map<String, JdbcRegistryData> currentJdbcDataMap = jdbcOperator.queryAllJdbcRegistryData()
                        .stream()
                        .collect(Collectors.toMap(JdbcRegistryData::getDataKey, Function.identity()));
                // find the different
                List<JdbcRegistryData> addedData = new ArrayList<>();
                List<JdbcRegistryData> deletedData = new ArrayList<>();
                List<JdbcRegistryData> updatedData = new ArrayList<>();
                for (Map.Entry<String, JdbcRegistryData> entry : currentJdbcDataMap.entrySet()) {
                    JdbcRegistryData newData = entry.getValue();
                    JdbcRegistryData oldData = jdbcRegistryDataMap.get(entry.getKey());
                    if (oldData == null) {
                        addedData.add(newData);
                    } else {
                        if (!entry.getValue().getLastUpdateTime().equals(oldData.getLastUpdateTime())) {
                            updatedData.add(newData);
                        }
                    }
                }
                for (Map.Entry<String, JdbcRegistryData> entry : jdbcRegistryDataMap.entrySet()) {
                    if (!currentJdbcDataMap.containsKey(entry.getKey())) {
                        deletedData.add(entry.getValue());
                    }
                }
                jdbcRegistryDataMap.clear();
                jdbcRegistryDataMap.putAll(currentJdbcDataMap);
                // trigger listener
                for (Map.Entry<String, List<SubscribeListener>> entry : dataSubScribeMap.entrySet()) {
                    String subscribeKey = entry.getKey();
                    List<SubscribeListener> subscribeListeners = entry.getValue();
                    triggerListener(addedData, subscribeKey, subscribeListeners, Event.Type.ADD);
                    triggerListener(deletedData, subscribeKey, subscribeListeners, Event.Type.REMOVE);
                    triggerListener(updatedData, subscribeKey, subscribeListeners, Event.Type.UPDATE);
                }
            } catch (Exception e) {
                log.error("Query data from jdbc registry error");
            }
        }

        private void triggerListener(List<JdbcRegistryData> dataList,
                                     String subscribeKey,
                                     List<SubscribeListener> subscribeListeners,
                                     Event.Type type) {
            for (JdbcRegistryData data : dataList) {
                if (data.getDataKey().startsWith(subscribeKey)) {
                    subscribeListeners.forEach(subscribeListener -> subscribeListener
                            .notify(new Event(data.getDataKey(), data.getDataKey(), data.getDataValue(), type)));
                }
            }
        }

    }
}
```


RegistryLockManager 主要 注册中心锁
```java
@Slf4j
public class RegistryLockManager implements AutoCloseable {

    private final JdbcOperator jdbcOperator;
    private final JdbcRegistryProperties registryProperties;
    //记录所有的锁的数据
    private final Map<String, JdbcRegistryLock> lockHoldMap;
    //定时任务 主要用于轮训 失效的key并把它删除
    private final ScheduledExecutorService lockTermUpdateThreadPool;

    public RegistryLockManager(JdbcRegistryProperties registryProperties, JdbcOperator jdbcOperator) {
        this.registryProperties = registryProperties;
        this.jdbcOperator = jdbcOperator;
        this.lockHoldMap = new ConcurrentHashMap<>();
        this.lockTermUpdateThreadPool = Executors.newSingleThreadScheduledExecutor(
                new ThreadFactoryBuilder().setNameFormat("JdbcRegistryLockTermRefreshThread").setDaemon(true).build());
    }

    public void start() {
        lockTermUpdateThreadPool.scheduleWithFixedDelay(
                new LockTermRefreshTask(lockHoldMap, jdbcOperator),
                registryProperties.getTermRefreshInterval().toMillis(),
                registryProperties.getTermRefreshInterval().toMillis(),
                TimeUnit.MILLISECONDS);
    }

    /**
     * Acquire the lock, if cannot get the lock will await.
     */
    public void acquireLock(String lockKey) throws RegistryException {
        // maybe we can use the computeIf absent
        lockHoldMap.computeIfAbsent(lockKey, key -> {
            JdbcRegistryLock jdbcRegistryLock;
            try {
                //主要是像数据库插入指定的lockey 如果存在指定的key那么返回null 当前前程睡眠1s 重试
                while ((jdbcRegistryLock = jdbcOperator.tryToAcquireLock(lockKey)) == null) {
                    log.debug("Acquire the lock {} failed try again", key);
                    // acquire failed, wait and try again
                    ThreadUtils.sleep(JdbcRegistryConstant.LOCK_ACQUIRE_INTERVAL);
                }
            } catch (SQLException e) {
                throw new RegistryException("Acquire the lock error", e);
            }
            return jdbcRegistryLock;
        });
    }

    public void releaseLock(String lockKey) {
        JdbcRegistryLock jdbcRegistryLock = lockHoldMap.get(lockKey);
        if (jdbcRegistryLock != null) {
            try {
                // 从数据库删除id 并移除 内存的map数据
                jdbcOperator.releaseLock(jdbcRegistryLock.getId());
                lockHoldMap.remove(lockKey);
            } catch (SQLException e) {
                throw new RegistryException(String.format("Release lock: %s error", lockKey), e);
            }
        }
    }

    @Override
    public void close() {
        //关闭线程池并 删除所有的 lock 数据
        lockTermUpdateThreadPool.shutdownNow();
        for (Map.Entry<String, JdbcRegistryLock> lockEntry : lockHoldMap.entrySet()) {
            releaseLock(lockEntry.getKey());
        }
    }
}
```