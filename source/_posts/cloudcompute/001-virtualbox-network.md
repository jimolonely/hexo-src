---
title: virtualbox局域网配置
tags:
  - 云计算
  - linux
p: cloudcompute/001-virtualbox-network
# date: 2018-03-25 11:10:49
---
有时不仅需要虚拟机能连外网,还需要虚拟机之间能互相通信.

# 了解virtualbox的4种联网方式

可以参考[文章](https://www.cnblogs.com/york-hust/archive/2012/03/29/2422911.html)

通过3张图来看看.

{% asset_img 004.png %}
{% asset_img 005.png %}
{% asset_img 006.png %}

# 目标
1. 虚拟机可以访问外网
2. 虚拟机有静态IP可以互相通信

# 环境
2台redhut虚拟机.(其他系统也可以,都可以在界面上配置IP)

# 实现
1. 每台虚拟机准备2个网卡,第一个设置为NAT(这里名为enp0s3),第二个设置为host only(名为enp0s8)

{% asset_img 000.png %} 
{% asset_img 001.png %}

2. enp0s3设置为DHCP,enp0s8设置为静态IP,手动配置

{% asset_img 002.png %} 
{% asset_img 003.png %}

3. 另一台除了enp0s8的静态IP变了,其余一样.

# 问题
在ubuntu里会出现2张网卡,但内部通讯的网卡成了默认的,也就是enp0s8:
```shell
$ ip r
default via 192.168.56.1 dev enp0s8  proto static  metric 100 
default via 10.0.2.2 dev enp0s3  proto static  metric 101 
10.0.2.0/24 dev enp0s3  proto kernel  scope link  src 10.0.2.15  metric 100 
169.254.0.0/16 dev enp0s8  scope link  metric 1000 
192.168.56.0/24 dev enp0s8  proto kernel  scope link  src 192.168.56.11  metric 100 
192.168.122.0/24 dev virbr0  proto kernel  scope link  src 192.168.122.1 linkdown 
```
这时候会导致虚拟机之间可以通信,但无法访问外网.

所以我们需要修改网卡顺序,经过查找,ifmetric这个工具可以解决.

1.先安装
```shell
$ sudo apt install ifmetric
```
2.修改
```shell
$ sudo ifmetric enp0s3
```
3.查看路由
```shell
$ ip r
default via 10.0.2.2 dev enp0s3  proto static 
default via 192.168.56.1 dev enp0s8  proto static  metric 100 
10.0.2.0/24 dev enp0s3  proto kernel  scope link  src 10.0.2.15 
169.254.0.0/16 dev enp0s8  scope link  metric 1000 
192.168.56.0/24 dev enp0s8  proto kernel  scope link  src 192.168.56.11  metric 100 
192.168.122.0/24 dev virbr0  proto kernel  scope link  src 192.168.122.1 linkdown 
```
这时候可以访问外网,虚拟机也可以通讯了.

有时候重启了又会恢复,可以在开机脚本里搞定.

