---
title: spring无法注入依赖库中的bean
tags:
  - java
  - spring
p: java/049-spring-autowire-in-dependency
date: 2019-07-17 16:18:24
---

记一次依赖注入的小问题。

# 问题描述

在一个多模块工程中，A引用了内部封装的B。

B封装了一些redis的缓存操作。

但是A启动时无法注入B中的redis Bean。

在B中单独测试没问题。

# 原因
spring boot的自动扫描没有将B中的类纳入，导致找不到实现。

# 解决
手动增加扫描：

```java
@ComponentScan(basePackageClasses = {RedisServiceImpl.class})
```

参考：[https://stackoverflow.com/questions/30796306/cant-i-autowire-a-bean-which-is-present-in-a-dependent-library-jar](https://stackoverflow.com/questions/30796306/cant-i-autowire-a-bean-which-is-present-in-a-dependent-library-jar)

