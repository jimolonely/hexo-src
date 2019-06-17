---
title: 2019-24-周报
tags:
  - life
  - week
p: life/018-weekly-learn
date: 2019-06-10 19:55:37
---

这是2019年第24周周报.

1. {% post_link java/047-springboot-boot-failed springboot启动失败原因分析 %}

2. [重新认识3范式](https://blog.csdn.net/Dream_angel_Z/article/details/45175621)
    1. 先看列是否满足原子性（1NF）
    2. 再看非主键列是否完全依赖主键（2NF）
    3. 再看传递依赖：是否非主键列之间不存在依赖（3NF）

3. {% post_link git/005-gitlab-backup-config gitlab定时备份配置 %}

4. {% post_link java/048-spring-boot-multi-netcard spring cloud多网卡问题 %}

5. docker
    1. COPY的上下文环境，不允许copycontext之外的文件
    2. 视图设置JVM参数失败，想到可以直接设置容器参数：-m ,但内存不足不能启动
    3. 关于网络共通问题
    4. 学会用`docker stats`查看服务资源消耗
    5. 学会移除none的image镜像： `docker rmi $(docker images -f "dangling=true" -q)`
    


