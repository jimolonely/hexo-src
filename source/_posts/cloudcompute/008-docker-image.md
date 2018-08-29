---
title: 2.docker镜像
tags:
  - docker
p: cloudcompute/008-docker-image
date: 2018-08-01 13:51:55
---
docker镜像.

# 本文结构

{% asset_img 000.png %}

# 1.docker commit方式创建镜像
1. 运行容器: it进入进入交互环境.
```shell
root@jimo-VirtualBox:/home/jimo# docker run -it ubuntu
root@4a12c1ec8971:/#
```
2. 安装vim
```shell
root@4a12c1ec8971:/# apt-get install -y vim
```
3. 查看运行的实例: 我们需要那个随机的名字: eager_austin
```shell
root@jimo-VirtualBox:~# docker ps
CONTAINER ID        IMAGE               COMMAND              CREATED              STATUS              PORTS                  NAMES
4a12c1ec8971        ubuntu              "/bin/bash"          About a minute ago   Up About a minute                          eager_austin
```
4. 保存为新的镜像
```shell
root@jimo-VirtualBox:~# docker commit eager_austin ubuntu-with-vi
sha256:96f59c2ae190683ba0337823c718e08ae53d468b452220b3c5492a252ae9fb16
```
5. 验证
```shell
root@jimo-VirtualBox:~# docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
ubuntu-with-vi      latest              96f59c2ae190        50 seconds ago      179MB
ubuntu              latest              452a96d81c30        3 weeks ago         79.6MB
```
可以看到变大了,进入可以使用vim.

以上演示了如何用 docker commit 创建新镜像。然而，Docker 并不建议用户通过这种方式构建镜像。原因如下：
1. 这是一种手工创建镜像的方式，容易出错，效率低且可重复性弱。比如要在 debian base 镜像中也加入 vi，还得重复前面的所有步骤。
2. 更重要的：使用者并不知道镜像是如何创建出来的，里面是否有恶意程序。也就是说无法对镜像进行审计，存在安全隐患。

既然 docker commit 不是推荐的方法，我们干嘛还要花时间学习呢？
原因是：即便是用 Dockerfile（推荐方法）构建镜像，底层也 docker commit 一层一层构建新镜像的。学习 docker commit 能够帮助我们更加深入地理解构建过程和镜像的分层结构。

# 2.Dockerfile定义镜像
按以下步骤重新定义上面的内容:
```shell
root@jimo-VirtualBox:~/workplace# pwd
/root/workplace
root@jimo-VirtualBox:~/workplace# ls
Dockerfile
root@jimo-VirtualBox:~/workplace# cat Dockerfile 
FROM ubuntu
RUN apt-get update && apt-get install -y vim
root@jimo-VirtualBox:~/workplace# docker build -t ubuntu-with-vi-dockerfile .
Sending build context to Docker daemon  2.048kB
Step 1/2 : FROM ubuntu
 ---> 452a96d81c30
Step 2/2 : RUN apt-get update && apt-get install -y vim
 ---> Running in 9f736146b482
......
......
Removing intermediate container 9f736146b482
 ---> 98dc6c72d0ed
Successfully built 98dc6c72d0ed
Successfully tagged ubuntu-with-vi-dockerfile:latest
```
查看镜像:
```shell
root@jimo-VirtualBox:~/workplace# docker images
REPOSITORY                  TAG                 IMAGE ID            CREATED             SIZE
ubuntu-with-vi-dockerfile   latest              98dc6c72d0ed        2 minutes ago       179MB
ubuntu-with-vi              latest              96f59c2ae190        14 minutes ago      179MB
ubuntu                      latest              452a96d81c30        3 weeks ago         79.6MB
```
从
```shell
Step 1/2 : FROM ubuntu
 ---> 452a96d81c30
```
可以看出第一层是ubuntu层,在之上构建了vim.

history命令显示了层次:
```shell
root@jimo-VirtualBox:~/workplace# docker history ubuntu-with-vi-dockerfile
IMAGE               CREATED             CREATED BY                                      SIZE                COMMENT
98dc6c72d0ed        5 minutes ago       /bin/sh -c apt-get update && apt-get install…   99.7MB              
452a96d81c30        3 weeks ago         /bin/sh -c #(nop)  CMD ["/bin/bash"]            0B                  
<missing>           3 weeks ago         /bin/sh -c mkdir -p /run/systemd && echo 'do…   7B                  
<missing>           3 weeks ago         /bin/sh -c sed -i 's/^#\s*\(deb.*universe\)$…   2.76kB              
<missing>           3 weeks ago         /bin/sh -c rm -rf /var/lib/apt/lists/*          0B                  
<missing>           3 weeks ago         /bin/sh -c set -xe   && echo '#!/bin/sh' > /…   745B                
<missing>           3 weeks ago         /bin/sh -c #(nop) ADD file:81813d6023adb66b8…   79.6MB   
```
# docker image的缓存功能
执行以下步骤:
```shell
root@jimo-VirtualBox:~/workplace# ls
Dockerfile  testfile
root@jimo-VirtualBox:~/workplace# cat Dockerfile 
FROM ubuntu
RUN apt-get update && apt-get install -y vim
COPY testfile /

root@jimo-VirtualBox:~/workplace# docker build -t ubuntu-with-vi-dockerfile-2 .
Sending build context to Docker daemon   2.56kB
Step 1/3 : FROM ubuntu
 ---> 452a96d81c30
Step 2/3 : RUN apt-get update && apt-get install -y vim
 ---> Using cache
 ---> 98dc6c72d0ed
Step 3/3 : COPY testfile /
 ---> 3281ec1c6e9e
Successfully built 3281ec1c6e9e
Successfully tagged ubuntu-with-vi-dockerfile-2:latest

root@jimo-VirtualBox:~/workplace# docker images
REPOSITORY                    TAG                 IMAGE ID            CREATED             SIZE
ubuntu-with-vi-dockerfile-2   latest              3281ec1c6e9e        12 seconds ago      179MB
ubuntu-with-vi-dockerfile     latest              98dc6c72d0ed        15 minutes ago      179MB
ubuntu-with-vi                latest              96f59c2ae190        27 minutes ago      179MB
ubuntu                        latest              452a96d81c30        3 weeks ago         79.6MB
```
可看到第2步使用了缓存:
```shell
Step 2/3 : RUN apt-get update && apt-get install -y vim
 ---> Using cache
 ---> 98dc6c72d0ed
```
注意点:
1. 如果我们希望在构建镜像时不使用缓存，可以在 docker build 命令中加上 --no-cache 参数.

2. 如果我们改变 Dockerfile 指令的执行顺序，或者修改或添加指令，都会使缓存失效

3. 除了构建时使用缓存，Docker 在下载镜像时也会使用

# 3.调试Dockerfile
按以下步骤:
```shell
root@jimo-VirtualBox:~/workplace/debug# ls
Dockerfile
root@jimo-VirtualBox:~/workplace/debug# docker build -t image-debug .
Sending build context to Docker daemon  2.048kB
Step 1/4 : FROM busybox
latest: Pulling from library/busybox
f70adabe43c0: Pull complete 
Digest: sha256:da268b65d710e5ca91271f161d0ff078dc63930bbd6baac88d21b20d23b427ec
Status: Downloaded newer image for busybox:latest
 ---> 8ac48589692a
Step 2/4 : RUN touch tmpfile
 ---> Running in b6a64a6a50fc
Removing intermediate container b6a64a6a50fc
 ---> 2d8187e6451a
Step 3/4 : RUN /bin/bash -c echo "build..."
 ---> Running in 3e9f5c9eae7c
/bin/sh: /bin/bash: not found
The command '/bin/sh -c /bin/bash -c echo "build..."' returned a non-zero code: 127
```
可以看到第三步时出错了,我们可以利用第二步的镜像2d8187e6451a调试:
```shell
root@jimo-VirtualBox:~/workplace/debug# docker run -it 2d8187e6451a
/ # /bin/bash -c echo "build..."
sh: /bin/bash: not found
/ # 
```


