---
title: docker知识总结成图
tags:
  - docker
p: cloudcompute/018-docker-conclude-to-graph
date: 2019-07-01 13:43:50
---

本文将大部分docker知识按图总结，便于理解。

# 存储

## 存储分类
https://www.cnblogs.com/CloudMan6/p/7152775.html

{% asset_img 000.png %}

## 共享数据
分为主机与容器之间、容器之间共享。

https://www.cnblogs.com/CloudMan6/p/7163399.html

### 主机与容器
1. bind volume
2. docker managed volume

{% asset_img 001.ong %}

### 容器与容器-bind volume

{% asset_img 002.ong %}

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





