

## Anaconda 是什么 

#####  简介
Anaconda（官方网站）就是可以便捷获取包且对包能够进行管理，同时对环境可以统一管理的发行版本。Anaconda包含了conda、Python在内的超过180个科学包及其依赖项。

#####  特点
其特点的实现主要基于Anaconda拥有的：

▪ conda包
▪ 环境管理器
▪ 1,000+开源库

#####  区别
 Anaconda、conda、pip、virtualenv的区别

 - Anaconda是一个包含180+的科学包及其依赖项的发行版本。其包含的科学包包括：conda, numpy, scipy, ipython notebook等。
 - conda 是包及其依赖项和环境的管理工具。
 - pip 是用于安装和管理软件包的包管理器。
 - virtualenv是用于创建一个独立的Python环境的工具。


##### 常用命令

-  conda info 查看包括版本的更多信息
-  conda update conda 更新conda至最新版本
-  conda create --name python36 python=3.6  创建新环境时指定python版本为3.6，环境名称为python36
-  conda activate python36  切换到环境名为python36的环境（默认是base环境），切换后可通过python -V查看是否切换成功
-  conda deactivate 返回前一个python环境
-  conda info -e 显示已创建的环境，会列出所有的环境名和对应路径
-  conda remove --name envname --all 删除虚拟环境
-  conda list -n python36   ##获取指定环境中已安装的包 

##### 常用包命令
```shell
##在当前环境中安装包
conda install scrapy  

##在指定环境中安装包
conda install -n python36 scrapy

##在当前环境中更新包  
conda update scrapy   

##在指定环境中更新包
conda update -n python36 scrapy  

##更新当前环境所有包
conda update --all   

##在当前环境中删除包
conda remove scrapy   

##在指定环境中删除包
conda remove -n python2 scrapy
```













