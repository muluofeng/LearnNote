参考：https://www.jianshu.com/p/4735fe7ae921


- 创建自己的starter项目需要maven依赖是如下所示:

```xml
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-autoconfigure</artifactId>
        <version>1.4.4.RELEASE</version>
    </dependency>
    
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-configuration-processor</artifactId>
        <version>1.4.4.RELEASE</version>
    </dependency>
```

- 编写核心装配类- 这个类可以提供该starter核心bean

```
@Configuration
@ConditionalOnClass(StorageService.class)
@EnableConfigurationProperties(StorageServiceProperties.class)
public class StorageAutoConfigure {
    @Autowired
    private StorageServiceProperties properties;

    @Bean
    @ConditionalOnMissingBean(StorageService.class)
    @ConditionalOnProperty(prefix = "storage.service", value = "enabled", havingValue = "true")
    StorageService exampleService() {
        return new StorageService(properties);
    }
}


说明：

 *   @Configuration  被该注解注释的类会提供一个或则多个@bean修饰的方法并且会被spring容器处理来生成bean definitions
 *   @ConditionalOnClass 注解是条件判断的注解，表示对应的类在classpath目录下存在时，才会去解析对应的配置文件
 *   @EnableConfigurationProperties 注解给出了该配置类所需要的配置信息类，也就是StorageServiceProperties类，
 *                                  这样spring容器才会去读取配置信息到StorageServiceProperties对象中
 *
 *   @ConditionalOnMissingBean 注解也是条件判断的注解，表示如果不存在对应的bean条件才成立，这里就表示如果已经有StorageService的bean了，
 *                              那么就不再进行该bean的生成。这个注解十分重要，涉及到默认配置和用户自定义配置的原理。
 *                              也就是说用户可以自定义一个StorageService的bean,这样的话，spring容器就不需要再初始化这个默认的bean了
 *   @ConditionalOnProperty 注解是条件判断的注解，表示如果配置文件中的响应配置项数值为true,才会对该bean进行初始化
```
- 配置信息类

```
@ConfigurationProperties("storage.service")
public class StorageServiceProperties {
    private String username;
    private String password;
    private String url;

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getUrl() {
        return url;
    }

    public void setUrl(String url) {
        this.url = url;
    }
}

说明
@ConfigurationProperties注解就是让spring容器知道该配置类的配置项前缀是什么，上述的源码给出的配置信息项有storage.service.username,storage.service.password和storage.service.url
```

- 核心bean-类是提供整个starter的核心功能的类

```
public class StorageService {
    private String url;
    private String username;
    private String password;
    private HashMap<String, Object> storage = new HashMap<String, Object>();

    public StorageService(StorageServiceProperties properties) {
        super();
        this.url = properties.getUrl();
        this.username = properties.getUsername();
        this.password = properties.getPassword();
    }
    //getter  setter
    
    
}
```
- 如何通知springboot 容器导入自己的auto-configuration类

```
1.一般都是在starter项目的resources/META-INF文件夹下的spring.factories文件中加入需要自动化配置类的全限定名称。
org.springframework.boot.autoconfigure.EnableAutoConfiguration=starter.StorageAutoConfigure

这种方法只要是引入该starter，那么spring.factories中的auto-configuration类就会被装载

2.但是如果你希望有更加灵活的方式，那么就使用自定义注解来引入装配类
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
@Import(StorageAutoConfigure.class)
@Documented
public @interface EnableStorage {
}

有了这个注解，你可以在你引入该starter的项目中使用该注解，通过@import注解，spring容器会自动加载StorageAutoConfigure并自动化进行配置
```


