---
title: Tomcat9-文档2-安装
tags:
  - tomcat
p: server/007-tomcat9-doc-2-setup
date: 2019-08-20 10:43:33
---

本文翻译自：[https://tomcat.apache.org/tomcat-9.0-doc/setup.html](https://tomcat.apache.org/tomcat-9.0-doc/setup.html)

{% post_link server/006-tomcat9-doc-1-introduction prev: Tomcat9-文档1-介绍 %}

# 介绍
有几种方法可以将Tomcat设置为在不同平台上运行。这方面的主要文档是一个名为[RUNNING.txt](https://tomcat.apache.org/tomcat-9.0-doc/RUNNING.txt)的文件。如果以下信息无法解答您的一些问题，我们建议您参考该文件。

# Windows
使用Windows安装程序可以轻松地在Windows上安装Tomcat。它的界面和功能类似于其他基于向导的安装程序，只有少数需要注意的项目。

* 作为服务安装：无论选择何种设置，Tomcat都将作为Windows服务安装。使用组件页面上的复选框将服务设置为“自动”启动，以便在Windows启动时自动启动Tomcat。为获得最佳安全性，该服务应作为单独的用户运行，权限降低（请参阅Windows服务管理工具及其文档）。
* Java位置：安装程序将提供用于运行服务的默认JRE。安装程序使用注册表来确定`Java 8`或更高版本JRE的基本路径，包括作为完整JDK的一部分安装的JRE。在64位操作系统上运行时，安装程​​序将首先查找64位JRE，如果未找到64位JRE，则仅查找32位JRE。使用安装程序检测到的默认JRE不是必需的。可以使用任何已安装的Java 8或更高版本的JRE（32位或64位）。
* 托盘图标：当Tomcat作为服务运行时，Tomcat运行时不会出现任何托盘图标。请注意，在安装结束时选择运行Tomcat时，即使Tomcat作为服务安装，也将使用托盘图标。
* 默认值：可以使用`/C=<config file>`命令行参数覆盖安装程序使用的默认值。配置文件使用格式`name = value`，每对在一个单独的行上。可用配置选项的名称是：
  * JavaHome
  * TomcatPortShutdown
  * TomcatPortHttp
  * TomcatPortAjp
  * TomcatMenuEntriesEnable
  * TomcatShortcutAllUsers
  * TomcatServiceDefaultName
  * TomcatServiceName
  * TomcatServiceFileName
  * TomcatServiceManagerFileName
  * TomcatAdminEnable
  * TomcatAdminUsername
  * TomcatAdminPassword
  * TomcatAdminRoles
  * 通过使用`/C=...`以及`/S`和`/D=`可以执行Apache Tomcat的完全配置,且无需干预。
* 有关如何将Tomcat作为Windows服务进行管理的信息，请参阅[Windows服务操作方法](https://tomcat.apache.org/tomcat-9.0-doc/windows-service-howto.html)。

安装程序将创建允许启动和配置Tomcat的快捷方式。请务必注意，Tomcat管理Web应用程序只能在Tomcat运行时使用。

# Unix守护进程
可以使用`commons-daemon`项目中的`jsvc`工具将Tomcat作为守护程序运行。 jsvc的源代码压缩包包含在Tomcat二进制文件中，需要编译。 构建jsvc需要C ANSI编译器（例如GCC），GNU Autoconf和JDK。

在运行脚本之前，应将`JAVA_HOME`环境变量设置为JDK的基本路径。 或者，在调用`./configure`脚本时，可以使用`--with-java`参数指定JDK的路径，例如`./configure --with-java=/ usr/java`。

使用以下命令应该导致编译的jsvc二进制文件位于`$CATALINA_HOME/bin`文件夹中。 这假定使用了GNU TAR，并且CATALINA_HOME是指向Tomcat安装的基本路径的环境变量。

请注意，您应该在FreeBSD系统上使用GNU make（gmake）而不是本机BSD make。
```s
cd $CATALINA_HOME/bin
tar xvfz commons-daemon-native.tar.gz
cd commons-daemon-1.1.x-native-src/unix
./configure
make
cp jsvc ../..
cd ../..
```
使用下面的命令就可以将tomcat作为守护进程运行：
```s
CATALINA_BASE=$CATALINA_HOME
cd $CATALINA_HOME
./bin/jsvc \
    -classpath $CATALINA_HOME/bin/bootstrap.jar:$CATALINA_HOME/bin/tomcat-juli.jar \
    -outfile $CATALINA_BASE/logs/catalina.out \
    -errfile $CATALINA_BASE/logs/catalina.err \
    -Dcatalina.home=$CATALINA_HOME \
    -Dcatalina.base=$CATALINA_BASE \
    -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager \
    -Djava.util.logging.config.file=$CATALINA_BASE/conf/logging.properties \
    org.apache.catalina.startup.Bootstrap
```
当使用Java 9时，还需要添加额外的配置来避免关闭时的警告：
```s
...
--add-opens=java.base/java.lang=ALL-UNNAMED \
--add-opens=java.base/java.io=ALL-UNNAMED \
--add-opens=java.rmi/sun.rmi.transport=ALL-UNNAMED \
...
```
如果JVM默认使用服务器端的JVM而不是客户端JVM，则可能还需要指定`-jvm server`。这已在OSX上观察到。

`jsvc`还有其他有用的参数，比如 `-user`，它会在守护进程初始化完成后切换到另一个用户。例如，这允许将Tomcat作为非特权用户运行，同时仍然能够使用特权端口。请注意，如果使用此选项并以root身份启动Tomcat，则需要禁用`org.apache.catalina.security.SecurityListener`检查，以阻止以root身份运行时启动Tomcat。

`jsvc --help`将返回完整的jsvc使用信息。特别是，`-debug`选项对于调试运行jsvc的问题很有用。

文件`$ CATALINA_HOME/bin/daemon.sh`可以用作模板，用于在启动时从`/etc/init.d`使用jsvc自动启动Tomcat。

请注意，`Commons-Daemon JAR`文件必须位于运行时类路径上才能以这种方式运行Tomcat。 Commons-Daemon JAR文件位于`bootstrap.jar`清单的Class-Path条目中，但如果您获得Commons-Daemon类的`ClassNotFoundException或NoClassDefFoundError`，则在启动jsvc时将Commons-Daemon JAR添加到`-cp`参数。

<hr>

{% post_link server/008-tomcat9-doc-4-deployer next: Tomcat9-文档3-部署 %}

