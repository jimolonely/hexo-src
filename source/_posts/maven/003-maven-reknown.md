---
title: maven再学习
tags:
  - maven
p: maven/003-maven-reknown
date: 2019-03-22 11:02:59
---

共同学习把：

[Maven提高篇系列](https://www.cnblogs.com/davenkin/p/advanced-maven-multi-module-vs-inheritance.html)

[maven book](https://books.sonatype.com/mvnref-book/reference/pom-relationships.html)

# 
创建父模块
```shell
$ mvn archetype:generate -DgroupId=com.jimo -DartifactId=maven-multi -DarchetypeGroupId=org.codehaus.mojo.archetypes -DarchetypeArtifactId=pom-root -DinteractiveMode=false

$ cd maven-multi

$ cat pom.xml 
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/maven-v4_0_0.xsd">
  <modelVersion>4.0.0</modelVersion>
  <groupId>com.jimo</groupId>
  <artifactId>maven-multi</artifactId>
  <packaging>pom</packaging>
  <version>1.0-SNAPSHOT</version>
  <name>maven-multi Maven Multi Project</name>
  <url>http://maven.apache.org</url>
</project>
```
创建子模块
```java
$ mvn archetype:generate -DgroupId=com.jimo -DartifactId=core -DarchetypeArtifactId=maven-archetype-quickstart -DinteractiveMode=false

$ cd core/

core$ ls
pom.xml  src

core$ tree
.
├── pom.xml
└── src
    ├── main
    │   └── java
    │       └── com
    │           └── jimo
    │               └── App.java
    └── test
        └── java
            └── com
                └── jimo
                    └── AppTest.java

9 directories, 3 files

core$ cat pom.xml 
<?xml version="1.0"?>
<project xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd" xmlns="http://maven.apache.org/POM/4.0.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <modelVersion>4.0.0</modelVersion>
  <parent>
    <groupId>com.jimo</groupId>
    <artifactId>maven-multi</artifactId>
    <version>1.0-SNAPSHOT</version>
  </parent>
  <groupId>com.jimo</groupId>
  <artifactId>core</artifactId>
  <version>1.0-SNAPSHOT</version>
  <name>core</name>
  <url>http://maven.apache.org</url>
  <dependencies>
    <dependency>
      <groupId>junit</groupId>
      <artifactId>junit</artifactId>
      <version>3.8.1</version>
      <scope>test</scope>
    </dependency>
  </dependencies>
</project>
```
返回父模块，发现pom已经变了：
```java
core$ cd ..

maven-multi$ cat pom.xml 
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/maven-v4_0_0.xsd">
  <modelVersion>4.0.0</modelVersion>
  <groupId>com.jimo</groupId>
  <artifactId>maven-multi</artifactId>
  <packaging>pom</packaging>
  <version>1.0-SNAPSHOT</version>
  <name>maven-multi Maven Multi Project</name>
  <url>http://maven.apache.org</url>
  <modules>
    <module>core</module>
  </modules>
```
继续创建另一个模块webapp
```java
$ mvn archetype:generate -DgroupId=com.jimo -DartifactId=webapp -DarchetypeArtifactId=maven-archetype-webapp -DinteractiveMode=false
```

```java
$ mvn clean install
```
# 学习后的问题总结

1. maven的多模块和继承有什么区别？
    1. 多模块： 在install时会把所有模块都安装到本地残酷，而继承只会安装父模块
    2. 只有多模块声明时，当然不能共享pom了，每个子模块都得声明一套自己的依赖

2. 如何搭建自己的仓库？
    1. nexus
    2. Artifactory
    3. FTP服务器

3. maven的profile作用是啥，怎么使用？

4. 常用命令： 
    1. tree命令 :`mvn dependency:tree -Dverbose`
    2. 查看从super-pom继承了哪些属性：`mvn help:effective-pom`

5. 如何写一个maven plugin出来？




```java
```

