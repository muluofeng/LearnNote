参考：https://qbgbook.gitbooks.io/spring-boot-reference-guide-zh/IX.%20%E2%80%98How-to%E2%80%99%20guides/80.5%20Use%20a%20Spring%20Boot%20application%20as%20a%20dependency.html
springboot多模块依赖
```
多模块项目仅仅需要在启动类所在的模块添加打包插件即可！！不要在父类添加打包插件，
因为那样会导致全部子模块都使用spring-boot-maven-plugin的方式来打包（例如BOOT-INF/com/hehe/xx）


解决办法： 需要打包依赖的子项目时，去掉spring-boot-maven-plugin，这样打包的jar就没有BOOT-INF这一层了，即可正常引用
```

- 将Spring Boot应用作为依赖
```
1.跟war包一样，Spring Boot应用不是用来作为依赖的。如果你的应用包含需要跟其他项目共享的类，
最好的方式是将代码放到单独的模块，然后其他项目及你的应用都可以依赖该模块

2.实在不行的话，你需要配置Spring Boot的Maven和Gradle插件去产生一个单独的artifact，以适合于作为依赖。
可执行存档不能用于依赖，因为可执行jar格式将应用class打包到BOOT-INF/classes，也就意味着可执行jar用于依赖时会找不到。

3.解决办法：
为了产生两个artifacts（一个用于依赖，一个用于可执行jar），你需要指定classifier。classifier用于可执行存档的name，默认存档用于依赖。



##maven
<build>
    <plugins>
        <plugin>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-maven-plugin</artifactId>
            <configuration>
                <classifier>exec</classifier>
            </configuration>
        </plugin>
    </plugins>
</build>

#Gradle
bootRepackage  {
    classifier = 'exec'
}
```


Maven中的version和classifier

classifier 的粒度比 version更细

```
比如一个jar， mrunit-1.1.0-hadoop1.jar,需要这样写才可以
<dependency>
	<groupId>org.apache.mrunit</groupId>
	<artifactId>mrunit</artifactId>
	<version>1.1.0</version>
		<classifier>hadoop1</classifier>
</dependency>
```

