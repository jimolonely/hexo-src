---
title: javac源码编译到认识编译过程
tags:
  - java
  - jvm
p: java/053-jdk-javac-compile
date: 2019-07-25 08:45:25
---

本文讲述学习过程：先编译jdk的javac源码，再学习主要的java源码编译过程。

# 1.下载jdk源码

我使用的ubuntu系统，因此可以直接安装源码，这里选择openjdk1.8：
```shell
# 查看
$ apt list openjdk*
正在列表... 完成
openjdk-11-dbg/bionic-updates,bionic-security 11.0.3+7-1ubuntu2~18.04.1 amd64
openjdk-11-demo/bionic-updates,bionic-security 11.0.3+7-1ubuntu2~18.04.1 amd64
openjdk-11-doc/bionic-updates,bionic-updates,bionic-security,bionic-security 11.0.3+7-1ubuntu2~18.04.1 all
openjdk-11-jdk/bionic-updates,bionic-security 11.0.3+7-1ubuntu2~18.04.1 amd64
openjdk-11-jdk-headless/bionic-updates,bionic-security 11.0.3+7-1ubuntu2~18.04.1 amd64
openjdk-11-jre/bionic-updates,bionic-security,now 11.0.3+7-1ubuntu2~18.04.1 amd64 [已安装，自动]
openjdk-11-jre-dcevm/bionic-updates,bionic-security 11.0.1+8-1~18.04.1 amd64
openjdk-11-jre-headless/bionic-updates,bionic-security,now 11.0.3+7-1ubuntu2~18.04.1 amd64 [已安装，自动]
openjdk-11-jre-zero/bionic-updates,bionic-security 11.0.3+7-1ubuntu2~18.04.1 amd64
openjdk-11-source/bionic-updates,bionic-updates,bionic-security,bionic-security 11.0.3+7-1ubuntu2~18.04.1 all
openjdk-8-dbg/bionic-updates,bionic-security 8u212-b03-0ubuntu1.18.04.1 amd64
openjdk-8-demo/bionic-updates,bionic-security 8u212-b03-0ubuntu1.18.04.1 amd64
openjdk-8-doc/bionic-updates,bionic-updates,bionic-security,bionic-security 8u212-b03-0ubuntu1.18.04.1 all
openjdk-8-jdk/bionic-updates,bionic-security,now 8u212-b03-0ubuntu1.18.04.1 amd64 [已安装]
openjdk-8-jdk-headless/bionic-updates,bionic-security,now 8u212-b03-0ubuntu1.18.04.1 amd64 [已安装，自动]
openjdk-8-jre/bionic-updates,bionic-security,now 8u212-b03-0ubuntu1.18.04.1 amd64 [已安装，自动]
openjdk-8-jre-dcevm/bionic 8u112-2 amd64
openjdk-8-jre-headless/bionic-updates,bionic-security,now 8u212-b03-0ubuntu1.18.04.1 amd64 [已安装，自动]
openjdk-8-jre-zero/bionic-updates,bionic-security 8u212-b03-0ubuntu1.18.04.1 amd64
openjdk-8-source/bionic-updates,bionic-updates,bionic-security,bionic-security 8u212-b03-0ubuntu1.18.04.1 all

# 安装
$ sudo apt install openjdk-8-source
```
安装位置默认：
```python
/usr/lib/jvm/openjdk-8$ ll -h
总用量 50M
drwxr-xr-x 2 root root 4.0K 7月  25 08:43 ./
drwxr-xr-x 5 root root 4.0K 7月  25 08:43 ../
-rw-r--r-- 1 root root  50M 4月  26 09:04 src.zip

# 拷贝出来
$ cp src.zip /home/jack/workspace/jvm/
```





```shell
```
```shell
```

