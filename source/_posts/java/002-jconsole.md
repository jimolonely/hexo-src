---
title: java调优工具jconsole
tags:
  - java
p: java/002-jconsole
date: 2018-07-01 13:51:55
---

对java应用的监控必不可少．

# 位置
windows位于　java/bin/jconsole.exe

linux一般已加入环境变量．

输入jconsole启动．

{% asset_img 000.png %}

# 功能
有关内存，线程，类，ＶＭ等．

内存的分区有显示，可清楚看到．

{% asset_img 001.png %}

线程的数量和每个线程的堆栈跟踪以及死锁检测．

{% asset_img 002.png %}

加载的类数量．

{% asset_img 003.png %}

VM概要，重点是VM参数．

{% asset_img 004.png %}

这只是一个开始，可以通过实践观察垃圾如何回收．
