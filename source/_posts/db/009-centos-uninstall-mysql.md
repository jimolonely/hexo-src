---
title: centos完全卸载mysql
tags:
  - linux
  - centos
  - mysql
p: db/009-centos-uninstall-mysql
date: 2019-05-29 08:38:01
---

采用yum按照官方文档安装的mysql的卸载方式。

# 1.卸载mysql软件

```shell
# yum remove mysql
Loaded plugins: fastestmirror
Resolving Dependencies
--> Running transaction check
---> Package mysql-community-client.x86_64 0:8.0.15-1.el7 will be erased
--> Processing Dependency: mysql-community-client(x86-64) >= 8.0.0 for package: mysql-community-server-8.0.15-1.el7.x86_64
--> Running transaction check
---> Package mysql-community-server.x86_64 0:8.0.15-1.el7 will be erased
--> Finished Dependency Resolution

Dependencies Resolved

================================================================================================================================================================================
 Package                                          Arch                             Version                                   Repository                                    Size
================================================================================================================================================================================
Removing:
 mysql-community-client                           x86_64                           8.0.15-1.el7                              @mysql80-community                           120 M
Removing for dependencies:
 mysql-community-server                           x86_64                           8.0.15-1.el7                              @mysql80-community                           1.6 G

Transaction Summary
================================================================================================================================================================================
Remove  1 Package (+1 Dependent package)

Installed size: 1.7 G
Is this ok [y/N]: y
Downloading packages:
Running transaction check
Running transaction test
Transaction test succeeded
Running transaction
  Erasing    : mysql-community-server-8.0.15-1.el7.x86_64                                                                                                                   1/2 
  Erasing    : mysql-community-client-8.0.15-1.el7.x86_64                                                                                                                   2/2 
  Verifying  : mysql-community-client-8.0.15-1.el7.x86_64                                                                                                                   1/2 
  Verifying  : mysql-community-server-8.0.15-1.el7.x86_64                                                                                                                   2/2 

Removed:
  mysql-community-client.x86_64 0:8.0.15-1.el7                                                                                                                                  

Dependency Removed:
  mysql-community-server.x86_64 0:8.0.15-1.el7                                                                                                                                  

Complete!
```
当然，可以看下有哪些安装包：

```shell
# rpm -qa | grep mysql
mysql80-community-release-el7-2.noarch
mysql-community-common-8.0.15-1.el7.x86_64
mysql-community-libs-8.0.15-1.el7.x86_64
mysql-community-libs-compat-8.0.15-1.el7.x86_64
```

所以可以按需清楚：
```shell
# yum remove mysql-server mysql-libs
# yum remove mysql80-community-release-el7-2
```
直到： `rpm -qa | grep mysql` 什么都查不出来。

# 2.清除数据
默认情况下（如果改了配置，那根据自己的来）
```shell
# rm -rf /var/lib/mysql
# rm /etc/my.cnf
```

