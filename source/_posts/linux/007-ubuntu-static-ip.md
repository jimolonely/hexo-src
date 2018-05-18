---
title: ubuntu下设置静态ip
tags:
  - linux
  - ubuntu
  - ip
p: linux/007-ubuntu-static-ip
date: 2018-01-26 11:04:41
---
记录下ip,掩码,网关的基础知识和ubuntu下的配置.

# 基础知识
学过计算机网络肯定知道,如果不用也很快就忘了.

什么是IP,子网掩码,网关?

简单来说IP用于定位地址,用于屏蔽物理差异,由网络号和主机号组成.
子网掩码用于区分前面的网络号和后面的具体地址,前面为1和后面为0.
网关也是个ip,是通向其他网络的IP.

举个例子:
```
IP: 192.168.1.100/24
子网掩码:255.255.255.0
```
24代表掩码前面的1的个数,也表示这个子网可以容纳256个局域网IP.

如何得到网关(gateway):
```
一般来说采用dhcp不需要关注,当配置静态ip时就需要配网关了.
一般取该子网第一个或最后一个可用IP.
方法:
使用IP和掩码相与得: 192.168.1.0
一般1和255不用,所以可以取2或则254,那么网关为:192.168.1.2或192.168.1.254
```

# 在虚拟机里的ubuntu配置静态IP

在配之前查看下原来的IP:发现IP是10.0.2.15/24
```shell
jimo@jimo-ubuntu:~$ ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 08:00:27:dd:c4:25 brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic enp0s3
       valid_lft 84947sec preferred_lft 84947sec
    inet6 fe80::2466:c20b:788d:f576/64 scope link 
       valid_lft forever preferred_lft forever
```
设置静态IP:修改为14

文件/etc/network/interfaces

原来:
```shell
# interfaces(5) file used by ifup(8) and ifdown(8)
auto lo
iface lo inet loopback
```
现在:
```shell
jimo@jimo-ubuntu:~$ sudo vim /etc/network/interfaces
# interfaces(5) file used by ifup(8) and ifdown(8)
auto lo
iface lo inet loopback

auto enp0s3

iface enp0s3 inet static
address 10.0.2.14
netmask 255.255.255.0
gateway 10.0.2.2
```
重启服务:
```shell
jimo@jimo-ubuntu:~$ sudo /etc/init.d/networking restart
[ ok ] Restarting networking (via systemctl): networking.service.
```

再重启一下连接.

# 更简单的
直接在界面上操作

{% asset_img 000.png %}

然后需要重启一下连接.