---
title: git常用命令
tags:
  - git
p: git/001-git-command-collect
date: 2018-05-30 16:27:46
---

git 的常用操作。


只提交已经删除的文件

```shell
git ls-files --deleted | xargs git rm
```
或者：
```shell
git add -u #u代表update
```
