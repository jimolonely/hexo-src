---
title: git-恢复之前版本误删的文件
tags:
  - git
p: git/006-git-revert-deleted-files
date: 2019-07-10 16:59:37
---

本文记录恢复误删文件的方式，实际遇到的问题的解决方案。

# 问题定义
一个同事，在你不知道的情况下删掉了一些文件，你一直专注开发，知道n次提交之后才发现那些文件还有用。

因此，你需要恢复那些文件。

前提： 你知道那些文件在哪次提交中被删除的。

# 解决办法

解决逻辑：

1. 找到最近一次那文件还存在的版本
2. 从那个版本恢复文件（`git checkout commitid <files>`）

下面是更详细操作：

1. 使用`git log`列出提交的commit id:
    ```shell
    git log
    commit 3ca068f5037b5d494901f67bb78e5f13cd3b93d9 (HEAD -> dev, origin/dev)
    Author: jimo <jimo@jimo.com>
    Date:   Wed Jul 10 16:58:19 2019 +0800

        修改iad-admin、iad-api、iad-config模块

    commit d2b5a88d1d8dfb799c84582218a9152f10738386
    Author: jimo <jimo@jimo.com>
    Date:   Wed Jul 10 16:21:38 2019 +0800

        方法名修改

    commit 1601c4ec2016a22cb424ac4956d0b5b7824b6ae5
    Author: jimo <jimo@jimo.com>
    Date:   Wed Jul 10 09:56:08 2019 +0800

        云环境摘要
    ```

2. 使用`git diff`对比出2次差异：只显示删除的文件（这一步是可选的，用于不确定文件是否存在时）
    ```shell
    git diff --name-only --diff-filter=D \
      1601c4ec2016a22cb424ac4956d0b5b7824b6ae5 3ca068f5037b5d494901f67bb78e5f13cd3b93d9
    ```
    1. `--name-only`： 只显示文件名
    2. `--diff-filter=D`: 只显示删除的
    3. 这句命令的意思是： 显示前面id版本 到 后面id版本时被删除的文件名，注意：id的顺序很重要

3. 恢复需要的文件： 你可能只需要恢复某些文件，后面还可以用正则匹配
    ```shell
    git checkout 1601c4ec2016a22cb424ac4956d0b5b7824b6ae5 文件路径/文件夹（git diff列出来的）
    ```
    1. 含义是：恢复这个id对应版本的文件(夹)


