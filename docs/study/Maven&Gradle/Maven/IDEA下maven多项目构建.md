参考：http://www.cnblogs.com/Brake/p/maven_pom_optimization.html
- 创建多个项目
  
  
```
  新建主项目   mutimodules 
        主子项目       web-app 依赖dao和service
        子项目       dao
        子项目       service
```

- 添加2个项目之间的依赖

```xml
Project Structure -->Modules-->web-app(项目模块名称)-->添加模块

pom.xml添加引用
    
     <dependency>
            <groupId>${parent.groupId}</groupId>
            <artifactId>dao</artifactId>
            <version>${parent.version}</version>
    </dependency>
     <dependency>
            <groupId>${parent.groupId}</groupId>
            <artifactId>service</artifactId>
            <version>${parent.version}</version>
    </dependency>
```

- 多项目依赖的一些问题
  
    -   子项目依赖同一个包，版本号保持一致 
    
    ```xml
    //主项目pom.xml定义一个包的版本号，注意这里只是定义而已，maven不会去下载该包
    <dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>org.apache.commons</groupId>
                <artifactId>commons-lang3</artifactId>
                <version>3.2.1</version>
            </dependency>
        </dependencies>
    </dependencyManagement>
    
    //子项目pom.xml添加该包,不需要指定版本
       <dependency>
            <groupId>org.apache.commons</groupId>
            <artifactId>commons-lang3</artifactId>
        </dependency>
    ```

    -   一个项目里面的包版本号保持一致 property
    
```xml
<properties>
    <hibernate.annotations.version>3.3.0.ga</hibernate.annotations.version>
</properties>
<dependencyManagement>
    <dependencies>
        <dependency>
            <groupId>junit</groupId>
            <artifactId>junit</artifactId>
            <version>4.12</version>
        </dependency>
        <dependency>
            <groupId>org.hibernate</groupId>
            <artifactId>hibernate-annotations</artifactId>
            <version>${hibernate.annotations.version}</version>
        </dependency>
        <dependency>
            <groupId>org.hibernate</groupId>
            <artifactId>hibernate-commons-annotations</artifactId>
            <version>${hibernate.annotations.version}</version>
        </dependency>
        <dependency>
            <groupId>org.hibernate</groupId>
            <artifactId>hibernate</artifactId>
            <version>${hibernate.annotations.version}</version>
        </dependency>
    </dependencies>
</dependencyManagement>
```


​    
​    
​    
​    
​    
​        
-   主项目中的兄弟项目版本号和groupId保持一致
    
```xml
//主项目pom.xml
    <parent>
        <artifactId>multi-module</artifactId>
        <groupId>com.xing</groupId>
        <version>1.0-SNAPSHOT</version>
    </parent>
    
    <dependency>
            <groupId>${parent.groupId}</groupId>
            <artifactId>dao</artifactId>
            <version>${parent.version}</version>
    </dependency>
    <dependency>
            <groupId>${parent.groupId}</groupId>
            <artifactId>service</artifactId>
            <version>${parent.version}</version>
    </dependency>
```




## maven 多继承实现

在maven多模块项目中，为了保持模块间依赖的统一，常规做法是在parent model中，使用dependencyManagement预定义所有模块需要用到的dependency(依赖)，然后，子model根据实际需要引入parent中预定义的依赖

- 问题：

单继承：maven的继承跟java一样，单继承，也就是说子model中只能出现一个parent标签；
parent模块中，dependencyManagement中预定义太多的依赖，造成pom文件过长，而且很乱；

- 问题解决：import scope依赖

### 注意：import scope只能用在dependencyManagement里面



```xml
父项目

<project>
	<modelVersion>4.0.0</modelVersion>
	<groupId>com.test.sample</groupId>
	<artifactId>base-parent1</artifactId>
	<packaging>pom</packaging>
	<version>1.0.0-SNAPSHOT</version>
	<dependencyManagement>
		<dependencies>
			<dependency>
				<groupId>junit</groupId>
				<artifactid>junit</artifactId>
				<version>4.8.2</version>
			</dependency>
			<dependency>
				<groupId>log4j</groupId>
				<artifactid>log4j</artifactId>
				<version>1.2.16</version>
			</dependency>
		</dependencies>
	</dependencyManagement>
</project>


子项目
<!--引入父项目的配置，不通过parent，而是通过  import scope -->
<dependencyManagement>
	<dependencies>
		<dependency>
			<groupId>com.test.sample</groupId>
			<artifactid>base-parent1</artifactId>
			<version>1.0.0-SNAPSHOT</version>
			<type>pom</type>
			<scope>import</scope>
		</dependency>
	</dependencies>
</dependencyManagement>
 
<dependency>
	<groupId>junit</groupId>
	<artifactid>junit</artifactId>
</dependency>
<dependency>
	<groupId>log4j</groupId>
	<artifactid>log4j</artifactId>
</dependency>

```

