## jar打包失败




最近使用springboot项目中打包 可执行jar，使用java -jar 执行失败  xxxx.jar中没有主清单属性

项目原因
项目介绍
  - main project 主项目不继承springboot-parent
 - child project 继承 main project

使用maven打包的时候不是可执行jar



解决办法：在 main  project 添加

```xml
 <build>
        <pluginManagement>
            <plugins>
                <plugin>
                    <groupId>org.springframework.boot</groupId>
                    <artifactId>spring-boot-maven-plugin</artifactId>
                    <version>${spring-boot.version}</version>
                    <executions>
                        <execution>
                            <goals>
<!--                  参考     https://docs.spring.io/spring-boot/docs/2.3.2.RELEASE/maven-plugin/reference/html/-->
                                <goal>repackage</goal>
                            </goals>
                        </execution>
                    </executions>
                </plugin>
                </plugins>
        </pluginManagement>
    </build>
```
 参考  https://docs.spring.io/spring-boot/docs/2.3.2.RELEASE/maven-plugin/reference/html/#repackage







## 资源文件失败



springboot 打包项目 excel 文件从  9 k 变成 15k 
项目原因
项目介绍
  - main project 主项目不继承springboot-parent
 - child project 继承 main project

 在  main project  pom.xml 中

 

 ```xml
  <resources>
    <resource>
      <directory>${basedir}/src/main/resources</directory>
      <filtering>true</filtering>
    </resource>
 </resources>
 ```



解决办法
```xml
<resources>
            <!--   开启资源过滤         -->
            <resource>
             <directory>${basedir}/src/main/resources</directory>
                   <filtering>true</filtering>
                        <includes>
                           <include>**/application*.yml</include>
                          <include>**/application*.yaml</include>
                    <include>**/application*.properties</include>
                   </includes>
             </resource>
            <!--   不开启资源过滤         -->
            <resource>
                <directory>${basedir}/src/main/resources</directory>
                <filtering>false</filtering>
                <excludes>
                    <exclude>**/application*.yml</exclude>
                    <exclude>**/application*.yaml</exclude>
                    <exclude>**/application*.properties</exclude>
                </excludes>
            </resource>
        </resources>
```


如果在 pom 文件中继承了 spring-boot-starter-parent pom文件，那么maven-resources-plugins的 Filtering 默认的过滤符号就从 ${*} 改为 @...@ (i.e. @maven.token@ instead of ${maven.token})来防止与 spring 中的占位符冲突, 所以filter = true 会去解析文件内容，导致二进制文件损坏

参考 [https://juejin.im/post/6844904185557680142](https://juejin.im/post/6844904185557680142)

