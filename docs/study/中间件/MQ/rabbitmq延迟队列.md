### 使用 rabbitmq 延迟队列

延迟队列存储的对象肯定是对应的延时消息，所谓”延时消息”是指当消息被发送以后，并不想让消费者立即拿到消息，而是等待指定时间后，消费者才拿到这个消息进行消费。

比如以下场景：在订单系统中，一个用户下单之后通常有30分钟的时间进行支付，如果30分钟之内没有支付成功，那么这个订单将进行一场处理。这是就可以使用延时队列将订单信息发送到延时队列。

### 实现原理

1. **Time To Live(TTL)**

  RabbitMQ可以针对Queue设置x-expires 或者 针对Message设置 x-message-ttl，来控制消息的生存时间，如果超时(两者同时设置以最先到期的时间为准)，则消息变为dead letter(死信)
    
  RabbitMQ针对队列中的消息过期时间有两种方法可以设置。  

```md
A:  通过队列属性设置，队列中所有消息都有相同的过期时间。

B:  对消息进行单独设置，每条消息TTL可以不同。

如果同时使用，则消息的过期时间以两者之间TTL较小的那个数值为准。消息在队列的生存时间一旦超过设置的TTL值，就成为dead letter
```

1. **Dead Letter Exchanges（DLX）**

RabbitMQ的Queue可以配置x-dead-letter-exchange和x-dead-letter-routing-key（可选）两个参数，如果队列内出现了dead letter，则按照这两个参数重新路由转发到指定的队列。

x-dead-letter-exchange：出现dead letter之后将dead letter重新发送到指定exchange
x-dead-letter-routing-key：出现dead letter之后将dead letter重新按照指定的routing-key发送

队列出现dead letter的情况有：  
  消息或者队列的TTL过期
  队列达到最大长度
  消息被消费端拒绝（basic.reject or basic.nack）并且requeue=false



### rabbitmq延迟队列安装

1. 下载 rabbitmq-delayed-message-exchange 插件 ，下载对应的版本

   下载地址：  https://github.com/rabbitmq/rabbitmq-delayed-message-exchange/tags

2. 插件安装，RabbitMQ 的插件目录在 docker 容器中的目录为： `/plugins` ，所以我们要将解压好的插件导入到 docker 容器中

   ```shell
   docker cp 本地文件路径 CONTAINER_ID:/plugins
   ```

3. 进入到容器内启动插件

   ```shell
   docker exec -it CONTAINER_ID /bin/bash
   cd /plugins
   ## 使用插件
   rabbitmq-plugins enable rabbitmq_delayed_message_exchange
   ## 查看插件启动列表： 
   rabbitmq-plugins list
   ## 重启mq
    docker restart  CONTAINER_ID
   ```

   重启后，前往 RabbitMQ web 控制台中，在创建交换机的选项中我们能发现多了一项类型：x-delayed-message

   ![image-20220825113706270](https://qiniu.muluofeng.com//uPic/202208/image-20220825113706270.png)

### springboot 实现延迟队列

1. Maven引入

   ```xml
   <!--消息队列模块-->
   <dependency>
       <groupId>org.springframework.boot</groupId>
       <artifactId>spring-boot-starter-amqp</artifactId>
       <version>${spring-boot.version}</version>
   </dependency>
   ```

2. 配置文件 yml

   ```yml
   spring:
     rabbitmq:
       host: 127.0.0.1
       port: 5672
       username: admin
       password: rabbitmq的密码
   ```



3. Java代码

   ```java
   //定义产量
   public class Constant {
       public static final String DELAYED_EXCHANGE_NAME = "delay_exchange";
       public static final String DELAYED_QUEUE_NAME = "delayed.queue";
       public static final String DELAYED_TPOCI_NAME = "delayed.topic";
   }
   ```

   ```java
   // 交换机枚举
   public enum RabbitMQExchangeEnum {
       /**
        * 延迟交换机
        */
       DelayedExchange(Constant.DELAYED_EXCHANGE_NAME);
       private String exchange;
       private RabbitMQExchangeEnum(String exchange) {
           this.exchange = exchange;
       }
       public String getExchange() {
           return this.exchange;
       }
   }
   ```

   ```java
   // 交换机、队列、topic 绑定
   @Component
   public class RabbitMQInitialize {
       @Autowired
       private CachingConnectionFactory rabbitConnectionFactory;
       public void rabbitmqInitialize() {
           // 新建交换机
           RabbitAdmin admin = new RabbitAdmin(rabbitConnectionFactory);
           Map<String, TopicExchange> map = new HashMap<String, TopicExchange>();
           for (RabbitMQExchangeEnum exchanges : RabbitMQExchangeEnum.values()) {
               String name = exchanges.getExchange();
               TopicExchange exchange = new TopicExchange(name);
               if (name.equals(Constant.DELAYED_EXCHANGE_NAME)) {
                   //交换机为延迟交换机
                   exchange.setDelayed(true);
               }
               admin.declareExchange(exchange);
               map.put(name, exchange);
           }
   
           //交换机和 队列和 topic绑定
           for (RabbitMQQueueEnum _queue : RabbitMQQueueEnum.values()) {
               Queue queue = new Queue(_queue.getQueueName());
               admin.declareQueue(queue);
               TopicExchange exchange = map.get(_queue.getExchange());
               String topic = _queue.getTopicName();
               admin.declareBinding(BindingBuilder.bind(queue).to(exchange).with(topic));
           }
       }
   }
   ```

   

```java
//订阅队列的消费者
@Slf4j
@Service
@RequiredArgsConstructor
public class FzjcDelayedMessageConsumerListener extends BaseMessageConsumerListener implements ChannelAwareMessageListener {
    @Override
    public void onMessage(Message message, Channel channel) throws Exception {
        try {
            byte[] body = message.getBody();
            log.info(new String(body));
        } catch (Exception e) {
            log.error(e.getMessage(), e);
        }
        channel.basicAck(message.getMessageProperties().getDeliveryTag(), false);
    }
}
```

```java

// 延迟队列指定  绑定对应的 消费者
@Component
public class FzjcDelayMessageSubscribe {
	@Autowired
	private CachingConnectionFactory rabbitConnectionFactory;
	@Autowired
	private FzjcDelayedMessageConsumerListener delayedMessageConsumerListener;
	public void receiveMessage() {
		SimpleMessageListenerContainer container =new SimpleMessageListenerContainer(rabbitConnectionFactory);
	    MessageListenerAdapter adapter = new MessageListenerAdapter(delayedMessageConsumerListener);
	    container.setMessageListener(adapter);
	    container.setPrefetchCount(Constant.DEFAULT_PREFETCH_COUNT);
	    container.setQueueNames(Constant.DELAYED_QUEUE_NAME);
	    container.setAcknowledgeMode(AcknowledgeMode.MANUAL);
	    container.setDefaultRequeueRejected(false);
	    container.start();
	}
}
```

```java

//初始化绑定
@Component
public class RabbitMQSubscribe {
    @Autowired
    private FzjcDelayMessageSubscribe delayMessageSubscribe;

    /**
     * 订阅所有RabbitMQ
     */
    public void subscribeAllRabbitMQ() {
        delayMessageSubscribe.receiveMessage();
    }
}
```

```java


//发送延迟消息 调用示例
  	@SneakyThrows
    @Override
    public <T extends BaseMessageDTO> void sendMessage(T message, String topic, Integer delay) {
        String serialized = new ObjectMapper().writeValueAsString(message);
        Message messageBuilder = MessageBuilder
                .withBody(serialized.getBytes(CHARSET_UTF8))
                .setType(RabbitMQExchangeEnum.IntegralExchange.getExchange())
                .setCorrelationId(UUID.randomUUID().toString())
                .setDeliveryMode(MessageDeliveryMode.PERSISTENT)
                .build();
        this.rabbitTemplate.convertAndSend(Constant.DELAYED_EXCHANGE_NAME, topic, messageBuilder,a->{
            a.getMessageProperties().setDelay(delay);
        });
    }
```




