### rpc 调用的实现

ds rpc 实现主要是基于 netty 的自定义TCP协议实现

#### 0  数据包的协议设计 
下面是数据包类
```java
@Data
public class Transporter implements Serializable {

    private static final long serialVersionUID = -1L;
    //魔术变量 用于确认连接的双方是否使用同一协议
    public static final byte MAGIC = (byte) 0xbabe;
    //协议版本
    public static final byte VERSION = 0;
    // 请求方法的唯一标识 和请求id
    private TransporterHeader header;
    //数据内容 请求的话是 请求方法的参数 ，响应的话是返回的结果
    private byte[] body;

    // 响应数据生成数据包
    public static Transporter of(@NonNull TransporterHeader header, StandardRpcResponse iRpcResponse) {
        return of(header, JsonSerializer.serialize(iRpcResponse));
    }

    //请求数据生成数据包
    public static Transporter of(@NonNull TransporterHeader header, StandardRpcRequest iRpcRequest) {
        return of(header, JsonSerializer.serialize(iRpcRequest));
    }

    public static Transporter of(@NonNull TransporterHeader header, byte[] body) {
        Transporter transporter = new Transporter();
        transporter.setHeader(header);
        transporter.setBody(body);
        return transporter;
    }

}
```
编码器
TransporterEncoder 按照顺序写入数据包 依次为 
- MAGIC   魔术变量
- VERSION 版本
- HEADER_LENGTH 头的长度
- HEADER   头的内容
- BODY_LENGTH 请求体的长度
- BODY 请求体的内容

```java
@Sharable
public class TransporterEncoder extends MessageToByteEncoder<Transporter> {

    @Override
    protected void encode(ChannelHandlerContext ctx, Transporter transporter, ByteBuf out) throws Exception {
        if (transporter == null) {
            throw new RemotingException("encode msg is null");
        }
        out.writeByte(Transporter.MAGIC);
        out.writeByte(Transporter.VERSION);

        // write header
        byte[] header = transporter.getHeader().toBytes();
        out.writeInt(header.length);
        out.writeBytes(header);

        // write body
        byte[] body = transporter.getBody();
        out.writeInt(body.length);
        out.writeBytes(body);
    }

}
```

解码器
TransporterDecoder  按照编码器的数据顺序解析数据

```java
@Slf4j
public class TransporterDecoder extends ReplayingDecoder<TransporterDecoder.State> {

    public TransporterDecoder() {
        super(State.MAGIC);
    }

    private int headerLength;
    private byte[] header;
    private int bodyLength;
    private byte[] body;

    @Override
    protected void decode(ChannelHandlerContext ctx, ByteBuf in, List<Object> out) throws Exception {
        switch (state()) {
            case MAGIC:
                checkMagic(in.readByte());
                checkpoint(State.VERSION);
            case VERSION:
                checkVersion(in.readByte());
                checkpoint(State.HEADER_LENGTH);
            case HEADER_LENGTH:
                headerLength = in.readInt();
                checkpoint(State.HEADER);
            case HEADER:
                header = new byte[headerLength];
                in.readBytes(header);
                checkpoint(State.BODY_LENGTH);
            case BODY_LENGTH:
                bodyLength = in.readInt();
                checkpoint(State.BODY);
            case BODY:
                body = new byte[bodyLength];
                in.readBytes(body);
                Transporter transporter =
                        Transporter.of(JsonSerializer.deserialize(header, TransporterHeader.class), body);
                out.add(transporter);
                checkpoint(State.MAGIC);
                break;
            default:
                log.warn("unknown decoder state {}", state());
        }
    }

    private void checkMagic(byte magic) {
        if (magic != Transporter.MAGIC) {
            throw new IllegalArgumentException("illegal packet [magic]" + magic);
        }
    }

    private void checkVersion(byte version) {
        if (version != Transporter.VERSION) {
            throw new IllegalArgumentException("illegal protocol [version]" + version);
        }
    }

    enum State {
        MAGIC,
        VERSION,
        HEADER_LENGTH,
        HEADER,
        BODY_LENGTH,
        BODY;
    }
}
```


#### 1. server 的实现
初始化 注解对应的bean和方法加载到到 变量为methodInvokerMap的ConcurrentHashMap中
核心类 NettyRemotingServer 

#### 2. client 的实现
使用动态代理和 netty实现


```java
public class JdkDynamicRpcClientProxyFactory implements IRpcClientProxyFactory {

    private final NettyRemotingClient nettyRemotingClient;

    private static final LoadingCache<String, Map<String, Object>> proxyClientCache = CacheBuilder.newBuilder()
            // expire here to remove dead host
            .expireAfterAccess(Duration.ofHours(1))
            .build(new CacheLoader<String, Map<String, Object>>() {

                @Override
                public Map<String, Object> load(String key) {
                    return new ConcurrentHashMap<>();
                }
            });

    public JdkDynamicRpcClientProxyFactory(NettyRemotingClient nettyRemotingClient) {
        this.nettyRemotingClient = nettyRemotingClient;
    }

    @SneakyThrows
    @SuppressWarnings("unchecked")
    @Override
    public <T> T getProxyClient(String serverHost, Class<T> clientInterface) {
        return (T) proxyClientCache.get(serverHost)
                .computeIfAbsent(clientInterface.getName(), key -> newProxyClient(serverHost, clientInterface));
    }

    @SuppressWarnings("unchecked")
    private <T> T newProxyClient(String serverHost, Class<T> clientInterface) {
        return (T) Proxy.newProxyInstance(
                clientInterface.getClassLoader(),
                new Class[]{clientInterface},
                new ClientInvocationHandler(Host.of(serverHost), nettyRemotingClient));
    }
}

```

```java
public class SingletonJdkDynamicRpcClientProxyFactory {

    private static final JdkDynamicRpcClientProxyFactory INSTANCE = new JdkDynamicRpcClientProxyFactory(
            NettyRemotingClientFactory.buildNettyRemotingClient(new NettyClientConfig()));

    public static <T> T getProxyClient(String serverAddress, Class<T> clazz) {
        return INSTANCE.getProxyClient(serverAddress, clazz);
    }

}
```
添加测试调用
```java
@Slf4j
public class RpcTest {
    private NettyRemotingServer nettyRemotingServer;

    private IService iService;
    @BeforeEach
    public void before() {
        iService =  SingletonJdkDynamicRpcClientProxyFactory.getProxyClient("127.0.0.1:5678", IService.class);
    }

    @Test
    public void sendTest() {
        String pong = iService.ping("ping");
        log.info("{}",pong);
    }
}

```