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

保证有pip和git
```shell
$ sudo apt install python-pip
$ sudo apt install git
```

创建stack用户并获取devstack:
```shell
jimo@controller:~$ sudo useradd -s /bin/bash -d /opt/stack -m stack
[sudo] password for jimo: 
jimo@controller:~$ echo "stack ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/stack
stack ALL=(ALL) NOPASSWD: ALL
jimo@controller:~$ sudo su - stack
stack@controller:~$ pwd
/opt/stack
stack@controller:~$ ls
examples.desktop
stack@controller:~$ git clone https://git.openstack.org/openstack-dev/devstack
Cloning into 'devstack'...
remote: Counting objects: 41926, done.
remote: Compressing objects: 100% (20930/20930), done.
remote: Total 41926 (delta 29730), reused 32028 (delta 20336)
Receiving objects: 100% (41926/41926), 8.51 MiB | 969.00 KiB/s, done.
Resolving deltas: 100% (29730/29730), done.
Checking connectivity... done.
stack@controller:~$ cd devstack/
stack@controller:~/devstack$
```
同时更换root和stack用户的pip源,切换到stack用户并更换pip源为豆瓣的:
```shell
$ su - stack
root@controller:~# su - stack
stack@controller:~$ mkdir .pip
stack@controller:~$ cd .pip/
stack@controller:~/.pip$ vim pip.conf
stack@controller:~/.pip$ cat pip.conf 
[global]
index-url =https://pypi.douban.com/simple/
download_cache = ~/.cache/pip
[install]
use-mirrors =true 
mirrors =http://pypi.douban.com/simple/ 
trusted-host =pypi.douban.com
```

接着在devstack目录下创建local.conf文件,内容如下:
```shell
[[local|localrc]]

MULTI_HOST=true

# management & api network
HOST_IP=192.168.0.10
LOGFILE=/opt/stack/logs/stack.sh.log

# Credentials
ADMIN_PASSWORD=1234
MYSQL_PASSWORD=1234
RABBIT_PASSWORD=1234
SERVICE_PASSWORD=1234
SERVICE_TOKEN=abcdefghijklmnopqrstuvwxyz

# enable neutron-ml2-vlan
disable_service n-net
enable_service q-svc,q-agt,q-dhcp,q-l3,q-meta,neutron,q-lbaas,q-fwaas
Q_AGENT=linuxbridge
ENABLE_TENANT_VLANS=True
TENANT_VLAN_RANGE=3001:4000
PHYSICAL_NETWORK=default

LOG_COLOR=True
LOGDIR=$DEST/logs
SCREEN_LOGDIR=$LOGDIR/screen

# use TryStack git mirror
GIT_BASE=http://git.trystack.cn
NOVNC_REPO=http://git.trystack.cn/kanaka/noVNC.git
SPICE_REPO=http://git.trystack.cn/git/spice/spice-html5.git
```

然后就可以执行stack.sh了.

计算节点的配置:
```shell
[[local|localrc]]

MULTI_HOST=true
# management & api network
HOST_IP=192.168.0.20

# Credentials
ADMIN_PASSWORD=1234
MYSQL_PASSWORD=1234
RABBIT_PASSWORD=1234
SERVICE_PASSWORD=1234
SERVICE_TOKEN=abcdefghijklmnopqrstuvwxyz

# Service information
SERVICE_HOST=192.168.0.10
MYSQL_HOST=$SERVICE_HOST
RABBIT_HOST=$SERVICE_HOST
GLANCE_HOSTPORT=$SERVICE_HOST:9292
Q_HOST=$SERVICE_HOST
KEYSTONE_AUTH_HOST=$SERVICE_HOST
KEYSTONE_SERVICE_HOST=$SERVICE_HOST

ENABLED_SERVICES=n-cpu,q-agt,neutron
Q_AGENT=linuxbridge
ENABLE_TENANT_VLANS=True
TENANT_VLAN_RANGE=3001:4000
PHYSICAL_NETWORK=default

# vnc config
NOVA_VNC_ENABLED=True
NOVNCPROXY_URL="http://$SERVICE_HOST:6080/vnc_auto.html"
VNCSERVER_LISTEN=$HOST_IP
VNCSERVER_PROXYCLIENT_ADDRESS=$VNCSERVER_LISTEN

LOG_COLOR=True
LOGDIR=$DEST/logs
SCREEN_LOGDIR=$LOGDIR/screen

# use TryStack git mirror
GIT_BASE=http://git.trystack.cn
NOVNC_REPO=http://git.trystack.cn/kanaka/noVNC.git
SPICE_REPO=http://git.trystack.cn/git/spice/spice-html5.git
```

**在虚拟机中不要关闭,休眠即可,因为下次还得重新执行stack.sh**
