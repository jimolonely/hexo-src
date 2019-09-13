---
title: log4j、logback、log4j12、slf4j的区别
tags:
  - java
  - log4j
  - log4j12
  - logback
  - slf4j
p: java/067-log4j-slf4j-logback-log4j12-diff
date: 2019-09-13 09:05:15
---

日志是一个系统必不可少的部分，每个程序员都在用，但是对于java程序员来说，不断发现的日志框架让我们晕头转向，
于是，有识之士说：必须把这个弄清楚！

其实，只要花那么几分钟就可以明白他们之间的关系，只要找对了资源，网上很多博客都是抄过来抄过去，很少自己掌握了信息来源和独立见解。

最好的信息来源当然是官网，下面就开始花几分钟弄明白他们的关系。

# SLF4J

去到它的官网：[https://www.slf4j.org/manual.html](https://www.slf4j.org/manual.html), 不下一分钟，就会发现这张图：

{% asset_img 000.png %}

再看看开头的解释：
> `Simple Logging Facade for Java（SLF4J）`可用作各种日志框架的简单外观或抽象，例如`java.util.logging`，`logback和log4j`。 SLF4J允许最终用户在部署时插入所需的日志记录框架。 请注意，启用SLF4J的库/应用程序意味着只添加一个强制依赖项，即`slf4j-api-2.0.0-alpha1-SNAPSHOT.jar`。

反正我瞬间就明白了，不明白自己去读把。

特殊说明下：slf4j和log4j中间那一层log4j12就是一个连接层，就像适配器一样把slf4j和log4j连接起来。

好了，本文完结，但是为了自己好，还是将这些slf4j的实现的配置文档都记录下，方便查找配置。

# log4j

[https://logging.apache.org/log4j](https://logging.apache.org/log4j)

关于配置看这里：[https://logging.apache.org/log4j/2.x/manual/configuration.html](https://logging.apache.org/log4j/2.x/manual/configuration.html)

里面有各种格式文件的示例：

* xml
* yaml
* json
* properties

# logback

官方：[https://logback.qos.ch/](https://logback.qos.ch/), 其github: [https://github.com/qos-ch/logback](https://github.com/qos-ch/logback)

关于配置查看这里：[https://logback.qos.ch/manual/configuration.html](https://logback.qos.ch/manual/configuration.html)


# 常见问题

使用spring框架时，spring本身依赖logback，而其他库的实现使用log4j打日志，一般解决方法是：去掉logback，完全使用log4j。



