---
title: 如何解决问题
tags:
  - java
p: java/024-java-fix-problem
date: 2019-01-28 14:13:31
---

今天遇到一个简单的问题： nacos + springcloud
环境搭好后，spring-cloud项目启动，打了一条日志就退出了，而这条日志还是个INFO级别的，

让我很是困扰， 于是思考应该怎么解决，于是采用普遍思维：debug。

从那条日志的类开始打断点，经过十几个类，终于找到错误原因： 找不到一个类。

再一查，发现来自guava包，然后明白是版本冲突了，nacos使用的19.0版本被spring-cloud的12.0覆盖了，于是找不到类。

但编译时没报错，运行时报错了。

这也算一个经验把，于是查找IDEA下maven依赖包的有用工具，
比如下面这个：

[maven helper](https://blog.csdn.net/sunpeng_sp/article/details/77393348)

虽然idea自带了查看依赖图，但真的太多包时根本看不过来。




