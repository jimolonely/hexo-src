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
* scope: 见[后面](##scope)
* optional: 是否可选,见[后面](#可选依赖(optional))

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

## 传递性依赖范围影响

| | compile | test | provided | runtime |
|:---|:---|:---|:---|:---|
| compile | compile | - | - | runtime |
| test | test | - | - | test |
| provided | provided | - | provided | provided |
| runtime | runtime | - | - | runtime |

## 依赖路径

1. 最近优先：`A->B->C->X（1.0）、A->D->X（2.0）`
2. 路径长度相同，先声明的优先(2.0.8之后)：`A->B->Y（1.0）、A->C->Y（2.0）`

# 可选依赖(optional)

如果，A->B、B->X（可选）、B->Y（可选），那么A将不会依赖X和Y

但是不建议使用，因为OOP的单一职责原则。

# 常用maven命令

## 查看依赖
看3个地方：都是冒号分隔的

1. 依赖名
2. 中间的版本号
3. 最后的依赖范围

```s
$ mvn dependency:list | grep springframework
```
查看依赖树，层级关系（第一依赖、第二依赖...）
```s
$ mvn dependency:tree
```
## 分析依赖
```s
$ mvn dependency:analyze
```
接下来看其输出，着重关注警告。

`Used undeclared dependencies found`： 
指项目中使用到的，但是没有显式声明的依赖，这里是spring-context。这种依赖意味着潜在的风险，当前项目直接在使用它们，例如有很多相关的Java import声明，而这种依赖是通过直接依赖传递进来的，当升级直接依赖的时候，相关传递性依赖的版本也可能发生变化，这种变化不易察觉，但是有可能导致当前项目出错。例如由于接口的改变，当前项目中的相关代码无法编译。这种隐藏的、潜在的威胁一旦出现，就往往需要耗费大量的时间来查明真相。因此，显式声明任何项目中直接用到的依赖。
```s
[WARNING] Used undeclared dependencies found:
[WARNING]    org.springframework.boot:spring-boot:jar:2.0.4.RELEASE:compile
[WARNING]    org.springframework.cloud:spring-cloud-netflix-eureka-server:jar:2.0.1.RELEASE:compile
[WARNING]    org.springframework:spring-test:jar:5.0.8.RELEASE:test
[WARNING]    org.springframework.boot:spring-boot-test:jar:2.0.4.RELEASE:test
[WARNING]    junit:junit:jar:4.12:test
[WARNING]    org.springframework.boot:spring-boot-autoconfigure:jar:2.0.4.RELEASE:compile
```
`Unused declared dependencies`: 意指项目中未使用的，但显式声明的依赖。需要注意的是，对于这样一类依赖，我们不应该简单地直接删除其声明，而是应该仔细分析。由于dependency：analyze只会分析编译主代码和测试代码需要用到的依赖，一些执行测试和运行时需要的依赖它就发现不了。当然，有时候确实能通过该信息找到一些没用的依赖，但一定要小心测试。
```s
[WARNING] Unused declared dependencies found:
[WARNING]    org.springframework.cloud:spring-cloud-starter-netflix-eureka-server:jar:2.0.1.RELEASE:compile
[WARNING]    org.springframework.boot:spring-boot-starter-undertow:jar:2.0.4.RELEASE:compile
[WARNING]    org.springframework.boot:spring-boot-starter-web:jar:2.0.4.RELEASE:compile
[WARNING]    org.springframework.boot:spring-boot-starter-test:jar:2.0.4.RELEASE:test
[WARNING]    de.codecentric:spring-boot-admin-starter-client:jar:2.0.4:compile
[WARNING]    org.springframework.cloud:spring-cloud-starter-netflix-eureka-client:jar:2.0.1.RELEASE:compile
[WARNING]    com.github.ulisesbocchio:jasypt-spring-boot-starter:jar:2.1.1:compile
```

# 仓库

为了满足一些复杂的需求，Maven还支持更高级的镜像配置：

* `<mirrorOf>*</mirrorOf>`：匹配所有远程仓库。
* `<mirrorOf>external：*</mirrorOf>`：匹配所有远程仓库，使用localhost的除外，使用`file：//`协议的除外。也就是说，匹配所有不在本机上的远程仓库。
* `<mirrorOf>repo1，repo2</mirrorOf>`：匹配仓库repo1和repo2，使用逗号分隔多个远程仓库。
* `<mirrorOf>*，！repo1</mirrorOf>`：匹配所有远程仓库，repo1除外，使用感叹号将仓库从匹配中排除。

```xml
<mirrors>
  <mirror>
    <id>internal-repo</id>
    <name>repo jimo</name>
    <url>http://IP/maven3</url>
    <mirrorOf>*</mirrorOf>
  </mirror>
</mirrors>
```





