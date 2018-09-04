---
title: redis配置文件
tags:
  - redis
p: lang/010-redis-configuration
date: 2018-09-04 08:12:15
---

本文解释redis的配置文件。

# 配置文件位置
默认安装包下就有,当然也可以自己创建。

```shell
[root@jimo redis-4.0.11]# ls
00-RELEASENOTES  BUGS  CONTRIBUTING  COPYING  INSTALL  MANIFESTO  Makefile  README.md  deps  redis.conf  runtest  runtest-cluster  runtest-sentinel  sentinel.conf  src  tests  utils
```

本文基于`redis.conf`。

# 如何使用redis.conf
```shell
./redis-server /path/to/redis.conf
```
# 容量解释
```
# 1k => 1000 bytes
# 1kb => 1024 bytes
# 1m => 1000000 bytes
# 1mb => 1024*1024 bytes
# 1g => 1000000000 bytes
# 1gb => 1024*1024*1024 bytes
```
不区分大小写，也就是说：1GB=1gB=1Gb

# 包含其他配置文件
为避免被覆盖，最好放在文件结尾：
```
# include /path/to/local.conf
# include /path/to/other.conf
```
# 加载模块
在启动时加载模块，如果加载失败则无法启动。
```
# loadmodule /path/to/my_module.so
# loadmodule /path/to/other_module.so
```
# 网络
## bind
如果没有如下示例的`bind`，则server监听所有网卡。
```
# bind 192.168.1.100 10.0.0.1
# bind 127.0.0.1 ::1
```
***警告: 如果运行Redis的计算机直接暴露在互联网，绑定到所有接口是危险的，这将暴露对互联网上的每个人都有一个实例。 所以默认情况下我们取消注释遵循bind指令，这将强制Redis只监听IPv4回溯接口地址（这意味着Redis将能够仅接受来自运行到同一台计算机的客户端的连接在跑）*** 。

默认情况，绑定到本地：
```
bind 127.0.0.1
```
## 保护模式
```
protected-mode yes
```
保护模式默认打开，可以避免暴露到网络上被攻击或访问。

如果保护模式打开，且满足：
1. 没有`bind`指令
2. 没配置密码

则redis只接受127.0.0.1 和 ::1的客户端。
## TCP backlog
```
#默认值 511 
tcp-backlog：511
```

此参数确定了TCP连接中已完成队列(完成三次握手之后)的长度， 当然此值 **必须不大于Linux系统定义的** `/proc/sys/net/core/somaxconn`值，默认是511，而Linux的默认参数值是128。当系统并发量大并且客户端速度缓慢的时候，可以将这二个参数一起参考设定。

**建议修改为 2048**

修改somaxconn

该内核参数默认值一般是128，对于负载很大的服务程序来说大大的不够。一般会将它修改为2048或者更大。
```
# cat /proc/sys/net/core/somaxconn
128
```

`echo 2048 > /proc/sys/net/core/somaxconn` 但是这样系统重启后保存不了

在`/etc/sysctl.conf`中添加如下`net.core.somaxconn = 2048`

然后在终端中执行`sysctl -p`.

## port
监听端口，如果为0，则不监听。
```
port 6379
```
## unix socket
监听unix的socket连接，没有设置则不监听。
```
# unixsocket /tmp/redis.sock
# unixsocketperm 700
```
## timeout
在客户端空闲N秒后关闭连接（0表示禁用）
```
timeout 0
```
## TCP keepalive
如果非0，则在没有通信的情况下使用SO_KEEPALIVE向客户端发送TCP ACK。 这有两个原因：

1. 检测死的客户端。
2. 从中间网络设备的角度看有效连接。

 在Linux上，指定的值（以秒为单位）是用于发送ACK的时间段。 请注意，要关闭连接，需要两倍的时间。 在其他内核上，周期取决于内核配置。

此选项的合理值为300秒，这是从Redis 3.2.1开始的新Redis默认值。
```
tcp-keepalive 300
```
# 通用配置
## 守护程序
默认redis不开守护程序，如果打开，会写一个pid文件到`/var/run/redis.pid`
```
daemonize no
```
## supervised
如果从upstart或systemd运行Redis，Redis可以与您的监督树进行交互:
* supervised no - 不交互
* supervised upsert - 将redis放入SIGSTOP模式与upstart发信号
* supervised systemd - 通过写入READY=1到$NOTIFY_SOCKET与systemd交互
* supervised auto - 通过UPSERT_JOB 或 NOTIFY_SOCKET环境变量检测upstart或systemd方法

他们只发送“进程准备好”的信号，并不保持持续的ping连接。
```
supervised no
```
## pid file
指定的pid文件会在启动时写入，退出时移除。

* 如果守护进程关闭：pid文件不会创建；
* 否则一定会使用，默认是：`/var/run/redis.pid`

最好指定一个pid文件，即使无法创建也不会报错：
```
pidfile /var/run/redis_6379.pid
```
## loglevel
有`debug,verbose,notice,warning`,默认notice(生产环境)
```
loglevel notice
```
## logfile
如果为`""`,则输出到标准输出，如果同时还开启了守护进程，则转到`/dev/null`:
```
logfile ""
```


