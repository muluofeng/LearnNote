- 文档参考：http://www.tuicool.com/articles/mEvaq2
- git 远程操作详解：http://www.ruanyifeng.com/blog/2014/06/git_remote.html


-  linux下搭建git

```
a. 查看系统是否安装git
     git
b.安装git
    sudo apt-get install git
c.配置git用户名和邮箱
    git config --global user.name "Your Name"
    git config --global user.email "email@example.com"
注意：git config命令的--global参数，用了这个参数，表示你这台机器上所有的Git仓库都会使用这个配置，当然也可以对某个仓库指定不同的用户名和Email地址。
```

- linux使用git

```
a.创建空目录，添加git管理
    mkdir learngit
    cd learngit
    git init
    //使用成功多了一个.git目录，一个隐藏的文件夹

b. 创建文件readme.txt ，添加文件到git管理,更改了文件就add一下
    git add readme.txt
    
    //添加所有修改的和新增的文件到暂缓区
    git add .  

c. 提交更改的文件 
    git commint -m "提交说明"
    
    //git add命令实际上就是把要提交的所有修改放到暂存区（Stage），然后，执行git commit就可以一次性把暂存区的所有修改提交到分支
    
d. 查看git状态
    git status

e.查看git提交日志，可以看到提交的各个版本commit_id
    git log
f. 版本回退,HEAD表示当前版本，^代表回退多少个版本,
    git reset --hard  HEAD^  //上一个版本，
    git reset --hard  commit_id 

g.查看你执行过的git命令,就可以找到你之前的commit_id，    
    git reflog //找到commit_id
    git reset --hard commit_id //回退
    
h. 撤销修改
    修改文件还没add
        git checkout -- 文件名称  // 撤销文件的修改
    修改文件，git add 添加到缓存区
        git reset HEAD 文件名称  //撤销暂存区的修改，重新放回工作区
        git checkout -- 文件名称  //// 撤销文件的修改
j.删除文件
    git rm 文件名称
    git commit -m "..."
    //如果手动删除了文件
    git checkout -- 文件名称  //git checkout其实是用版本库里的版本替换工作区的版本，无论工作区是修改还是删除，都可以“一键还原”
```

HEAD指向的版本就是当前版本，因此，Git允许我们在版本的历史之间穿梭，使用命令git reset --hard commit_id。
穿梭前，用git log可以查看提交历史，以便确定要回退到哪个版本。
要重返未来，用git reflog查看命令历史，以便确定要回到未来的哪个版本。
每次修改，如果不add到暂存区，那就不会加入到commit中
- 从github clone一个新的版本库


```
a. 把本地生成的ssh key添加到github
    ssh-keygen 
    //然后系统提示输入文件保存位置等信息，连续敲三次回车即可，生成的SSH key文件保存在中～/.ssh/id_rsa.pub
    vim ~/.ssh/id_rsa.pub
    //接着拷贝.ssh/id_rsa.pub文件内的所以内容，将它粘帖到github帐号管理中的添加SSH key界面中。

b. 复制ssh地址，clone代码
    //复制github的地址，我的测试地址是：git@github.com:muluofeng/learngit.git
    git clone.git@github.com:muluofeng/learngit.git
c.修改文件，然后commit,提交到github
    //修改文件
    git add 文件名称 或者使用git add . 添加所有文件
    git commit -m "提交说明":
    //提交到远程
    git push origin master
```

- 添加远程仓库



```
a.为了便于管理，Git要求每个远程主机都必须指定一个主机名。git remote命令就用于管理主机名。不带选项的时候，
    git remote命令列出所有远程主机。
    1.git remote #命令列出所有远程主机
    2.git remote -v #查看远程主机地址
    3.git clone -o 远程主机命名 地址 
    #克隆版本库的时候，所使用的远程主机自动被Git命名为origin。如果想用其他的主机名需要用git clone命令的-o选项指定。
    4.git remote show <主机名> #可以查看该主机的详细信息。
    5.git remote add <主机名><网址>  #用于添加远程主机。
    6.git remote rm <主机名>  #删除远程主机
    7.git remote rename <原主机名><新主机名> #远程主机的改名

git pull
    取回远程主机某个分支的更新，再与本地的指定分支合并
    格式： git pull <远程主机名> <远程分支名>[:<本地分支名>]
    如果远程的分支与当前分支合并，那么:<本地分支名>可以省略
    demo: git pull origin master 将远程主机origin的master分支和本地合并，相当于 git fetch + git merge
```



注意：如果想要关联一个远程库，
            git remote add origin git@github.com:michaelliao/learngit.git
添加后，远程库的名字就是origin，这是Git默认的叫法，也可以改成别的，但是origin这个名字一看就知道是远程库。
git push -u origin master
可能会报错，出现错误的主要原因是github中的README.md文件不在本地代码目录中，使用
 git pull --rebase origin master 【注：pull=fetch+merge]】
 以后如果有新的提交
git push origin master
 以后如果从远程拉去代码
git pull origin master



3.使用远程服务器作为git服务器
参考：https://www.douban.com/note/407034249/





- git http/https方式储存密码
```
git config --global credential.helper store
```

- git 合并分支代码
```
## 将master分支合并到vms 上

## 先将主分支更新到最新
git checkout master

git pull 

##切换vms分支，合并提交
git checkout vms  

git merge  master  

git push 
```

- git 撤销一个文件的更改
```

##  -- 不能省略，否则就变成了切换分支了
git checkout -- fileName
```