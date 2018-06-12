---
title: 7.容器资源限制
tags:
  - docker
p: cloudcompute/013-docker-container-limit
---



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

