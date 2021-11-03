参考： http://www.asfx.xyz/p/a807cca1e325404b8bad99e85bb8936b

docker run -d --name kong-database \
--network=kong-net \
-p 25432:5432 \
-v kong-volume:/var/lib/postgresql/data \
-e "POSTGRES_USER=kong" \
-e "POSTGRES_PASSWORD=kong"  \
-e "POSTGRES_DB=kong" \
postgres:11.12


docker run --rm --network=kong-net -e "KONG_DATABASE=postgres" -e "KONG_PG_HOST=kong-database" -e "KONG_PG_USER=kong" -e "KONG_PG_PASSWORD=kong" -e "KONG_CASSANDRA_CONTACT_POINTS=kong-database" kong/kong:2.4.1 kong migrations bootstrap


docker run -d --network=kong-net -e "KONG_DATABASE=postgres" -e "KONG_PG_HOST=kong-database" -e "KONG_PG_PASSWORD=kong" -e "KONG_CASSANDRA_CONTACT_POINTS=kong-database" -e "KONG_PROXY_ACCESS_LOG=/dev/stdout" -e "KONG_ADMIN_ACCESS_LOG=/dev/stdout" -e "KONG_PROXY_ERROR_LOG=/dev/stderr" -e "KONG_ADMIN_ERROR_LOG=/dev/stderr" -e "KONG_ADMIN_LISTEN=0.0.0.0:8001, 0.0.0.0:8444 ssl" --restart=always -p 7777:8000 -p 8443:8443 -p 8002:8001 -p 8444:8444  --name kong kong/kong:2.4.1


docker run -d --network kong-net -e "TOKEN_SECRET=kongtoken" -e "DB_ADAPTER=postgres" -e "DB_HOST=kong-database" -e "DB_USER=kong" -e "DB_PASSWORD=kong"  --restart=always  -p 21337:1337 --name konga  pantsel/konga:0.14.9

端口：
21337
8002
7777


##### 注意开放端口对于8002 端口 不要所有ip都能访问