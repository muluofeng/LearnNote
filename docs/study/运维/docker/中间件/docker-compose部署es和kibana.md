


##  目录结构
```
-- data
-- docker-compose.yml
-- kibana.yml
-- config
  - elasticsearch.yml
-- plugins

```


## docker-compose.yml 
```yml
version: '3.7'
services:
    elasticsearch:
        image: elasticsearch:7.6.2
        privileged: true
        volumes:
            - /etc/localtime:/etc/localtime
            - /data/docker-compose/elasticsearch/plugins:/usr/share/elasticsearch/plugins #插件文件挂载
            - /data/docker-compose/elasticsearch/config/elasticsearch.yml:/usr/share/elasticsearch/config/elasticsearch.yml #配置文件挂载
            - /data/docker-compose/elasticsearch/data:/usr/share/elasticsearch/data #数据文件挂载
            # - /es/config/elastic-certificates.p12:/usr/share/elasticsearch/config/elastic-certificates.p12  ##es证书
            #- /es/security/:/usr/share/elasticsearch/jdk/lib/security

        environment:
            - bootstrap.memory_lock=true   # 内存交换的选项，官网建议为true
            - discovery.type=single-node      # 是否启用单节点模式
        ports:
            - '9200:9200'
            - '9300:9300'
        container_name: elasticsearch
        restart: always
        networks:
            - elk
    kibana:
        image: kibana:7.6.2
        container_name: kibana
        restart: always
        volumes:
            - /etc/localtime:/etc/localtime
            - /data/docker-compose/elasticsearch/kibana.yml:/usr/share/kibana/config/kibana.yml
        ports:
            - '5601:5601'
        links:
            - elasticsearch:es #可以用es这个域名访问elasticsearch服务
        environment:
            - ELASTICSEARCH_URL=http://elasticsearch:9200 #设置访问elasticsearch的地址
            - 'elasticsearch.hosts=http://es:9200' #设置访问elasticsearch的地址
            - I18N_LOCALE=zh-CN
        networks:
            - elk
        depends_on:
            - elasticsearch
networks:
    elk:
        name: elk
        driver:
            bridge
```

###  elasticsearch.yml 配置文件
```yml
cluster.name: "elasticsearch"
network.host: 0.0.0.0
http.cors.enabled: true
http.cors.allow-origin: "*"
http.cors.allow-headers: Authorization
xpack.security.enabled: true
xpack.security.transport.ssl.enabled: true
```

###  kibana.yml 配置文件
```yml
server.name: kibana  
server.host: "0.0.0.0"  
elasticsearch.hosts: ["http://elasticsearch:9200"]
elasticsearch.username: 'elastic'  
elasticsearch.password: 'yunlu2022@'  
#xpack.monitoring.ui.container.elasticsearch.enabled: true  
i18n.locale: "zh-CN"  
```