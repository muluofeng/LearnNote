

## 拉取镜像

```
sudo docker pull gitlab/gitlab-ce:latest
```

## 运行容器
```
docker run --detach \
--publish 2443:443 --publish 280:80  --publish 222:22 \
--name gitlab \
--memory 4g \
--restart always \
--volume /data/gitlab/config:/etc/gitlab \
--volume /data/gitlab/logs:/var/log/gitlab \
--volume /data/gitlab/data:/var/opt/gitlab \
gitlab/gitlab-ce:latest
```

## 配置账号密码 

```
sudo docker exec -it gitlab /bin/bash
cd /opt/gitlab/bin
##开始初始化密码
sudo gitlab-rails console production
## 在irb(main):001:0> 后面通过 u=User.where(id:1).first 来查找与切换账号（User.all 可以查看所有用户）
u=User.where(id:1).first 
##d、通过u.password='12345678'设置密码为12345678(这里的密码看自己喜欢)：
u.password='12345678'
## 通过u.password_confirmation='12345678' 再次确认密码
u.password_confirmation='12345678' 
## 通过 u.save!进行保存（切记切记 后面的 !）
u.save!
## 回到gitlab ,可以通过 root/12345678 这一超级管理员账号登录了
```
### gitlab中clone项目时，IP地址是一串数字（内网Gitlab的IP地址不正确）

```
vim /data/gitlab/config/gitlab.rb 
## 修改 需要注意的是，不加端口！！
external_url 'http://106.54.237.135'
## 退出，重启容器

```










### docker 安装jenkins


```
 docker run  -d  --rm   -u root   -p 8080:8080   -v /data/jenkins-data:/var/jenkins_home   -v /var/run/docker.sock:/var/run/docker.sock   -v "$HOME":/home   jenkins/jenkins:lts
```
