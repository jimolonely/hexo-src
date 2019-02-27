---
title: eureka使用总结
tags:
  - spring cloud
  - eureka
p: java/029-eureka-record
date: 2019-02-27 17:37:43
---

本文长期更新在使用eureka时用到的知识和问题。

# eureka接口

1. 遇到应用运行良好，但eureka显示DOWN了，再也拉不回去，可以使用eureka的强制更新状态接口：
    `curl -X PUT http://HOST:8761/eureka/apps/appName/instanceID/status?value=UP`
    [戳我看更加完整的接口](https://github.com/Netflix/eureka/wiki/Eureka-REST-operations),[或人家翻译的](https://my.oschina.net/u/943746/blog/2248156)

2. 上面的instanceID是什么？
    就是eureka界面STATUS列显示的，[看这篇文章:如何自定义微服务的Instance ID](http://www.itmuch.com/spring-cloud-sum/eureka-instance-id/)

