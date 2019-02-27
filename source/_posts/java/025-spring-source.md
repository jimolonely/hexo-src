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

在此之前，需要熟悉java通过反射创建对象的方式： {% post_link java/026-java-create-instance  java创建对象的方式和差别 %}


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

# AOP

aop是什么： 可以看作对OOP的一种扩展，目标是在扩展或增加新功能时解藕和，提高代码的可用性和灵活性。

aop可以做什么： 日志、性能、安全、事务、异常等。

[Java 面向切面编程（Aspect Oriented Programming，AOP）---推荐，写的不错](https://www.cnblogs.com/liuning8023/p/4343957.html)

## 1.原理理解

[AOP的底层实现-CGLIB动态代理和JDK动态代理](https://blog.csdn.net/dreamrealised/article/details/12885739)

{% post_link java/027-cglib 关于CGLib的原理 %}

学习了原理之后问自己以下问题，直到能快速回答出来为止：
1. AOP是一种模式，与OOP的区别是什么
2. AOP要解决什么问题，常见的有哪些
3. AOP中间有哪些概念，解释切面、切点、连接点、通知等概念以及他们的关系
4. spring的AOP是怎么实现的，2种实现的区别和优缺点？

## 2.spring AOP如何使用

关于使用，推荐几篇博客，写的很仔细：
1. [Spring AOP 实战](https://segmentfault.com/a/1190000007469982)
2. [基于注解的Spring AOP的配置和使用--转载](https://www.cnblogs.com/davidwang456/p/4013631.html)

学习完使用后问自己以下问题：
1. 实现AOP涉及的注解： `@Aspect, @PointCut`如何使用？
2. 切点的书写规则, 可以是某个包、类、方法、带有某个注解等
3. 通知的5种类型的含义和执行顺序：`@Before, @Around, @After, @AfterReturning, @AfterThrowing`


## 2.实现AOP

[Spring系列之AOP的原理及手动实现](https://juejin.im/post/5c1c402b6fb9a049a570df27), 这篇文章介绍了aop涉及的设计模式。

[他的源码实现](https://github.com/lliyu/myspring/tree/master/src/main/java/aop)

跟着做一遍。

# spring事务机制

## 如何使用
参考文章：[透彻的掌握 Spring 中@transactional 的使用](https://www.ibm.com/developerworks/cn/java/j-master-spring-transactional-use/index.html)

然后问自己：
1. `@Transactional` 注解有哪些属性，分别代表什么意思？
2. `propagation`属性的3个级别什么意思？
3. `rollbackFor`在什么情况下不会回滚？
4. 只有public方法才有效吗？
5. spring AOP的自调用问题： 非事务方法调用事务方法不会回滚

## 再深入一点
参考文章： [可能是最漂亮的Spring事务管理详解](https://juejin.im/post/5b00c52ef265da0b95276091)

