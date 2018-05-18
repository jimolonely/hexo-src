---
title: python使用pyodbc
tags:
  - python
p: python/000-pyodbc
date: 2018-01-02 20:03:01
---
使用pyodbc

# 安装
```shell
pip install pyodbc
```
如果出现:
```shell
src/pyodbc.h:56:10: 致命错误：sql.h：没有那个文件或目录
     #include <sql.h>
              ^~~~~~~
    编译中断。
    error: command 'gcc' failed with exit status 1
```
则再安装:
```shell
$ sudo pacman -S unixodbc
```
# 配置
1. 需要安装驱动,我使用freetds,如果linux没有自带安装源可以下载:[http://www.freetds.org/](http://www.freetds.org/)

2. 配置/etc/odbcinst.ini:
```shell
$ cat /etc/odbcinst.ini 
[SQL Server]
Description = FreeTDS ODBC driver for MSSQL

Driver = /usr/lib/libtdsodbc.so

Setup = /usr/lib/libtdsS.so

FileUsage = 1
```
3. 测试
```python
>>> import pyodbc

>>>cnxn = pyodbc.connect('DRIVER={SQL Server};SERVER=host\\sql;DATABASE=testDB;UID=sa;PWD=myPassword')
```

