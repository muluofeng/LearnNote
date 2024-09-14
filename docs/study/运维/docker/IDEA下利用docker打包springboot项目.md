- 编写dockerfile文件
  在项目的根目录下新建Dockerfile

    ```
    FROM openjdk:8u111-jdk-alpine
    MAINTAINER   906877230@qq.com
    COPY  target/xing-web-1.0-SNAPSHOT.jar   app.jar
    ENTRYPOINT ["java","-jar","/app.jar"]
    EXPOSE 8081
    ```
- 使用IDEA下载docker插件  : Docker integration
    配置docker:preferences->Clounds->新建docker
    ![image](http://qiniu.muluofeng.com/uPic/2021/09/3646.png)

```

```

- 使用IDEA打包镜像】
    Run/Debug Configurations->新建Docker Deployment
    点击run打包镜像
    ![image](http://qiniu.muluofeng.com/uPic/2021/09/3655.png)
- 运行springboot镜像连接本地数据库
  
```
docker run --name xingweb -d -e spring.datasource.url=jdbc:mysql://10.0.2.3:3306/xingweb?useUnicode=true -p 8081:8081 xingweb
```

- 运行springboot镜像连接mysql镜像

```
docker run --name mysql -d -e MYSQL_ROOT_PASSWORD=root -p 3307:3306  mysql

docker run --name xingweb -d  --link mysql  -e spring.datasource.url=jdbc:mysql://172.17.0.3:3306/xingweb?useUnicode=true -p 8081:8081 xingweb

```
