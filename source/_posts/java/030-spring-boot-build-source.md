---
title: spring-boot编译源码
tags:
  - java
  - spring-boot
p: java/030-spring-boot-build-source
date: 2019-03-06 14:37:12
---

学习spring-boot源码第一步： 编译源码，搭建环境。

# 编译环境
1. ubuntu18.04
2. JDK1.8
3. maven 3.5.2

# 编译过程
如果直接使用：`mvn -Dmaven.test.skip=true clean install` 安装，大概会遇到下面的错误：

{% asset_img 000.png %}

错误原因是： 内存不足。由于spring-boot-project/spring-boot-tools下的spring-boot-gradle-plugin项目造成的，一个比较暴力的解决办法是直接删掉这个项目下的src/test/java，因为暂时也用不到它。删除后再执行：
```shell
mvn -Dmaven.test.failure.ignore=true -Dmaven.test.skip=true clean install
```
编译了哪些模块请看附录， 还是很有价值的。

# 导入项目

idea： file-》open 即可

遇到一些maven问题，稍微修改下即可。主要是maven版本，idea自带的为3.3.9，需要升级：
[Properties in parent definition are prohibited](https://chenyongjun.vip/articles/98)

# 测试项目

运行自带的项目：`spring-boot-samples/spring-boot-sample-test/src/main/java/sample/test/SampleTestApplication.java`

# 附录
```java
[INFO] ------------------------------------------------------------------------
[INFO] Reactor Summary:
[INFO] 
[INFO] Spring Boot Build .................................. SUCCESS [  2.148 s]
[INFO] Spring Boot Dependencies ........................... SUCCESS [  3.160 s]
[INFO] Spring Boot Parent ................................. SUCCESS [  0.537 s]
[INFO] Spring Boot Tools .................................. SUCCESS [  0.180 s]
[INFO] Spring Boot Testing Support ........................ SUCCESS [  6.356 s]
[INFO] Spring Boot Configuration Processor ................ SUCCESS [  3.719 s]
[INFO] Spring Boot ........................................ SUCCESS [ 24.872 s]
[INFO] Spring Boot Test ................................... SUCCESS [  5.657 s]
[INFO] Spring Boot Auto-Configure Annotation Processor .... SUCCESS [  0.500 s]
[INFO] Spring Boot AutoConfigure .......................... SUCCESS [ 21.815 s]
[INFO] Spring Boot Actuator ............................... SUCCESS [  7.187 s]
[INFO] Spring Boot Actuator AutoConfigure ................. SUCCESS [  6.806 s]
[INFO] Spring Boot Developer Tools ........................ SUCCESS [  2.604 s]
[INFO] Spring Boot Configuration Metadata ................. SUCCESS [  0.556 s]
[INFO] Spring Boot Properties Migrator .................... SUCCESS [  0.478 s]
[INFO] Spring Boot Test Auto-Configure .................... SUCCESS [  2.757 s]
[INFO] Spring Boot Loader ................................. SUCCESS [01:09 min]
[INFO] Spring Boot Loader Tools ........................... SUCCESS [  1.346 s]
[INFO] Spring Boot Antlib ................................. SUCCESS [  3.436 s]
[INFO] Spring Boot Configuration Docs ..................... SUCCESS [  0.506 s]
[INFO] Spring Boot Gradle Plugin .......................... SUCCESS [  8.702 s]
[INFO] Spring Boot Maven Plugin ........................... SUCCESS [04:34 min]
[INFO] Spring Boot Starters ............................... SUCCESS [  6.059 s]
[INFO] Spring Boot Logging Starter ........................ SUCCESS [  0.929 s]
[INFO] Spring Boot Starter ................................ SUCCESS [  0.664 s]
[INFO] Spring Boot ActiveMQ Starter ....................... SUCCESS [  1.166 s]
[INFO] Spring Boot AMQP Starter ........................... SUCCESS [  0.288 s]
[INFO] Spring Boot AOP Starter ............................ SUCCESS [  0.325 s]
[INFO] Spring Boot Artemis Starter ........................ SUCCESS [  1.020 s]
[INFO] Spring Boot JDBC Starter ........................... SUCCESS [  0.226 s]
[INFO] Spring Boot Batch Starter .......................... SUCCESS [  0.548 s]
[INFO] Spring Boot Cache Starter .......................... SUCCESS [  0.247 s]
[INFO] Spring Boot Spring Cloud Connectors Starter ........ SUCCESS [  1.282 s]
[INFO] Spring Boot Data Cassandra Starter ................. SUCCESS [  0.937 s]
[INFO] Spring Boot Data Cassandra Reactive Starter ........ SUCCESS [  0.510 s]
[INFO] Spring Boot Data Couchbase Starter ................. SUCCESS [  0.641 s]
[INFO] Spring Boot Data Couchbase Reactive Starter ........ SUCCESS [  0.318 s]
[INFO] Spring Boot Data Elasticsearch Starter ............. SUCCESS [  2.257 s]
[INFO] Spring Boot Data JDBC Starter ...................... SUCCESS [  0.319 s]
[INFO] Spring Boot Data JPA Starter ....................... SUCCESS [  1.360 s]
[INFO] Spring Boot Data LDAP Starter ...................... SUCCESS [  0.219 s]
[INFO] Spring Boot Data MongoDB Starter ................... SUCCESS [  0.716 s]
[INFO] Spring Boot Data MongoDB Reactive Starter .......... SUCCESS [  0.241 s]
[INFO] Spring Boot Data Neo4j Starter ..................... SUCCESS [  0.485 s]
[INFO] Spring Boot Data Redis Starter ..................... SUCCESS [  0.468 s]
[INFO] Spring Boot Data Redis Reactive Starter ............ SUCCESS [  0.470 s]
[INFO] Spring Boot Json Starter ........................... SUCCESS [  0.362 s]
[INFO] Spring Boot Tomcat Starter ......................... SUCCESS [  0.219 s]
[INFO] Spring Boot Web Starter ............................ SUCCESS [  0.527 s]
[INFO] Spring Boot Data REST Starter ...................... SUCCESS [  0.552 s]
[INFO] Spring Boot Data Solr Starter ...................... SUCCESS [  0.654 s]
[INFO] Spring Boot FreeMarker Starter ..................... SUCCESS [  0.227 s]
[INFO] Spring Boot Groovy Templates Starter ............... SUCCESS [  0.439 s]
[INFO] Spring Boot HATEOAS Starter ........................ SUCCESS [  0.313 s]
[INFO] Spring Boot Integration Starter .................... SUCCESS [  0.267 s]
[INFO] Spring Boot Validation Starter ..................... SUCCESS [  0.217 s]
[INFO] Spring Boot Jersey Starter ......................... SUCCESS [  1.550 s]
[INFO] Spring Boot Jetty Starter .......................... SUCCESS [  1.195 s]
[INFO] Spring Boot JOOQ Starter ........................... SUCCESS [  0.261 s]
[INFO] Spring Boot Atomikos JTA Starter ................... SUCCESS [  0.352 s]
[INFO] Spring Boot Bitronix JTA Starter ................... SUCCESS [  0.214 s]
[INFO] Spring Boot Log4j 2 Starter ........................ SUCCESS [  0.774 s]
[INFO] Spring Boot Mail Starter ........................... SUCCESS [  0.337 s]
[INFO] Spring Boot Mustache Starter ....................... SUCCESS [  0.222 s]
[INFO] Spring Boot Actuator Starter ....................... SUCCESS [  0.427 s]
[INFO] Spring Boot OAuth2/OpenID Connect Client Starter ... SUCCESS [ 14.000 s]
[INFO] Spring Boot OAuth2 Resource Server Starter ......... SUCCESS [  0.205 s]
[INFO] Spring Boot Starter Parent ......................... SUCCESS [  0.149 s]
[INFO] Spring Boot Quartz Starter ......................... SUCCESS [  0.258 s]
[INFO] Spring Boot Reactor Netty Starter .................. SUCCESS [  0.322 s]
[INFO] Spring Boot Security Starter ....................... SUCCESS [  0.206 s]
[INFO] Spring Boot Test Starter ........................... SUCCESS [  0.963 s]
[INFO] Spring Boot Thymeleaf Starter ...................... SUCCESS [  0.299 s]
[INFO] Spring Boot Undertow Starter ....................... SUCCESS [  0.815 s]
[INFO] Spring Boot WebFlux Starter ........................ SUCCESS [  1.018 s]
[INFO] Spring Boot WebSocket Starter ...................... SUCCESS [  0.265 s]
[INFO] Spring Boot Web Services Starter ................... SUCCESS [  0.370 s]
[INFO] Spring Boot CLI .................................... SUCCESS [  7.202 s]
[INFO] Spring Boot Docs ................................... SUCCESS [  3.744 s]
[INFO] Spring Boot Build .................................. SUCCESS [  0.086 s]
[INFO] Spring Boot Samples Invoker ........................ SUCCESS [03:40 min]
[INFO] Spring Boot Tests .................................. SUCCESS [  0.111 s]
[INFO] Spring Boot Integration Tests ...................... SUCCESS [  0.101 s]
[INFO] Spring Boot Configuration Processor Tests .......... SUCCESS [  0.235 s]
[INFO] Spring Boot DevTools Tests ......................... SUCCESS [  0.264 s]
[INFO] Spring Boot Hibernate 5.2 tests .................... SUCCESS [  2.060 s]
[INFO] Spring Boot Server Tests ........................... SUCCESS [  0.574 s]
[INFO] Spring Boot Launch Script Integration Tests ........ SUCCESS [ 10.431 s]
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 12:36 min
[INFO] Finished at: 2019-03-06T14:46:31+08:00
[INFO] Final Memory: 730M/1412M
[INFO] ------------------------------------------------------------------------
```
