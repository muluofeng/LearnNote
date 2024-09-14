 ###  Git 中 merge 和 rebase 的区别

什么是 rebase?

git rebase 你其实可以把它理解成是“重新设置基线”，将你的当前分支重新设置开始点。这个时候才能知道你当前分支于你需要比较的分支之间的差异。
原理很简单：rebase 需要基于一个分支来设置你当前的分支的基线，这基线就是当前分支的开始时间轴向后移动到最新的跟踪分支的最后面，这样你的当前分支就是最新的跟踪分支。这里的操作是基于文件事务处理的，所以你不用怕中间失败会影响文件的一致性。在中间的过程中你可以随时取消 rebase 事务。


```shell
//将分支切换到master分支
git checkout master
​
//把test分支合并到master分支
git rebase test
```

![1646809313170.png](https://qiniu.muluofeng.com/1646809313170.png)



```shell
//将分支切换到master分支
git checkout master
​
//把test分支合并到master分支
git merge test
```


![1646809344969.png](https://qiniu.muluofeng.com/1646809344969.png)
