---
title: 源码解读spring-boot加载配置文件的顺序
tags:
  - java
  - spring-boot
p: java/040-spring-boot-load-properties-order-by-source-code
date: 2019-03-26 19:28:47
---

本文从源码解读spring-boot加载配置文件（application.properties,application.yml）的顺序。

# 一个坑点
[网上基本上都是这样说的](https://blog.csdn.net/wohaqiyi/article/details/79940380)：
```
第一种是在jar包的同一目录下建一个config文件夹，然后把配置文件放到这个文件夹下。
第二种是直接把配置文件放到jar包的同级目录。
第三种在classpath下建一个config文件夹，然后把配置文件放进去。
第四种是在classpath下直接放配置文件。
```
但是，如果你有多个版本的配置文件（application-dev.yml, application-prod.yml），且运行时命令行指定了`--spring.profiles.active=prod`,
那么你在jar包同一目录声明想要覆盖jar内部配置的新配置文件`application.yml`是不行的。

因为命名必须要是： `application-prod.yml`

# 接下来读源码把



参考：[](https://blog.csdn.net/puhaiyang/article/details/78335703)

