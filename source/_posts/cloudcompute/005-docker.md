---
title: docker那些事-swarm
tags:
  - docker
p: cloudcompute/005-docker
date: 2018-04-05 08:01:31
---
docker那些事-swarm.

本文档来自[docker-swarm](https://docs.docker.com/get-started/part4/#deploy-the-app-on-the-swarm-manager)

# docker-swarm是什么

只需记住一点:**swarm里的manager才可以执行命令,worker只是为了扩容**.

# 创建虚拟机集群
1. 安装virtualbox
2. 安装docker-machine

```shell
docker-machine create --driver virtualbox myvm1
docker-machine create --driver virtualbox myvm2
```
会发现在用户目录下:
```shell
[jimo@jimo-pc machine]$ pwd
/home/jimo/.docker/machine
$ tree
.
├── cache
│   └── boot2docker.iso
├── certs
│   ├── ca-key.pem
│   ├── ca.pem
│   ├── cert.pem
│   └── key.pem
└── machines
    ├── myvm1
    │   ├── boot2docker.iso
    │   ├── ca.pem
    │   ├── cert.pem
    │   ├── config.json
    │   ├── disk.vmdk
    │   ├── id_rsa
    │   ├── id_rsa.pub
    │   ├── key.pem
    │   ├── myvm1
    │   │   ├── Logs
    │   │   │   └── VBox.log
    │   │   ├── myvm1.vbox
    │   │   └── myvm1.vbox-prev
    │   ├── server-key.pem
    │   └── server.pem
    └── myvm2
        ├── boot2docker.iso
        ├── config.json
        ├── disk.vmdk
        ├── id_rsa
        ├── id_rsa.pub
        └── myvm2
            ├── Logs
            │   └── VBox.log
            ├── myvm2.vbox
            └── myvm2.vbox-prev

9 directories, 26 files
```
# 查看IP
```shell
$ docker-machine ls
NAME    ACTIVE   DRIVER       STATE     URL                         SWARM   DOCKER        ERRORS
myvm1   -        virtualbox   Running   tcp://192.168.99.100:2376           v18.03.0-ce   
myvm2   -        virtualbox   Running   tcp://192.168.99.101:2376           v18.03.0-ce
```
# 初始化swarm并添加节点
初始化管理节点:
```shell
$ docker-machine ssh myvm1 "docker swarm init --advertise-addr 192.168.99.100:2377"
Swarm initialized: current node (h5djq52r65l5pdd7y9qgkf8t0) is now a manager.

To add a worker to this swarm, run the following command:

    docker swarm join --token SWMTKN-1-0s3thc4ypv4dzgc45npuod5qsj7bxsll69mqx5fluz63l9e5f2-9hzc6upuktak78i2flgz3ktxg 192.168.99.100:2377

To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.
```
将myvm2作为worker加入swarm:
```shell
$ docker-machine ssh myvm2 "docker swarm join --token \
> SWMTKN-1-0s3thc4ypv4dzgc45npuod5qsj7bxsll69mqx5fluz63l9e5f2-9hzc6upuktak78i2flgz3ktxg 192.168.99.100:2377 "
This node joined a swarm as a worker.
```
查看节点:
```shell
[jimo@jimo-pc services]$ docker-machine ssh myvm1 "docker node ls"
ID                            HOSTNAME            STATUS              AVAILABILITY        MANAGER STATUS      ENGINE VERSION
h5djq52r65l5pdd7y9qgkf8t0 *   myvm1               Ready               Active              Leader              18.03.0-ce
id4h8ujbzwbpne3j1txd6fcmj     myvm2               Ready               Active                                  18.03.0-ce
```
# 查看环境变量
```shell
$ docker-machine env myvm1
export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="tcp://192.168.99.100:2376"
export DOCKER_CERT_PATH="/home/jimo/.docker/machine/machines/myvm1"
export DOCKER_MACHINE_NAME="myvm1"
# Run this command to configure your shell: 
# eval $(docker-machine env myvm1)
```
确定当前活跃的是myvm1
```shell
$ eval $(docker-machine env myvm1)

$ docker-machine ls
NAME    ACTIVE   DRIVER       STATE     URL                         SWARM   DOCKER        ERRORS
myvm1   *        virtualbox   Running   tcp://192.168.99.100:2376           v18.03.0-ce   
myvm2   -        virtualbox   Running   tcp://192.168.99.101:2376           v18.03.0-ce  
```
# 部署本地APP到swarm
```shell
$ docker stack deploy -c docker-compose.yml getstartedlab
Creating network getstartedlab_webnet
Creating service getstartedlab_web
```
查看:
```shell
$ docker stack ps getstartedlab
ID                  NAME                  IMAGE                        NODE                DESIRED STATE       CURRENT STATE                  ERROR               PORTS
lu9e6l8grpdx        getstartedlab_web.1   jackpler/get-started:part1   myvm1               Running             Preparing about a minute ago                       
yhk1catbc1bw        getstartedlab_web.2   jackpler/get-started:part1   myvm2               Running             Preparing about a minute ago                       
55ci41l42fsw        getstartedlab_web.3   jackpler/get-started:part1   myvm2               Running             Preparing about a minute ago                       
ijnzkgub9t5l        getstartedlab_web.4   jackpler/get-started:part1   myvm1               Running             Preparing about a minute ago                       
o7c1c6rcp2ge        getstartedlab_web.5   jackpler/get-started:part1   myvm2               Running             Preparing about a minute ago                       
```
