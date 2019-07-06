---
title: docker知识总结成图
tags:
  - docker
p: cloudcompute/018-docker-conclude-to-graph
date: 2019-07-01 13:43:50
---

本文将大部分docker知识按图总结，便于理解。

# 存储

本章我们学习以下内容：

1. docker 为容器提供了两种存储资源：数据层和 Data Volume。
2. 数据层包括镜像层和容器层，由 storage driver 管理。
3. Data Volume 有两种类型：bind mount 和 docker managed volume。
4. bind mount 可实现容器与 host 之间，容器与容器之间共享数据。
5. volume container 是一种具有更好移植性的容器间数据共享方案，特别是 data-packed volume container。
6. 最后我们学习如何备份、恢复、迁移和销毁 Data Volume。

## 存储分类
https://www.cnblogs.com/CloudMan6/p/7152775.html

{% asset_img 000.png %}

## 共享数据
分为主机与容器之间、容器之间共享。

https://www.cnblogs.com/CloudMan6/p/7163399.html

### 主机与容器
1. bind volume
2. docker managed volume

{% asset_img 001.png %}

### 容器与容器-bind volume

{% asset_img 002.png %}

### 容器与容器-volume container
创建专门的volume容器来实现

{% asset_img 003.png %}

### 容器与容器-data-packed volume container
把数据封装在容器里，不依赖于主机，适合与不需要改变的静态配置文件。

1. 创建带有数据的镜像：
    ```docker
    FROM busybox:latest
    ADD htdocs /usr/local/apache2/htdocs
    VOLUME /usr/local/apache2/htdocs # 相当于 -v 选项
    ```
2. 创建容器： `docker build -t datapacked .`, `docker create --name vc_data datapacked`

3. 使用： `docker run --volumes-from vc_data httpd`

## 存储的生命周期

创建、共享、使用、备份、迁移、恢复备份、销毁。

现在说出这些阶段如何实现。

# docker machine
[https://docs.docker.com/machine/install-machine/](https://docs.docker.com/machine/install-machine/)

学习docker machine是干嘛的

怎么使用

[了解docker machine有哪些driver](https://docs.docker.com/machine/drivers/)

## 创建
使用docker machine创建docker环境：

1. ssh-copy-id 目标机器
2. docker-machine create --driver generic --generic-ip-address=192.168.xxx.xxx hostname
3. docker-machine ls

## 管理远程docker

1. 查看环境变量：`docker-machine env hostname`
2. 切换到远程shell： `eval $(docker-machine env hostname)`
3. 升级到最新版: `docker-machine upgrade host1 host2`
4. 在不同机器间拷贝文件： `docker-machine scp host1:/xxx host2:/xxx`







