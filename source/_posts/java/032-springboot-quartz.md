---
title: spring-boot quartz
tags:
  - java
  - spring-boot
  - quartz
p: java/032-springboot-quartz
date: 2019-03-07 13:52:21
---

因为项目用到，需要研究下quartz这个定时框架。

[quartz官网](http://www.quartz-scheduler.org/)

# 理论概念


# 使用

## 原生使用

## spring boot集成
如果硬要在官网去找使用方法，还是有点困难的，不过我找到了下面几个：
1. [Quartz Scheduler](https://docs.spring.io/spring-boot/docs/current/reference/html/boot-features-quartz.html),这一页只是简单的说明有这个东西，却没有告诉怎么用
2. [common-application-properties](https://docs.spring.io/spring-boot/docs/current/reference/html/common-application-properties.html)，这一页搜索quartz，可以得到支持的quartz配置，如下：

```yml
# QUARTZ SCHEDULER (QuartzProperties)
spring.quartz.auto-startup=true # Whether to automatically start the scheduler after initialization.
spring.quartz.jdbc.comment-prefix=-- # Prefix for single-line comments in SQL initialization scripts.
spring.quartz.jdbc.initialize-schema=embedded # Database schema initialization mode.
spring.quartz.jdbc.schema=classpath:org/quartz/impl/jdbcjobstore/tables_@@platform@@.sql # Path to the SQL file to use to initialize the database schema.
spring.quartz.job-store-type=memory # Quartz job store type.
spring.quartz.overwrite-existing-jobs=false # Whether configured jobs should overwrite existing job definitions.
spring.quartz.properties.*= # Additional Quartz Scheduler properties.
spring.quartz.scheduler-name=quartzScheduler # Name of the scheduler.
spring.quartz.startup-delay=0s # Delay after which the scheduler is started once initialization completes.
spring.quartz.wait-for-jobs-to-complete-on-shutdown=false # Whether to wait for running jobs to complete on shutdown.
```

[参考这篇博客](https://www.cnblogs.com/youzhibing/p/10024558.html)

# 源码阅读

这一步需要阅读源码大概知道是怎么实现的。

// TODO
