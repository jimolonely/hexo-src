---
title: docker基础
tags:
  - docker
p: cloudcompute/007-docker-basic
---
容器技术.

# 本文结构

{% asset_img 004.png %}

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

# hello-world解析
看看hello-world的[Dockerfile](https://github.com/docker-library/hello-world/blob/b0a34596994b120f5456f08992ef9a75ed56f34e/amd64/hello-world/Dockerfile)

```dockerfile
FROM scratch 此镜像是从 0 开始构建。
COPY hello / 将文件“hello”复制到镜像的根目录
CMD ["/hello"] 容器启动时，执行 /hello
```
[hello](https://github.com/docker-library/hello-world/tree/b0a34596994b120f5456f08992ef9a75ed56f34e/amd64/hello-world)是个二进制文件,只是打印一句话.

# base镜像
条件
1. 不依赖其他镜像,从0构建
2. 其他镜像可在其上扩展

比如centos,只有几百兆.
```dockerfile
FROM scratch
ADD centos-7-docker.tar.xz /

LABEL org.label-schema.schema-version = "1.0" \
    org.label-schema.name="CentOS Base Image" \
    org.label-schema.vendor="CentOS" \
    org.label-schema.license="GPLv2" \
    org.label-schema.build-date="20180402"

CMD ["/bin/bash"]
```
docker可以适用很多OS,但是有2点需要知道:
1. centos只有rootfs,bootfs适用Host的;
2. centos适用的是Host的kernel,所以对于特定kernel版本的应用,容器不适合.

# 镜像的分层结构
如下dockerfile
```dockerfile
FROM debian
RUN apt install emacs
RUN apt install apache2
CMD ["/bin/bash"]
```
则结构如下:

{% asset_img 002.png %}

每层共享,但相互修改不影响,因为如下图:

{% asset_img 003.png %}

容器层记录每个每个容器各自的修改,而镜像层是只读的,可以被多个容器共享.
这个技术称为Copy-On-Write(只有当需要修改时才复制一份数据).

1. 添加文件: 在容器中创建文件时，新文件被添加到容器层中。
2. 读取文件: 在容器中读取某个文件时，Docker 会从上往下依次在各镜像层中查找此文件。一旦找到，打开并读入内存。
3. 修改文件: 在容器中修改已存在的文件时，Docker 会从上往下依次在各镜像层中查找此文件。一旦找到，立即将其复制到容器层，然后修改之。
4. 删除文件: 在容器中删除文件时，Docker 也是从上往下依次在镜像层中查找此文件。找到后，会在容器层中记录下此删除操作。

本节来自[blog](http://www.cnblogs.com/CloudMan6/p/6806193.html)


