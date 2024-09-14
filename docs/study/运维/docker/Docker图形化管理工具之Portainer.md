


```
docker search portainer
docker pull portainer/portainer
docker run -d -p 9000:9000 --name portainer --restart always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer
```


汉化：
https://www.quchao.net/Portainer-CN.html

```
docker run -d -p 9000:9000 -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data -v /public:/public portainer/portainer:1.20.2

```