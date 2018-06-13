---
title: 7.容器资源限制
tags:
  - docker
p: cloudcompute/013-docker-container-limit
---

{% asset_img 002.png %}

# 限制内存
参数解释:
1. --vm 1: 启动一个内存工作线程
2. --vm-bytes: 每个线程分配的内存
3. -m: 内存
4. --memory-swap: 内存 + 交换内存 (**若不指定,则默认为 -m 的2倍**)

```shell
root@jimo-VirtualBox:~# docker run -it -m 200M --memory-swap=300M progrium/stress --vm 1 --vm-bytes 180M
WARNING: Your kernel does not support swap limit capabilities or the cgroup is not mounted. Memory limited without swap.
stress: info: [1] dispatching hogs: 0 cpu, 0 io, 1 vm, 0 hdd
stress: dbug: [1] using backoff sleep of 3000us
stress: dbug: [1] --> hogvm worker 1 [5] forked
stress: dbug: [5] allocating 188743680 bytes ...
stress: dbug: [5] touching bytes in strides of 4096 bytes ...
stress: dbug: [5] freed 188743680 bytes
stress: dbug: [5] allocating 188743680 bytes ...
stress: dbug: [5] touching bytes in strides of 4096 bytes ...
```
可以看到我的内核不支持交换空间,所以上面的例子是小于内存的,会反复执行分配释放过程.

当大于200M内存,会卡死在那.

# 限制CPU

看他们之间的相对比例.
1. --cpu : 设置工作线程的数量
2. -c/--cpu-shares  : 设置使用CPU的资源.

```shell
root@jimo-VirtualBox:~# docker run --name container_A -it -c 1024 progrium/stress --cpu 1
stress: info: [1] dispatching hogs: 1 cpu, 0 io, 0 vm, 0 hdd
stress: dbug: [1] using backoff sleep of 3000us
stress: dbug: [1] --> hogcpu worker 1 [5] forked

root@jimo-VirtualBox:~# docker run --name container_B -it -c 512 progrium/stress --cpu 1
stress: info: [1] dispatching hogs: 1 cpu, 0 io, 0 vm, 0 hdd
stress: dbug: [1] using backoff sleep of 3000us
stress: dbug: [1] --> hogcpu worker 1 [5] forked
```
看以下CPU消耗

{% asset_img 001.png %}

然后暂停container_A
```shell
root@jimo-VirtualBox:/home/jimo# docker pause container_A
container_A
```
{% asset_img 000.png %}

# 限制IO
--blkio-weight 与 --cpu-shares 类似，设置的是相对权重值，默认为 500,大家都一样.

bps 是 byte per second，每秒读写的数据量。
iops 是 io per second，每秒 IO 的次数。

可通过以下参数控制容器的 bps 和 iops：
1. --device-read-bps，限制读某个设备的 bps。
2. --device-write-bps，限制写某个设备的 bps。
3. --device-read-iops，限制读某个设备的 iops。
4. --device-write-iops，限制写某个设备的 iops

```shell
root@jimo-VirtualBox:~# docker run -it --device-write-bps /dev/sda:30MB ubuntu
root@fa812ba7a517:/# time dd if=/dev/zero of=test.out bs=1M count=100 oflag=direct
100+0 records in
100+0 records out
104857600 bytes (105 MB, 100 MiB) copied, 4.41395 s, 23.8 MB/s

real	0m4.430s
user	0m0.067s
sys	0m0.015s
```
# 底层技术

1. 实现资源限制利用了cgroup(control group).
2. 资源隔离使用了namespace.

```shell
root@jimo-VirtualBox:~# docker run -it --cpu-shares 512 progrium/stress -c 1
stress: info: [1] dispatching hogs: 1 cpu, 0 io, 0 vm, 0 hdd
stress: dbug: [1] using backoff sleep of 3000us
stress: dbug: [1] --> hogcpu worker 1 [5] forked

root@jimo-VirtualBox:~# docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED              STATUS              PORTS               NAMES
fc631c15666d        progrium/stress     "/usr/bin/stress --v…"   About a minute ago   Up About a minute                       pensive_hamilton

root@jimo-VirtualBox:~# ls /sys/fs/cgroup/cpu/docker/fc631c15666de759766eaa8635ffac600b6bf015f5684797f37d8f941755de73/
cgroup.clone_children  cpuacct.stat   cpuacct.usage_all     cpuacct.usage_percpu_sys   cpuacct.usage_sys   cpu.cfs_period_us  cpu.shares  notify_on_release
cgroup.procs           cpuacct.usage  cpuacct.usage_percpu  cpuacct.usage_percpu_user  cpuacct.usage_user  cpu.cfs_quota_us   cpu.stat    tasks
```

详情见[博客](http://www.cnblogs.com/CloudMan6/p/7045784.html).

