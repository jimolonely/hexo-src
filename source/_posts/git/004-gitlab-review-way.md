---
title: 使用gitlab进行review代码
tags:
  - git
  - gitlab
  - review
p: git/004-gitlab-review-way
date: 2019-05-28 17:51:56
---

review是一个重要的阶段：
1. 对自己可以约束写好代码
2. 对后来者更好的维护

本文尝试用gitlab结合多分支实现review。

假设主分支为develop，每隔开发者的分支为 develop-name, 下面是一个流程：

1. 每个人都在`develop-*`分支上工作，比如`develop-jimo`, 禁止直接push代码到主分支（当然，权限限制了这样做）
2. 修改自己分支上的代码后，先提交：
    ```shell
    $ git add .
    $ git commit -m 'xxx'
    ```
3. 然后更新主分支代码： 并解决冲突
    ```shell
    $ git pull origin develop
    ```
4. 提交到自己的分支：
    ```shell
    $ git push origin develop-jimo
    ```

5. 一天中可能提交多次

6. 当一天结束前，到gitlab上： 发起一个merge request(一天至少发起一次)，然后待大部分人都看了并发表评价，
    决定是否符合规范，是否可以合并到主分支：
    1. 如果ok： 合并即可
    2. 否则，开发者根据评价修改，重复这一周期

7. 特殊说明： 如果同事之间工作具有先后关系，比如季蓉需要我写的组件，那么他可以等我写完了直接pull我的分支的代码：
    ```shell
    $ git branch -b develop-jirong
    $ git pull origin develop-jimo
    ```


