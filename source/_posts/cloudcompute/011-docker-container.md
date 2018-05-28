---
title: 5.docker container run
tags:
  - docker
p: cloudcompute/011-docker-container
---
容器的运行,进入与分类.
{% asset_img 000.png %}

# 一闪而过运行容器
```shell
root@jimo-VirtualBox:~# docker run ubuntu pwd
/
root@jimo-VirtualBox:~#
```
查看容器运行状态:发现并没运行,而是一闪而过.
```shell
root@jimo-VirtualBox:~# docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES

root@jimo-VirtualBox:~# docker container ls -a
CONTAINER ID        IMAGE               COMMAND                  CREATED              STATUS                          PORTS               NAMES
524c62fc3f68        ubuntu              "pwd"                    About a minute ago   Exited (0) About a minute ago                       pensive_khorana
```
# 长时间运行容器
因为容器的生命周期依赖于启动时执行的命令，只要该命令不结束，容器也就不会退出。
理解了这个原理，我们就可以通过执行一个长期运行的命令来保持容器的运行状态:
```shell
root@jimo-VirtualBox:/home/jimo# docker run ubuntu /bin/bash -c "while true ; do sleep 1; done"

# 另一终端
root@jimo-VirtualBox:~# docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED              STATUS              PORTS               NAMES
549aa9db3954        ubuntu              "/bin/bash -c 'while…"   36 seconds ago       Up 34 seconds                           elastic_cray
```
-d参数: 后台运行.
--name : 指定名字,不指定会随机分配.
如下:
```shell
root@jimo-VirtualBox:~# docker run --name "my-http-server" -d httpd
5faa46b16ea9437f7230cb6c276014640e7cc73b661341fbe38305d3effbaebd
root@jimo-VirtualBox:~# docker ps
CONTAINER ID        IMAGE               COMMAND              CREATED             STATUS              PORTS               NAMES
5faa46b16ea9        httpd               "httpd-foreground"   5 seconds ago       Up 4 seconds        80/tcp              my-http-server
```
通过history可看到是通过CMD执行的:
```shell
root@jimo-VirtualBox:~# docker history httpd
IMAGE               CREATED             CREATED BY                                      SIZE                COMMENT
fb2f3851a971        3 weeks ago         /bin/sh -c #(nop)  CMD ["httpd-foreground"]     0B               
```
# 停止容器
```shell
root@jimo-VirtualBox:~# docker stop 549aa9db3954
549aa9db3954
```
# 进入容器

1. attach方式:
```shell
root@jimo-VirtualBox:~# docker run -d -it ubuntu /bin/bash -c "while true;do sleep 2;echo In_container;done"
bdd94e3338fbfebdc2f2b679773f1755796bfee9f3d3da48e765977b311bf0cb

# 可通过 Ctrl+p 然后 Ctrl+q 组合键退出 attach 终端,但启动时要加-it
root@jimo-VirtualBox:~# docker attach bdd94e3338fbfebdc2f2b679773f1755796bfee9f3d3da48e765977b311bf0cb
In_container
In_container
read escape sequence
```
2. exec方式: docker exec -it ID bash|sh
```shell
root@jimo-VirtualBox:~# docker exec -it bdd94e3338fb bash
root@bdd94e3338fb:/# ps -elf
F S UID        PID  PPID  C PRI  NI ADDR SZ WCHAN  STIME TTY          TIME CMD
4 S root         1     0  0  80   0 -  4594 wait   06:34 pts/0    00:00:00 /bin/
4 S root        80     0  0  80   0 -  4627 wait   06:37 pts/1    00:00:00 bash
0 S root        93     1  0  80   0 -  1133 hrtime 06:37 pts/0    00:00:00 sleep
4 R root        94    80  0  80   0 -  8600 -      06:37 pts/1    00:00:00 ps -e
root@bdd94e3338fb:/# exit
exit
root@jimo-VirtualBox:~#
```
3. exec VS attach
```shell
1. attach 直接进入容器 启动命令 的终端，不会启动新的进程。
2. exec 则是在容器中打开新的终端，并且可以启动新的进程。
3. 如果想直接在终端中查看启动命令的输出，用 attach；其他情况使用 exec。
```
4. 如果只是为了查看启动命令的输出，可以使用 docker logs 命令,-f会连续打印输出
```shell
root@jimo-VirtualBox:~# docker logs -f bdd94e3338fb
In_container
In_container
In_container
In_container
...
```

# 容器分类
1. 服务类容器以 daemon 的形式运行，对外提供服务。比如 web server，数据库等。通过 -d 以后台方式启动这类容器是非常合适的。如果要排查问题，可以通过 exec -it 进入容器。
2. 工具类容器通常给能我们提供一个临时的工作环境，通常以 run -it 方式运行,如:
```shell
root@jimo-VirtualBox:~# docker run -it busybox
/ # wget www.baidu.com
Connecting to www.baidu.com (61.135.169.121:80)
index.html           100% |**************************************************************************************************************************************************************|  2381   0:00:00 ETA
/ # exit
```
# 指定容器的方式
1. 短ID。
2. 长ID。
3. 容器名称。 可通过 --name 为容器命名。重命名容器可执行docker rename。
