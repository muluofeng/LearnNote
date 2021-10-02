### 什么是maven
是 Apache 下的一个纯 Java 开发的开源项目,Maven是Java项目构建工具，可以用于管理Java依赖，还可以用于编译、打包以及发布Java项目，类似于JavaScript生态系统中的NPM。php中的composer

### 为什么要用maven
对于小型的项目而言，比如大学开始的Java课可能要求我们写一个简单的计算器等。该项目依赖的外部的代码很少，几乎使用Java自带的SDK就可以了,但是，对于大中型的项目，都会依赖很多外部开发资源。网络上开源了大量的代码，在我们编写程序的时候可以==帮助我们减少重复性的工作==，大大提升复用情况，==降低编程难度==。对于这种项目的代码维护，以及依赖维护是很复杂的。什么程序依赖什么版本的什么外部包，如果不使用构建工具帮助我们管理这些依赖，那将增加开发人员大量的负担。因此，包括上述编译、打包和发布等功能，构建工具在帮助我们管理这些东西，大大提升编程效率


###  安装maven

Maven 是一个基于 Java 的工具，所以要做的第一件事情就是安装 JDK，在MacBook上使用brew安装很方便

```
//安装
brew install maven
//查看
mvn -version
```
官网下载maven地址： http://maven.apache.org/download.cgi

Maven的命令行工具为mvn，其常用命令如下表所示：

```
mvn compile	编译Java源代码
mvn package	打包Java项目
mvn deploy	将Java项目发布到Maven仓库
mvn clean	删除构建目录
```

Maven的配置文件为pom.xml，maven的中央仓库为 https://mvnrepository.com/ ，这里可以找到各种Java依赖


## 约定优于配置

Maven会假设用户的项目是这样的：

```
源码目录为src/main/java
编译输出目录为target/classes/
打包方式为jar
包输出目录为target/
```
遵循约定虽然损失了一定的灵活性，用户不能随意安排目录结构，但是却能减少配置。更重要的是，遵循约定能够帮助用户遵守构建标准。有了Maven的约定，大家都知道什么目录放什么内容，像mvn clean install 这样的命令可以用来构建几乎任何的Maven项目



## POM 

POM( Project Object Model，项目对象模型 ) 是 Maven 工程的基本工作单元，是一个XML文件，包含了项目的基本信息，用于描述项目如何构建，声明项目依赖，等等

执行任务或目标时，Maven 会在当前目录中查找 POM。它读取 POM，获取所需的配置信息，然后执行目标。




所有 POM 文件都需要 project 元素和三个必需字段：groupId，artifactId，version

```
1. project  工程的根标签。
2. groupId   这是工程组的标识。它在一个组织或者项目中通常是唯一的。例如 org.springframework.boot 
3. artifactId  这是工程的标识。它通常是工程的名称。例如 spring-boot-starter-web
4. version  这是工程的版本号。在 artifact 的仓库中，它用来区分不同的版本。
```

### maven常用内置变量,在pom中我们可以使用，当然我们也可以通过 properties 来自定义变量

```
${basedir} 项目根目录
${project.build.directory} 构建目录，缺省为target
${project.build.outputDirectory} 构建过程输出目录，缺省为target/classes
${project.build.finalName} 产出物名称，缺省为${project.artifactId}-${project.version}
${project.packaging} 打包类型，缺省为jar
${project.xxx} 当前pom文件的任意节点的内容
```



### pom.xml详解，下面以一个pom为例，对常见的标签做解释

```xml
<!--定义maven的GAV坐标-->
<modelVersion>4.0.0</modelVersion>
<groupId>com.luqi.technology</groupId>
<artifactId>sport</artifactId>
<version>1.0-SNAPSHOT</version>

<!--通过properties统一定义版本号-->
<properties>
  <java.version>1.8</java.version>
  <mysql.version>5.1.47</mysql.version>
</properties>

<dependencies>
    <!--多个依赖-->
       <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
         <dependency>
            <groupId>mysql</groupId>
            <artifactId>mysql-connector-java</artifactId>
            <version>${mysql.version}</version>
        </dependency>
</dependencies>


    <build>
        <!--打包后的文件名称-->
        <finalName>${project.artifactId}</finalName>
        <plugins>
            <!--使用springboot打包插件-->
            <plugin>
               <groupId>org.springframework.boot</groupId>
               <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
         </plugins>
    </build>

<!-- 阿里云maven仓库 -->
    <repositories>
        <repository>
            <id>public</id>
            <name>aliyun nexus</name>
            <url>http://maven.aliyun.com/nexus/content/groups/public/</url>
            <releases>
                <enabled>true</enabled>
            </releases>
        </repository>
    </repositories>
```

### maven中的scope
-  compile

默认就是compile，什么都不配置也就是意味着compile。compile表示被依赖项目需要参与当前项目的编译，当然后续的测试，运行周期也参与其中，是一个比较强的依赖。打包的时候通常需要包含进去

- provided

provided意味着打包的时候可以不用包进去，别的设施(Web Container)会提供。事实上该依赖理论上可以参与编译，测试，运行等周期。相当于compile，但是在打包阶段做了exclude的动作

3. runtime
4. test
5. system
6. import

```

### maven中的profiles

profile的作用

我们的软件会面对不同的运行环境，比如开发环境、测试环境、生产环境，而我们的软件在不同的环境中，有的配置可能会不一样
maven提供了一种方便的解决这种问题的方案，就是profile功能

- profile定义在setting.xml

当profile定义在settings.xml中时意味着该profile是==全局==的，它会对所有项目或者某一用户的所有项目都产生作用。因为它是全局的==所以在settings.xml中只能定义一些相对而言范围宽泛一点的配置信息，比如远程仓库等。而一些比较细致一点的需要根据项目的不同来定义的就需要定义在项目的pom.xml中==
- profile定义在pom.xml中

pom.xml中
```xml
<profiles> 
    <profile> 
        <id>profileTest1</id> 
        <properties> 
            <hello>world</hello> 
        </properties> 
        <activation> 
            <activeByDefault>true</activeByDefault> 
        </activation> 
    </profile> 
    <profile> 
        <id>profileTest2</id> 
        <properties> 
            <hello>andy</hello> 
        </properties> 
    </profile> 
</profiles>
```


可以在profile中的activation元素中指定激活条件，当没有指定条件，然后指定==activeByDefault为true的时候就表示当没有指定其他profile为激活状态时==，该profile就默认会被激活。所以当我们调用mvn package的时候上面的profileTest1将会被激活，但是当我们使用==mvn package –P profileTest2==的时候将激活profileTest2，而这个时候profileTest1将不会被激活


### profile 实际开发中的运用
在微服务开发中，项目微服务数量很多，而且很多微服务之间有相互依赖关系，指定顺序打包
比如，下面的工程里面包含了很多的模块，通过modules 定义顺序，那么打包的时候不需要手动一个个打包，通过下面的命令打包指定id的 profile 


```shell
##-p 表示激活指定的profile,多个用逗号分隔，-Dmaven.test.skip=true 表示跳过单元测试
 mvn clean install  -P 1.basic,2.basic-management,3.self-management   -Dmaven.test.skip=true
```


```
    <profiles>
        <profile>
            <id>1.basic</id>
            <activation>
                <activeByDefault>true</activeByDefault>
            </activation>
            <modules>
                <module>framework/com.quarkioe.ncore.base</module>
                <module>framework/com.quarkioe.ncore.mapper</module>
                <module>platform/application-management/application.model</module>
                <module>platform/user-management/user.model</module>
                <module>platform/identity-management/identity.model</module>
                <module>platform/alarm-management/alarm.model</module>
                <module>platform/audit-management/audit.model</module>
                <module>platform/cep-management/cep-model</module>
                <module>platform/mongo-dao</module>
                <module>platform/conversion</module>
            </modules>
        </profile>
        <profile>
            <id>2.basic-management</id>
            <modules>
                <module>platform/rest-dao</module>
                <module>platform/rest-dto</module>
                <module>platform/rest-mapper</module>
                <module>platform/systemSetting</module>
                <module>framework/com.quarkioe.ncore.security</module>
                <module>platform/notification</module>
                <module>platform/broadcast-service</module>
                <module>platform/user-management/user.inner</module>
                <module>platform/tenant-management/tenant.inner</module>
                <module>platform/application-management/application.inner</module>
                <module>platform/user-management/user</module>
            </modules>
        </profile>
```



## 仓库

Maven 仓库是项目中依赖的第三方库，这个库所在的位置叫做仓库 

在 Maven 中，任何一个依赖、插件或者项目构建的输出，都可以称之为构件。

Maven 仓库能帮助我们管理构件（主要是JAR），它就是放置所有JAR文件（WAR，ZIP，POM等等）的地方。

Maven 仓库有三种类型：

```
本地（local）
中央（central）
远程（remote）
```

###  本地仓库
默认情况下，不管Linux还是 Windows，每个用户在自己的用户目录下都有一个路径名为 .m2/respository/ 的仓库目录。


### 中央仓库
Maven 中央仓库是由 Maven 社区提供的仓库，其中包含了大量常用的库。
中央仓库包含了绝大多数流行的开源Java构件，以及源码、作者信息、SCM、信息、许可证信息等。一般来说，简单的Java项目依赖的构件都可以在这里下载到。

### 远程仓库
如果 Maven 在中央仓库中也找不到依赖的文件，它会停止构建过程并输出错误信息到控制台。为避免这种情况，Maven 提供了远程仓库的概念，它是开发人员自己定制仓库，包含了所需要的代码库或者其他工程中用到的 jar 文件。比如我们自己搭建的nexus私服


###  Maven 依赖搜索顺序
- 步骤 1，在本地仓库中搜索，如果找不到，执行步骤 2，如果找到了则执行其他操作。
- 步骤 2 － 在中央仓库中搜索，如果找不到，并且有一个或多个远程仓库已经设置，则执行步骤 4，如果找到了则下载到本地仓库中以备将来引用。
- 步骤 3 － 如果远程仓库没有被设置，Maven 将简单的停滞处理并抛出错误（无法找到依赖的文件）。
- 步骤 4 － 在一个或多个远程仓库中搜索依赖的文件，如果找到则下载到本地仓库以备将来引用，否则 Maven 将停止处理并抛出错误（无法找到依赖的文件）。


###  使用阿里云的仓库

-  修改 maven 根目录下的 conf 文件夹中的 setting.xml 文件

```
<mirrors>
    <mirror>
      <id>alimaven</id>
      <name>aliyun maven</name>
      <url>http://maven.aliyun.com/nexus/content/groups/public/</url>
      <mirrorOf>central</mirrorOf>        
    </mirror>
</mirrors>
```

-  第二步: pom.xml文件里添加：

```
<repositories>  
        <repository>  
            <id>alimaven</id>  
            <name>aliyun maven</name>  
            <url>http://maven.aliyun.com/nexus/content/groups/public/</url>  
            <releases>  
                <enabled>true</enabled>  
            </releases>  
            <snapshots>  
                <enabled>false</enabled>  
            </snapshots>  
        </repository>  
</repositories>
```



Maven本质上是一个插件框架，它的核心并不执行任何具体的构建任务，所有这些任务都交给插件来完成。。Maven 插件通常用于：

```
创建 jar 文件
创建 war 文件
编译代码文件
进行代码单元测试
```

## maven默认插件

```
maven-clean-plugin 清理上一次执行创建的目标文件 clean
maven-resources-plugin 处理源资源文件和测试资源文件 resources,testResources
maven-compiler-plugin 编译源文件和测试源文件 compile,testCompile
maven-surefire-plugin 执行测试文件 test
maven-jar-plugin 创建 jar jar
maven-install-plugin 安装 jar，将创建生成的 jar 拷贝到 .m2/repository 下面 install
maven-deploy-plugin 发布 jar deploy
```


## maven 常用其他插件

插件网址： http://maven.apache.org/components/plugins/

1.  maven-compiler-plugin  编译java的源码 ,可以指定项目源码的 jdk 版本，编译后的 jdk 版本，以及编码。

```
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-compiler-plugin</artifactId>
    <version>3.8.0</version>
    <configuration>
        <source>1.8</source>
        <target>1.8</target>
        <encoding>UTF-8</encoding>
    </configuration>
</plugin>
```

2.  springboot打包插件
``` 
<plugin>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-maven-plugin</artifactId>
</plugin>
```
3. mybatis生成代码插件 ：mybatis-generator-maven-plugin
4. docker插件

```
<plugin>
    <groupId>com.spotify</groupId>
    <artifactId>docker-maven-plugin</artifactId>
    <version>0.4.14</version>
</plugin>
```

