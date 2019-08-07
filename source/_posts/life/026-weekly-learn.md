---
title: 2019-32-周报
tags:
  - life
  - week
p: life/026-weekly-learn
date: 2019-08-05 20:09:29
---

这是2019年第32周周报.

1. 看面试题学习：范围为JVM、多线程、kafka、redis、spring

类加载机制：

- 加载(玩出了花样-jar，war，zip)
- 验证（安全，VerifyError，格式、元数据、字节码、符号引用（找不到方法或类）-Xverify:none）
- 准备: 设置初值
- 解析：符号引用替换为直接引用（类、接口、字段、方法），找不到依然报错
- 初始化：执行构造器、static块
- 使用
- 卸载

-XX:+TraceClassLoading

类加载器：

- 启动类
- 扩展类
- 应用程序类
- 自定义类加载器

双亲委派模型：优先父类加载器（组合形式）加载，找不到才子类，why？因为和jdk重名就混乱了





