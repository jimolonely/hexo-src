---
title: SLF4JLoggerContext cannot be cast to LoggerContext
tags:
  - java
  - maven
p: java/073-SLF4JLoggerContext-cannot-be-cast-to-LoggerContext
date: 2019-09-29 11:46:27
---

 org.apache.logging.slf4j.SLF4JLoggerContext cannot be cast to org.apache.logging.log4j.core.LoggerContext.

 参考[https://stackoverflow.com/questions/49688304/slf4jloggercontext-cannot-be-cast-to-loggercontext](https://stackoverflow.com/questions/49688304/slf4jloggercontext-cannot-be-cast-to-loggercontext)

 解决办法：移除spring-boot-starter-web里的log4j-to-slf4j的依赖

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
    <exclusions>
    <exclusion>
        <groupId>org.apache.logging.log4j</groupId>
        <artifactId>log4j-to-slf4j</artifactId>
    </exclusion>
    </exclusions>
</dependency>
```

这样产生的结果是：spring的日志输出将轮为logback，而其他日志使用log4j

