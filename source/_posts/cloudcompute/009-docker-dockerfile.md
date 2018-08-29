---
title: 3.dockerfile命令
tags:
  - docker
p: cloudcompute/009-docker-dockerfile
date: 2018-08-02 13:51:55
---
dockerfile命令.

# 总图导航

{% asset_img 000.png %}

# 执行例子
```Dockerfile
FROM busybox
MAINTAINER jimo
WORKDIR /testdir
RUN touch tmpfile1
COPY ["tmpfile2","."]
ADD ["test.tar.gz","."]
ENV WELCOME "welcome,hello jimo!"
```
步骤:
```Shell
root@jimo-VirtualBox:~/workplace/dockerfile# ls
Dockerfile  test.tar.gz  tmpfile2

root@jimo-VirtualBox:~/workplace/dockerfile# docker build -t my-image .
Sending build context to Docker daemon  3.584kB
Step 1/7 : FROM busybox
 ---> 8ac48589692a
Step 2/7 : MAINTAINER jimo
 ---> Running in cddd7ca74cac
Removing intermediate container cddd7ca74cac
 ---> 4c677feaf9b1
Step 3/7 : WORKDIR /testdir
Removing intermediate container 74aa3f9fe05c
 ---> dee8626e9257
Step 4/7 : RUN touch tmpfile1
 ---> Running in 8778416873e1
Removing intermediate container 8778416873e1
 ---> 454f8faf14d7
Step 5/7 : COPY ["tmpfile2","."]
 ---> acc5e5121870
Step 6/7 : ADD ["test.tar.gz","."]
 ---> 64e240a80739
Step 7/7 : ENV WELCOME "welcome,hello jimo!"
 ---> Running in f1b75e490e80
Removing intermediate container f1b75e490e80
 ---> 135177378c5b
Successfully built 135177378c5b
Successfully tagged my-image:latest
```
验证:进入容器
```shell
root@jimo-VirtualBox:~/workplace/dockerfile# docker run -it my-image
/testdir # ls
Dockerfile  tmpfile1    tmpfile2
/testdir # echo $WELCOME
welcome,hello jimo!
/testdir # 
```
# CMD
下面看看 CMD 是如何工作的。Dockerfile 片段如下：
```dockerfile
CMD echo "Hello world"
```
运行容器 docker run -it [image] 将输出：
Hello world

但当后面加上一个命令，比如 docker run -it [image] /bin/bash，CMD 会被忽略掉，命令 bash 将被执行：
```dockerfile
root@10a32dc7d3d3:/#
```

# ENTRYPOINT
1. ENTRYPOINT 的 Exec 格式用于设置要执行的命令及其参数，同时可通过 CMD 提供额外的参数。
2. ENTRYPOINT 中的参数始终会被使用，而 CMD 的额外参数可以在容器启动时动态替换掉。

比如下面的 Dockerfile 片段：
```dockerfile
ENTRYPOINT ["/bin/echo", "Hello"]  
CMD ["world"]
```
当容器通过 docker run -it [image] 启动时，输出为：
Hello world

而如果通过 docker run -it [image] jimo 启动，则输出为：
Hello jimo

# 总结
本文来自[blog](http://www.cnblogs.com/CloudMan6/p/6875834.html)

最佳学习方式: 去 [Docker Hub](https://hub.docker.com/) 上参考那些官方镜像的 Dockerfile.


