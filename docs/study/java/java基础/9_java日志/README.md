## 日志框架

市面上的日志框架
JUL  JCL  JBoss-logging、logback、log4j、log4j2、slf4j

| 日志门面                                                     | 日志实现                                         |
| ------------------------------------------------------------ | ------------------------------------------------ |
| JCL(Jakarta Commons Logging)、SLF4j(simple Logging Facade for java )、Jboss-logging | Log4J、JUL（java.util.logging）、Log4j2、Logback |



SLF4j 和 Log4J、Logback 是同一个作者

springboot使用 SLF4j 和 Logback 作为日志框架

代码使用,导入slfj的jar和logback的jar

```java
Logger  logger = LoggerFactory.getLogger(xxx.class);
```



每一个日志的实现框架都有自己的配置文件，使用slf4j以后，**配置文件还是做成日志实现框架的配置文件**





如何把日志框架统一使用slf4j 

1. 
2. 

