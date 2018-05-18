---
title: ERROR 1698 (28000):Access denied for user
tags:
  - mysql
  - linux
p: db/000-mysql-error-1698
date: 2018-03-27 09:07:24
---
ERROR 1698 (28000): Access denied for user 问题的解决.

# 问题
在ubuntu下,使用sudo安装mysql后,普通用户登录时会出现该问题:
```shell
$ mysql -uroot -p
Enter password: 
ERROR 1698 (28000): Access denied for user 'root'@'localhost'
```
# 解决
使用sudo用户权限登录进行修改:
```shell
$ sudo mysql -uroot
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 41
Server version: 10.0.34-MariaDB-0ubuntu0.16.04.1 Ubuntu 16.04

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> use mysql;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
MariaDB [mysql]> update user set plugin ='' where user='root';
Query OK, 1 row affected (0.01 sec)
Rows matched: 1  Changed: 1  Warnings: 0

MariaDB [mysql]> flush privileges;
Query OK, 0 rows affected (0.00 sec)

MariaDB [mysql]> exit;
Bye
```
简单来说就是:
```shell
sudo mysql -uroot
use mysql;
update user set plugin='' where user='root';
flush privileges;
exit;
```