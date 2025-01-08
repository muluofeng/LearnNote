
### Apache Zookeeper Java客户端Curator使用
zookeeper官方的java客户端API主要有3个
- zookeeper官方的java客户端。存在一些不足之处
- ZkClient开源客户端，对官方的客户端进行了包装，但是社区活跃不足，文档不够完善
- curator 是Netflix开源的客户端，提供的功能比较全面，Curator是Apache基金会的顶级项目之一，具有更加完善的文档
  Curator还提供了ZooKeeper一些比较普遍的分布式开发的开箱即 用的解决方案，比如Recipes、共享锁服务、Master选举机制和分布式 计算器等。Java应用开发时在这些小的组件上可以不用重复造轮子
#### 添加maven依赖 版本号自己指定
- curator-framework:对ZooKeeper底层API的一些封装。
- curator-recipes:封装了一些高级特性，如Cache事件监 听、选举、分布式锁、分布式计数器、分布式Barrier等。

```xml
<dependency>
    <groupId>org.apache.curator</groupId>
    <artifactId>curator-framework</artifactId>
    <version>5.2.0</version> 
</dependency>

<dependency>
  <groupId>org.apache.curator</groupId>
  <artifactId>curator-recipes</artifactId>
  <version>5.2.0</version>
</dependency>

```


####  编写操作zookeeper的类
Curator内部实现的几种重试策略:
- ExponentialBackoffRetry:重试指定的次数, 且每一次重试之间停顿的时间逐渐增加，时间间隔 = baseSleepTimeMs * Math.max(1, random.nextInt(1 << (retryCount + 1)))
- RetryNTimes:指定最大重试次数的重试策略
- RetryOneTime:仅重试一次
- RetryUntilElapsed:一直重试直到达到规定的时间
  namespace: 值得注意的是session会话含有隔离命名空间，即客户端对Zookeeper上数据节点的任何操作都是相对/xxx，这有利于实现不同的Zookeeper的业务之间的隔离

  ***操作zookeeper 执行的方法有一个特点 无论是 checkExists、getData、getChildren方法都是返回构造者示例，不会立即执行，forPath()方法会执行实际的操作***
  ***异步操作只需要加上对应的 inBackground(BackgroundCallback callback)方法，异步操作不是阻塞的***
```java
 @Slf4j
public class ZookeeperComponent {
    public static volatile CuratorFramework instance;

    public static CuratorFramework getInstance() {
        if (instance == null) {
            synchronized (ZookeeperComponent.class) {
                if (instance == null) {
                    CuratorFramework curatorFramework = null;
                    try {
                        curatorFramework = CuratorFrameworkFactory.builder()
                                 // 指定命名空间 后续所有的节点都在该命名空间下
                                .namespace("zkTest")
                                .connectString("localhost:2181")
                                .sessionTimeoutMs(5000)
                                .connectionTimeoutMs(20000)
                                //重试指定的次数, 且每一次重试之间停顿的时间逐渐增加，时间间隔 = baseSleepTimeMs * Math.max(1, random.nextInt(1 << (retryCount + 1)))
                                .retryPolicy(new ExponentialBackoffRetry(1000, 3)).build();
                        curatorFramework.start();
                        //阻塞直到链接成功
                        curatorFramework.blockUntilConnected();
                        instance = curatorFramework;
                        log.info("zookeeper starter success");
                    } catch (InterruptedException e) {
                        log.error("zookeeper starter error", e);
                    }
                }
            }
        }
        return instance;
    }

    public static void checkAndDeletePath(String nodePath) {
        try {
            Stat exists = getInstance().checkExists().forPath(nodePath);
            if (exists != null) {
                getInstance().delete().forPath(nodePath);
            }
        } catch (Exception e) {
            log.error("checkAndDeletePath error, path={}", nodePath, e);
        }
    }

    public static String createNode(CreateMode createMode, String nodePath) {
        try {
            return getInstance().create().creatingParentsIfNeeded().withMode(createMode).forPath(nodePath);
        } catch (Exception e) {
            log.error("error", e);
        }
        return null;
    }

    public static void createNodeAndSetData(CreateMode createMode, String nodePath, String data) {
        try {
            getInstance().create().creatingParentsIfNeeded().withMode(createMode).forPath(nodePath, data.getBytes(StandardCharsets.UTF_8));
        } catch (Exception e) {
            log.error("error", e);
        }
    }

    public static void setNodeData(String nodePath, String data) {
        try {
            getInstance().setData().forPath(nodePath, data.getBytes(StandardCharsets.UTF_8));
        } catch (Exception e) {
            log.error("error", e);
        }
    }

    public static void deleteNode(String nodePath) {
        try {
            getInstance().delete().forPath(nodePath);
        } catch (Exception e) {
            log.error("error", e);
        }
    }
}
 ```

#### curator curd 操作
```java
    public void nodeCRUD() throws Exception {
        log.info("开始创建节点");
        String node = ZookeeperComponent.createNode(CreateMode.PERSISTENT, "/node");
        log.info("节点创建成功：" + node);
        Stat stat = new Stat(); //存储节点信息
        ZookeeperComponent.getInstance().getData().storingStatIn(stat).forPath(node);
        log.info("查询节点：" + node + "信息，stat:" + stat);
        stat = ZookeeperComponent.getInstance().setData().withVersion(stat.getVersion()).forPath(node, "Hello World".getBytes());
        String result = new String(ZookeeperComponent.getInstance().getData().forPath(node));
        log.info("修改节点后的数据信息：" + result);
        log.info("开始删除节点");
        ZookeeperComponent.getInstance().delete().forPath(node);
        Stat exist = ZookeeperComponent.getInstance().checkExists().forPath(node);
        if (exist == null) {
            log.info("节点删除成功");
        }
    }

```
执行日志：
```log 
2024-10-25 17:24:42.205 [main] INFO  org.example.CuratorMain - 节点创建成功：/node
2024-10-25 17:24:42.210 [main] INFO  org.example.CuratorMain - 查询节点：/node信息，stat:2571,2571,1729848282203,1729848282203,0,0,0,0,14,0,2571

2024-10-25 17:24:42.226 [main] INFO  org.example.CuratorMain - 修改节点后的数据信息：Hello World
2024-10-25 17:24:42.226 [main] INFO  org.example.CuratorMain - 开始删除节点
2024-10-25 17:24:42.233 [main] INFO  org.example.CuratorMain - 节点删除成功
```

#### Curator 事件监听
这个属于 Curator 比较重要的部分，Curator 事件有两种模式，
- 标准的观察模式，标准的监听模式是使用Watcher 监听器
- 缓存监听模式，缓存监听模式引入了一种本地缓存视图的Cache机制，来实现对Zookeeper服务端事件监听

Watcher 监听器比较简单，只有一种。Cache事件监听的种类有3种
- Path Cache
- Node Cache
- Tree Cache （结合了上面2种）


#####  Curator标准的观察模式
利用Watcher来对节点进行监听操作，但此监听操作只能监听一次,所以下面的监听只会输出一次
WatchedEvent包含了三个基本属性：
- 通知状态（keeperState）
- 事件类型（EventType）
- 节点路径（path）
  ZooKeeper集群直接传递过来的事件实例是WatcherEvent，而Curator 封装过的事件实例WatchedEvent，名称上有一个字母之差，而且功能也是一样的，都表示的是同一个事物
```java 
    private void watch() throws Exception {
        log.info("开始创建节点");
        String nodePath = "/watch-node";
        String node = ZookeeperComponent.createNode(CreateMode.PERSISTENT, nodePath);
        //利用Watcher来对节点进行监听操作，但此监听操作只能监听一次
        Watcher w = new Watcher() {
            @Override
            public void process(WatchedEvent watchedEvent) {
                log.info("监听器watchedEvent：" + watchedEvent);
            }
        };
        ZookeeperComponent.getInstance().getData().usingWatcher(w).forPath(nodePath);
        ZookeeperComponent.getInstance().setData().forPath(nodePath, "Hello World1".getBytes());
        ZookeeperComponent.getInstance().setData().forPath(nodePath, "Hello World2".getBytes());
        ZookeeperComponent.getInstance().delete().forPath(nodePath);
    }
```
执行日志：
```log 
2024-10-25 17:24:42.240 [main] INFO  org.example.CuratorMain - 开始创建节点
2024-10-25 17:24:42.290 [main-EventThread] INFO  org.example.CuratorMain - 监听器watchedEvent：WatchedEvent state:SyncConnected type:NodeDataChanged path:/watch-node
```


#####  Curator  Cache 节点缓存的监听
Curator引入的Cache缓存实现，是一个系列，包括了Node Cache 、Path Cache、Tree Cache三组类。
- Node Cache节点缓存可以用于ZNode节点的监听
- Path Cache子节点缓存用于ZNode的子节点的监听，不能递归监听，子节点下的子节点不能递归监控
- Tree Cache树缓存是Path Cache的增强，不光能监听子节点，也能监听ZNode节点自身
```java 
    private void nodeCache() {
        try {
            String nodePath = "/nodeCache";
            ZookeeperComponent.checkAndDeletePath(nodePath);
            ZookeeperComponent.getInstance().create().creatingParentsIfNeeded().withMode(CreateMode.PERSISTENT).forPath(nodePath);
            NodeCache nodeCache = new NodeCache(ZookeeperComponent.getInstance(), nodePath);
            nodeCache.getListenable().addListener(new NodeCacheListener() {
                @Override
                public void nodeChanged() throws Exception {
                    ChildData childData = nodeCache.getCurrentData();
                    log.info("ZNode节点状态改变, path={}", childData.getPath());
                    log.info("ZNode节点状态改变, data={}", new String(childData.getData(), "Utf-8"));
                    log.info("ZNode节点状态改变, stat={}", childData.getStat());
                }
            });
            // 一定要调用 start
            nodeCache.start();
            ZookeeperComponent.getInstance().setData().forPath(nodePath, "hello world 1".getBytes(StandardCharsets.UTF_8));
            Thread.sleep(1000);
            ZookeeperComponent.getInstance().setData().forPath(nodePath, "hello world 2".getBytes(StandardCharsets.UTF_8));
            Thread.sleep(Integer.MAX_VALUE);
        } catch (Exception e) {
            log.error("error", e);
        }
    }
```

```java  
    private void pathChildrenCache() {
        String nodePath = "/rootNode";
        String subWorkerPath = "/rootNode/childrenNode";
        try {
            ZookeeperComponent.checkAndDeletePath(nodePath);
            ZookeeperComponent.getInstance().create().creatingParentsIfNeeded().withMode(CreateMode.PERSISTENT).forPath(nodePath);
            PathChildrenCache cache = new PathChildrenCache(ZookeeperComponent.getInstance(), nodePath, true);
            PathChildrenCacheListener listener = new PathChildrenCacheListener() {
                @Override
                public void childEvent(CuratorFramework curatorFramework, PathChildrenCacheEvent event) throws Exception {
                    try {
                        ChildData data = event.getData();
                        switch (event.getType()) {
                            case CHILD_ADDED:

                                log.info("子节点增加, path={}, data={}", data.getPath(), new String(data.getData(), "UTF-8"));

                                break;
                            case CHILD_UPDATED:
                                log.info("子节点更新, path={}, data={}", data.getPath(), new String(data.getData(), "UTF-8"));
                                break;
                            case CHILD_REMOVED:
                                log.info("子节点删除, path={}, data={}", data.getPath(), new String(data.getData(), "UTF-8"));
                                break;
                            default:
                                break;
                        }

                    } catch (UnsupportedEncodingException e) {
                        log.error("error", e);
                    }
                }
            };
            cache.getListenable().addListener(listener);
            cache.start(PathChildrenCache.StartMode.BUILD_INITIAL_CACHE);
            Thread.sleep(1000);
            for (int i = 0; i < 3; i++) {
                ZookeeperComponent.getInstance().create().withMode(CreateMode.PERSISTENT)
                        .forPath(subWorkerPath + i, new String("孩子节点" + i).getBytes(StandardCharsets.UTF_8));
            }
            Thread.sleep(1000);
            for (int i = 0; i < 3; i++) {
                ZookeeperComponent.getInstance().delete().forPath(subWorkerPath + i);
            }
        } catch (Exception e) {
            log.error("PathCache监听失败, path=", nodePath);
        }
    }
```

```java 
private void treeCache() {
        try {
            String nodePath = "/treeCache";
            String subWorkerPath = "/treeCache/childrenNode";
            ZookeeperComponent.checkAndDeletePath(nodePath);
            ZookeeperComponent.createNode(CreateMode.PERSISTENT, nodePath);
            TreeCache treeCache = new TreeCache(ZookeeperComponent.getInstance(), nodePath);
            TreeCacheListener treeCacheListener = new TreeCacheListener() {
                @Override
                public void childEvent(CuratorFramework curatorFramework, TreeCacheEvent event) throws Exception {
                    try {
                        ChildData data = event.getData();
                        if (data == null) {
                            log.info("数据为空");
                            return;
                        }
                        switch (event.getType()) {
                            case NODE_ADDED:
                                log.info("[TreeCache]节点增加, path={}, data={}", data.getPath(), new String(data.getData(), "UTF-8"));
                                break;
                            case NODE_UPDATED:
                                log.info("[TreeCache]节点更新, path={}, data={}", data.getPath(), new String(data.getData(), "UTF-8"));
                                break;
                            case NODE_REMOVED:
                                log.info("[TreeCache]节点删除, path={}, data={}", data.getPath(), new String(data.getData(), "UTF-8"));
                                break;
                            default:
                                break;
                        }
                    } catch (UnsupportedEncodingException e) {
                        log.error("error", e);
                    }
                }
            };
            treeCache.getListenable().addListener(treeCacheListener);
            treeCache.start();
            Thread.sleep(1000);
            for (int i = 0; i < 3; i++) {
                ZookeeperComponent.createNodeAndSetData(CreateMode.PERSISTENT, subWorkerPath + i, subWorkerPath + i);
            }

            Thread.sleep(10000);
            for (int i = 0; i < 3; i++) {
                ZookeeperComponent.deleteNode(subWorkerPath + i);
            }
            Thread.sleep(1000);
            ZookeeperComponent.deleteNode(nodePath);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

```