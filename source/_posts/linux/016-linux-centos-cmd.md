---
title: centos那些常用命令
tags:
  - linux
  - centos
p: linux/016-linux-centos-cmd
date: 2018-10-12 08:09:10
---

本文记录那些常用命令。

# 防火墙相关
[https://havee.me/linux/2015-01/using-firewalls-on-centos-7.html](https://havee.me/linux/2015-01/using-firewalls-on-centos-7.html)

## 防火墙的开闭

## 开放某个端口
```java
firewall-cmd --zone=public --add-port=2888/tcp --permanent
# 重启生效
firewall-cmd --reload
```
## 查看开放的所有端口
```java
# firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: eth0
  sources:
  services: dhcpv6-client ssh
  ports: 8080/tcp 8088/tcp
  protocols:
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```
