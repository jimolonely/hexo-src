---
title: JWT在不同库中的实现差异问题
tags:
  - java
  - python
  - jwt
p: basic/022-jwt-pro-between-different-lib
date: 2019-09-28 16:49:31
---

今天需要跨系统验证JWT时发现验证不通过：

A（java，采用[jjwt](https://github.com/jwtk/jjwt/issues?utf8=%E2%9C%93&q=secret+base64)生成）

B（python，采用[python-jose](https://github.com/mpdavis/python-jose/)生成）

同样的secret key，但是相互验证通不过。

原因：base64编码，jjwt编码的方式不一样。

解决办法：换一个java jwt库：[auth0/java-jwt](https://github.com/auth0/java-jwt)

这下就通过了，其实js也有问题，jjwt和[官网](https://jwt.io/)的结果也有区别。


