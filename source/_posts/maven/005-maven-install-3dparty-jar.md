---
title: maven安装第三方jar
tags:
  - java
  - maven
p: maven/005-maven-install-3dparty-jar
date: 2019-05-24 08:35:28
---

本次实验分为3部分：
1. 准备第三方jar
2. 安装到本地仓库
3. 使用

# 准备第三方jar
在这个以构建工具为主的时代，为什么还需要自己导jar包？ 如果你参与过国企的落后开发环境，不允许连外网，
所有工具都是U盘拷贝，包括jar包，这时候你会指天骂娘，这都什么年代了。

例如，银行的支付会给一个打好的jar包和他们对接。我们需要把它安装到本地，{% post_link java/037-jar-java-cmdline 关于如何自己打包一个jar包参考 %}。

我们就用上例中的Hello.jar.

# 安装到本地仓库

参考官网： [https://maven.apache.org/guides/mini/guide-3rd-party-jars-local.html](https://maven.apache.org/guides/mini/guide-3rd-party-jars-local.html)

```
mvn install:install-file -Dfile=<path-to-file> -DgroupId=<group-id> \
    -DartifactId=<artifact-id> -Dversion=<version> -Dpackaging=<packaging>
```

然后实践：
```
$ mvn install:install-file -Dfile=Hello.jar \
  -DgroupId=jimo -DartifactId=hello -Dversion=1.0.0 -Dpackaging=jar
```

**注意的就是： groupId和artifactId只要不和已有的重复就行。**

# 使用
这个就简单了：
```maven
    <dependency>
        <groupId>jimo</groupId>
        <artifactId>hello</artifactId>
        <version>1.0.0</version>
    </dependency>
```




