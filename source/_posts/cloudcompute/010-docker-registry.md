---
title: 4.docker Registry
tags:
  - docker
p: cloudcompute/010-docker-registry
date: 2018-08-03 13:51:55
---

# 总图导航

{% asset_img 000.png %}

# 镜像命名
```Shell
# docker images
REPOSITORY                    TAG                 IMAGE ID            CREATED             SIZE
my-image                      latest              135177378c5b        About an hour ago   1.15MB
```
镜像名称组成: REPOSITORY:TAG,默认TAG是latest,并无强制要求.

# TAG最佳实践
1. 采用docker社区普遍采用的3级格式.
2. 一个版本可以有多个TAG.

命令如下
```Shell
# 最初为1.9.1
docker tag myimage-v1.9.1 myimage:1
docker tag myimage-v1.9.1 myimage:1.9
docker tag myimage-v1.9.1 myimage:1.9.1
docker tag myimage-v1.9.1 myimage:latest

#升级到1.9.2
docker tag myimage-v1.9.2 myimage:1
docker tag myimage-v1.9.2 myimage:1.9
docker tag myimage-v1.9.2 myimage:1.9.2
docker tag myimage-v1.9.2 myimage:latest

# 2.0.0发布
docker tag myimage-v2.0.0 myimage:2
docker tag myimage-v2.0.0 myimage:2.0
docker tag myimage-v2.0.0 myimage:2.0.0
docker tag myimage-v2.0.0 myimage:latest
```

如下图:

{% asset_img 001.png %}

这种TAG的解释和好处:
1. myimage:1 始终指向 1 这个分支中最新的镜像。
2. myimage:1.9 始终指向 1.9.x 中最新的镜像。
3. myimage:latest 始终指向所有版本中最新的镜像。
4. 如果想使用特定版本，可以选择 myimage:1.9.1、myimage:1.9.2 或 myimage:2.0.0。

# 上传到Registry
注意个人需要带上 : 用户名/image:tag
```Shell
root@jimo-VirtualBox:~/workplace/dockerfile# docker login -u jackpler
Password: 
Login Succeeded
root@jimo-VirtualBox:~/workplace/dockerfile# docker tag my-image jackpler/my-image:v1
root@jimo-VirtualBox:~/workplace/dockerfile# docker images
REPOSITORY                    TAG                 IMAGE ID            CREATED             SIZE
jackpler/my-image             v1                  135177378c5b        About an hour ago   1.15MB
my-image                      latest              135177378c5b        About an hour ago   1.15MB
root@jimo-VirtualBox:~/workplace/dockerfile# docker push jackpler/my-image:v1
The push refers to repository [docker.io/jackpler/my-image]
f89ed34343be: Pushed 
d2fc55a59506: Pushed 
7046cf07d08a: Pushed 
bdad0d9725ad: Pushed 
0314be9edf00: Mounted from library/busybox 
v1: digest: sha256:a07e725b2cf9fdfbbb80ee71efa890070cab2bea9fb1006fb31078e8eaeb7898 size: 1355
```
在网站可看到:

{% asset_img 002.png %}

在网站上可以删除.

# 搭建本地Registry
原因很多: 网速,费用,安全.

使用[官方的registry](https://hub.docker.com/r/library/registry/)
```shell
root@jimo-VirtualBox:~/workplace/dockerfile# docker run -d -p 5001:5000 -v /home/jimo/myregistry:/var/lib/registry registry:latest
Unable to find image 'registry:latest' locally
latest: Pulling from library/registry
81033e7c1d6a: Pull complete 
b235084c2315: Pull complete 
c692f3a6894b: Pull complete 
ba2177f3a70e: Pull complete 
a8d793620947: Pull complete 
Digest: sha256:feb40d14cd33e646b9985e2d6754ed66616fedb840226c4d917ef53d616dcd6c
Status: Downloaded newer image for registry:latest
80f81f33ed15616f5334d6e49642da0eff1cd4777aae075f816f48f6de52269a

root@jimo-VirtualBox:~/workplace/dockerfile# docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                    NAMES
80f81f33ed15        registry:latest     "/entrypoint.sh /etc…"   11 seconds ago      Up 10 seconds       0.0.0.0:5001->5000/tcp   agitated_clarke
```
-p : 绑定在5001端口
-v : 把镜像存储映射到本地
-d : 后台运行

上传到本地registry
```Shell
root@jimo-VirtualBox:~# docker tag jackpler/my-image:v1 localhost:5001/jackpler/my-image:v1.1

root@jimo-VirtualBox:~# docker images
REPOSITORY                         TAG                 IMAGE ID            CREATED             SIZE
jackpler/my-image                  v1                  135177378c5b        2 hours ago         1.15MB
my-image                           latest              135177378c5b        2 hours ago         1.15MB
localhost:5001/jackpler/my-image   v1.1                135177378c5b        2 hours ago         1.15MB

root@jimo-VirtualBox:~# docker push localhost:5001/jackpler/my-image:v1.1
The push refers to repository [localhost:5001/jackpler/my-image]
f89ed34343be: Pushed 
d2fc55a59506: Pushed 
7046cf07d08a: Pushed 
bdad0d9725ad: Pushed 
0314be9edf00: Pushed 
v1.1: digest: sha256:a07e725b2cf9fdfbbb80ee71efa890070cab2bea9fb1006fb31078e8eaeb7898 size: 1355
```
**注意:**
REPOSITORY的格式: [registry-host]:[port]/[username]/xxx
只有docker hub上的镜像可以省略 [registry-host]:[port] 

本文来自[blog](http://www.cnblogs.com/CloudMan6/p/6902325.html)


