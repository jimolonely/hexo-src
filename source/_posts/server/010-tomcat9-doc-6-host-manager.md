---
title: Tomcat9-文档5-主机管理
tags:
  - tomcat
p: server/010-tomcat9-doc-6-host-manager
date: 2019-08-22 08:59:30
---

本文翻译自：[https://tomcat.apache.org/tomcat-9.0-doc/host-manager-howto.html](https://tomcat.apache.org/tomcat-9.0-doc/host-manager-howto.html)

{% post_link server/009-tomcat9-doc-5-manager prev: Tomcat9-文档4-管理 %}

# 介绍
Tomcat Host Manager应用程序使您可以在Tomcat中创建，删除和管理虚拟主机。本操作指南最好附有以下文档：

* 有关虚拟主机的更多信息，请参阅[虚拟主机方法](https://tomcat.apache.org/tomcat-9.0-doc/virtual-hosting-howto.html)。
* [主机容器](https://tomcat.apache.org/tomcat-9.0-doc/config/host.html)，以获取有关虚拟主机的基础xml配置和属性描述的更多信息。

Tomcat Host Manager应用程序是Tomcat安装的一部分，默认情况下使用以下上下文：`/host-manager`。您可以通过以下方式使用主机管理器：

* 利用图形用户界面，可在以下位置访问：` {server}:{port}/host-manager/html`。
* 利用一组适合脚本编写的最小HTTP请求。您可以在以下位置访问此模式：` {server}:{port}/host-manager/text`。

这两种方式都允许您添加，删除，启动和停止虚拟主机。可以使用persist命令预先进行更改。本文档重点介绍文本界面。有关图形界面的更多信息，请参阅[Host Manager App  -  HTML界面](https://tomcat.apache.org/tomcat-9.0-doc/html-host-manager-howto.html)。

# 配置Manager应用的访问权限
下面的描述使用`$CATALINA_HOME`来引用基本Tomcat目录。它是您安装Tomcat的目录，例如`C:\tomcat9`, or `/usr/share/tomcat9`。

Host Manager应用程序要求用户具有以下角色之一：

* `admin-gui`  - 将此角色用于图形Web界面。
* `admin-script`  - 将此角色用于脚本Web界面。

要启用对Host Manager应用程序的文本界面的访问，请为Tomcat用户授予适当的角色，或者创建具有正确角色的新角色。例如，打开`${CATALINA_BASE}/conf/tomcat-users.xml`并输入以下内容：
```xml
<user username="test" password="chang3m3N#w" roles="admin-script"/>
```
无需进一步设置。当您现在访问` {server}:{port}/host-manager/text/${COMMAND}`时，您可以使用创建的凭据登录。例如：

```s
$ curl -u ${USERNAME}:${PASSWORD} http://localhost:8080/host-manager/text/list
OK - Listed hosts
localhost:
```
请注意，如果使用`DataSourceRealm`，`JDBCRealm`或`JNDIRealm`机制检索用户，请分别在数据库或目录服务器中添加适当的角色。

# 命令列表
支持以下命令：

* list
* add
* remove
* start
* stop
* persist

在以下小节中，假定用户名和密码为`test:test`。 对于您的环境，请使用前面部分中创建的凭据。

## list命令
使用list命令查看Tomcat实例上的可用虚拟主机。

示例命令：
```s
curl -u test:test http://localhost:8080/host-manager/text/list
```
实践：
```s
$ curl -u jimo-host-script:jimo localhost:8080/host-manager/text/list
OK - 已列出Host
[localhost]:[]
```

## add命令
使用add命令添加新的虚拟主机。用于add命令的参数：

* String name：虚拟主机的名称。需要
* String aliases：虚拟主机的别名。
* String appBase：将由此虚拟主机提供服务的应用程序的基本路径。提供相对或绝对路径。
* Boolean manager：如果为true，则将Manager应用程序添加到虚拟主机。您可以使用`/manager`上下文访问它。
* Boolean autoDeploy：如果为true，Tomcat会自动重新部署appBase目录中的应用程序。
* Boolean deployOnStartup：如果为true，则Tomcat会在启动时自动部署appBase目录中的应用程序。
* Boolean deployXML：如果为true，则Tomcat将读取并使用`/META-INF/context.xml`文件。
* Boolean copyXML：如果为true，则Tomcat会复制`/META-INF/context.xml`文件并使用原始副本，而不管应用程序的`/META-INF/context.xml`文件的更新如何。

示例命令：
```s
curl -u test:test http://localhost:8080/host-manager/text/add?name=www.awesomeserver.com\
&aliases=awesomeserver.com&appBase/mnt/appDir&deployOnStartup=true
```
响应示例：
```s
add: Adding host [www.awesomeserver.com]
```
实践：
```s
$ curl -u jimo-host-script:jimo localhost:8080/host-manager/text/add?name=www.jimo.com\
> &aliases=jimo.com&appBase=/home/jack/workspace/temp/&deployOnStartUp=true
[1] 21859
[2] 21860
[3] 21861
[2]-  已完成               aliases=jimo.com
确定-添加主机[www.jimo.com]
[1]-  已完成               curl -u jimo-host-script:jimo localhost:8080/host-manager/text/add?name=www.jimo.com
[3]+  已完成               appBase=/home/jack/workspace/temp/
```
结果： `${CATALINA_HOME}`和`${CATALINA_HOME}/conf/catalina/`下都出现了`www.jimo.com`目录


## start命令
使用start命令启动虚拟主机。 用于start命令的参数：

* 字符串name：要启动的虚拟主机的名称。 需要

示例命令：
```s
curl -u test:test http://localhost:8080/host-manager/text/start?name=www.awesomeserver.com
```
响应示例：
```s
OK - Host www.awesomeserver.com started
```
实践：
```s
$ curl -u jimo-host-script:jimo localhost:8080/host-manager/text/start?name=www.jimo.com
失败 - Host[www.jimo.com]已经启动。
```

## stop命令
使用stop命令停止虚拟主机。 用于stop命令的参数：

* 字符串name：要停止的虚拟主机的名称。 需要

示例命令：
```s
curl -u test:test http://localhost:8080/host-manager/text/stop?name=www.awesomeserver.com
```
响应示例：
```s
OK - Host www.awesomeserver.com stopped
```
实践：
```s
$ curl -u jimo-host-script:jimo localhost:8080/host-manager/text/stop?name=www.jimo.com
OK - 主机 [www.jimo.com] 已停止
```

## persist命令
使用persist命令将虚拟主机持久保存到`server.xml`中。 用于persist命令的参数：

* 字符串name：要保留的虚拟主机的名称。 需要

默认情况下禁用此功能。 要启用此选项，必须首先配置`StoreConfigLifecycleListener`侦听器。 为此，请将以下侦听器添加到`server.xml`：

```xml
<Listener className="org.apache.catalina.storeconfig.StoreConfigLifecycleListener"/>
```
示例命令：
```s
curl -u test:test http://localhost:8080/host-manager/text/persist?name=www.awesomeserver.com
```
响应示例：
```s
OK - Configuration persisted
```
手动输入示例：

```xml
<Host appBase="www.awesomeserver.com" name="www.awesomeserver.com" deployXML="false" unpackWARs="false">
</Host>
```
实践：
```s
# 未开启功能
$ curl -u jimo-host-script:jimo localhost:8080/host-manager/text/persist?name=www.jimo.com
失败 - 无法持久化配置
Please enable StoreConfig to use this feature.

# 开启之后： 记得重启tomcat， 重启完后之前add的主机会丢失，需要重新添加
$ curl -u jimo-host-script:jimo localhost:8080/host-manager/text/persist?name=www.jimo.com
OK - 配置持久化了.

# server.xml里增加了Host
      <Host appBase="www.jimo.com" name="www.jimo.com">
      </Host>
```
每次持久化，server.xml都会被备份：
```s
apache-tomcat-9.0.24/conf$ ll server.xml*
-rw-r----- 1 jack jack 1906 8月  22 09:58 server.xml
-rw-r--r-- 1 jack jack 7767 8月  22 09:52 server.xml.2019-08-22.09-54-11
-rw-r----- 1 jack jack 1836 8月  22 09:54 server.xml.2019-08-22.09-58-47
```

## remove命令
使用remove命令删除虚拟主机。 用于remove命令的参数：

* 字符串name：要删除的虚拟主机的名称。 需要

示例命令：
```s
curl -u test:test http://localhost:8080/host-manager/text/remove?name=www.awesomeserver.com
```
响应示例：
```s
remove: Removing host [www.awesomeserver.com]
```
实践：
```s
$ curl -u jimo-host-script:jimo localhost:8080/host-manager/text/remove?name=www.jimo.com
确定-已删除主机[www.jimo.com]

$ curl -u jimo-host-script:jimo localhost:8080/host-manager/text/persist?name=www.jimo.com
OK - 配置持久化了.
```

<hr>


