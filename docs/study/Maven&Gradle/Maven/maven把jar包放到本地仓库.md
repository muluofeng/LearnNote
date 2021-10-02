maven- pom.xml指定jdk版本
```xml
<properties>
    <java.version>1.8</java.version>
</properties>

<repositories>
    <repository>
        <id>alimaven</id>
        <name>aliyun maven</name>
        <url>http://maven.aliyun.com/nexus/content/groups/public/</url>
    </repository>
</repositories>
 <build>
        <finalName>qms-web</finalName>
        <plugins>
            <!--在添加了该插件之后，当运行“mvn package”进行打包时，会打包成一个可以直接运行的 JAR 文件，使用“Java -jar”命令就可以直接运行。这在很大程度上简化了应用的部署，只需要安装了 JRE 就可以运行 -->
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
            <!-- 使用编译插件，指定jdk版本-->
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <configuration>
                    <source>${java.version}</source>
                    <target>${java.version}</target>
                    <encoding>UTF8</encoding>
                </configuration>
            </plugin>
        </plugins>
</build>

```


## maven打包到本地仓库

```
mvn install:install-file 
-Dfile=hadoop-hdfs-2.2.0-tests.jar 
-DgroupId=org.apache.hadoop 
-DartifactId=hadoop-hdfs 
-Dversion=2.2.0 
-Dpackaging=jar
```


-- DgroupId和DartifactId构成了该jar包在pom.xml的坐标， 对应依赖的DgroupId和DartifactId

-- Dfile表示需要上传的jar包的绝对路径

-- Dpackaging 为安装文件的种类

-- Dversion 版本号