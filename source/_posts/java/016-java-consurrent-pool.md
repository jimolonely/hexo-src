---
title: java并发-线程池
tags:
  - java
p: java/016-java-consurrent-pool
date: 2018-10-13 17:57:43
---

这一篇以ThreadPoolExecutor为例学习线程池。

# 基本概念
首先要知道线程池是什么，用来干什么。

## 解决什么问题
1. 提高多个异步任务的性能，减少每个任务的调用开销
2. 管理资源：线程资源，消耗的资源，基础统计数据（如运行完的线程数）

# ThreadPoolExecutor
这个类比较复杂，提供了很多可调的参数，可以构造丰富的线程池，适应不同场景。我们大可使用`Executors.newXXXThreadPool()`
这个工厂方法来创建线程池实例，那也是非常简单和初级的。现在我们会学习为什么这个类可以实现如此多的线程池类型。

接下来就是了解这些参数。
## core/max pool size
既然是个池子，肯定有容量把。这里有2个关于容量的参数：corePoolSize ，maximumPoolSize.

1. 运行的线程数 `< corePoolSize`: 直接创建新的线程来处理请求；
2. 运行的线程数介于corePoolSize和maximumPoolSize之间，只有当队列满了才会创建新线程；

当corePoolSize==maximumPoolSize时，就是FixedThreadPool了。

这两个参数的设置：
1. 构造方法
2. `setCorePoolSize(int) 和 setMaximumPoolSize(int)` 动态修改

## keep-alive time
当前线程数大于corePoolSize时，为了节省资源，空闲（Idle）的线程会在超过 `keepAliveTime`参数设定的时间后被终止。

设置这个值也可以动静结合：
1. 构造方法
2. `setKeepAliveTime(long, TimeUnit)`

如果` allowCoreThreadTimeOut(true)`方法被调用，则当线程数小于corePoolSize时也可以终止，默认是false的。
## 队列
这个队列是用来存储线程的，会在以下情况用到：
1. 线程数 < corePoolSize,直接创建新线程，不使用队列；
2. 线程数介于corePoolSize和maximumPoolSize之间，优先缓存到队列中；
3. 队列满了，则再创建线程，直到线程数达到maxmimumPoolSize, 后面再有线程就会被拒绝。

ThreadPoolExecutor使用的是`BlockingQueue`队列，排队也有排队的策略，排队论就不说了，下面是这里几种策略：

1. 
