##  什么是debezium

Debezium 是一个用于变更数据捕获的开源分布式平台。启动它，将其指向您的数据库，您的应用程序就可以开始响应其他应用程序提交给您的数据库的所有插入、更新和删除操作。 Debezium 耐用且快速，因此即使出现问题，您的应用程序也可以快速响应并且不会错过任何事件

支持的数据类型：mysql、pgsql、orecal、sqlserver

官网： https://debezium.io/

当前稳定版本是 2.1下面都是基于2.1 版本作为介绍  https://debezium.io/releases/2.1/

2.1 版本支持的组件

<img src="https://qiniu.muluofeng.com//uPic/202303/image-20230325153610664.png" alt="image-20230325153610664" style="zoom: 50%;" />

 使用方式

- 结合kafka connetor 使用

  Debezium 连接器通常通过将它们部署到 Kafka Connect 服务来运行，并配置一个或多个连接器来监视上游数据库并为它们在上游数据库中看到的所有更改生成数据更改事件。这些数据更改事件被写入 Kafka，在那里它们可以被许多不同的应用程序独立使用。 Kafka Connect 提供出色的容错性和可扩展性，因为它作为分布式服务运行并确保所有已注册和配置的连接器始终运行。例如，即使集群中的一个 Kafka Connect 端点出现故障，其余 Kafka Connect 端点将重新启动之前在现已终止的端点上运行的任何连接器，从而最大限度地减少停机时间并消除管理活动。

- 在应用程序中嵌入 Debezium 连接器

  并非每个应用程序都需要这种级别的容错性和可靠性，它们可能不想依赖外部 Kafka 代理集群和 Kafka Connect 服务。相反，一些应用程序更愿意将 Debezium 连接器直接嵌入到应用程序空间中。他们仍然想要相同的数据更改事件，但更愿意让连接器将它们直接发送到应用程序，而不是将它们持久保存在 Kafka 中。

​		这个 `debezium-embedded` 模块定义了一个小型库，允许应用程序轻松配置和运行 Debezium 连接器。

​      参考github:  https://github.com/debezium/debezium/blob/main/debezium-embedded/README.md



##  基于Embedding Debezium捕获mysql的binlog数据

数据库开启binlog，确认binlog已开启写入功能，并且`binlog_format=ROW` 

my.cnf配置如下：

```cnf
log_bin=binlog # 开启 binlog，在MySQL 8.0中默认开启
binlog-format=ROW # 选择 ROW 模式
server_id=1 #不要和连接器中配置的database.server.id重复
```

mysql binlog 有3种格式 ROW 格式可以获取数据变更前后的变化，产生日志详细，但是日志数据也很多



项目目录结构

<img src="https://qiniu.muluofeng.com//uPic/202304/image-20230402134151387.png" alt="image-20230402134151387" style="zoom:50%;" />

#### 1. pom 依赖

```xml
 
  <properties>
        <java.version>11</java.version>
        <debezium.version>2.1.0.Final</debezium.version>
        <mysql-connector.version>8.0.29</mysql-connector.version>
    </properties>
<dependencies>

				<!--debezium 连接mysql        -->
        <dependency>
            <groupId>io.debezium</groupId>
            <artifactId>debezium-connector-mysql</artifactId>
            <version>${debezium.version}</version>
        </dependency>

        <!--    内嵌式的 debezium 程序    -->
        <dependency>
            <groupId>io.debezium</groupId>
            <artifactId>debezium-embedded</artifactId>
            <version>${debezium.version}</version>
        </dependency>

        <dependency>
            <groupId>io.debezium</groupId>
            <artifactId>debezium-api</artifactId>
            <version>${debezium.version}</version>
        </dependency>


        <dependency>
            <groupId>mysql</groupId>
            <artifactId>mysql-connector-java</artifactId>
            <version>${mysql-connector.version}</version>
        </dependency>

       

        <dependency>
            <groupId>org.apache.commons</groupId>
            <artifactId>commons-lang3</artifactId>
        </dependency>

        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <optional>true</optional>
        </dependency>
             
</dependencies>
```



2. 添加mysql 配置文件 debezium-mysql.properties 

   ```properties
   name=embedded-engine
   connector.class=io.debezium.connector.mysql.MySqlConnector
   ## offset config begin - 使用文件来存储已处理的binlog偏移量
   offset.storage=org.apache.kafka.connect.storage.FileOffsetBackingStore
   offset.storage.file.filename=/Users/muluofeng/workspace/java/MyNote/Debezium/src/main/resources/offsets/mysql_offsets.dat
   offset.flush.interval.ms=0
   ## offset config end
   
   database.hostname=localhost
   database.port=3306
   database.user=root
   database.password=数据库密码
   ## 需要与MySQL的server-id不同
   database.server.id=1
   database.server.name=my-app-connector
   
   ## 数据库历史记录变更存储
   schema.history.internal=io.debezium.storage.file.history.FileSchemaHistory
   schema.history.internal.file.filename=/Users/muluofeng/workspace/java/MyNote/Debezium/src/main/resources/dbhistory/dbhistory.dat
   ## 要捕获的数据库名
   database.include.list=test
   ## 要捕获的数据表
   table.include.list=test.debezium_signal,test.users
   snapshot.new.tables=parallel
   ## 信令数据收集配置表。插入该表中的数据可以 实现数据同步快照
   signal.data.collection=test.debezium_signal
   ## 时区
   database.serverTimezone=Asia/Shanghai
   ## 每次批处理多少条记录
   max.batch.size=2
   
   topic.prefix=muluofeng
   ## 全量+增量
   snapshot.mode=initial
   poll.interval.ms=1000
   ## 是否包含ddl语句
   include.schema.changes=true
   #converters=datetime
   #DateTimeConverter.CONVERTERS_TYPE=com.example.debezium.config.DateTimeConverter
   
   ##  MySQL 连接器将快照事件作为 READ 操作 ("op" : "r 发出 ，如果您希望连接器将快照事件作为 CREATE ( c ) 事件发出 请配置 Debezium ReadToInsertEvent
   transforms=snapshotasinsert
   transforms.snapshotasinsert.type=io.debezium.connector.mysql.transforms.ReadToInsertEvent
   
   

添加 DebeziumConfiguration 配置

```java
import io.debezium.embedded.Connect;
import io.debezium.engine.DebeziumEngine;
import io.debezium.engine.RecordChangeEvent;
import io.debezium.engine.format.ChangeEventFormat;
import lombok.extern.slf4j.Slf4j;
import org.apache.kafka.connect.source.SourceRecord;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.io.IOException;
import java.util.Properties;

@Slf4j
@Configuration
public class DebeziumConfiguration {
    @Bean("debeziumMysqlProperties")
    public Properties configuration() {
        Properties props = new Properties();
        try {
            props.load(DebeziumConfiguration.class.getClassLoader().getResourceAsStream("debezium-mysql.properties"));
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

        return props;
          @Bean
    public DebeziumEngine<RecordChangeEvent<SourceRecord>> debeziumEngine(  ) {
        DebeziumEngine<RecordChangeEvent<SourceRecord>> debeziumEngine = DebeziumEngine.create(ChangeEventFormat.of(Connect.class))
                .using(configuration())
                .notifying(new ChangeEventConsumer())
                .build();
        return debeziumEngine;
    }
}
```

添加监听处理类ChangeEventConsumer

```java
package com.example.debezium.config;

import io.debezium.data.Envelope;
import io.debezium.engine.DebeziumEngine;
import io.debezium.engine.RecordChangeEvent;
import lombok.SneakyThrows;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.tuple.Pair;
import org.apache.kafka.connect.data.Field;
import org.apache.kafka.connect.data.Struct;
import org.apache.kafka.connect.source.SourceRecord;

import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.concurrent.atomic.AtomicInteger;

import static io.debezium.data.Envelope.FieldName.AFTER;
import static io.debezium.data.Envelope.FieldName.BEFORE;
import static io.debezium.data.Envelope.FieldName.OPERATION;
import static io.debezium.data.Envelope.FieldName.SOURCE;
import static java.util.stream.Collectors.toMap;


@Slf4j
public class ChangeEventConsumer implements DebeziumEngine.ChangeConsumer<RecordChangeEvent<SourceRecord>> {

    private  AtomicInteger num  = new AtomicInteger(0);
    @SneakyThrows
    @Override
    public void handleBatch(List<RecordChangeEvent<SourceRecord>> list,
            DebeziumEngine.RecordCommitter<RecordChangeEvent<SourceRecord>> recordCommitter) throws InterruptedException {
        try {
            log.info("handleBatch size:{}",list.size());
            for (int i = 0; i < list.size(); i++) {
                RecordChangeEvent<SourceRecord> r = list.get(i);
                SourceRecord sourceRecord = r.record();
                log.info(sourceRecord.toString());
                Struct sourceRecordChangeValue = (Struct) sourceRecord.value();

                if (sourceRecordChangeValue != null) {
                    // 判断操作的类型 过滤掉读 只处理增删改   这个其实可以在配置中设置
                    Field ddlField = sourceRecordChangeValue.schema().field("ddl");
                    if (Objects.nonNull(ddlField)) {
                        //暂时不处理ddl
                        markProcessed(recordCommitter, r);
                        continue;
                    }
                    Envelope.Operation operation = Envelope.Operation.forCode((String) sourceRecordChangeValue.get(OPERATION));

                    if (operation != Envelope.Operation.READ) {

                        String record = operation == Envelope.Operation.DELETE ? BEFORE : AFTER;
                        // 获取增删改对应的结构体数据
                        Struct struct = (Struct) sourceRecordChangeValue.get(record);

                        Struct source = (Struct) sourceRecordChangeValue.get(SOURCE);
                        Map<String, Object> sources = source.schema().fields().stream().map(Field::name)
                                .filter(fieldName -> source.get(fieldName) != null).map(fieldName -> Pair.of(fieldName, source.get(fieldName)))
                                .collect(toMap(Pair::getKey, Pair::getValue));

                        Map<String, Object> payload = struct.schema().fields().stream().map(Field::name)
                                .filter(fieldName -> struct.get(fieldName) != null).map(fieldName -> Pair.of(fieldName, struct.get(fieldName)))
                                .collect(toMap(Pair::getKey, Pair::getValue));
                        // 这里简单打印一下
                        String name = struct.schema().name();
                        log.info("operation = " + operation.name());
                        log.info("payload = " + payload);
                        log.info("db.table = " + sources.get("db") +"." + sources.get("table"));

                        markProcessed(recordCommitter, r);
                    } else {
                        //读取数据
                    }
                }

            }
        } catch (Exception e) {
            log.error("handleBatch error", e);
        }
        //标记当前批次为提交
        recordCommitter.markBatchFinished();
    }

    private static void markProcessed(DebeziumEngine.RecordCommitter<RecordChangeEvent<SourceRecord>> recordCommitter,
            RecordChangeEvent<SourceRecord> r) {
        try {
            recordCommitter.markProcessed(r);
        } catch (InterruptedException e) {
            throw new RuntimeException(e);
        }
    }
}

```



添加 debezium  管理类 DebeziumServerBootstrap

```java
package com.example.debezium.config;


import io.debezium.embedded.Connect;
import io.debezium.engine.DebeziumEngine;
import io.debezium.engine.format.ChangeEventFormat;
import lombok.Data;
import lombok.SneakyThrows;
import org.glassfish.jersey.internal.guava.Lists;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import javax.annotation.PostConstruct;
import javax.annotation.PreDestroy;
import java.util.Arrays;
import java.util.List;
import java.util.Properties;
import java.util.concurrent.Executor;
import java.util.concurrent.Executors;


@Data
@Component
public class DebeziumServerBootstrap {

    private final Executor executor = Executors.newSingleThreadExecutor();

    @Autowired
    private DebeziumEngine<?> debeziumEngine;


    @Autowired
    private Properties debeziumMysqlProperties;


    @PostConstruct
    public void start() {
        this.executor.execute(debeziumEngine);
    }

    @SneakyThrows
    @PreDestroy
    public void stop() {
        if (debeziumEngine != null) {
            debeziumEngine.close();
        }
    }

    public void restartWithNewTable(String dbName, String tableName) {
        String includeTableStr = "table.include.list";
        String includeTableValueStr = debeziumMysqlProperties.getProperty(includeTableStr);
        List<String> tables = Lists.newArrayList(Arrays.asList(includeTableValueStr.split(",")));
        String newTable =  dbName + "." + tableName;
        if(tables.contains(newTable)){
            return;
        }
        String value = includeTableValueStr + "," +newTable;
        debeziumMysqlProperties.setProperty(includeTableStr,value);
        this.stop();
        this.debeziumEngine = DebeziumEngine.create(ChangeEventFormat.of(Connect.class)).using(debeziumMysqlProperties)
                .notifying(new ChangeEventConsumer()).build();
        this.start();

    }
}
```

## 遇到的一些问题

### 1. 如何初始化一个表的数据

向Debezium连接器发送信号实现临时增量快照

具体做法是添加一个信号表，用于向Debezium发送信号请求来启动临时快照（目前仅支持触发增量快照）。

在本例中创建信号表为debezium_signal，需要包含id, type, data这三个字段，具体的字段含义可以参考

https://debezium.io/documentation/reference/2.1/configuration/signalling.html#debezium-signaling-data-collection-structure

添加配置：

```

table.include.list=test.users,test.debezium_signal
signal.data.collection=test.debezium_signal
```

其中test.users是要进行数据更改捕获的表，test.debezium_signal为创建的信号数据收集表，用于向连接器发送信号。

指定一个信号实例snapshot-001，新增一条信号数据如下：

```sql
TRUNCATE debezium_signal
INSERT INTO `test`.`debezium_signal` ( `id`, `type`, `data` )
VALUES
	( 'snapshot-001', 'execute-snapshot', '{\"data-collections\": [\"test.users\"],\"type\":\"INCREMENTAL\",\"additional-condition\":\"id>10\"}' );
	
```

连接器收到此信号后，会启动一个临时快照。后续就能接收到相关的数据了



### 2. 关闭墓碑消息

当执行删除操作时，debezium会生成两个事件 

- 具有仅包含旧数据的纪录，操作类型为‘d’

- 具有null值和相同键的记录（墓碑消息）

墓碑消息作为Kafka的标记，主要作用是删除源记录后，发出墓碑事件（默认行为）允许Kafka完全删除与已删除行的键相关的所有事件，以防为主题启用日志压缩。

消息过滤器不会处理墓碑消息，如果不需要处理墓碑消息，可以配置连接器属性为

```properties
tombstones.on.delete=false
```



###  3. 数据更改事件对象(ChangeEvent)

下面是各数据变更事件纪录value的内容示例：

- 更新事件

```json
{
  "before": {
      "id": 4,
      "test_text": "254",
      "test_double": "11.09",
      "test_time": "19:01:01",
      "test_datetime": "2022-12-07 19:01:03",
      "test_timestamp": "2022-12-15 15:18:30"
  },
  "after": {
      "id": 4,
      "test_text": "255",
      "test_double": "11.09",
      "test_time": "19:01:01",
      "test_datetime": "2022-12-07 19:01:03",
      "test_timestamp": "2022-12-15 15:20:02"
  },
  "source": {
      "version": "1.9.7.Final",
      "connector": "mysql",
      "name": "app_debezium_connector_v0.2",
      "ts_ms": 1671088802000,
      "snapshot": "false",
      "db": "testdb",
      "sequence": null,
      "table": "test_cdc",
      "server_id": 1,
      "gtid": null,
      "file": "binlog.000005",
      "pos": 27953,
      "row": 0,
      "thread": 3450,
      "query": null
  },
  "op": "u",
  "ts_ms": 1671088802985,
  "transaction": null
}
```

- 新增事件

  ```json
  {
    "before": null,
    "after": {
        "id": 4,
        "test_text": "255",
        "test_double": "11.09",
        "test_time": "19:01:01",
        "test_datetime": "2022-12-07 19:01:03",
        "test_timestamp": "2022-12-15 15:20:02"
    },
    "source": {
        "version": "1.9.7.Final",
        "connector": "mysql",
        "name": "app_debezium_connector_v0.2",
        "ts_ms": 1671088829000,
        "snapshot": "false",
        "db": "testdb",
        "sequence": null,
        "table": "test_cdc",
        "server_id": 1,
        "gtid": null,
        "file": "binlog.000005",
        "pos": 29354,
        "row": 0,
        "thread": 3450,
        "query": null
    },
    "op": "c",
    "ts_ms": 1671088829475,
    "transaction": null
  }
  ```

  

- 删除事件

```json
{
  "before": {
      "id": 4,
      "test_text": "255",
      "test_double": "11.09",
      "test_time": "19:01:01",
      "test_datetime": "2022-12-07 19:01:03",
      "test_timestamp": "2022-12-15 15:20:02"
  },
  "after": null,
  "source": {
      "version": "1.9.7.Final",
      "connector": "mysql",
      "name": "app_debezium_connector_v0.2",
      "ts_ms": 1671088824000,
      "snapshot": "false",
      "db": "testdb",
      "sequence": null,
      "table": "test_cdc",
      "server_id": 1,
      "gtid": null,
      "file": "binlog.000005",
      "pos": 28662,
      "row": 0,
      "thread": 3450,
      "query": null
  },
  "op": "d",
  "ts_ms": 1671088824425,
  "transaction": null
}
```

