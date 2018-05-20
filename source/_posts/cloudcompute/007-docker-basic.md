---
title: docker基础
tags:
  - docker
p: cloudcompute/007-docker-basic
---
容器技术.

# 基本概念
看下面的图.

{% asset_img 000.png %}

# 安装加速器
访问[https://dashboard.daocloud.io/build-flows](https://dashboard.daocloud.io/build-flows),
注册用户,然后使用加速器,体验飞速下载.

安装完后重启
```shell
$ sudo systemctl restart docker
```
# 容器和虚拟机对比
为什么需要容器: 让软件具备很强的移植能力.

容器的单词是container,也就是集装箱的意思,将以前运送货物的思想用到软件上,则软件变成了可移植了.

# docker核心组件

{% asset_img 001.png %}


