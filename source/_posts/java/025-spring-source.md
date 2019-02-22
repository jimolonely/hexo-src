---
title: spring源码学习（一）
tags:
  - java
  - spring
p: java/025-spring-source
date: 2019-02-21 11:27:42
---

终于到了这一步，曾经无数次想过，没想到来得如此平缓。只要还在学习，就还在路上，就永远不晚。

# IOC理解

## 1.理解概念
[Ioc和DI概念的理解](https://jinnianshilongnian.iteye.com/blog/1413846).

然后问自己那几个问题：
1. Ioc是什么，控制了什么，谁控制谁，反转了什么，谁反转谁
2. DI是什么，谁依赖谁，依赖了什么，为什么依赖，谁注入了什么，给谁注入
3. Ioc和DI的关系

## 2.学习源码
[Spring源码剖析——核心IOC容器原理](https://blog.csdn.net/lisongjia123/article/details/52129340)

## 3.自己实现

可以参考博客：[blog1](https://segmentfault.com/a/1190000013130650), [blog2](https://www.jianshu.com/p/72aeb5d94360)

在此之前，需要熟悉java通过反射创建对象的方式： {% post_link 026-java-create-instance  java创建对象的方式和差别 %}


// TODO

# springmvc
从理解到实现。

传统的基于servlet的spring和spring5+里面的基于reactive stream的东西，都需要熟悉。

## 1.流程理解
盗一下下面博客的图：

{% asset_img 000.png %}

{% asset_img 001.png %}


## 2.实现一个
[自己手写一个SpringMVC框架(简化)](https://my.oschina.net/liughDevelop/blog/1622646)

