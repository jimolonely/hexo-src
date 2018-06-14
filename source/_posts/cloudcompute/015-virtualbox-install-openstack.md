---
title: Virtualbox安装openstack
tags:
  - 云计算
  - openstack
  - linux
p: cloudcompute/015-virtualbox-install-openstack
---

# 环境介绍
安装一个控制节点[4G+40G],计算节点[2G+20G]

ubuntu16.04

# 网络配置
控制节点配置3块网卡(一块用作通信,一块用作neturon通信,一块用作连接外网),如下:

{% asset_img 001.png %}

计算节点配置2块网卡(不需要连接外网):
{% asset_img 000.png %}

先修改root密码:
```shell
$ sudo su -
[sudo] password for jimo:
root@controller:~# passwd
Enter new UNIX password:
Retype new UNIX password:
passwd:
```

## 配置SSH
在controller查看ip:
```shell
$ ip r
```
然后在主机中通过ssh访问:
```shell
$ ssh jimo@192.168.0.104
```
允许root用户SSH访问:
编辑配置文件: /etc/ssh/sshd_config:
```shell
PermitRootLogin yes
```
记得重启ssh服务

## 配置IP
其中一块配置静态IP,其他交给openstack.
编辑 /etc/network/interfaces:
```shell
# interfaces(5) file used by ifup(8) and ifdown(8)
auto lo
iface lo inet loopback

auto enp0s3
iface enp0s3 inet static
address 192.168.0.10
netmask 255.255.255.0
gateway 192.168.0.1
dns-nameservers 192.168.0.1

auto enp0s8
iface enp0s8 inet manual

auto enp0s9
iface enp0s9 inet manual
```
同样将计算节点也配置成这样,IP为20.
```shell
auto lo
iface lo inet loopback

auto enp0s3
iface enp0s3 inet static
address 192.168.0.20
netmask 255.255.255.0
gateway 192.168.0.1
dns-nameservers 192.168.0.1

auto enp0s8
iface enp0s8 inet manual
```

现在相互间应该可以ping通,控制节点可以访问网络.

# 安装openstack
我们使用[devstack](https://docs.openstack.org/devstack/latest/)


