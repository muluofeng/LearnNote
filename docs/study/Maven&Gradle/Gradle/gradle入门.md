gradle 官网： https://docs.gradle.org/current/userguide/userguide.html


 ## 什么gradle？

 Gradle是专注于灵活性和性能的开源构建自动化工具。Gradle构建脚本是使用Groovy或Kotlin DSL 编写的

 1. Groovy是一门jvm语言，最终编译成class文件然后在jvm上执行，Java语言的特性Groovy都支持，我们可以混写Java和Groovy，就是在同一文件中可以混写,==但是groovy相对来说是目前比较流行的gradle配置方式==
 2.  Kotlin 也是一门jvm，目前是android的官方编程语言


Gradle 是一个开源的构建自动化工具，既然是用于项目构建，那它肯定要制定一些规则，在Gradle中每一个待编译的工程都称为Project，每个Project都可以引入自己需要的插件，==引入插件的目的其实就是引入插件中包含的Task，一个Project可以引入多个插件，每个插件同样可以包含一个或多个Task==，


##  下载安装gradle ：https://gradle.org/install/
安装前提：  ==必须安装jdk==

 下载地址：https://gradle.org/releases/

 windos下手动安装

 mac: 使用： 

```
 brew install gradle
```

 验证安装：

```
gradle -v
```



###  Projects 和 tasks 概念理解


 1. 每一个构建都是由一个或多个 projects 构成的. 一个 project 到底代表什么取决于你想用 Gradle 做什么. 举个例子, 一个 project 可以代表一个 JAR 或者一个网页应用. 它也可能代表一个发布的 ZIP 压缩包, 这个 ZIP 可能是由许多其他项目的 JARs 构成的.
 2. 每一个 project 是由一个或多个 tasks 构成的. 一个 task 代表一些更加细化的构建. 可能是编译一些 classes, 创建一个 JAR, 生成 javadoc, 或者生成某个目录的压缩文件


## 编写 hello world
==gradle 命令会在当前目录中查找一个叫 build.gradle 的文件==. 我们称这个 build.gradle 文件为一个构建脚本 (build script), 但是严格来说它是一个构建配置脚本 (build configuration script). 这个脚本定义了一个 project 和它的 tasks.

build.gradle

```
//这个构建脚本定义了一个独立的 task, 叫做 hello
task hello {
    doLast {
        println 'Hello world!'
    }
}
```

在命令行里, 进入脚本所在的文件夹然后输入 gradle -q hello 来执行构建脚本(-q. 代表 quiet 模式. 它不会生成 Gradle 的日志信息):

```
> gradle -q hello
Hello world!
```




## gradle目录结构
## idea 下 创建gradle 项目
![image](https://note.youdao.com/yws/public/resource/1d675de19d80a20f1d5e40438502197a/xmlnote/CC637C65EF5D43EA9ADFA0D4D73F9656/13253)


![image](https://note.youdao.com/yws/public/resource/1d675de19d80a20f1d5e40438502197a/xmlnote/7992078F7328495CA1EADEAE18AE67B3/13255)


![image](https://note.youdao.com/yws/public/resource/1d675de19d80a20f1d5e40438502197a/xmlnote/499696AE0AEC40B5AA594CEE61A086EC/13260)
## gradle 重要的目录结构解析


1. ==build.gradle==:整个项目的构建脚本，它是用Groovy语言编写的脚本
2. ==gradlew==（是在Linux或Mac系统中使用的） 和 gradlew.bat（windows）
这两个是gradle环境的脚本，双击这个脚本可以自动完成构建
3. ==gradle 文件夹==，可以利用它进行安装项目默认的gradle，保证项目中使用的gradle版本统一
4. ==setting.gradle== 该文件名字必须为settings.gradle 用来包含所有的project,实现Multiproject    


相当于我们在Android Studio看到的Project和Module概念一样。根工程相当于Android Studio的Project，一个根工程可以有很多自工程，也就是很多Module，这样就和Android Studio定义的Module概念对应上了
```
rootProject.name = 'testgradle'  //根工程
include 'testGradle3'            //模块

```




```
#|____build.gradle   //整个项目的构建脚本
#|____gradle
#| |____wrapper
#| | |____gradle-wrapper.jar  
#| | |____gradle-wrapper.properties  //配置文件
#|____gradlew       //Linux 下可执行脚本
#|____gradlew.bat  //Windows 下可执行脚本


# Gradle Wrapper有以下好处
#   1.不用安装gradle也能运行gradle
#   2.所有人使用相同的gradle版本

```




### gradle 常用命令

1. 获取依赖列表


```
gradle dependencies
```

2.执行 gradle tasks 命令会列出项目中所有任务.

```
gradle tasks 
```


3. 获取任务具体信息 :gradle -q help --task taskName

```
xing@xxx java/testgradle » gradle -q help --task build
Detailed task information for build

Path
     :build

Type
     Task (org.gradle.api.Task)

Description
     Assembles and tests this project.

Group
     build

```
这些结果包含了任务的路径、类型以及描述信息等.


4.多任务调用

```
gradle task1 [task]
```





gradlew 命令
==注意都是./gradlew, ./代表当前目录，gradlew代表 gradle wrapper，意思是gradle的一层包装，可以理解为在这个项目本地就封装了gradle，即gradle wrapper，只要下载成功即可用grdlew wrapper的命令代替全局的gradle命令==。



5. gradlew 命令
```
./gradlew -v  版本号
./gradlew clean 清除....../app目录下的build文件夹
./gradlew build 检查依赖并编译打包
```


6. gradle 插件的命令
    比如引入java插件，插件提供一些task，我们可以使用gradle 运行对应的task ，下面的是常用插件提供的命令，在做java开发的时候比较经常用到

```
//java 插件
compileJava //使用 javac 编译产品中的 Java 源文件。
build   //构建项目
clean  //删除项目构建目录

//springboot 插件
bootJar  //打包成可执行jar
//war 插件
bootWar  //打包成war包
```

