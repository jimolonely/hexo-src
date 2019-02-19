---
title: mysql ERROR 1133(42000)
tags:
  - mysql
p: db/006-mysql-error-1133
date: 2019-02-19 10:01:16
---

原因是存在一个用户名为空的用户，导致不能使用root用户登陆。

这里的安装方法采用：[https://www.linode.com/docs/databases/mysql/how-to-install-mysql-on-centos-7/](https://www.linode.com/docs/databases/mysql/how-to-install-mysql-on-centos-7/)

官方文档： [https://dev.mysql.com/doc/mysql-yum-repo-quick-guide/en/#repo-qg-yum-fresh-install](https://dev.mysql.com/doc/mysql-yum-repo-quick-guide/en/#repo-qg-yum-fresh-install)

错误解决博客[https://www.cnblogs.com/Anker/p/3551610.html](https://www.cnblogs.com/Anker/p/3551610.html)

copy一份：

# 方法一
1.关闭mysql
```shell
   # systemctl stop mysqld
```
2.屏蔽权限
```shell
   # mysqld_safe --skip-grant-table
   屏幕出现： Starting demo from .....
```
3.新开起一个终端输入
```shell
   # mysql -u root mysql
   mysql> UPDATE user SET Password=PASSWORD('newpassword') where USER='root';
   mysql> FLUSH PRIVILEGES;//记得要这句话，否则如果关闭先前的终端，又会出现原来的错误
   mysql> \q
```

# 方法二
1.关闭mysql
```shell
   # systemctl stop mysqld
```
2.屏蔽权限
```shell
   # mysqld_safe --skip-grant-table
   屏幕出现： Starting demo from .....
```
3.新开起一个终端输入
```shell
   # mysql -u root mysql
   mysql> delete from user where USER='';
   mysql> FLUSH PRIVILEGES;//记得要这句话，否则如果关闭先前的终端，又会出现原来的错误
   mysql> \q
```
