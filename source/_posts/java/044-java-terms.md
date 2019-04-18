---
title: 那些java技术和术语解释
tags:
  - java
  - term
p: java/044-java-terms
date: 2019-04-18 10:54:29
---

有一些英文缩写，这里是与java相关的。

# JDK/JRE

# javax vs java包

[来源](https://stackoverflow.com/questions/727844/javax-vs-java-package)

最初javax包下的库旨在用于扩展，有时候做得好的会从javax升级到java。

一个问题是Netscape（可能还有IE）限制了可能在java包中的类。

当Swing被设置为从javax“升级”到java时，有一阵小小的骚动，因为人们意识到他们必须修改他们的所有接口。 鉴于向后兼容性是Java的主要目标之一，他们改变了主意。

在那个时间点，至少对于社区（可能不是对于Sun而言），javax的全部内容都已丢失。 所以现在我们在javax中有一些东西可能应该在java中......但除了选择包名的人之外，我不知道是否有人可以根据具体情况弄清楚原理是什么。

# TM
```java
$ java -version
java version "1.8.0_181"
Java(TM) SE Runtime Environment (build 1.8.0_181-b13)
Java HotSpot(TM) 64-Bit Server VM (build 25.181-b13, mixed mode)
```
TM: trade mark(商标)

# JCP

[Java Community Process](https://www.jcp.org/en/home/index):
> JCP建立于1998年，是为Java技术开发标准技术规范机构。 任何人都可以注册该站点并参与审阅和提供Java规范请求（JSR）的反馈，任何人都可以注册成为JCP成员，然后参与JSR的专家组，甚至提交他们自己的JSR提案。

# JSR
Java Specification Requests（Java规范请求），由JCP成员向委员会提交的Java发展议案，经过一系列流程后，如果通过最终会体现在未来的Java中。

最终的JSR提供了一个参考实现，它是源代码形式的技术的免费实现，以及用于验证API规范的技术兼容性工具包

# TCK
Technology Compatibility Kit，技术兼容性测试 。如果一个平台型程序想要宣称自己兼容Java，就必须通过TCK测试

# JEP
[JDK Enhancement Proposal(JDK增强提议)](https://openjdk.java.net/jeps/0):
> OpenJDK社区用于收集JDK增强功能的提议的过程.

# JAX-RS
[Java API for RESTful Web Services](https://github.com/jax-rs), [参考wiki](https://zh.wikipedia.org/wiki/JAX-RS).

> Java EE 6 引入了对 JSR-311 的支持。JSR-311（JAX-RS：Java API for RESTful Web Services）旨在定义一个统一的规范，使得 Java 程序员可以使用一套固定的接口来开发 REST 应用，避免了依赖于第三方框架。同时，JAX-RS 使用 POJO 编程模型和基于标注的配置，并集成了 JAXB，从而可以有效缩短 REST 应用的开发周期。

JAX-RS 定义的 API 位于 `javax.ws.rs（猜测ws是webservice的缩写）` 包中. [参考](https://www.ibm.com/developerworks/cn/java/j-lo-jaxrs/index.html)

JAX-RS 的具体实现由第三方提供，例如 Sun 的参考实现 [Jersey](https://jersey.github.io/)、Apache 的 CXF 以及 JBoss 的 RESTEasy。

[关于Jersey请参考入门指导](https://jersey.github.io/documentation/latest/getting-started.html)

# 


```java
$ java -version

```
```java
$ java -version

```
```java
$ java -version

```
```java
$ java -version

```
```java

```



