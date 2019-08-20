---
title: Tomcat9-文档1-介绍
tags:
  - tomcat
p: server/006-tomcat9-doc-1-introduction
date: 2019-08-20 10:20:11
---

翻译自：[https://tomcat.apache.org/tomcat-9.0-doc/introduction.html](https://tomcat.apache.org/tomcat-9.0-doc/introduction.html)

# 介绍
对于管理员和Web开发人员来说，在开始之前，您应该熟悉一些重要的信息。本文档简要介绍了Tomcat容器背后的一些概念和术语。

# 术语
在阅读这些文档的过程中，您将遇到许多术语;一些特定于Tomcat的，以及其他由[Servlet和JSP规范](https://wiki.apache.org/tomcat/Specifications)定义的。

* Context - 简而言之，Context是一个Web应用程序。

这就对了。如果您发现我们需要在此部分添加更多字词，请告知我们。

# 目录和文件
这些是一些关键的tomcat目录：

* / bin  - 启动，关闭和其他脚本。 `*.sh`文件（对于Unix系统）是`* .bat`文件的功能副本（对于Windows系统）。由于Win32命令行缺少某些功能，因此这里有一些额外的文件。
* / conf  - 配置文件和相关的DTD。这里最重要的文件是`server.xml`。它是容器的主要配置文件。
* / logs  - 默认情况下，日志文件在此处。
* / webapps  - 这是您的webapps的用武之地。

# CATALINA_HOME和CATALINA_BASE
在整个文档中，引用了以下两个属性：

* CATALINA_HOME：表示Tomcat安装的根目录，例如`/home/tomcat/apache-tomcat-9.0.10`或`C：\ Program Files \ apache-tomcat-9.0.10`。
* CATALINA_BASE：表示特定Tomcat实例的运行时配置的根路径。如果要在一台计算机上拥有多个Tomcat实例，请使用CATALINA_BASE属性。

如果将属性设置为不同的位置，则CATALINA_HOME位置包含静态源，例如`.jar`文件或二进制文件。 CATALINA_BASE位置包含配置文件，日志文件，已部署的应用程序和其他运行时需求。

## 为什么使用CATALINA_BASE
默认情况下，CATALINA_HOME和CATALINA_BASE指向同一目录。当您需要在一台计算机上运行多个Tomcat实例时，请手动设置CATALINA_BASE。这样做有以下好处：

* 更轻松地管理升级到更新版本的Tomcat。由于具有单个CATALINA_HOME位置的所有实例共享一组`.jar`文件和二进制文件，因此您可以轻松地将文件升级到较新版本，并使用相同的CATALIA_HOME目录将更改传播到所有Tomcat实例。
* 避免重复相同的静态`.jar`文件。
* 可能共享某些设置，例如`setenv` shell或bat脚本文件（取决于您的操作系统）。

## CATALINA_BASE的内容
在开始使用CATALINA_BASE之前，首先考虑并创建CATALINA_BASE使用的目录树。请注意，如果您不创建所有推荐的目录，Tomcat会自动创建目录。如果无法创建必要的目录，例如由于权限问题，Tomcat将无法启动，或者可能无法正常运行。

请考虑以下目录列表：

* 带有`setenv.sh`，`setenv.bat`和`tomcat-juli.jar`文件的`bin`目录。
    * 推荐：不。
    * 查找顺序：首先检查CATALINA_BASE;没有才检查CATALINA_HOME。

* `lib`目录中包含要在classpath上添加的更多资源。
    * 推荐：是的，如果您的应用程序依赖于外部库。
    * 查找顺序：首先检查CATALINA_BASE; CATALINA_HOME第二次加载。

* 特定于实例的日志文件的`logs`目录。
    * 推荐：是的。

* 用于自动加载的Web应用程序的webapps目录。
    * 推荐：是的，如果要部署应用程序。
    * 查找顺序：仅限CATALINA_BASE。

* 包含已部署Web应用程序的临时工作目录的工作目录。
    * 推荐：是的。

* JVM用于临时文件的临时目录。
    * 推荐：是的。

我们建议您不要更改`tomcat-juli.jar`文件。但是，如果您需要自己的日志记录实现，则可以替换特定Tomcat实例的`CATALINA_BASE`位置中的`tomcat-juli.jar`文件。

我们还建议您将所有配置文件从`CATALINA_HOME / conf`目录复制到`CATALINA_BASE / conf /`目录中。如果CATALINA_BASE中缺少配置文件，则不会回退到CATALINA_HOME。因此，这可能会导致失败。

CATALINA_BASE至少必须包含：

* `conf / server.xml`
* `conf / web.xml`

这包括conf目录。否则，Tomcat无法启动或无法正常运行。

有关高级配置信息，请参阅[RUNNING.txt文件](https://tomcat.apache.org/tomcat-9.0-doc/RUNNING.txt)。

## 如何使用CATALINA_BASE
CATALINA_BASE属性是一个环境变量。 您可以在执行Tomcat启动脚本之前进行设置，例如：

* 在Unix上：`CATALINA_BASE = /tmp/tomcat_base1 bin/catalina.sh start`
* 在Windows上：`CATALINA_BASE = C:\tomcat_base1 bin/catalina.bat start`

# 配置Tomcat
本节将使您了解容器配置期间使用的基本信息。

配置文件中的所有信息都在启动时读取，这意味着对文件的任何更改都需要重新启动容器。


{% post_link server/007-tomcat9-doc-2-setup next: Tomcat9-文档2-安装 %}

