- 是Mac OSX上的软件包管理工具，能在Mac中方便的安装软件或者卸载软件， 使用命令，非常方便
- 常用命令
```shell
##查找软件
brew search git
##安装软件
brew install git
##卸载软件
brew uninstall git
##查看已经安装的软件包
brew list
##更新 homebrew的信息(更新软件包列表)
brew update
## 查看那些软件可以升级
brew outdated
##升级软件 (如果不是升级所有的软件，可以指定要升级的软件名称)
brew upgrade <xxx>  
##清理旧版的得包缓存(homebrew 将会把老版本的包缓存下来，以便当你想回滚至旧版本时使用。但这是比较少使用的情况，当你想清理旧版本的包缓存时)
brew cleanup

```


- brew 仓库扩展【brew 有个默认的仓库，brew tap 你可以看成是第三方的仓库】
```shell
##列出已有仓库
brew tap
##添加仓库
brew tap  仓库名称
##删除仓库
brew untap 仓库名称
```

- brew cask【brew用来安装命令行程序，那么brew cask 用来安装os X的图形界面程序】
```shell
## 添加 Github 上的 caskroom/cask 库
brew tap caskroom/cask  
##安装brew-cask
brew install brew-cask
##安装图形界面程序
brew cask install google-chrome

```

- brew 管理后台进程
```shell
##查看brew services 帮助
brew services --help
##查看系统通过brew安装的服务
brew services list
##启动服务
brew services start nginx
##停止服务
brew services stop mysql
##重启服务
brew services restart nginx

##安装图形界面管理brew services 【使用图形界面管理统一管理很方便,图形界面启动的只能图形界面关闭，使用命令行启动的不能用这个关闭】 
brew cask install launchrocket

```


参考：http://wiki.jikexueyuan.com/project/mac-dev-setup/homebrew.html