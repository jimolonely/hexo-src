---
title: keepalived踩坑记录
tags:
  - linux
  - keepalived
p: linux/019-keepalived-learn
date: 2019-02-15 12:32:02
---

本文记录了使用keepalived的常用场景和踩坑经历。

首先贴上官网： [http://www.keepalived.org/manpage.html](http://www.keepalived.org/manpage.html)

对于每个配置的含义，还是以这里为准较好。

# 关于环境和安装
这里就不说了，太多博客了。

# keealived可以做什么
这个是首先要问的问题。

Keepalived是一个用C编写的路由软件。

主要目标是为Linux系统和基于Linux的基础架构提供简单而强大的负载平衡和高可用性设施。

简单来说就是： 负载均衡和高可用。一般和nginx结合使用。

# 如何做到的
1. 负载平衡： 依赖于众所周知且广泛使用的Linux虚拟服务器（IPVS）内核模块，提供Layer4层负载均衡。 Keepalived实现了一组检查器，以根据其健康状况动态地和自适应地维护和管理负载平衡的服务器池。
2. VRRP协议实现了高可用性。 VRRP是路由器故障转移的基础。此外，Keepalived为VRRP有限状态机实现了一组挂钩，提供低级和高速协议交互。为了提供最快的网络故障检测，Keepalived实现了BFD协议。 VRRP状态转换可以考虑BFD提示来驱动快速状态转换。 
3. Keepalived框架可以单独使用，也可以一起使用，以提供灵活的基础架构。

有一些关键词需要了解：

1. LVS: [http://www.linuxvirtualserver.org/](http://www.linuxvirtualserver.org/)
2. VRRP: [https://tools.ietf.org/html/rfc5798](https://tools.ietf.org/html/rfc5798)
3. BFD: [https://tools.ietf.org/html/rfc5881](https://tools.ietf.org/html/rfc5881), [http://www.h3c.com/cn/d_200804/603261_30003_0.htm](http://www.h3c.com/cn/d_200804/603261_30003_0.htm)

# 场景分析
1. keepalived+nginx： nginx做负载均衡，keepalived做高可用
2. keepalived+redis： 配置redis的主从备份
3. keepalived+mysql： 配置数据库的主从备份

# 关键问题
很常见的应用就是主从备份，那关键就是主从何时切换？

1. 主keepalived挂了，肯定需要切换
2. 主keepalived监控的应用挂了， 需要切换

第一种好说，第二种需要注意： 看下面的配置：

MASTER：
```shell
vrrp_script chk_app {
    script "/etc/keepalived/scripts/monitor_app.sh"
    interval 2
    weight   -20
    fall   3
    rise   1
}

vrrp_instance VI_112 {
    interface ens4f0
    lvs_sync_daemon ens4f0
    state MASTER 
    virtual_router_id 177 

    priority 100
    advert_int 1
    garp_master_delay 1

    track_interface {
       ens4f0 
    }
    virtual_ipaddress {
        192.168.17.176/32 dev ens4f0 
    }
    track_script {
       chk_nginx
       chk_app
    }
    authentication {
        auth_type PASS
        auth_pass secret
    }
}
```
BACKUP：
```shell
vrrp_script chk_app {
    script "/etc/keepalived/scripts/monitor_app.sh"
    interval 2
    weight   -20
    fall   3
    rise   1
}

vrrp_instance VI_112 {
    interface ens4f0
    lvs_sync_daemon ens4f0
    state BACKUP 
    virtual_router_id 177 

    priority 90
    advert_int 1
    garp_master_delay 1

    track_interface {
       ens4f0 
    }
    virtual_ipaddress {
        192.168.17.176/32 dev ens4f0 
    }
    track_script {
       chk_nginx
       chk_app
    }
    authentication {
        auth_type PASS
        auth_pass secret
    }
}
```
vrrp_script里的weight很关键，master检测到应用挂了，权重会减少20，这样master的权重就比backup的低了，这样就会切换到backup。

如果把weight设为5，这样永远都切不过去，所以是没用的。

## keepalived-LVS
[http://www.keepalived.org/LVS-NAT-Keepalived-HOWTO.html](http://www.keepalived.org/LVS-NAT-Keepalived-HOWTO.html)


# 参考文章
[keepalived vip漂移基本原理及选举算法](https://www.cnblogs.com/pangguoping/p/5721517.html)

[vrrp协议与keepalived详解](http://blog.51cto.com/xiexiaojun/1718990)