---
title: gradle必经之路
tags:
  - java
  - gradle
  - tool
p: tools/006-gradle
date: 2018-03-05 10:30:57
---
这篇讲了如何学习gradle以及会遇到的问题.

# 预备知识
对{% post_link lang/000-groovy Groovy %}语言有了解,对Java开发了解.
# 安装
参考[https://gradle.org/install/](https://gradle.org/install/)
# 下载gradle慢
如果是下载gradle本身慢,
比如遇到:
```shell
[jimo@jimo-pc basic-demo]$ ./gradlew copy
Downloading https://services.gradle.org/distributions/gradle-4.5.1-bin.zip
....
```
一般只有30k,所以去下载:https://services.gradle.org/distributions/gradle-4.5.1-bin.zip
,然后修改该项目的配置文件:basic-demo/gradle/wrapper/gradle-wrapper.properties
```shell
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
#distributionUrl=https\://services.gradle.org/distributions/gradle-4.5.1-bin.zip
distributionUrl=gradle-4.5.1-bin.zip
```
当然这个路径可以自由修改.

然后编译就简单了:
```shell
[jimo@jimo-pc basic-demo]$ ./gradlew copy
Downloading file:/home/xxx/basic-demo/gradle/wrapper/gradle-4.5.1-bin.zip
.....................................................................
Unzipping /home/jimo/.gradle/wrapper/dists/gradle-4.5.1-bin/3o6uzay4hcvg4k8e46n74bbqi/gradle-4.5.1-bin.zip to /home/jimo/.gradle/wrapper/dists/gradle-4.5.1-bin/3o6uzay4hcvg4k8e46n74bbqi
Set executable permissions for: /home/jimo/.gradle/wrapper/dists/gradle-4.5.1-bin/3o6uzay4hcvg4k8e46n74bbqi/gradle-4.5.1/bin/gradle

BUILD SUCCESSFUL in 1s
1 actionable task: 1 executed
```
# 下载jar包慢
```shell
buildscript {
    repositories {
        maven { url 'http://maven.aliyun.com/nexus/content/groups/public/' }
        jcenter()
    }
}

allprojects {
    repositories {
        maven { url 'http://maven.aliyun.com/nexus/content/groups/public/' }
        jcenter()
    }
}
```
# 怎么学习
用官网提供的例子即可:[https://gradle.org/guides/#getting-started](https://gradle.org/guides/#getting-started)

[W3C提供的教程也可以](https://www.w3cschool.cn/gradle/ms7n1hu2.html)
