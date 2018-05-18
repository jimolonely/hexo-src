---
title: 在ubuntu上安装openstack
tags:
  - python
  - 云计算
  - openstack
  - linux
p: cloudcompute/000-install-openstack-unbuntu
date: 2018-01-26 19:57:01
---
本文讲述了在ubuntu16.04上安装openstack的注意事项.
如果是redhat或centos,请参考{% post_link cloudcompute/002-packstack 另一篇文章 %}

# 正文
安装[官网](https://docs.openstack.org/developer/devstack/index.html)的步骤,
有可能会成功.经过反复试验,在不翻墙的情况下还是可以安装成功了.

下面是步骤:
```shell
# 1.stack用户
$ sudo useradd -s /bin/bash -d /opt/stack -m stack

# 2.分配权限
$ echo "stack ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/stack

# 3.采用stack用户
$ sudo su - stack

# 4.在stack环境下
$ git clone https://git.openstack.org/openstack-dev/devstack
$ cd devstack

# 5.创建local.conf文件,并填入下面的文件
[[local|localrc]]
ADMIN_PASSWORD=secret
DATABASE_PASSWORD=$ADMIN_PASSWORD
RABBIT_PASSWORD=$ADMIN_PASSWORD
SERVICE_PASSWORD=$ADMIN_PASSWORD

# 6.官网说可以直接执行stack.sh了,但经过反复验证,有一个资源下载很慢
# 就是会去下载此linux镜像:cirros-0.3.5-x86_64-disk.img
# 可以下载好了,在/opt/stack下建一个files文件夹,放上此文件,不过也不一定
# 也就12M,慢慢下也能下完
```
成功的结果:
```shell
=========================
DevStack Component Timing
 (times are in seconds)  
=========================
run_process           89
test_with_retry        4
apt-get-update        17
pip_install          164
osc                  197
wait_for_service      40
dbsync                62
apt-get               16
-------------------------
Unaccounted time     1100
=========================
Total runtime        1689



This is your host IP address: 192.168.1.126
This is your host IPv6 address: ::1
Horizon is now available at http://192.168.1.126/dashboard
Keystone is serving at http://192.168.1.126/identity/
The default users are: admin and demo
The password: 1234

WARNING: 
Using lib/neutron-legacy is deprecated, and it will be removed in the future


Services are running under systemd unit files.
For more information see: 
https://docs.openstack.org/devstack/latest/systemd.html

DevStack Version: queens
Change: 66c893f25c6eb50edef47ec86a6d97fa58d2ea05 Merge "Bump the Cinder LVM backing file size to 24Gb." 2018-01-25 19:26:49 +0000
OS Version: Ubuntu 16.04 xenial

2018-01-26 10:01:51.399 | stack.sh completed in 1689 seconds.
```
可以看到接近半小时才整完,而且是反复很多次.

另外,出错了需要先执行./unstack.sh,再执行stack.sh.

只要有耐心,一定能装好.

可以在本地登录:

{% asset_img 000.png %}