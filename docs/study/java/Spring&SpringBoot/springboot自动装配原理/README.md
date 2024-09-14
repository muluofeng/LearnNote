### 什么是SPI
SPI ，全称为 Service Provider Interface(服务提供者接口)，是一种服务发现机制。它通过在classpath路径下的META-INF/services文件夹查找文件，自动加载文件中所定义的类。

定义接口 和实现类

```java
/**
 * 服务提供者 动物
 */
public interface Animal {

    // 叫
    void call();
}

public class Cat implements Animal {
    @Override
    public void call() {
        System.out.println("喵喵喵～～");
    }
}

public class Dog implements Animal {

    @Override
    public void call() {
        System.out.println("汪汪汪!!!");
    }
}

```



比如 META-INF/services/com.example.Animal 文件添加: 里面的内容就是 ：  接口的全限定类名就是文件名

```java
com.example.zoo.Dog
```

编写测试类

```java
public class SpiTest {

    public static void main(String[] args) {
        // 使用Java的ServiceLoader进行加载
        ServiceLoader<Animal> load = ServiceLoader.load(Animal.class);
        load.forEach(Animal::call);
    }
}
```

我们在resources下创建了一个文件，里面放了些实现类，然后通过`ServiceLoader`这个类加载器就把它们加载出来了



###  什么是自动装配

SpringBoot 定义了一套接口规范，这套规范规定：SpringBoot 在启动时会扫描外部引用 jar 包中的META-INF/spring.factories文件，将文件中配置的类型信息加载到 Spring 容器（此处涉及到 JVM 类加载机制与 Spring 的容器知识），并执行类中定义的各种操作。对于外部 jar 来说，只需要按照 SpringBoot 定义的标准，就能将自己的功能装置进 SpringBoot。通过注解或者一些简单的配置就能在 Spring Boot 的帮助下实现某块功能


### springboot 如何实现自动装配
 SpringBoot 的核心注解 @SpringBootApplication 
@SpringBootApplication看作是 @Configuration、@EnableAutoConfiguration、@ComponentScan 注解的集合。根据 SpringBoot 官网，这三个注解的作用分别是：

- @EnableAutoConfiguration：启用 SpringBoot 的自动配置机制

- @Configuration：允许在上下文中注册额外的 bean 或导入其他配置类

- @ComponentScan： 扫描被@Component (@Service,@Controller)注解的 bean，注解默认会扫描启动类所在的包下所有的类 ，可以自定义不扫描某些 bean。如下图所示，容器中将排除TypeExcludeFilter和AutoConfigurationExcludeFilter。



![image-20210929104441130](http://qiniu.muluofeng.com/uPic/2021/09/image-20210929104441130.png)

@EnableAutoConfiguration:实现自动装配的核心注解


EnableAutoConfiguration 只是一个简单地注解，自动装配核心功能的实现实际是通过 AutoConfigurationImportSelector类。

![image-20210929104640460](http://qiniu.muluofeng.com/uPic/2021/09/image-20210929104640460.png)

`AutoConfigurationImportSelector`类的继承体系如下：

```java
public class AutoConfigurationImportSelector implements DeferredImportSelector, BeanClassLoaderAware, ResourceLoaderAware, BeanFactoryAware, EnvironmentAware, Ordered {

}

public interface DeferredImportSelector extends ImportSelector {

}

public interface ImportSelector {
    String[] selectImports(AnnotationMetadata var1);
}
```

可以看出，`AutoConfigurationImportSelector` 类实现了 `ImportSelector`接口，也就实现了这个接口中的 `selectImports`方法，该方法主要用于**获取所有符合条件的类的全限定类名，这些类需要被加载到 IoC 容器中**

```java
private static final String[] NO_IMPORTS = new String[0];

public String[] selectImports(AnnotationMetadata annotationMetadata) {
        // <1>.判断自动装配开关是否打开
        if (!this.isEnabled(annotationMetadata)) {
            return NO_IMPORTS;
        } else {
          //<2>.获取所有需要装配的bean
            AutoConfigurationMetadata autoConfigurationMetadata = AutoConfigurationMetadataLoader.loadMetadata(this.beanClassLoader);
            AutoConfigurationImportSelector.AutoConfigurationEntry autoConfigurationEntry = this.getAutoConfigurationEntry(autoConfigurationMetadata, annotationMetadata);
            return StringUtils.toStringArray(autoConfigurationEntry.getConfigurations());
        }
    }
```

这里我们需要重点关注一下`getAutoConfigurationEntry()`方法，这个方法主要负责加载自动配置类的。

![image-20210929104640460](http://qiniu.muluofeng.com/uPic/2021/09/3c1200712655443ca4b38500d615bb70~tplv-k3u1fbpfcp-watermark.image)现在我们结合`getAutoConfigurationEntry()`的源码来详细分析一下：

```java
private static final AutoConfigurationEntry EMPTY_ENTRY = new AutoConfigurationEntry();

AutoConfigurationEntry getAutoConfigurationEntry(AutoConfigurationMetadata autoConfigurationMetadata, AnnotationMetadata annotationMetadata) {
        //<1>. 判断自动装配开关是否打开 默认spring.boot.enableautoconfiguration=true，可在 application.properties 或 application.yml 中设置
        if (!this.isEnabled(annotationMetadata)) {
            return EMPTY_ENTRY;
        } else {
            //<2>.  用于获取EnableAutoConfiguration注解中的 exclude 和 excludeName
            AnnotationAttributes attributes = this.getAttributes(annotationMetadata);
            //<3>.  获取需要自动装配的所有配置类，读取META-INF/spring.factories
            List<String> configurations = this.getCandidateConfigurations(annotationMetadata, attributes);
            //<4>. 过滤不需要的配置类
            configurations = this.removeDuplicates(configurations);
            Set<String> exclusions = this.getExclusions(annotationMetadata, attributes);
            this.checkExcludedClasses(configurations, exclusions);
            configurations.removeAll(exclusions);
            configurations = this.filter(configurations, autoConfigurationMetadata);
            this.fireAutoConfigurationImportEvents(configurations, exclusions);
            return new AutoConfigurationImportSelector.AutoConfigurationEntry(configurations, exclusions);
        }
    }
```

- 1. 判断自动装配开关是否打开。默认`spring.boot.enableautoconfiguration=true`，可在 `application.properties` 或 `application.yml` 中设置

  ![image](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/77aa6a3727ea4392870f5cccd09844ab~tplv-k3u1fbpfcp-watermark.image)

- 2. 用于获取`EnableAutoConfiguration`注解中的 `exclude` 和 `excludeName`。

     ![img](http://qiniu.muluofeng.com/uPic/2021/09/3d6ec93bbda1453aa08c52b49516c05a~tplv-k3u1fbpfcp-zoom-1.image)

     

     

- 3.获取需要自动装配的所有配置类，读取`META-INF/spring.factories`

     

![img](http://qiniu.muluofeng.com/uPic/2021/09/58c51920efea4757aa1ec29c6d5f9e36~tplv-k3u1fbpfcp-watermark.image)

不光是这个依赖下的`META-INF/spring.factories`被读取到，所有 Spring Boot Starter 下的`META-INF/spring.factories`都会被读取到

- 4. 过滤不需要的配置类

到这里可能面试官会问你:“`spring.factories`中这么多配置，每次启动都要全部加载么？”。很明显，这是不现实的。我们 debug 到后面你会发现，`configurations` 的值变小了。从100多变成50 多了

![img](http://qiniu.muluofeng.com/uPic/2021/09/267f8231ae2e48d982154140af6437b0~tplv-k3u1fbpfcp-watermark.image)

总结：

- 1. springboot  的@EnableAutoConfiguration注解 会扫描外部引用 jar 包中的`META-INF/spring.factories`文件，将文件中配置的类型信息加载到 Spring 容器

     

