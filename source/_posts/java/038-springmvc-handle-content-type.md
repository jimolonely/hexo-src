---
title: springmvc如何处理content-type源码解析
tags:
  - java
  - spring
p: java/038-springmvc-handle-content-type
date: 2019-03-25 12:29:42
---

核心类：
HttpMessageConverter里定义的处理参数和处理返回值接口：
它的实现类就是处理各种格式到java类之间的相互转化实现。

AbstractMessageConverterMethodProcessor:
使用HttpMessageConverter的实现处理方法参数和返回值。

处理注解了@RequestBody, @ResponseBody的参数和返回值：
RequestResponseBodyMethodProcessor


参考： 
1. [Spring源码学习之十一：SpringMVC-@RequestBody接收json数据报415](https://juejin.im/post/59e87d566fb9a04509089d65)
2. [SpringMVC源码(六)-@RequestBody和@ResponseBody](https://my.oschina.net/u/2377110/blog/1552979)


