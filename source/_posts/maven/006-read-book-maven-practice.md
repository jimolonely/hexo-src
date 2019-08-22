---
title: 读《maven实战》笔记
tags:
  - maven
p: maven/006-read-book-maven-practice
date: 2019-08-22 08:13:23
---

本文为阅读书籍《maven实战--》的读书笔记。

# maven坐标

1. groupId：公司+项目，，eg：`org.springframework.boot`
2. artifactId: 项目下的模块，eg：`spring-boot-starter-web`
3. version
4. packaging: jar, war等
5. classfier: 附属构件，由附加的插件生成，比如`spring-boot-starter-web-2.0.4.RELEASE-javadoc.jar`

## dependency

```xml
<project>
  ...
  <dependencies>
    <dependency>
      <groupId></groupId>
      <artifactId></artifactId>
      <version></version>
      <type></type>
      <scope></scope>
      <optional></optional>
      <exclusions>
        <exclusion>
          ...
        </exclusion>
      </exclusions>
    </dependency>
  </dependencies>
</project>
```
* type: packaging, jar(默认)/war
* scope: 见后面
* optional: 是否可选

## scope

* compile: 编译、测试、运行都有效
* test: 只对测试有效,eg: `junit`
* provided: 编译和测试有效，运行时无效，eg：`servlet-api.jar`
* runtime: 测试和运行有效，编译时无效: eg: `JDBC驱动`
* system: 和provided一样，只是依赖时必须用systemPath显示指定依赖路径，而不是由maven解析，是与本机绑定：
    ```xml
      <dependency>
      <groupId></groupId>
      <artifactId></artifactId>
      <version></version>
      <scope>system</scope>
      <systemPath>/xxx/xx.jar</systemPath>
    </dependency>
    ```
* import: TODO

# 传递性依赖

A -> B -> C

A--> C


```xml
```

```xml
```

```xml
```




