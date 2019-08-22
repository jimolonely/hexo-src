---
title: docker安装mysql
tags:
  - docker
  - mysql
p: db/010-docker-install-mysql
date: 2019-08-22 13:44:24
---

想要一个mysql的测试环境，又不想直接在本机上安装，因为会搞乱系统，同时想学习多个版本的mysql。
docker容器技术提供了一个新思路，比虚拟机更轻巧，性能更好。

前提：
1. 已安装好docker环境
2. 使用的操作系统为：ubuntu18.04

# 下载mysql镜像

```s
docker pull mysql:5.7
```

# 运行mysql

## 得到配置文件
这一步通过直接运行复制出配置文件：
```s
docker run -d \
--name mysql5.7 \
-p 3306:3306 \
-e MYSQL_ROOT_PASSWORD=123456 \
mysql:5.7
```
复制配置文件和数据目录：
```s
# 将容器中的 mysql 配置文件复制到宿主机中指定路径下，路径你可以根据需要，自行修改
$ docker cp mysql5.7:/etc/mysql/mysql.conf.d/mysqld.cnf ~/software/docker/mysql/config/
# 将容器中的 mysql 存储目录复制到宿主机中
$ docker cp mysql5.7:/var/lib/mysql/ ~/software/docker/mysql/data/
```
然后删除：
```s
docker rm -f mysql5.7
```

## 正式运行
将mysql的配置和数据目录映射出来
```s
docker run -d \
--name mysql5.7 \
-p 3306:3306 \
-v ~/software/docker/mysql/config/mysqld.cnf:/etc/mysql/mysql.conf.d/mysqld.cnf \
-v ~/software/docker/mysql/data/mysql:/var/lib/mysql \
-e MYSQL_ROOT_PASSWORD=123456 \
mysql:5.7
```

这时候会发现目录权限变为docker了：
```s
$ ll
总用量 188484
drwxr-xr-x 5  999 docker     4096 8月  22 14:27 ./
drwxrwxr-x 3 jack jack       4096 8月  22 14:25 ../
-rw-r----- 1  999 docker       56 8月  22 14:18 auto.cnf
-rw------- 1  999 docker     1675 8月  22 14:18 ca-key.pem
-rw-r--r-- 1  999 docker     1107 8月  22 14:18 ca.pem
-rw-r--r-- 1  999 docker     1107 8月  22 14:18 client-cert.pem
-rw------- 1  999 docker     1679 8月  22 14:18 client-key.pem
-rw-r----- 1  999 docker     1346 8月  22 14:18 ib_buffer_pool
-rw-r----- 1  999 docker 79691776 8月  22 14:27 ibdata1
-rw-r----- 1  999 docker 50331648 8月  22 14:27 ib_logfile0
-rw-r----- 1  999 docker 50331648 8月  22 14:18 ib_logfile1
-rw-r----- 1  999 docker 12582912 8月  22 14:27 ibtmp1
drwxr-x--- 2  999 docker     4096 8月  22 14:18 mysql/
drwxr-x--- 2  999 docker     4096 8月  22 14:18 performance_schema/
-rw------- 1  999 docker     1675 8月  22 14:18 private_key.pem
-rw-r--r-- 1  999 docker      451 8月  22 14:18 public_key.pem
-rw-r--r-- 1  999 docker     1107 8月  22 14:18 server-cert.pem
-rw------- 1  999 docker     1679 8月  22 14:18 server-key.pem
drwxr-x--- 2  999 docker    12288 8月  22 14:18 sys/
```

# 连接测试

## bash进入

```s
$ docker exec -it mysql5.7 bash
root@8db8fe0de68a:/# mysql
ERROR 1045 (28000): Access denied for user 'root'@'localhost' (using password: NO)
root@8db8fe0de68a:/# mysql -uroot -p
Enter password: 
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 3
Server version: 5.7.27 MySQL Community Server (GPL)

Copyright (c) 2000, 2019, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
4 rows in set (0.00 sec)
```

## 客户端连接

使用IDEA的连接：

{% asset_img 000.png %}

# 参考

1. [https://hub.docker.com/_/mysql?tab=description](https://hub.docker.com/_/mysql?tab=description)
2. [https://juejin.im/post/5ce531b65188252d215ed8b7](https://juejin.im/post/5ce531b65188252d215ed8b7)

