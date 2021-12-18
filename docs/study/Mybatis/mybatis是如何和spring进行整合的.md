#### mybatis是如何和spring进行整合的 



1. 使用jdk的动态代理对mapper的接口生成实现类
2. 生成的实现类使用 ImportBeanDefinitionRegistrar 注入到spring容器中





#### mybatis-spring-boot-starter可以帮助你快速创建基于Spring Boot的MyBatis应用程序。

引入mybatis-spring-boot-starter模块之后，其可以：


```
● 自动检测DataSource
● 使用SqlSessionFactoryBean注册SqlSessionFactory 实例，并设置DataSource数据源
● 基于SqlSessionFactory自动注册SqlSessionTemplate实例
● 自动扫描@Mapper注解类，并通过SqlSessionTemplate注册到Spring Context中
```

mybatis-spring-boot-starter就是参照Spring Boot的设计思想，化繁为简，以简单注解的方式让用户快速上手

pom 添加

```
<dependency>
    <groupId>org.mybatis.spring.boot</groupId>
    <artifactId>mybatis-spring-boot-starter</artifactId>
    <version>2.1.0</version>
</dependency>
```


###  集成源码分析

![image](https://qiniu.muluofeng.com//uPic/%202021%2012%20/13951.png)

统一的配置文件 spring.factories
必须在classpath下的META-INF文件夹下创建一个spring.factories，本质是一个Properties，所以得按照key-value的形式进行配置，这里使用springboot自动配置的功能（
==spring.factories就像是工厂一样配置了大量的接口对应的实现类，我们通过这些配置 + 反射处理就可以拿到相应的实现类。这种类似于插件式的设计方式，只要引入对应的jar包，那么对应的spring.factories就会被扫描到，对应的实现类也就会被实例化，如果不需要的时候，直接把jar包移除即可==）

```
# Auto Configure
org.springframework.boot.autoconfigure.EnableAutoConfiguration=\
org.mybatis.spring.boot.autoconfigure.MybatisAutoConfiguration
```

下面主要分析 MybatisAutoConfiguration ==MybatisAutoConfiguration 是spring boot 下 mybatis 默认的配置类，只要开启了注释了 @EnableAutoConfiguration 就可以了，spring boot 会默认执行。在SpringBoot启动的过程中 @SpringBootApplication 中组合了 EnableAutoConfiguration ，属于spring boot 自动配置和启动过程，SpringBoot启动时会进入到MybatisAutoConfiguration这个类里，这是一个自动配置类，这里面初始化了SqlSessionFactory、SqlSessionTemplate等一些我们在Spring项目中需要手动配置的==

![image](https://qiniu.muluofeng.com//uPic/%202021%2012%20/13966-20211217171519227.png)


注解分析
```
Configuration注解:说明这是spring的配置项，容器初始化的时候要进行解析处理
ConditionalOnClass注解:有类SqlSessionFactory(Mybatis)，SqlSessionFactoryBean(Mybatis-Spring)的时候才进行解析处理
ConditionalOnBean:容器中有DataSource Bean的时候才进行解析处理
AutoConfigureAfter注解: 在DataSourceAutoConfiguration后解析
EnableConfigurationProperties注解和MybatisProperties类:配置自己的Mybatis 属性，在Application.Properties中

```


其中有一个重要的类  AutoConfiguredMapperScannerRegistrar 
果在启动类上面没有@MapperScan就会执行AutoConfiguredMapperScannerRegistrar查找扫描出标注有 @Mapper 注解类的接口，并注册到Spring容器中

在项目中大多数用的都是@MapperScan注解，指定basePackages，扫描mybatis Mapper接口类，所以在下一篇重点分析这个





## 通过@MapperScan 注解来实现mapper注入到spring容器

![image](https://qiniu.muluofeng.com//uPic/%202021%2012%20/13980.png)

@Import(MapperScannerRegistrar.class) 会调用MapperScannerRegistrar 这个类

MapperScannerRegistrar 实现了  ==ImportBeanDefinitionRegistrar==

### 什么是 ImportBeanDefinitionRegistrar？

spring官方就是用这种方式，实现了@Component、@Service等注解的动态注入机制。定义一个ImportBeanDefinitionRegistrar的实现类，然后在有@Configuration注解的配置类上使用@Import导入,mybatis就是利用springboot的扩展方式，巧妙的把mapper 注入到spring容器中，下面分析注入过程

核心代码分析 ==ClassPathMapperScanner.doScan==

![image](https://qiniu.muluofeng.com//uPic/%202021%2012%20/14018.png)


```
    Set<BeanDefinitionHolder> beanDefinitions = super.doScan(basePackages);
```
获取配置路径下面所有的mapper的全限定类名，这样就拿到了所有mapper的 BeanDefinition


```
      definition.setBeanClass(this.mapperFactoryBeanClass);

```
个就是spring boot注册mapper的核心方法了，在上面的方法中可以发现通过definition.setBeanClass(this.mapperFactoryBeanClass)为我们定义的mapper添加了一个代理对象MapperFactoryBean，前往==MapperFactoryBean==可以发现这个类实现了Spring提供的FactoryBean接口，里面有个核心方法


```
  @Override
  public T getObject() throws Exception {
    return getSqlSession().getMapper(this.mapperInterface);
  }
```
继续深入
```
  @Override
  public <T> T getMapper(Class<T> type) {
    return getConfiguration().getMapper(type, this);
  }
```

```
  public <T> T getMapper(Class<T> type, SqlSession sqlSession) {
    return mapperRegistry.getMapper(type, sqlSession);
  }
```
核心方法 MapperRegistry getMapper
![image](https://qiniu.muluofeng.com//uPic/%202021%2012%20/14038.png)

这个方法通过调用MapperProxyFactory类，生成一个代理实例MapperProxy并返回


到这里，SpringBoot初始化Mapper完毕，接下来在我们调用自己定义的Mapper的时候，==实际上调用的便是MapperProxy这个代理对象了，MapperProxy类实现了InvocationHandler接口，这个类中最核心的方法便是Invoke方法==

什么是  FactoryBean？
http://note.youdao.com/noteshare?id=8a773e15be66379458d844e93bf711d1
