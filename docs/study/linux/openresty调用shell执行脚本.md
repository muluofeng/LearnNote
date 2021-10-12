###   目标 访问一个链接实现 代码自动pull打包重启


#### 1. 安装  openresty  
```shell
# add the yum repo:
wget https://openresty.org/package/centos/openresty.repo
sudo mv openresty.repo /etc/yum.repos.d/

# update the yum index:
sudo yum check-update


sudo yum install openresty


## 启动
openresty 
## 重新加载文件
openresty -s reload

```

#### 2. sockproc 安装

sockproc 是一个服务器程序, 侦测unix socket 或者 tcp socket , 并把收到的命令,传递给子进程执行,执行完毕后,把结果返回给客户端, 我们就让sockproc 侦测/tmp/shell.sock 的套接口有没有数据到来.
```shell
## 安装
git clone https://github.com/juce/sockproc
cd sockproc
make
## 启动
./sockproc /tmp/shell.sock
chmod 0666 /tmp/shell.sock

```

#### 3. lua-resty-shell 安装
它是一个很小的库, 配合openresty 使用, 目的是提供类似于os.execute 或io.popen的功能, 唯一区别它是非阻塞的, 也就是说即使需要耗时很久的命令,你也可以使用它

```shell
##安装
git clone https://github.com/juce/lua-resty-shell
cp lua-resty-shell/lib/resty/shell.lua ./lualib/resty/

```
书写需要执行的命令
vim ./lualib/gitpull.lua
```shell
local shell = require "resty.shell"
local args = {
     socket = "unix:/tmp/shell.sock"
}

local status, out, err = shell.execute("cd /project/ && git pull origin master", args)  --ls 是想调用的命令,
ngx.header.content_type = "text/plain"
ngx.say(out) -- 输出给nginx前端
```
#### 4.配置openresty 添加一个location
进入到刚才安装的 openresty 目录，我的是：/usr/local/openresty
修改 /usr/local/openresty/nginx/nginx.conf 在默认的server段中加入以下内容



```conf
location = /api/git-hook {
	content_by_lua_file /usr/local/openresty/lualib/gitpull.lua;
}
```

### 5 启动和测试
```shell
##重新加载  openresty 
openresty -s reload

```

访问   http://ip:port/api/git-hook