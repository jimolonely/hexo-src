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
要说为什么把单机部署单独提出来将，有2个目的：
1. 用作实验教学，搭建最小
2. 单机和集群有本质的区别

本次环境是一个电子支付的例子，最小环境里只包括了4个服务： `epay-eureka, epay-zuul, epay-icbc, epay-ccb`.
ICBC需要访问CCB来测试服务间调用。

## spring cloud配置
关于每个服务的maven依赖见[附录](#附录)

下面是每个服务的application.yml配置：

epay-eureka
```yml
server:
  port: 8761
spring:
  application:
    name: epay-eureka
eureka:
  client:
    register-with-eureka: false
    fetch-registry: false
    service-url:
      defaultZone: ${EUREKA_URLS}
  server:
    wait-time-in-ms-when-sync-empty: 0
    enable-self-preservation: false
    # 主动失效检测间隔，默认60s有点慢
    eviction-interval-timer-in-ms: 30000
```
epay-zuul
```yml
spring:
  application:
    name: epay-zuul

server:
  port: 5555

eureka:
  client:
    service-url:
      defaultZone: ${EUREKA_URLS}

zuul:
  add-host-header: true
  routes:
    icbc:
      path: /icbc/**
      service-id: epay-icbc
    ccb:
      path: /ccb/**
      service-id: epay-ccb
  ribbon-isolation-strategy: thread
  thread-pool:
    use-separate-thread-pools: true
    thread-pool-key-prefix: zullgateway
  # 这些参数可根据实际监控情况调节
  host:
    max-per-route-connections: 50
    max-total-connections: 300
    socket-timeout-millis: 5000
    connect-timeout-millis: 5000

ribbon:
  ConnectTimeout: 5000
  ReadTimeout: 5000
  MaxAutoRetries: 0 # 考虑到支付的特殊性，可能出现冥等问题，所以不重试
  MaxAutoRetriesNextServer: 0
  OkToRetryOnAllOperations: false

hystrix:
  threadpool:
    default:
      coresize: 20
      maximumSize: 50
      allowMaximumSizeToDivergeFromCoresize: true
  command:
    default:
      execution:
        isolation:
          thread:
            timeoutInMilliseconds: 10000

management:
  endpoints:
    web:
      exposure:
        include: "*"
  endpoint:
    health:
      show-details: ALWAYS
```
epay-icbc
```yml
server:
  port: 8001
spring:
  application:
    name: epay-icbc

eureka:
  client:
    service-url:
      defaultZone: ${EUREKA_URLS}

ribbon:
  ConnectTimeout: 5000
  ReadTimeout: 5000
  MaxAutoRetries: 0 # 考虑到支付的特殊性，可能出现冥等问题，所以不重试
  MaxAutoRetriesNextServer: 0
  OkToRetryOnAllOperations: false

hystrix:
  command:
    default:
      execution:
        isolation:
          thread:
            timeoutInMilliseconds: 10000

feign:
  hystrix:
    enabled: true
```
epay-ccb
```yml
server:
  port: 8002
spring:
  application:
    name: epay-ccb

eureka:
  client:
    service-url:
      defaultZone: ${EUREKA_URLS}

feign:
  hystrix:
    enabled: true

management:
  endpoints:
    web:
      exposure:
        include: "*"
  endpoint:
    health:
      show-details: always
```
注意点： `defaultZone: ${EUREKA_URLS}` 里面的EUREKA参数我们会从系统环境变量里读取。

## Dockerfile编写
很简单，我们以openjdk8为底层镜像：
```dockerfile
FROM openjdk:8-jre
MAINTAINER jimo
COPY epay-eureka/target/epay-eureka.jar /opt/lib/
ENTRYPOINT ["java", "-jar", "/opt/lib/epay-eureka.jar"]
```
注意，我们会在docker-compose里指定context，jar包的相对路径是根据此来的。

## docker compose组合

这里需要看下我的项目结构：

{% asset_img 000.png %}

docker-compose.yml
```yml
version: '2.2'
services:
  epay-eureka:
    container_name: epay-eureka
    build:
      context: ..
      dockerfile: docker/Dockerfile-eureka
    environment:
      - EUREKA_URLS=http://epay-eureka:8761/eureka/
    image: epay-eureka
    expose:
      - 8761
    ports:
      - 8761:8761
    mem_limit: 996m

  epay-zuul:
    container_name: epay-zuul
    build:
      context: ..
      dockerfile: docker/Dockerfile-zuul
    environment:
      - EUREKA_URLS=http://epay-eureka:8761/eureka/
    image: epay-zuul
    expose:
      - 5555
    ports:
      - 5555:5555
    mem_limit: 996m
    depends_on:
      - epay-eureka

  epay-icbc:
    container_name: epay-icbc
    build:
      context: ..
      dockerfile: docker/Dockerfile-icbc
    environment:
      - EUREKA_URLS=http://epay-eureka:8761/eureka/
    image: epay-icbc
    expose:
      - 8001
    ports:
      - 8001:8001
    mem_limit: 996m
    depends_on:
      - epay-eureka

  epay-ccb:
    container_name: epay-ccb
    build:
      context: ..
      dockerfile: docker/Dockerfile-ccb
    environment:
      - EUREKA_URLS=http://epay-eureka:8761/eureka/
    image: epay-ccb
    expose:
      - 8002
    ports:
      - 8002:8002
    mem_limit: 996m
    depends_on:
      - epay-eureka
```
## 运行

1. 打包好jar包
2. 在项目根目录（sc-epay-demo）运行： `docker-compose up --build`
3. 访问`localhost:8761`

# 集群部署

https://github.com/spring-cloud/spring-cloud-netflix/issues/3373

# 附录

spring cloud服务maven依赖

父模块依赖
```xml
    <modelVersion>4.0.0</modelVersion>
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>2.0.6.RELEASE</version>
        <relativePath/> <!-- lookup parent from repository -->
    </parent>

    <groupId>com.sinorail</groupId>
    <artifactId>sc-epay-demo</artifactId>
    <version>0.0.1</version>
    <packaging>pom</packaging>
    <name>sc-epay-demo</name>
    <description>电子支付spring cloud微服务框架demo</description>

    <properties>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <project.reporting.outputEncoding>UTF-8</project.reporting.outputEncoding>
        <java.version>1.8</java.version>
        <spring-cloud.version>Finchley.RELEASE</spring-cloud.version>
        <sleuth.version>2.1.0.RELEASE</sleuth.version>
        <dockerfile-maven-version>1.4.9</dockerfile-maven-version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-actuator</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <!-- spring-boot-starter-test测试框架依赖 -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-netflix-eureka-client</artifactId>
        </dependency>
    </dependencies>

    <dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>org.springframework.cloud</groupId>
                <artifactId>spring-cloud-dependencies</artifactId>
                <version>${spring-cloud.version}</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
        </dependencies>
    </dependencyManagement>

    <!--多模块声明-->
    <modules>
        <module>epay-config</module>
        <module>epay-eureka</module>
        <module>epay-zuul</module>
        <module>epay-ccb</module>
        <module>epay-icbc</module>
    </modules>
```
epay-eureka pom
```xml
```
epay-zuul pom
```xml
```
epay-icbc pom
```xml
```
epay-ccb pom
```xml
```


```xml
```
```xml
```
```xml
```
```xml
```
```xml
```

