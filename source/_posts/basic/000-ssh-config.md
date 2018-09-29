---
title: ssh配置记录
tags:
  - ssh
  - basic
p: basic/000-ssh-config
date: 2018-09-14 17:07:43
---

本文通过记录的形式解释ssh的配置。虽然非常简单，但这些配置都有实际需求。

# 配置文件地址

centos
```
/etc/ssh/sshd_config
```

# 超时配置
当连上远程的ssh服务器，如果没有操作，一会就断开连接了，这个时间可以设置得长一些。

## 方式1
```shell
ClientAliveInterval 10m          # 10 minutes
ClientAliveCountMax 2           # 2 次
```
## 方式2
```shell
# vi /etc/ssh/sshd_config
ClientAliveInterval 20m          # 20 minutes
ClientAliveCountMax 0            # 0 次
```
## 区别
这两种方法之间有一点区别。 对于第一种方法，sshd将通过加密通道发送消息，此处称为Client Alive Messages，如果客户端处于非活动状态10分钟，则从客户端请求响应。 sshd守护程序将最多发送这些消息两次。 如果在发送客户端活动消息时达到此阈值，sshd将断开客户端的连接。

但对于第二种方法，如果客户端处于非活动状态20分钟，sshd将不会发送客户端活动消息并直接终止会话。

## 重启ssh服务
```shell
# service sshd restart
```

# 参考
[http://blog.51cto.com/9237101/1907424](http://blog.51cto.com/9237101/1907424)

[https://www.thegeekdiary.com/centos-rhel-how-to-setup-session-idle-timeout-inactivity-timeout-for-ssh-auto-logout/](https://www.thegeekdiary.com/centos-rhel-how-to-setup-session-idle-timeout-inactivity-timeout-for-ssh-auto-logout/)
