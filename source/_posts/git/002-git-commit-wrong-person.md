---
title: 为什么git提交关联了错误的用户
tags:
  - git
p: git/002-git-commit-wrong-person
date: 2019-01-01 09:45:34
---

前几天检查github提交历史，发现明明提交了，为什么绿格子没有点亮。然后引发了让我惊奇的事情。
因为我在2台电脑上提交过，都使用的SSH的方式，然后就出现了2个陌生的用户：

{% asset_img 000.png %}

而且这2个账户还有自己单独的主页，虽然一看就知道才创建的。

经过查找，发现了[github社区的回答](https://github.community/t5/Support-Protips/Why-is-my-commit-associated-with-the-wrong-person/ba-p/6728).

大概内容如下：

1. github每次提交关联了3类用户：作者（修改文件的人）、提交者、推送者；
2. 提交者是通过邮件地址来确定的，不管是私有还是公有地址；
3. 查看一下提交者。

通过命令行：
```
$ git log
commit 5bca74ff5bcff3ffe9d21d96b4dfb3ba01309638
Author: jimo <11@11.com>
Date:   Mon Dec 31 23:18:58 2018 +0800

    modify
```
或通过github网站（所有人都能看到）：在https://github.com/用户名/仓库/commit/id.patch
{% asset_img 001.png %}

可以看出果然不是我，而是一个jimo的人，但也和上面的用户对不上，所以是根据邮箱随便产生的把（我猜测）。

那解决办法呢？

将邮件改正确(就是github账户里验证过的邮箱)试试：
```
$ git config user.email "yours"
```

然后再修改提交就ok了：

{% asset_img 002.png %}

