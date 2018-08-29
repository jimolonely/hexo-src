---
title: linux后台进程那些事
tags:
  - linux
p: linux/010-linux-background
date: 2018-03-01 13:51:55
---
linux后台进程那些事.

# &
一般就这样
# nohup
但是有输出时

如果遇到警告:
```
nohup: redirecting stderr to stdout
```
再加上来进行重定向
```shell
command 2>&1 &
```
