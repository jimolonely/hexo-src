---
title: 2019-11-周报
tags:
  - life
  - week
p: life/008-weekly-learn
date: 2019-03-11 09:32:09
---

2019年第10周学习。

1. pgsql:
    1. 去掉null约束： `alter table xxx alter column xxxx drop not null;`
    2. 更改类型： `alter table xxx alter column xxxx type varchar(100);`


2. zookeeper学习，基本概念：
    1. 集群角色： Leader，Follower，Observer
    2. Session： client--server，TCP长连接，sessionTimeout
    3. Znode： 数据节点，持久和临时
    4. Version： 3个版本，version，cversion，aversion
    5. Watcher： 事件监听
    6. ACL： access controller list
        1. CREATE/DELETE/READ/WRITE 子节点
        2. ADMIN: 设置ACL的权限


3. {% post_link basic/016-java-interview java面试复习 %}

4. 修改了ansible： {% post_link ansible/005-ansible-demo1 ansible实用写法 %}

5. [java: read string from stream](https://stackoverflow.com/questions/309424/how-do-i-read-convert-an-inputstream-into-a-string-in-java)

6. div里对`\n`可以换行： [stakoverflow](https://stackoverflow.com/questions/25862896/text-with-newline-inside-a-div-element-is-not-working)

7. [git: revert (reset) a single file](https://www.norbauer.com/rails-consulting/notes/git-revert-reset-a-single-file): `git checkout filename`


