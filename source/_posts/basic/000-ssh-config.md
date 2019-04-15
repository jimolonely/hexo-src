---
title: ssh连接超时配置
tags:
  - ssh
  - basic
p: basic/000-ssh-config
date: 2018-09-14 17:07:43
---

本文解释ssh的超时配置。

# 服务端和客户端

本文约定：
1. 客户端： 本机（想连远程主机）
2. 服务端： 远程主机

# 配置文件地址
分为sshd配置（守护进程）和ssh配置。
centos/ubuntu
```
/etc/ssh/sshd_config： 作为服务端的配置
/etc/ssh/ssh_config： 作为客户端的配置
```

# 超时配置
当连上远程的ssh服务器，如果没有操作，一会就断开连接了，这个时间可以设置得长一些。

## 在客户端修改
也就是在你本机上修改`/etc/ssh/ssh_config`文件，这样所有的连接都会起作用：
```python
Host *
ServerAliveInterval 120 # 秒
```
每隔120秒模拟发送按键事件，防止断开，一般是你可能会遇到这个问题有用：
`packet_write_wait: Connection to 192.168.100.11 port 22: Broken pipe`
## 在服务端修改
当然，如果你只想针对某台服务器修改，就可以在服务端去修改（注意需要遵守规范，毕竟服务端是大家共有的）。

### 方式1
```shell
ClientAliveInterval 10m          # 10 minutes
ClientAliveCountMax 2           # 2 次
```
### 方式2
```shell
# vi /etc/ssh/sshd_config
ClientAliveInterval 20m          # 20 minutes
ClientAliveCountMax 0            # 0 次
```

### 区别
这两种方法之间有一点区别。 对于第一种方法，sshd将通过加密通道发送消息，此处称为Client Alive Messages，如果客户端处于非活动状态10分钟，则从客户端请求响应。 sshd守护程序将最多发送这些消息两次。 如果在发送客户端活动消息时达到此阈值，sshd将断开客户端的连接。

但对于第二种方法，如果客户端处于非活动状态20分钟，sshd将不会发送客户端活动消息并直接终止会话。

# 直接修改超时时间
1. 修改/etc/profile下tmout参数
     如：sudo vi /etc/profile
     tmout=300
     就是300秒后闲置自动退出；
   
2. 在未设置TMOUT或者设置TMOUT=0时，此闲置超时自动退出的功能禁用。

这个很简单。

# 重启ssh服务
修改了任何配置记得重启服务（对应修改的哪端就重启哪端）
```shell
# service sshd restart
# service ssh restart
```

注意：在ubuntu上先安装`openssh-server`:
```shell
$ sudo apt install openssh-server
```

# 参考
[http://blog.51cto.com/9237101/1907424](http://blog.51cto.com/9237101/1907424)

[https://www.thegeekdiary.com/centos-rhel-how-to-setup-session-idle-timeout-inactivity-timeout-for-ssh-auto-logout/](https://www.thegeekdiary.com/centos-rhel-how-to-setup-session-idle-timeout-inactivity-timeout-for-ssh-auto-logout/)
