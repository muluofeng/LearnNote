## ES docker-compose 部署



####  0. 项目结构

![image-20230305130219379](https://qiniu.muluofeng.com//uPic/202303/image-20230305130219379.png)

### 1. 编写docker-compose.yml

```yml
version: '2'
services:
    elasticsearch:
        image: elasticsearch:7.6.2
        volumes:
            - /etc/localtime:/etc/localtime
            - /data/docker-compose/es/plugins:/usr/share/elasticsearch/plugins #插件文件挂载
            - /data/docker-compose/es/config/elasticsearch.yml:/usr/share/elasticsearch/config/elasticsearch.yml #配置文件挂载
            - /data/docker-compose/es/data:/usr/share/elasticsearch/data #数据文件挂载
        ports:
            - '9200:9200'
            - '9300:9300'
        container_name: elasticsearch
        restart: always
        environment:
            - 'cluster.name=elasticsearch' #设置集群名称为elasticsearch
            - 'discovery.type=single-node' #以单一节点模式启动
            - 'ES_JAVA_OPTS=-Xms2048m -Xmx2048m' #设置使用jvm内存大小
        networks:
            - elk
    kibana:
        image: kibana:7.6.2
        container_name: kibana
        restart: always
        links:
            - elasticsearch:es #可以用es这个域名访问elasticsearch服务
        environment:
            SERVER_HOST: 0.0.0.0
            ELASTICSEARCH_HOSTS: http://es:9200
            ELASTICSEARCH_USERNAME: elastic
            ELASTICSEARCH_PASSWORD: es密码
            I18N_LOCALE: zh-CN
            XPACK_MONITORING_UI_CONTAINER_ELASTICSEARCH_ENABLED: true
        networks:
            - elk
        depends_on:
            - elasticsearch            
        ports:
            - 5601:5601
     cerebro:
        image: lmenezes/cerebro:0.9.4
        container_name: cerebro
        ports:
        	- "9000:9000"
        command:
            - -Dhosts.0.host=http://elasticsearch:9200
        networks:
            - elk             
networks:
    elk:
        name: elk
        driver:
            bridge
```



###  2 编写 data/docker-compose/es/config/elasticsearch.yml 

```yml
cluster.name: "elasticsearch"
network.host: 0.0.0.0
http.cors.enabled: true
http.cors.allow-origin: "*"
http.cors.allow-headers: Authorization
xpack.security.enabled: true
xpack.security.transport.ssl.enabled: true
```

### 3. 添加账号密码

```yml
# docker-compose 启动
docker-compose up 
# 进入到容器内部
docker exec -it  elasticsearch /bin/bash
## 进入到bin目录 执行设置密码
cd bin
./elasticsearch-setup-passwords interactive
```



## ES 单机部署

参考： [https://juejin.im/post/5bb3a47c6fb9a05d1117961c](https://juejin.im/post/5bb3a47c6fb9a05d1117961c)
-

### 1. 安装jdk 

```
yum search java 
yum install java-1.8.0-openjdk.xxx  #选择一个版本的jdk安装

java -version
```

### 2.  单例安装ElasticSearch 
官网： https://www.elastic.co/cn/downloads/elasticsearch

 下载历史版本 https://www.elastic.co/cn/downloads/past-releases/elasticsearch-6-7-1
```
1.下载 
  cd /usr/local/
  wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.7.1.tar.gz
  tar -zvxf elasticsearch-6.7.1-linux-x86_64.tar.gz
2. 添加用户组
    安装完成后，我们需要新建一个普通用户，因为ElasticSearch不允许在root用户下运行，所以我们需要创建独立的用户来运行es。创建elsearch用户组及elsearch用户
    groupadd elsearch
    useradd elsearch -g elsearch 
    passwd elsearch  # 设置密码
    
3. 更改elasticsearch安装目录及其内部文件的所属用户及组为elsearch:elsearch，如下：
   cd /usr/local/
   chown -R elsearch:elsearch elasticsearch-6.7.1/

4.  设置系统参数
  vim /etc/sysctl.conf 
  vm.max_map_count=655360 #添加一行
  sysctl -p
5. 在启动es前先设置一下绑定的ip，设置为可被外部访问的ip，以及设置bootstrap相关的参数：
  network.host: 0.0.0.0  # 找到该项，设置为可被外部访问的ip
  
6. 启动ElasticSearch服务的命令：
  sh bin/elasticsearch
  sh bin/elasticsearch -d  #后台启动
7 浏览器查看 http:ip:9200
```

### 3. 7.6版本安装启动的问题

```
1../bin/elasticsearch-env: line 116: syntax error near unexpected token 
解决方法：elasticsearch-env文件中第116行修改为：done

2. the default discovery settings are unsuitable for production use; at least one of [discovery.seed_hosts, discovery.seed_providers, cluster.initial_master_nodes] must be configured
   vim config/elasticsearch.yml
   添加或者打开
   node.name: "node-1"
   cluster.initial_master_nodes: ["node-1"]




```
### 3. 安装中文分词
参考： https://www.jianshu.com/p/bb89ad7a7f7d

####  3.1  离线安装中文分词 

**ik的版本要与ES的版本一致**

```
1.下载ik中文分词
https://github.com/medcl/elasticsearch-analysis-ik/releases
2. 进入ES安装目录的bin，插件安装命令如下
    1、 elasticsearch-plugin install 插件地址
    install 参数指定的命令是安装指定的插件到当前ES节点中。
    
    2、 elasticsearch-plugin list
    list参数指定的命令是显示当前ES节点已经安装的插件列表。
    
    3、 elasticsearch-plugin remove 插件名称
    remove 参数指定的命令是删除已安装的插件。

3. 离线安装
   elasticsearch-plugin  instal  file:///usr/local/elasticsearch-7.6.2/elasticsearch-analysis-ik-7.6.2.zip
 
4. 重启es
  ps -ef|grep elasticsearch 
  kill -9 pid
```


####  3.2   6.7.1版本在线安装
```
./bin/elasticsearch-plugin  install https://github.com/medcl/elasticsearch-analysis-ik/releases/download/v6.7.1/elasticsearch-analysis-ik-6.7.1.zip
```



-  ik中文分词器的使用
ik提供了两个分词器，分别是ik_max_word 和ik_smart，下面我们分别测试下。
先测试ik_max_word


```
POST http://localhost:9200/_analyze
{  
    "analyzer": "ik_max_word",
    "text": "世界如此之大"  
}

POST http://localhost:9200/_analyze
{  
    "analyzer": "ik_smart",
    "text": "世界如此之大"  
}
比较两个分词器对同一句中文的分词结果，ik_max_word比ik_smart得到的中文词更多（从两者的英文名含义就可看出来），但这样也带来一个问题，使用ik_max_word会占用更多的存储空间
```

#### es 添加账号密码
```shell
#进入es安装目录下的config目录
vim elasticsearch.yml

# 配置X-Pack
http.cors.enabled: true
http.cors.allow-origin: "*"
http.cors.allow-headers: Authorization
xpack.security.enabled: true
xpack.security.transport.ssl.enabled: true

## 进入到bin目录 执行设置密码
./elasticsearch-setup-passwords interactive
```


## ES 集群部署



