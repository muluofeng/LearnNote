### 1. 前端

```java
cd /data/source_repo/fms_platform/

git pull

cd /data/source_repo/fms_platform/gcwe/web/


npm run build

rm -rf /data/soft/tomcat8/webapps/gcwe/dist/
rm -rf /data/soft/tomcat8/webapps/gcwe/index.html

cp -R /data/source_repo/fms_platform/gcwe/web/dist/*  /data/soft/tomcat8/webapps/gcwe/
```



###  2.后端发布到tomcat

```java

cd /data/source_repo/fms_platform/

git pull
echo "更新项目代码"

cd /data/source_repo/fms_platform/gcwe/java/


echo "关闭服务器"
sh /data/soft/tomcat8/bin/shutdown.sh


echo "执行清理、编译"
mvn clean package

if [ ! -f "/data/source_repo/fms_platform/gcwe/java/target/gcwe.war" ];then
echo "war文件不存在"
else

rm -rf /data/soft/tomcat8/gcwe.war
rm -rf /data/soft/tomcat8/webapps/gcwe

cp /data/source_repo/fms_platform/gcwe/java/target/gcwe.war /data/soft/tomcat8/


unzip /data/soft/tomcat8/gcwe.war -d /data/soft/tomcat8/webapps/ROOT


echo "检查服务器有没有关闭"

ID=`ps -ef| grep 'tomcat'|grep -v 'grep'|awk '{print $2}'`
for pid in $ID
do
    kill -9 $pid
    echo "kill tomcat pid:$pid"
done



echo "复制完成,重新启动服务器"


sh /data/soft/tomcat8/bin/startup.sh

fi
```

### 3.发布jar包
```shell
cd /data/code/town-web

git checkout .

git pull



mvn clean package

cd ./town-api/target


ID=`ps -ef| grep 'town-api.jar'|grep -v 'grep'|awk '{print $2}'`
for pid in $ID
do
    kill -9 $pid
    echo "kill town-api.jar pid:$pid"
done


cp town-api.jar /data/webserver

cd /data/webserver

nohup java -jar -Djava.security.egd=file:/dev/./urandom  -Dspring.profiles.active=prod town-api.jar >> town-api.log &
```
