---
title: docker搭建springcloud微服务集群环境
tags:
  - spring cloud
  - docker
p: cloudcompute/017-docker-spring-cloud-build
date: 2019-06-17 10:43:56
---

一个简单的细节问题，导致eureka的url设置不正确。

[但我肯定不是孤独的](https://github.com/spring-cloud/spring-cloud-netflix/issues/2541)

设置eureka的defaultZone时：
```yml
eureka:
  client:
    service-url:
      default-zone: http://epay-eureka:8761/eureka/
```
`default-zone`失效，导致eureka加载的默认配置： 在 `EurekaClientConfigBean`类里：
```java
  public static final String DEFAULT_ZONE = "defaultZone";

	private Map<String, String> serviceUrl = new HashMap<>();

	{
		this.serviceUrl.put(DEFAULT_ZONE, DEFAULT_URL);
	}
```
DEFAULT_ZONE的默认值是驼峰命名的， 而写成`default-zone`会被当成全小写`defaultzone`, 因此不起作用。
这算是一个坑吧，

ok，可以开始叙述正式内容了： spring cloud在docker中的单机和集群部署实践。

# 单机部署

# 集群部署

https://github.com/spring-cloud/spring-cloud-netflix/issues/3373
