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

8. NIO基础理论
    1. linux 网络IO模型： 阻塞IO、非阻塞IO、IO复用、信号驱动IO、异步IO的区别
    2. 零拷贝（zero copy）
        1. 缓存IO是啥？
        2. 零拷贝的分类
        3. mmap函数的利弊： 将内核空间映射到用户空间
    3. 零拷贝的例子：
        1. FileChannel.transferTo()----》 sendfile
            1. 2.1版本：直接从磁盘--》内核buffer--》socket buffer--》NIC网卡
            2. 2.4版本：磁盘--》内核buffer--》追加偏移量到socket buffer--》根据socket的偏移量直接从内核copy 数据到NIC


9. [IDEA中将java项目转为maven项目](https://www.jetbrains.com/help/idea/maven-support.html#convert_project_to_maven)

10. {% post_link  java/035-mybatis-mapkey mybatis中的mapkey %}



