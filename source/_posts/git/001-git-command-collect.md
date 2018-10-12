---
title: git常用命令
tags:
  - git
p: git/001-git-command-collect
date: 2018-05-30 16:27:46
---

git 的常用操作。


# 只提交已经删除的文件

```shell
git ls-files --deleted | xargs git rm
```
或者：
```shell
git add -u #u代表update
```

# 删除本该忽略的文件
例如，idea的配置文件夹：`.idea`,在开始时忘记加入`.gitignore`了，结果提交到仓库去了。这时可以使用下面的语句删除提交：
```java
git rm -r --cached .idea
```
然后重新加入`.gitignore`文件。再次提交。

[git rm与git rm --cached 区别](https://www.jianshu.com/p/337aeafc2f40)
