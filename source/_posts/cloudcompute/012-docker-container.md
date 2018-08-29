---
title: 6.容器的使用
tags:
  - docker
p: cloudcompute/012-docker-container
date: 2018-08-05 13:51:55
---

{% asset_img 000.png %}

# 暂停
比如打个快照之类的. **注意看下面的状态**
```shell
root@jimo-VirtualBox:~# docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
3ecd69d08416        ubuntu              "/bin/bash"         45 seconds ago      Up 44 seconds                           confident_kalam
root@jimo-VirtualBox:~# docker pause confident_kalam
confident_kalam
root@jimo-VirtualBox:~# docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS                  PORTS               NAMES
3ecd69d08416        ubuntu              "/bin/bash"         8 minutes ago       Up 8 minutes (Paused)                       confident_kalam

root@jimo-VirtualBox:~# docker unpause confident_kalam
confident_kalam
root@jimo-VirtualBox:~# docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
3ecd69d08416        ubuntu              "/bin/bash"         8 minutes ago       Up 8 minutes                            confident_kalam
```

# 删除镜像
退出的容器依然会占用空间,所以可以删除.
```shell
root@jimo-VirtualBox:~# docker ps -a
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS                      PORTS               NAMES
3ecd69d08416        ubuntu              "/bin/bash"              15 minutes ago      Up 15 minutes                                   confident_kalam
cfb902a91605        ubuntu              "/bin/bash"              18 minutes ago      Exited (0) 18 minutes ago                       hungry_bell
ee2a6312fbe5        my-image            "sh"                     18 minutes ago      Exited (0) 18 minutes ago                       cocky_payne
ffac6be3da49        busybox             "sh"                     13 days ago         Exited (0) 13 days ago                          zen_leavitt
bdd94e3338fb        ubuntu              "/bin/bash -c 'while…"   13 days ago         Exited (137) 13 days ago                        gifted_hopper
b4027dadae2a        ubuntu              "/bin/bash -c 'while…"   13 days ago         Exited (137) 13 days ago                        eager_easley
5faa46b16ea9        httpd               "httpd-foreground"       13 days ago         Exited (0) 13 days ago                          my-http-server
549aa9db3954        ubuntu              "/bin/bash -c 'while…"   13 days ago         Exited (137) 13 days ago                        elastic_cray
16858e7ee65c        ubuntu              "/bin/bash -c 'while…"   13 days ago         Exited (137) 13 days ago                        clever_murdock
a67b81d3ff90        ubuntu              "/bin/bash -c 'echo …"   13 days ago         Exited (0) 13 days ago                          xenodochial_elbakyan
21f6607ec8dc        ubuntu              "/bin/bash -c 'while…"   13 days ago         Exited (137) 13 days ago                        eager_perlman
e34dcec1bd64        ubuntu              "/bin/basg -c 'while…"   13 days ago         Created                                         happy_hugle
524c62fc3f68        ubuntu              "pwd"                    13 days ago         Exited (0) 13 days ago                          pensive_khorana
80f81f33ed15        registry:latest     "/entrypoint.sh /etc…"   2 weeks ago         Exited (2) 2 weeks ago                          agitated_clarke
06d0403206f8        registry:latest     "/entrypoint.sh /etc…"   2 weeks ago         Created                                         mystifying_hawking
0fe657284887        my-image            "sh"                     2 weeks ago         Exited (0) 2 weeks ago                          determined_boyd
e7bac1b935b3        2d8187e6451a        "sh"                     2 weeks ago         Exited (127) 2 weeks ago                        unruffled_keldysh
3e9f5c9eae7c        2d8187e6451a        "/bin/sh -c '/bin/ba…"   2 weeks ago         Exited (127) 2 weeks ago                        laughing_mendeleev
4a12c1ec8971        ubuntu              "/bin/bash"              2 weeks ago         Exited (127) 2 weeks ago                        eager_austin
2eda339fa711        hello-world         "/hello"                 2 weeks ago         Exited (0) 2 weeks ago                          practical_shaw
01fa717064e8        httpd               "httpd-foreground"       2 weeks ago         Exited (0) 2 weeks ago                          hardcore_lewin
36ee204c603c        httpd               "httpd-foreground"       2 weeks ago         Created                                         eloquent_turing

root@jimo-VirtualBox:~# docker rm 36ee204c603c 01fa717064e8
36ee204c603c
01fa717064e8

root@jimo-VirtualBox:~# docker ps -aq -f status=exited
cfb902a91605
ee2a6312fbe5
ffac6be3da49
bdd94e3338fb
b4027dadae2a
5faa46b16ea9
549aa9db3954
16858e7ee65c
a67b81d3ff90
21f6607ec8dc
524c62fc3f68
80f81f33ed15
0fe657284887
e7bac1b935b3
3e9f5c9eae7c
4a12c1ec8971
2eda339fa711

root@jimo-VirtualBox:~# docker rm -v $(docker ps -aq -f status=exited)
cfb902a91605
ee2a6312fbe5
ffac6be3da49
bdd94e3338fb
b4027dadae2a
5faa46b16ea9
549aa9db3954
16858e7ee65c
a67b81d3ff90
21f6607ec8dc
524c62fc3f68
80f81f33ed15
0fe657284887
e7bac1b935b3
3e9f5c9eae7c
4a12c1ec8971
2eda339fa711

root@jimo-VirtualBox:~# docker ps -a
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS               NAMES
3ecd69d08416        ubuntu              "/bin/bash"              17 minutes ago      Up 17 minutes                           confident_kalam
e34dcec1bd64        ubuntu              "/bin/basg -c 'while…"   13 days ago         Created                                 happy_hugle
06d0403206f8        registry:latest     "/entrypoint.sh /etc…"   2 weeks ago         Created                                 mystifying_hawking
root@jimo-VirtualBox:~#
```

# 总结
一张图理解.内容来自[blog](http://www.cnblogs.com/CloudMan6/p/6961665.html)

{% asset_img 001.jpg %}

**注意以下几点:**
1. 状态的几种变换
2. docker run = docker create + docker start
3. --restart 只在容器进程退出时才有效.

