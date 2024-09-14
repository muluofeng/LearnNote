


##  目录结构
```
-- data
-- docker-compose
-- conf
-- | -- my.cnf
```


## docker-compose.yml 
```yml
version: '3'
services: 
  mysql:
    image: "mysql:8.0"
    container_name: mysql8
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: Yunlu2021!
      MYSQL_DATABASE: social_govern_center
      MYSQL_USER: yunluadmin 
      MYSQL_PASSWORD: Yunlu2021!
    ports:
      - "3306:3306"
    command:
      --default-authentication-plugin=mysql_native_password
      --lower_case_table_names=1
      --character-set-server=utf8mb4
      --collation-server=utf8mb4_general_ci
    volumes:
      - /etc/localtime:/etc/localtime
      - /data/docker-compose/mysql8/data:/var/lib/mysql
      - /data/docker-compose/mysql8/conf/:/etc/mysql/conf.d
        #      - /data/docker-compose/mysql8/my.cnf:/etc/mysql/my.cnf
```

### my.cnf 配置文件
```cnf
[mysqld]
user=mysql
# 表示允许任何主机登陆MySQL
bind-address = 0.0.0.0
port=3306
default-storage-engine=INNODB
#character-set-server=utf8
character-set-client-handshake=FALSE
character-set-server=utf8mb4
collation-server=utf8mb4_unicode_ci
init_connect='SET NAMES utf8mb4'
secure-file-priv=
sql_mode=STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION
[client]
default-character-set=utf8mb4
[mysql] 
default-character-set=utf8mb4
```