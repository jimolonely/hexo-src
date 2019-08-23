---
title: 读《maven实战》笔记
tags:
  - maven
p: maven/006-read-book-maven-practice
date: 2019-08-22 08:13:23
---

本文为阅读书籍《maven实战--》的读书笔记。

# 项目结构

```s
my-app
|-- pom.xml
`-- src
    |-- main
    |   `-- java
    |       `-- com
    |           `-- mycompany
    |               `-- app
    |                   `-- App.java
    `-- test
        `-- java
            `-- com
                `-- mycompany
                    `-- app
                        `-- AppTest.java
```


```s
```
```s
```

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

# maven生命周期

Maven拥有三套相互独立的生命周期，它们分别为clean、default和site。

* clean生命周期的目的是清理项目
* default生命周期的目的是构建项目
* site生命周期的目的是建立项目站点。

## clean

1. pre-clean执行一些清理前需要完成的工作。
2. clean清理上一次构建生成的文件。
3. post-clean执行一些清理后需要完成的工作。

## default

[官方文档](https://maven.apache.org/guides/introduction/introduction-to-the-lifecycle.html)

* validate
* initialize
* generate-sources
* process-sources处理项目主资源文件。一般来说，是对src/main/resources目录的内容进行变量替换等工作后，复制到项目输出的主classpath目录中。
* generate-resources
* process-resources
* compile编译项目的主源码。一般来说，是编译src/main/java目录下的Java文件至项目输出的主classpath目录中。
* process-classes
* generate-test-sources
* process-test-sources处理项目测试资源文件。一般来说，是对src/test/resources目录的内容进行变量替换等工作后，复制到项目输出的测试classpath目录中。
* generate-test-resources
* process-test-resources
* test-compile编译项目的测试代码。一般来说，是编译src/test/java目录下的Java文件至项目输出的测试classpath目录中。
* process-test-classes
* test使用单元测试框架运行测试，测试代码不会被打包或部署。
* prepare-package
* package接受编译好的代码，打包成可发布的格式，如JAR。
* pre-integration-test
* integration-test
* post-integration-test
* verify
* install将包安装到Maven本地仓库，供本地其他Maven项目使用。
* deploy将最终的包复制到远程仓库，供其他开发人员和Maven项目使用。

## site

* pre-site执行一些在生成项目站点之前需要完成的工作。
* site生成项目站点文档。
* post-site执行一些在生成项目站点之后需要完成的工作。
* site-deploy将生成的项目站点发布到服务器上。

## 生命周期命令

就是各个生命周期的命令组合使用：
```s
$ mvn clean
$ mvn test
$ mvn clean install
$ mvn clean deploy site-deploy
```

# 插件

maven的核心功能只有几兆，生命周期的功能都是由插件完成的，需要时会下载。

[官方文档介绍了插件及其开源地址](https://maven.apache.org/plugins/index.html)

## 插件目标

因为很多任务背后有很多可以复用的代码，因此，这些功能聚集在一个插件里，每个功能就是一个插件目标。

`maven-dependency-plugin`有十多个目标，每个目标对应了一个功能，常见的插件目标为`dependency：analyze`、`dependency：tree`和`dependency：list`。
这是一种通用的写法，冒号前面是插件前缀，冒号后面是该插件的目标。类似地，还可以写出`compiler：compile`（这是`maven-compiler-plugin`的`compile`目标）和`surefire：test`（这是`maven-surefire-plugin`的`test`目标）。

## 插件配置

命令行配置： `-Dkey=value`, 实际上是java自带的系统属性方式
```s
$ mvn install -Dmaven.test.skip=true
```

POM文件全局配置
```xml
  <plugin>
      <groupId>org.apache.maven.plugins</groupId>
      <artifactId>maven-compiler-plugin</artifactId>
      <configuration>
          <source>1.8</source>
          <target>1.8</target>
      </configuration>
  </plugin>
```

## 插件帮助描述

`mvn help:describe -Dplugin=xxx [-Dgoal=xxx] [-Ddetail]`

```s
$ mvn help:describe -Dplugin=org.apache.maven.plugins:maven-compiler-plugin
[INFO] Scanning for projects...
[INFO] 
[INFO] ------------------------< com.jimo:jasypt-demo >------------------------
[INFO] Building jasypt-demo 0.0.1-SNAPSHOT
[INFO] --------------------------------[ jar ]---------------------------------
[INFO] 
[INFO] --- maven-help-plugin:3.1.1:describe (default-cli) @ jasypt-demo ---
[INFO] org.apache.maven.plugins:maven-compiler-plugin:3.8.1

Name: Apache Maven Compiler Plugin
Description: The Compiler Plugin is used to compile the sources of your
  project.
Group Id: org.apache.maven.plugins
Artifact Id: maven-compiler-plugin
Version: 3.8.1
Goal Prefix: compiler

This plugin has 3 goals:

compiler:compile
  Description: Compiles application sources

compiler:help
  Description: Display help information on maven-compiler-plugin.
    Call mvn compiler:help -Ddetail=true -Dgoal=<goal-name> to display
    parameter details.

compiler:testCompile
  Description: Compiles application test sources.

For more information, run 'mvn help:describe [...] -Ddetail'
```


```s
```
```s
```



