---
title: ubuntu防火墙
tags:
  - ubuntu
  - linux
p: linux/032-ubuntu-ufw
date: 2019-09-15 09:43:02
---

本文记录下ubuntu的防火墙命令：`ufw`.

# 简介
UFW 全称为 Uncomplicated Firewall.

是 Ubuntu 系统上默认的防火墙组件, 为了轻量化配置 iptables 而开发的一款工具

# 状态
默认不活动：

```s
$ sudo ufw status
[sudo] jack 的密码： 
状态：不活动
```
开启防火墙：
```s
$ sudo ufw enable
在系统启动时启用和激活防火墙
```

# 开放端口
```s
$ sudo ufw allow 22
规则已添加
规则已添加 (v6)
```
查看：
```s
$ sudo ufw status
状态： 激活

至                          动作          来自
-                          --          --
22                         ALLOW       Anywhere                  
22 (v6)                    ALLOW       Anywhere (v6) 
```

# 其所有用法

```s
$ sudo ufw -h
ERROR: Invalid syntax

Usage: ufw COMMAND

Commands:
 enable                          enables the firewall
 disable                         disables the firewall
 default ARG                     set default policy
 logging LEVEL                   set logging to LEVEL
 allow ARGS                      add allow rule
 deny ARGS                       add deny rule
 reject ARGS                     add reject rule
 limit ARGS                      add limit rule
 delete RULE|NUM                 delete RULE
 insert NUM RULE                 insert RULE at NUM
 route RULE                      add route RULE
 route delete RULE|NUM           delete route RULE
 route insert NUM RULE           insert route RULE at NUM
 reload                          reload firewall
 reset                           reset firewall
 status                          show firewall status
 status numbered                 show firewall status as numbered list of RULES
 status verbose                  show verbose firewall status
 show ARG                        show firewall report
 version                         display version information

Application profile commands:
 app list                        list application profiles
 app info PROFILE                show information on PROFILE
 app update PROFILE              update PROFILE
 app default ARG                 set default application policy
```

关于这个ARGS，不知道其英文单词，但意义是一系列规则：

```s
# 允许SSH的22端口的传入和传出连接
$ sudo ufw allow ssh
$ sudo ufw allow 22

# 特定端口上deny流量
$ sudo ufw deny 111

# 也可以允许基于TCP或者UDP的包
$ sudo ufw allow 80/tcp
$ sudo ufw allow http/tcp
$ sudo ufw allow 1725/udp

# 允许从一个IP地址连接
$ sudo ufw allow from 123.45.67.89

# 允许特定子网的连接
$ sudo ufw allow from 123.45.67.89/24

# 允许特定IP/端口的组合
$ sudo ufw allow from 123.45.67.89 to any port 22 proto tcp
$ sudo ufw allow from 123.45.67.89 to any port 22 proto udp
```


