---
title: spring cloud zipkin 找不到服务
tags:
  - java
  - spring cloud
  - zipkin
p: java/046-springcloud-zipkin-service-not-found
date: 2019-06-09 14:00:33
---

当使用sleuth+zipkin对spring cloud进行链路跟踪时，发现始终只有eureka一个服务能被zipkin server发现，
其他都不行，纠结了很久，最后终于发现了原因： zipkin的发送方式问题。

# 问题重现
我们知道，最新的zipkin server已经不建议自己写服务端，所以运行完服务端一切正常，界面也可以访问：
```java
java -jar zipkin.jar
```

在spring cloud里的配置如下：
```yml
spring:
  application:
    name: ccb
  # 用于bus批量刷新的mq
  rabbitmq:
    host: localhost
    port: 5672
    username: guest
    password: guest
  zipkin:
    base-url: http://localhost:9411
  sleuth:
    web:
      client:
        enabled: true
    sampler:
      probability: 1.0 # 全采样
```

maven依赖如下：
```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-zipkin</artifactId>
</dependency>

<!--config 的mq通信使用-->
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-bus-amqp</artifactId>
</dependency>

<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-config-client</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-openfeign</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-netflix-hystrix</artifactId>
</dependency>
```
主要就是zipkin的依赖，zipkin包含了sleuth的依赖，所以不用重复引入。

如果你现在看出哪里有问题，那么就可以不往下读了。

# 问题解决

这样写，zipkin永远不能发现ccb这个服务，也就不存在监控了。

经过查找资料，发现了[spring sleuth官方解释](https://cloud.spring.io/spring-cloud-sleuth/1.3.x/multi/multi__sending_spans_to_zipkin.html):
```java
Important
spring-cloud-sleuth-stream is deprecated and should no longer be used. If spring-cloud-sleuth-zipkin is on the classpath then the app will generate and collect Zipkin-compatible traces. By default it sends them via HTTP to a Zipkin server on localhost (port 9411). If you depend on spring-rabbit or spring-kafka your app will send traces to a broker instead of http.

翻译：
默认，发送span给zipkin server是通过HTTP， 但是如果有rabbit或者kafka的依赖，则优先使用。
```

于是豁然开朗，为了支持config的批量刷新，我引入了rabbitmq，但是eureka没有引入，所以监控信息是发给消息队列了，所以本地zipkin server收不到。

然后进一步，解决办法也很简单： 修改发送方式：
```yml
  zipkin:
    base-url: http://localhost:9411
    sender:
      type: web # 另外2个是 rabbit和kafka
```
重启后，记得要发送完第一条调用后才能看到服务。

# 总结
这个问题很简单，重要的是能从中总结出什么经验？

1. 确定这个问题涉及的范围： 用到了spring cloud的sluth和zipkin两个东西

2. 借助于搜索引擎： 能google到当然最好，但是这个问题并没有搜到；

3. 分别查找各自可能的原因： 既然别人没有分享这个问题，那只有我来了；
    1. 我先到zipkin的issue去看有没有可能的原因，开始还以为是依赖问题；
    2. 然后看了spring cloud的官方文档，才明白过来；

4. 总结分享： 解决一个问题不算什么，解决一类问题说明触类旁通， 但不害怕一切问题才是制胜关键；

祝我失败得痛苦，成功得快乐。



