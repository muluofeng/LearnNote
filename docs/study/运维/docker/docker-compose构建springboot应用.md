参考： http://www.ityouknow.com/springboot/2018/03/28/dockercompose-springboot-mysql-nginx.html

- 作用： **使用 Docker Compose 可以轻松、高效的管理容器，它是一个用于定义和运行多容器 Docker 的应用程序工具**



- Docker Compose 常用命令与配置

```
docker-compose up -d nginx                     构建建启动nignx容器

docker-compose exec nginx bash            登录到nginx容器中

docker-compose down                              删除所有nginx容器,镜像

docker-compose ps                                   显示所有容器

docker-compose restart nginx                   重新启动nginx容器

docker-compose run --no-deps --rm php-fpm php -v  在php-fpm中不启动关联容器，并容器执行php -v 执行完成后删除容器

docker-compose build nginx                     构建镜像 。        

docker-compose build --no-cache nginx   不带缓存的构建。

docker-compose logs  nginx                     查看nginx的日志 

docker-compose logs -f nginx                   查看nginx的实时日志

 

docker-compose config  -q                        验证（docker-compose.yml）文件配置，当配置正确时，不输出任何内容，当文件配置错误，输出错误信息。 

docker-compose events --json nginx       以json的形式输出nginx的docker日志

docker-compose pause nginx                 暂停nignx容器

docker-compose unpause nginx             恢复ningx容器

docker-compose rm nginx                       删除容器（删除前必须关闭容器）

docker-compose stop nginx                    停止nignx容器

docker-compose start nginx                    启动nignx容器



```


## docker-compose 构建 同一用户项目

```yml
#表示使用第三代语法来构建 docker-compose.yaml 文件。
version: '3'
#用来表示 compose 需要启动的服务
services:
  #   网关
  getway-core:
    restart: always
    container_name: getway-core
    image: 47.114.174.69:5000/getway-core:0.0.3
    build:
      context: ./
      dockerfile: getway/getway-core/Dockerfile
    ports:
      - 8080:8080
  auth-server:
    restart: always
    container_name: auth-server
    image: 47.114.174.69:5000/auth-server:0.0.1
    build:
      context: ./
      dockerfile: auth/auth-server/Dockerfile
    ports:
      - 8882:8882
  platform:
    restart: always
    container_name: platform
    image: 47.114.174.69:5000/platform:0.0.5
    build:
      context: ./
      dockerfile: platform/Dockerfile
    ports:
      - 1081:1081
  repository:
    restart: always
    container_name: repository
    image: 47.114.174.69:5000/repository:0.0.1
    build:
      context: ./
      dockerfile: repository/Dockerfile
    ports:
      - 1082:1082
```