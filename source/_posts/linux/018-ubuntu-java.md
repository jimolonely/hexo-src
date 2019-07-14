---
title: ubuntu安装/更新Java
tags:
  - java
  - ubuntu
  - linux
p: linux/018-ubuntu-java
date: 2019-01-27 09:50:17
---

# ubuntu18.x

参考[文章](https://linuxconfig.org/how-to-install-java-on-ubuntu-18-04-bionic-beaver-linux)


## 安装相应版本Java

JDK11（默认）
```shell
$ sudo apt install openjdk-11-jdk
```
JDK8
```shell
$ sudo apt install openjdk-8-jdk
```

## 切换版本

注意对于安装多个jdk版本时如何切换jdk版本：

```shell
$ sudo update-alternatives --config java
有 2 个候选项可用于替换 java (提供 /usr/bin/java)。

  选择       路径                                          优先级  状态
------------------------------------------------------------
* 0            /usr/lib/jvm/java-11-openjdk-amd64/bin/java      1101      自动模式
  1            /usr/lib/jvm/java-11-openjdk-amd64/bin/java      1101      手动模式
  2            /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java   1081      手动模式

要维持当前值[*]请按<回车键>，或者键入选择的编号：2
update-alternatives: 使用 /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java 来在手动模式中提供 /usr/bin/java (java)

jack@jack:~/workspace/iad-boot/nacos-server-0.8.0/nacos$ java -version
openjdk version "1.8.0_191"
OpenJDK Runtime Environment (build 1.8.0_191-8u191-b12-0ubuntu0.18.04.1-b12)
OpenJDK 64-Bit Server VM (build 25.191-b12, mixed mode)
```
