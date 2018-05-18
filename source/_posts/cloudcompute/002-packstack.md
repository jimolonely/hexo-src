---
title: packstack安装openstack
tags:
  - linux
  - centos
  - openstack
  - 云计算
p: cloudcompute/002-packstack
date: 2018-03-30 12:49:34
---
安装openstack的一些方法.

# 1.从源码安装
可以参考{% post_link cloudcompute/000-install-openstack-unbuntu 在ubuntu上安装openstack %}

# 2.按照官方文档
官方文档是这样开始的 :[install openstack](https://docs.openstack.org/install-guide/environment.html)

# 3.使用packstack
packstack安装可以参考[官网](https://www.rdoproject.org/install/packstack/)

它可以在一台节点上模拟一个概念上的云,想很快尝试openstack是很快的.

在CentOS上:
```shell
$ sudo yum install -y centos-release-openstack-queens
$ sudo yum update -y
$ sudo yum install -y openstack-packstack
$ sudo packstack --allinone
```
最后一步需要的时间最长,其中下面是主要花的时间:
```shell
pplying 10.0.2.15_controller.pp
10.0.2.15_controller.pp:                             [ DONE ]      
Applying 10.0.2.15_network.pp
10.0.2.15_network.pp:                                [ DONE ]   
Applying 10.0.2.15_compute.pp
10.0.2.15_compute.pp:                                [ DONE ]   
Applying Puppet manifests                            [ DONE ]
Finalizing                                           [ DONE ]

 **** Installation completed successfully ******
```
其默认创建了2个用户:admin和demo,其密码在用户目录下:
```shell
[root@localhost ~]# ls key*
keystonerc_admin  keystonerc_demo

[root@localhost ~]# cat keystonerc_demo 
unset OS_SERVICE_TOKEN
export OS_USERNAME=demo
export OS_PASSWORD='6c43ac4dbcc141e3'
export PS1='[\u@\h \W(keystone_demo)]\$ '
export OS_AUTH_URL=http://10.0.2.15:5000/v3
    
export OS_PROJECT_NAME=demo
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_DOMAIN_NAME=Default
export OS_IDENTITY_API_VERSION=3
```
启动openstack只需在浏览器输入自己的ip/dashboard:
```shell
To access the OpenStack Dashboard browse to http://10.0.2.15/dashboard
```

如果重启了系统,只需要再运行上次的answer-file下的配置:
```shell
[root@localhost ~]# ls packstack*
packstack-answers-20180329-220625.txt

[root@localhost ~]# packstack --answer-file packstack-answers-20180329-220625.txt 
Welcome to the Packstack setup utility

The installation log file is available at: /var/tmp/packstack/20180330-004508-tneRpU/openstack-setup.log
...
```

使用demo用户登录然后可以创建一个实例试试:
{% asset_img 000.png %}

