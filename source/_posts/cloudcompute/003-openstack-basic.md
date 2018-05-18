---
title: openstack基础
tags:
  - openstack
  - 云计算
p: cloudcompute/003-openstack-basic
date: 2018-03-30 15:45:45
---
这是我学习openstack的路径.

# 安装openstack
参考

# 基础术语
User
Credentials
Authentication
Token
Tenant
Service
Endpoint
Role
# 架构
{% asset_img 000.png %}

# 网络结构
每个节点有3张网卡,一个用于内网,一个外网,一个心跳.

# 学会如何使用openstack
装好了,也有了基本概念,最快上手的方式就是使用起来.
根据[官网](https://docs.openstack.org/mitaka/user-guide/intro-user.html)介绍,使用的方式可多了.

Horizon界面,CLI,python SDK等等.

# 学会使用Horizon界面
创建实例,配置网络等.
[文档](https://docs.openstack.org/mitaka/user-guide/dashboard.html).

# 使用命令行
```shell
[root@localhost ~]# source keystonerc_demo 
[root@localhost ~(keystone_demo)]# nova list
+--------------------------------------+---------+---------+------------+-------------+------------------+
| ID                                   | Name    | Status  | Task State | Power State | Networks         |
+--------------------------------------+---------+---------+------------+-------------+------------------+
| 19498801-c774-4297-8a75-bff9c2503c5e | cissor1 | SHUTOFF | -          | Shutdown    | private=10.0.0.7 |
+--------------------------------------+---------+---------+------------+-------------+------------------+
```
常用命令参考[文档](https://docs.openstack.org/mitaka/user-guide/cli_cheat_sheet.html)

通过debug标志可以看到整个API的请求过程:
```shell
[root@localhost ~(keystone_demo)]# nova --debug list
...
REQ: curl -g -i -X GET http://10.0.2.15:8774/v2.1/ab4c85f86cc04230894ba9eaa0c412e4/servers/detail -H "OpenStack-API-Version: compute 2.53" -H "User-Agent: python-novaclient" -H "Accept: application/json" -H "X-OpenStack-Nova-API-Version: 2.53" -H "X-Auth-Token: {SHA1}a6994f0daf077433ede7e26fd93007a12472e7e5"
DEBUG (connectionpool:395) http://10.0.2.15:8774 "GET /v2.1/ab4c85f86cc04230894ba9eaa0c412e4/servers/detail HTTP/1.1" 200 1443
DEBUG (session:419) RESP: [200] Content-Length: 1443 Content-Type: application/json Openstack-Api-Version: compute 2.53 X-Openstack-Nova-Api-Version: 2.53 Vary: OpenStack-API-Version, X-OpenStack-Nova-API-Version X-Openstack-Request-Id: req-050308b9-3752-44e8-80ab-01c5e8468000 X-Compute-Request-Id: req-050308b9-3752-44e8-80ab-01c5e8468000 Date: Fri, 30 Mar 2018 08:33:39 GMT Connection: keep-alive 
RESP BODY: {"servers": [{"OS-EXT-STS:task_state": null, "addresses": {"private": [{"OS-EXT-IPS-MAC:mac_addr": "fa:16:3e:7d:96:7e", "version": 4, "addr": "10.0.0.7", "OS-EXT-IPS:type": "fixed"}]}, "links": [{"href": "http://10.0.2.15:8774/v2.1/ab4c85f86cc04230894ba9eaa0c412e4/servers/19498801-c774-4297-8a75-bff9c2503c5e", "rel": "self"}, {"href": "http://10.0.2.15:8774/ab4c85f86cc04230894ba9eaa0c412e4/servers/19498801-c774-4297-8a75-bff9c2503c5e", "rel": "bookmark"}], "image": "", "OS-EXT-STS:vm_state": "stopped", "OS-SRV-USG:launched_at": "2018-03-30T03:05:47.000000", "flavor": {"ephemeral": 0, "ram": 512, "original_name": "m1.tiny", "vcpus": 1, "extra_specs": {}, "swap": 0, "disk": 1}, "id": "19498801-c774-4297-8a75-bff9c2503c5e", "security_groups": [{"name": "default"}], "OS-SRV-USG:terminated_at": null, "user_id": "d069531f171b422289a106e106572aa7", "OS-DCF:diskConfig": "AUTO", "accessIPv4": "", "accessIPv6": "", "OS-EXT-STS:power_state": 4, "OS-EXT-AZ:availability_zone": "nova", "config_drive": "", "status": "SHUTOFF", "updated": "2018-03-30T03:10:19Z", "hostId": "a6480a085edf3a7b6698b4f6972bf20fba65501c4dbaeae382d274f0", "description": null, "tags": [], "key_name": null, "locked": false, "name": "cissor1", "created": "2018-03-30T03:05:04Z", "tenant_id": "ab4c85f86cc04230894ba9eaa0c412e4", "os-extended-volumes:volumes_attached": [{"id": "9736b299-0d18-4389-a7e9-67c864023a9e", "delete_on_termination": false}], "metadata": {}}]}
```

更多[官方文档](https://docs.openstack.org/mitaka/user-guide/cli.html)

