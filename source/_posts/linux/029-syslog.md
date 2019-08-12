---
title: 认识syslog
tags:
  - linux
  - syslog
p: linux/029-syslog
date: 2019-08-12 18:03:31
---

最近遇到一个问题：需要限制keepalived的日志大小。翻来覆去没找到keepalived自己怎么配，听说syslog可以，于是研究一下。



[The BSD syslog Protocol](https://tools.ietf.org/html/rfc3164)


[syslog协议的Facility, Severity数字代号和PRI计算](https://www.ichenfu.com/2017/08/31/syslog-facility-and-severity/)

[keepalived 文档参考](https://fossies.org/linux/keepalived/doc/man/man8/keepalived.8)

# 最通用的办法

在这篇问答里：[How to limit log file size using >>](https://unix.stackexchange.com/questions/17209/how-to-limit-log-file-size-using)，
提出了好几种限制文件大小的方法，都很通用。

1. 使用[logratote](http://linux.die.net/man/8/logrotate)

2. 从系统参数入手：`ulimit -f $((200*1024))`，前提是你只有一个文件需要限制

3. 甚至创建一个固定大小的文件系统镜像

4. 使用`head -c`限制： `run_program | head -c ${size} >> myprogram.log`，不过好像有问题

5. 自己写个定时任务来检测和限制大小



