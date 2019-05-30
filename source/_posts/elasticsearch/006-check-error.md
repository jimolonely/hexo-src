---
title: ES启动错误：max file descriptors/max virtual memory
tags:
  - elasticsearch
  - linux
p: elasticsearch/006-check-error
date: 2019-05-30 08:07:17
---

从ES启动报错里学习一些linux相关知识。

环境： ES 5.6.16， centos7， JDK8

# 错误

当我们修改了`network.host`配置的IP后，再次启动就会报错：

```java
ERROR: [2] bootstrap checks failed
[1]: max file descriptors [4096] for elasticsearch process is too low, increase to at least [65536]
[2]: max virtual memory areas vm.max_map_count [65530] is too low, increase to at least [262144]
```
接下来就需要弄清楚这几个参数什么意思。

# 参数含义

## max file descriptors

[关于文件描述符的解释](https://zh.wikipedia.org/wiki/%E6%96%87%E4%BB%B6%E6%8F%8F%E8%BF%B0%E7%AC%A6)很常见，简单来说就是： 
一个整数，描述符是文件元数据到文件本身的映射，可以用来引用文件，描述符是唯一的，可以在进程间共享。

每个进程都有个映射文件物理地址的表格（0标准输入 1标准输出 2标准错误；3、4、5....就映射你打开过文件的地址），FileDescriptor 相当于这个1、2、3、4.

那这个参数如何修改呢？

```java
# vim /etc/security/limits.conf 

# 添加下面设置 root 是用户

root soft nofile 65536
root hard nofile 65536
```

重新登录使其生效，然后通过ulimit查看下：
```
$ ulimit -n
65536
```

## max virtual memory areas vm.max_map_count

`max_map_count`： 文件包含限制一个进程可以拥有的VMA(虚拟内存区域)的数量。虚拟内存区域是一个连续的虚拟地址空间区域。在进程的生命周期中，每当程序尝试在内存中映射文件，链接到共享内存段，或者分配堆空间的时候，这些区域将被创建。调优这个值将限制进程可拥有VMA的数量。限制一个进程拥有VMA的总数可能导致应用程序出错，因为当进程达到了VMA上线但又只能释放少量的内存给其他的内核进程使用时，操作系统会抛出内存不足的错误。如果你的操作系统在NORMAL区域仅占用少量的内存，那么调低这个值可以帮助释放内存给内核用。

如何查看这个值？
```
$ sysctl -a | grep vm.max_map_count
vm.max_map_count = 65536
```
可以看到太小，那如何修改呢？

```java
vi /etc/sysctl.conf

// 添加下面配置：
vm.max_map_count=655360

// 并执行命令：
sysctl -p
```

# 延伸

## ulimit -a
查看所有限制：
```
$ ulimit -a
core file size          (blocks, -c) 0
data seg size           (kbytes, -d) unlimited
scheduling priority             (-e) 0
file size               (blocks, -f) unlimited
pending signals                 (-i) 63397
max locked memory       (kbytes, -l) 64
max memory size         (kbytes, -m) unlimited
open files                      (-n) 65536
pipe size            (512 bytes, -p) 8
POSIX message queues     (bytes, -q) 819200
real-time priority              (-r) 0
stack size              (kbytes, -s) 8192
cpu time               (seconds, -t) unlimited
max user processes              (-u) 4096
virtual memory          (kbytes, -v) unlimited
file locks                      (-x) unlimited
```

## sysctl -a
这是关于设备、文件系统、内核、网络、虚拟资源的所有系统配置，很多。

