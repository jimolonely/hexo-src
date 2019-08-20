---
title: 认识syslog
tags:
  - linux
  - syslog
p: linux/029-syslog
date: 2019-08-12 18:03:31
---

最近遇到一个问题：需要限制keepalived的日志大小。翻来覆去没找到keepalived自己怎么配，听说syslog可以，于是研究一下。

# syslog协议

不得不说，这个协议是非常简单的，查看其 RFC文档：[The BSD syslog Protocol](https://tools.ietf.org/html/rfc3164)，

简单解释：一种用来在互联网协议（TCP/IP）的网络中传递日志消息的标准。

下面是其可能的架构图： 一个发送端，中间可能有多个中继（Relay），一个或多个接收端（collector收集器）

```python
  +------+         +---------+
  |Device|---->----|Collector|
  +------+         +---------+

  +------+         +-----+         +---------+
  |Device|---->----|Relay|---->----|Collector|
  +------+         +-----+         +---------+

  +------+     +-----+            +-----+     +---------+
  |Device|-->--|Relay|-->--..-->--|Relay|-->--|Collector|
  +------+     +-----+            +-----+     +---------+

  +------+         +-----+         +---------+
  |Device|---->----|Relay|---->----|Collector|
  |      |-\       +-----+         +---------+
  +------+  \
             \      +-----+         +---------+
              \-->--|Relay|---->----|Collector|
                    +-----+         +---------+

  +------+         +---------+
  |Device|---->----|Collector|
  |      |-\       +---------+
  +------+  \
             \      +-----+         +---------+
              \-->--|Relay|---->----|Collector|
                    +-----+         +---------+

  +------+         +-----+            +---------+
  |Device|---->----|Relay|---->-------|Collector|
  |      |-\       +-----+         /--|         |
  +------+  \                     /   +---------+
             \      +-----+      /
              \-->--|Relay|-->--/
                    +-----+
```

## 格式
直观的看一个例子：
```s
 <34>Oct 11 22:14:15 mymachine su: 'su root' failed for lonvick on /dev/pts/8
```
其他好理解，最重要的是前面那个`<34>`,为了统一规范，定义了一个PRI（）来区分日志的模块（Facility）和严重级别（Severity）

看RFC或此文的解释： [syslog协议的Facility, Severity数字代号和PRI计算](https://www.ichenfu.com/2017/08/31/syslog-facility-and-severity/)

这里贴出来： 最重要的当然是内核级别的危险警告，其计算公式为： `PRI=Facility*8+Severity`,
**这里为什么乘以8？ 也很好理解，因为Severity有8个，为了保证结果能唯一标识2种编码值，乘以8就不会重复了。**

```s
       Numerical             Facility
          Code

           0             kernel messages
           1             user-level messages
           2             mail system
           3             system daemons
           4             security/authorization messages (note 1)
           5             messages generated internally by syslogd
           6             line printer subsystem
           7             network news subsystem
           8             UUCP subsystem
           9             clock daemon (note 2)
          10             security/authorization messages (note 1)
          11             FTP daemon
          12             NTP subsystem
          13             log audit (note 1)
          14             log alert (note 1)
          15             clock daemon (note 2)
          16             local use 0  (local0)
          17             local use 1  (local1)
          18             local use 2  (local2)
          19             local use 3  (local3)
          20             local use 4  (local4)
          21             local use 5  (local5)
          22             local use 6  (local6)
          23             local use 7  (local7)
-------------------------------------------------------------------
        Numerical         Severity
          Code

           0       Emergency: system is unusable
           1       Alert: action must be taken immediately
           2       Critical: critical conditions
           3       Error: error conditions
           4       Warning: warning conditions
           5       Notice: normal but significant condition
           6       Informational: informational messages
           7       Debug: debug-level messages
```
更规范的说法是由3部分构成的： 

```s
<PRI>{HEADER}{MSG}
```

## 实践

TODO

# 解决问题

[keepalived 文档参考](https://fossies.org/linux/keepalived/doc/man/man8/keepalived.8)

当然，现成的办法肯定是有的，只是要理解为什么这么做，因此，上面讲的syslog就是基础知识。

看这篇博客：[修改Keepalived配置文件位置以及重定向Keepalived日志的输出路径](https://blog.csdn.net/u013256816/article/details/49356689)

里面讲到了如何把keepalived默认输出到`/var/log/messages`的日志重定向出来：

```s
# vim /etc/sysconfig/keepalived

KEEPALIVED_OPTIONS="-f [配置文件路径] -D -S 0" 

# -S 0代表： local0.* 具体的还需要看一下/etc/rsyslog.conf文件: 

# vim /etc/rsyslog.conf
...
# Save news errors of level crit and higher in a special file.
uucp,news.crit                                          /var/log/spooler
 
# Save boot messages also to boot.log
local7.*                                                /var/log/boot.log

# 我们增加一个设备local0.*
local0.*                                                /var/log/keepalived.log
```
显然，这里面的`local0`就是上面的`Facility`.

但是，这样还么解决问题，我们需要限制日志大小，既然都有单独的日志文件了，那么方法就很多了，看下面一节。推荐用[logratate](https://man.linuxde.net/logrotate)

# 最通用的办法

在这篇问答里：[How to limit log file size using >>](https://unix.stackexchange.com/questions/17209/how-to-limit-log-file-size-using)，
提出了好几种限制文件大小的方法，都很通用。

1. 使用[logratote](http://linux.die.net/man/8/logrotate)

2. 从系统参数入手：`ulimit -f $((200*1024))`，前提是你只有一个文件需要限制

3. 甚至创建一个固定大小的文件系统镜像

4. 使用`head -c`限制： `run_program | head -c ${size} >> myprogram.log`，不过好像有问题

5. 自己写个定时任务来检测和限制大小



