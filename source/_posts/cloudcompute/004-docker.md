---
title: docker那些事-进入
tags:
  - docker
p: cloudcompute/004-docker
date: 2018-04-02 11:48:19
---
docker的那些事.

# 安装
如果安装时使用的root用户,那么普通用户使用时就收到限制,会出现:
```shell
$ docker images
Got permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock: Get http://%2Fvar%2Frun%2Fdocker.sock/v1.37/images/json: dial unix /var/run/docker.sock: connect: permission denied
```
解决办法很简单,将当前用户加入docker用户组:
```shell
$ sudo usermod -aG docker $USER
$ sudo systemctl restart docker
$ newgrp docker
$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
```
# 配置镜像源
可以参考[镜像对比文档](https://ieevee.com/tech/2016/09/28/docker-mirror.html)

我就先使用阿里云了,登进去[https://cr.console.aliyun.com/](https://cr.console.aliyun.com/),
选择镜像加速器就可以看到自己的地址和配置方法了.

# docker的存储目录
默认:
```shell
$ sudo ls /var/lib/docker/
[sudo] jimo 的密码：
builder  containerd  containers  image	network  overlay2  plugins  runtimes  swarm  tmp  trust  volumes
```
# 学习docker
1. [docker-get-started(推荐,很容易)](https://docs.docker.com/get-started/#test-docker-installation)
2. [docker](https://www.rails365.net/articles/docker-de-rong-qi-san)


