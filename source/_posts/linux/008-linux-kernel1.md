---
title: Linux内核
tags:
  - linux
  - linux kernel
p: linux/008-linux-kernel1
date: 2018-04-27 14:56:37
---

# 1.常识
### 1.1 背景
1. Unix的历史
2. Linux的历史
3. Linux和Unix比较
4. Linux内核版本开发的版本号规则

### 1.2 准备
1. 使用git跟随源码
2. 安装源码,打补丁,了解源码文件结构
3. 配置,编译,安装内核
4. 内核开发的特点
  1. 内核开发不能使用任何外部库,比如C库.
  2. GNU C
  3. 无内存保护机制
  4. 难以执行浮点运算
  5. 进程堆栈小
  6. 同步并发
  7. 考虑移植性

# 2.进程
### 2.1 进程是什么
正在执行的程序代码的实时结果.线程是特殊的进程,每个线程都有独立的PC,进程栈和进程寄存器.
### 2.2 进程描述符
1. 双向循环链表
2. 进程描述符:存在放栈顶或栈底,或者不同的架构使用专门的寄存器.
3. 进程的5种状态:就绪,运行,阻塞/不可中断,跟踪,停止
4. 进程上下文
5. 进程家族树:PID=1的init根进程

系统最大进程数配置,理论可达几百万:
```shell
$ cat /proc/sys/kernel/pid_max
32768
```
### 2.3 进程创建
1. fork() + exec()
2. Copy-on-write: 只有在写入时才复制,在之前子进程和父进程共享空间.
3. fork(),vfork()

### 2.4 linux中的线程
1. 就是进程,只是和进程共享资源
2. 创建线程: clone(指定共享的资源)
3. 内核线程:只运行在内核空间的线程,kthread

### 2.5 进程终结
1. 删除进程描述符
2. 孤儿(僵死)进程的寻父之旅.

# 3.进程调度

### 3.1 多任务类型
1. 抢占式多任务
2. 非抢占式

UNIX采用抢占式.

### 3.2 Linux的进程调度
O(1) => CFS(完全公平的调度)

### 3.3 进程类型
1. IO密集型(硬盘,网络,界面交互)
2. CPU密集型(计算)
3. 2者的混合

linux偏向于交互式应用.
### 3.4 进程优先级
1. nice值: -19到20,越大越低,默认为0.
```shell
# 注意NI值
$ ps -el
F S   UID   PID  PPID  C PRI  NI ADDR SZ WCHAN  TTY          TIME CMD
4 S     0     1     0  0  80   0 - 56804 -      ?        00:00:15 systemd
1 S     0     2     0  0  80   0 -     0 -      ?        00:00:00 kthreadd
1 S     0     3     2  0  80   0 -     0 -      ?        00:00:04 ksoftirqd/0
1 S     0     5     2  0  60 -20 -     0 -      ?        00:00:00 kworker/0:0H
1 S     0     7     2  0  80   0 -     0 -      ?        00:01:24 rcu_preempt
1 S     0    10     2  0 -40   - -     0 -      ?        00:00:00 migration/0
1 S     0    11     2  0  60 -20 -     0 -      ?        00:00:00 lru-add-drain
5 S     0    12     2  0 -40   - -     0 -      ?        00:00:00 watchdog/0
1 S     0    17     2  0  80   0 -     0 -      ?        00:00:01 ksoftirqd/1
1 S     0    19     2  0  60 -20 -     0 -      ?        00:00:00 kworker/1:0H
1 S     0    20     2  0  80   0 -     0 -      ?        00:00:00 cpuhp/2
```
2. 实时优先级:0-99,可配置,越大越高,高于任何普通进程优先级,"-"表示不是实时进程:
```shell
$ ps -eo state,uid,pid,ppid,rtprio,time,comm
S   UID   PID  PPID RTPRIO     TIME COMMAND
S     0     1     0      - 00:00:15 systemd
S     0     8     2      - 00:00:00 rcu_sched
S     0     9     2      - 00:00:00 rcu_bh
S     0    10     2     99 00:00:00 migration/0
S     0    11     2      - 00:00:00 lru-add-drain
S     0    12     2     99 00:00:00 watchdog/0
S     0    13     2      - 00:00:00 cpuhp/0
S     0    14     2      - 00:00:00 cpuhp/1
S     0    26     2      - 00:00:00 cpuhp/3
S     0    27     2     99 00:00:00 watchdog/3
S     0    28     2     99 00:00:00 migration/3
S     0   239     2     50 00:02:22 irq/279-iwlwifi
S     0   318     2     50 00:02:36 irq/51-DLLA6B2:
```
### 3.4 时间片
1. 太长或太短都不好
2. IO密集型希望短,CPU密集型希望长
3. Linux直接分配时间片到进程,这个进程获得的时间受系统负载和nice值的共同影响.
