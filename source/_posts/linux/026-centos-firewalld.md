---
title: 重新认识centos防火墙
tags:
  - linux
  - centos
p: linux/026-centos-firewalld
date: 2019-07-15 09:14:26
---

本文基于firewalld官方文档做一个学习笔记，涉及到大部分方面。

# firewalld简介

什么是firewalld：
> Firewalld提供动态管理的防火墙，支持网络/防火墙区域(zone)，用于定义网络连接或接口的信任级别。 它支持IPv4，IPv6防火墙设置，以太网桥和IP集。 运行时和永久配置选项分开。 它还为服务或应用程序提供了直接添加防火墙规则的接口。

根据[官网](https://firewalld.org/)的介绍，firewalld有以下好处：

1. 可以在运行时环境中立即进行更改。 不需要重新启动服务或守护程序。

2. 使用firewalld D-Bus接口，服务，应用程序和用户都可以轻松调整防火墙设置。 界面完整，用于防火墙配置工具有firewall-cmd，firewall-config和firewall-applet。

3. 运行时和永久配置的分离使得可以在运行时进行评估和测试。 运行时配置仅在下次服务重新加载和重新启动或系统重新引导时有效。 然后将再次加载永久配置。 使用运行时环境，可以将运行时用于仅在有限时间内处于活动状态的设置。 如果运行时配置已用于评估，并且它已完成并正常工作，则可以将此配置保存到永久环境中。

哪些地方用了？

1. RHEL 7, CentOS 7
2. Fedora 18 and newer
3. 其他发布版

# 理解firewalld

根据其[开源github](https://github.com/firewalld/firewalld), 其采用python语言书写。

## 基本架构

根据[文档](https://firewalld.org/documentation/concepts.html)放出的一张图，我们可以观摩一下。

{% asset_img 000.png %}

这张图怎么看呢？英文好的同学可以直接看文档去，但是看完之后需要有一个自己的理解，我的理解如下：

1. 从上往下看，共有3个部分，最上面是4个提供给用户的操作接口（命令或界面），中间是firewalld的核心组件，下面是操作系统内核，很显然，我们应该关注中间和上面

2. 中间可以分为2层：上面的D-Bus和下面的Core，核心层负责处理配置和后端，如iptables，ip6tables，ebtables，ipset和模块加载器； D-Bus接口是更改和创建防火墙配置的主要方式，而接口中firewall-offline-cmd是个例外，它不和firewalld打交道，而是直接使用带有IO处理程序的firewalld核心来更改和创建firewalld配置文件。

3. 实际上我们不需要知道核心如何实现，只需要知道操作最上层的用户接口即可，但是，在这之前还需要了解一些基本概念。

## 必备概念

### Zone

**[Zone](https://firewalld.org/documentation/zone/)是什么？**

Zone定义了一个信任级别，什么的信任级别： 连接、接口或地址绑定。他们的关系是一对多，一个Zone可以有很多连接、接口和源地址。

简单来说，一个Zone里的东西是同路人，遵循相同的规则，受到相同的管理；不同Zone里的东西规则是不一样的。

**默认，已经有很多预定义的Zone：**

1. drop：任何传入的网络数据包都被丢弃，没有回复。只能进行传出网络连接。

2. block：任何传入的网络连接都会被拒绝，其中包含用于IPv4的icmp-host-prohibited消息和用于IPv6的icmp6-adm-prohibited。只能在此系统中启动网络连接。

3. public：用于公共场所。您相信网络上的其他计算机会损害您的计算机。仅接受选定的传入连接。

4. external：用于特别为路由器启用伪装的外部网络。您相信网络上的其他计算机可能会损害您的计算机。仅接受选定的传入连接。

5. dmz：对于非军事区中的计算机，这些计算机可公开访问，并且对内部网络的访问权限有限。仅接受选定的传入连接。

6. work：用于工作区域。您非常信任网络上的其他计算机不会损害您的计算机。仅接受选定的传入连接。

7. home：适用于家庭领域。您信任网络上的其他计算机不会损害您的计算机。仅接受选定的传入连接。

8. internal：用于内部网络。您信任网络上的其他计算机不会损害您的计算机。仅接受选定的传入连接。

9. trusted：接受所有网络连接。


可以看到，其开放程度逐渐递增，到最后为所有人开放。

**那你肯定会问默认的Zone是什么？**

如果没有指定Zone，那么使用默认的，谁都知道，但是，默认的Zone并不确定，而是[取决于NetworkManager](https://firewalld.org/documentation/zone/default-zone.html), 抱歉这让人失望，怎么理解呢？ [这篇文档给出了解释](https://firewalld.org/documentation/zone/connections-interfaces-and-sources.html)

**zone的配置文件什么样？**

默认目录：`/usr/lib/firewalld/zones`, 用户配置目录：`/etc/firewalld/zones`

```shell
[root@jimo1 zones]# pwd
/usr/lib/firewalld/zones
[root@jimo1 zones]# ll
总用量 36
-rw-r--r--. 1 root root 299 11月 12 2016 block.xml
-rw-r--r--. 1 root root 293 11月 12 2016 dmz.xml
-rw-r--r--. 1 root root 291 11月 12 2016 drop.xml
-rw-r--r--. 1 root root 304 11月 12 2016 external.xml
-rw-r--r--. 1 root root 369 11月 12 2016 home.xml
-rw-r--r--. 1 root root 384 11月 12 2016 internal.xml
-rw-r--r--. 1 root root 315 11月 12 2016 public.xml
-rw-r--r--. 1 root root 162 11月 12 2016 trusted.xml
-rw-r--r--. 1 root root 311 11月 12 2016 work.xml
[root@jimo1 zones]# cat public.xml 
<?xml version="1.0" encoding="utf-8"?>
<zone>
  <short>Public</short>
  <description>For use in public areas. You do not trust the other computers on networks to not harm your computer. Only selected incoming connections are accepted.</description>
  <service name="ssh"/>
  <service name="dhcpv6-client"/>
</zone>
```
再看看当我在public Zone开放8081端口时的配置：
```shell
[root@jimo1 zones]# 
[root@jimo1 zones]# pwd
/etc/firewalld/zones
[root@jimo1 zones]# ll
总用量 8
-rw-r--r--. 1 root root 377 7月   9 10:34 public.xml
-rw-r--r--. 1 root root 340 4月  17 10:07 public.xml.old
[root@jimo1 zones]# cat public.xml
<?xml version="1.0" encoding="utf-8"?>
<zone>
  <short>Public</short>
  <description>For use in public areas. You do not trust the other computers on networks to not harm your computer. Only selected incoming connections are accepted.</description>
  <service name="dhcpv6-client"/>
  <service name="http"/>
  <service name="ssh"/>
  <port protocol="tcp" port="8081"/>
</zone>
```
关于配置的XML含义和具体配置，参考[文档](https://firewalld.org/documentation/zone/options.html)

### service

firewalld服务可以是本地端口和目标的列表，还可以是在启用服务时自动加载的防火墙帮助程序模块列表。

在上面已经见过了，可以看更多[例子](https://firewalld.org/documentation/service/examples.html)

### IPSet
ipset可用于将多个IP或MAC地址组合在一起。 IP地址的ipset可用于IPv4或IPv6。 这由ipset的系列设置定义。 它可以是inet（默认值）或inet6。

通过使用ipsets，例如，黑名单或白名单的规则数量减少到ipset中的一长串地址的少数规则。 所需规则的数量取决于用例。

```xml
<?xml version="1.0" encoding="utf-8"?>
  <ipset type="hash:net">
  <short>white-list</short>
  <entry>1.2.3.4</entry>
  <entry>1.2.3.5</entry>
  <entry>1.2.3.6</entry>
</ipset>
```
### ICMP类型
Internet控制消息协议（ICMP）用于在Internet协议（IP）中交换信息以及错误消息。 可以在firewalld中使用ICMP类型来限制这些消息的交换。

```xml
<?xml version="1.0" encoding="utf-8"?>
<icmptype>
  <short>Echo Reply (pong)</short>
  <description>This message is the answer to an Echo Request.</description>
</icmptype>
```

# 配置firewalld

[使用firewalld](https://firewalld.org/documentation/utilities/firewall-cmd.html)








http://www.aboutyun.com/thread-17535-1-1.html


