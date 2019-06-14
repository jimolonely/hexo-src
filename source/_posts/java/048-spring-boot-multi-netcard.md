---
title: spring cloud多网卡问题
tags:
  - java
  - spring cloud
p: java/048-spring-boot-multi-netcard
date: 2019-06-14 08:27:13
---

多网卡问题。

# 问题描述
主机上有2个网卡，一个是内网，一个是外网，外网无法访问内网。

所以，如果多个网卡是互通的，那没什么问题，只要保证eureka中心的IP写对了就行。

然而，事实是：2台机器，一台的应用绑定在内网IP，另一台在外网，这样虽然可以提供服务，但不是高可用了。

# 问题解决

手动修改IP。这里有2种方式：

## 1.server.address

```yml
eureka:
  instance:
    prefer-ip-address: true

server:
  port: 5557
  address: 192.168.1.126
```
这种方式：只有192.168.1.126能访问，其他IP不行。

## 2.inetutils.preferred-networks

```yml
spring:
  cloud:
    inetutils:
      preferred-networks: 192.168.1.
```


