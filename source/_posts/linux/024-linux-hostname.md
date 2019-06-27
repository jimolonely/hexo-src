---
title: linux hostname修改
tags:
  - linux
p: linux/024-linux-hostname
date: 2019-06-27 13:21:19
---

[hostname的修改并不是那么简单](https://www.cnblogs.com/kerrycode/p/3595724.html)。

1. 修改`/etc/sysconfig/network`: `HOSTNAME=xxx`

2. 直接修改内核文件： `sudo echo xxx > /proc/sys/kernel/hostname`

> hostname是个内核参数，其地址为`/proc/sys/kernel/hostname`，这个值是在系统启动时从`rc.sysinit`
加载的,但centos7换成systemd了。




