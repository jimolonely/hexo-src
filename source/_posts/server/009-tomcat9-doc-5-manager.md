---
title: Tomcat9-文档4-管理
tags:
  - tomcat
p: server/009-tomcat9-doc-5-manager
date: 2019-08-20 13:38:08
---

本文翻译自：[https://tomcat.apache.org/tomcat-9.0-doc/manager-howto.html](https://tomcat.apache.org/tomcat-9.0-doc/manager-howto.html)

{% post_link server/008-tomcat9-doc-4-deployer prev: Tomcat9-文档3-部署 %}

# 介绍
在许多生产环境中，部署新Web应用程序或取消部署现有Web应用程序的功能非常有用，而无需关闭并重新启动整个容器。此外，即使您尚未在Tomcat服务器配置文件中声明可重新加载，也可以请求现有应用程序重新加载。

为了支持这些功能，Tomcat包括一个Web应用程序（默认安装在上下文路径/`manager`上），它支持以下功能：

* 从WAR文件的上载内容部署新的Web应用程序。
* 从服务器文件系统在指定的上下文路径上部署新的Web应用程序。
* 列出当前部署的Web应用程序，以及当前为这些Web应用程序处于活动状态的会话。
* 重新加载现有Web应用程序，以反映`/WEB-INF/classes or /WEB-INF/lib`内容的更改。
* 列出OS和JVM属性值。
* 列出可用的全局JNDI资源，以便在准备嵌套在`<Context>`部署描述中的`<ResourceLink>`元素的部署工具中使用。
* 启动已停止的应用程序（从而使其再次可用）。
* 停止现有应用程序（以使其变得不可用），但不要取消部署它。
* 取消部署已部署的Web应用程序并删除其文档基目录（除非它是从文件系统部署的）。

默认的Tomcat安装包括Manager。要将Manager Web应用程序Context的实例添加到新主机，请在` $CATALINA_BASE/conf/[enginename]/[hostname]`文件夹中安装`manager.xml`上下文配置文件。这是一个例子：(PS: 这里的enginename一般是指Catalina)

```xml
<Context privileged="true" antiResourceLocking="false"
         docBase="${catalina.home}/webapps/manager">
  <Valve className="org.apache.catalina.valves.RemoteAddrValve"
         allow="127\.0\.0\.1" />
</Context>
```
如果您将Tomcat配置为支持多个虚拟主机（网站），则需要为每个虚拟主机配置一个Manager。

有三种方法可以使用Manager Web应用程序。

* 作为具有用户界面的应用程序，您可以在浏览器中使用。 下面是一个示例URL，您可以在其中将`localhost`替换为您的网站主机名：`http://localhost:8080/manager/html`。
* 仅使用HTTP请求的最小版本，适用于系统管理员设置的脚本。 命令作为请求URI的一部分给出，响应采用简单文本的形式，可以很容易地进行解析和处理。 有关更多信息，请参阅[支持的管理器命令](https://tomcat.apache.org/tomcat-9.0-doc/manager-howto.html#Supported_Manager_Commands)
* Ant（1.4版或更高版本）构建工具的一组方便的任务定义。 有关更多信息，请参阅[使用Ant执行Manager命令](https://tomcat.apache.org/tomcat-9.0-doc/manager-howto.html#Executing_Manager_Commands_With_Ant)。

# 配置Manager应用的访问权限
下面的描述使用变量名`$CATALINA_BASE`来引用解析大多数相对路径的基目录。如果尚未通过设置`CATALINA_BASE`目录为多个实例配置Tomcat，则`$CATALINA_BASE`将设置为`$CATALINA_HOME`的值，即已安装Tomcat的目录。

使用默认设置使用Tomcat是非常不安全的，这些设置允许Internet上的任何人在您的服务器上执行Manager应用程序。因此，Manager应用程序出厂时要求尝试使用它的任何人必须使用具有与之关联的`manager-xxx`角色之一的用户名和密码进行身份验证（角色名称取决于所需的功能）。此外，分配给这些角色的默认用户文件（`$CATALINA_BASE/conf/tomcat-users.xml`）中没有用户名。**因此，默认情况下完全禁用对Manager应用程序的访问**。

您可以在Manager Web应用程序的`web.xml`文件中找到角色名称。可用的角色是：

* manager-gui  - 访问HTML界面。
* manager-status  - 仅访问“服务器状态”页面。
* manager-script  - 访问本文档中描述的工具友好的纯文本界面，以及“服务器状态”页面。
* manager-jmx  - 访问JMX代理接口和“服务器状态”页面。

HTML接口受到CSRF（跨站点请求伪造）攻击的保护，但文本和JMX接口无法受到保护。这意味着在使用Web浏览器访问Manager应用程序时，允许访问文本和JMX界面的用户必须小心谨慎。为了保持CSRF保护：

* 如果使用Web浏览器使用具有`manager-script`或`manager-jmx`角色的用户访问Manager应用程序（例如，用于测试纯文本或JMX接口），则必须先关闭浏览器的所有窗口以终止会话。如果您不关闭浏览器并访问其他站点，您可能会成为CSRF攻击的受害者。
* 建议永远不要将`manager-script`或`manager-jmx`角色授予具有`manager-gui`角色的用户。

**请注意，JMX代理接口实际上是Tomcat的像超级权限的低级管理接口。如果他知道要调用什么命令，那么可以做很多事情。启用`manager-jmx`角色时应该谨慎**。

要启用对Manager Web应用程序的访问，您必须创建新的用户名/密码组合并将其中一个`manager-xxx`角色与其关联，或者将manager-xxx角色添加到某些现有用户名/密码组合中。由于本文档的大部分内容都描述了使用文本界面，因此本示例将使用角色`manager-script`。具体如何配置用户名/密码取决于您使用的[Realm实现](https://tomcat.apache.org/tomcat-9.0-doc/config/realm.html)：

* `UserDatabaseRealm`加上`MemoryUserDatabase`或`MemoryRealm`  -  UserDatabaseRealm和MemoryUserDatabase在默认的`$CATALINA_BASE/conf/server.xml`中配置.MemoryUserDatabase和MemoryRealm都默认读取存储在`$CATALINA_BASE/conf/tomcat-users.xml`的XML格式文件，可以使用任何文本编辑器进行编辑。此文件包含每个用户的XML `<user>`标签，可能如下所示：
    * `<user username =“craigmcc”password =“secret”roles =“standard，manager-script”/>`
    * 它定义了此人登录时使用的用户名和密码，以及与其关联的角色名称。您可以将`manager-script`角色添加到一个或多个现有用户的逗号分隔角色属性，和/或 使用该分配的角色创建新用户。
* DataSourceRealm或JDBCRealm  - 您的用户和角色信息存储在通过JDBC访问的数据库中。根据环境的标准过程，将`manager-script`角色添加到一个或多个现有用户，和/或 创建一个或多个已分配此角色的新用户。
* JNDIRealm  - 您的用户和角色信息存储在通过LDAP访问的目录服务器中。根据环境的标准过程，将`manager-script`角色添加到一个或多个现有用户，和/或创建一个或多个已分配此角色的新用户。

第一次尝试发出下一节中描述的Manager命令之一时，您将面临使用BASIC身份验证登录的挑战。您输入的用户名和密码无关紧要，只要它们在用户数据库中标识拥有角色管理器脚本的有效用户即可。

除了密码限制之外，通过添加`RemoteAddrValve`或`RemoteHostValve`，远程IP地址或主机可以限制对Manager Web应用程序的访问。有关详情，请参阅[阀门文档](https://tomcat.apache.org/tomcat-9.0-doc/config/valve.html#Remote_Address_Filter)以下是通过IP地址限制对localhost的访问的示例：


```xml
<Context privileged="true">
         <Valve className="org.apache.catalina.valves.RemoteAddrValve"
                allow="127\.0\.0\.1"/>
</Context>
```
# 用户友好的HTMML界面
Manager Web应用程序的用户友好HTML界面位于

```s
http://{host}:{port}/manager/html
```

如上所述，您需要`manager-gui`角色才能访问它。 有一个单独的文档，提供有关此接口的帮助。 看：

* [HTML Manager文档](https://tomcat.apache.org/tomcat-9.0-doc/html-manager-howto.html)

HTML接口受到CSRF（跨站点请求伪造）攻击的保护。 每次访问HTML页面都会生成一个随机令牌，该令牌存储在您的会话中，并包含在页面上的所有链接中。 如果您的下一个操作没有正确的令牌值，则该操作将被拒绝。 如果令牌已过期，您可以从Manager的主页面或列表应用程序页面重新开始。

## 实践环节
这一节是我自己加的，边读文档边实践。

1. 在`apache-tomcat-9.0.24/conf/Catalina/localhost/`下建立`manager.xml`文件：
    ```xml
    <Context privileged="true">
            <Valve className="org.apache.catalina.valves.RemoteAddrValve"
                    allow="127\.0\.0\.1"/>
    </Context>
    ```
2. 在`tomcat-users.xml`里增加角色：
    ```xml
    <role rolename="manager-gui"/>
    <user username="jimo" password="jimo" roles="manager-gui,manager-status"/>
    <user username="jimo-script" password="jimo" roles="manager-script"/>
    ```
3. 在chrome浏览器访问： `localhost:8080/manager/html`
    * 结果找不到网页

4. 在firefox中访问：会弹出basic验证的用户名密码输入框，可以正常访问

5. 通过命令行访问： `curl -u jimo:jimo localhost:8080/manager/html`

实践结果：谷歌浏览器不知啥时候禁用了BASIC验证，开发者还是使用firefox把。


# 支持的Manager命令
Manager应用程序知道如何处理的所有命令都在单个请求URI中指定，如下所示：

```s
http://{host}:{port}/manager/text/{command}?{parameters}
```

其中`{host}`和`{port}`表示运行Tomcat的主机名和端口号，`{command}`表示您希望执行的Manager命令，`{parameters}`表示特定于该命令的查询参数。在下面的插图中，根据您的安装自定义主机和端口。

这些命令通常由HTTP GET请求执行。 `/deploy`命令具有由`HTTP PUT`请求执行的表单。

## 常用参数
大多数命令接受以下一个或多个查询参数：

* path - 您正在处理的Web应用程序的上下文路径（包括前导斜杠）。要选择ROOT Web应用程序，请指定`“/”`。
    * 注意：无法在Manager应用程序本身上执行管理命令。
    * 注意：如果未明确指定path参数，则将使用config参数中的标准上下文命名规则或如果config参数不存在而使用war参数来派生路径和版本。
* version - [并行部署](https://tomcat.apache.org/tomcat-9.0-doc/config/context.html)功能使用的此Web应用程序的版本。如果在需要路径的任何地方使用并行部署，则必须指定除路径之外的版本，并且路径和版本的组合必须是唯一的，而不仅仅是路径。
    * 注意：如果未明确指定路径，则忽略version参数。
* war - Web应用程序归档（WAR）文件的URL，或包含Web应用程序的目录的路径名，或Context的配置文件`".xml"`。您可以使用以下任何格式的网址：
    * `file:/absolute/path/to/a/directory` - 包含Web应用程序的解压缩版本的目录的绝对路径。此目录将附加到您指定的上下文路径，而不进行任何更改。
    * `file:/absolute/path/to/a/webapp.war` -  Web应用程序归档（WAR）文件的绝对路径。这仅对`/deploy`命令有效，并且是该命令唯一可接受的格式。
    * `file/absolute/path/to/a/context.xml`  -  Web应用程序的绝对路径上下文配置“.xml”文件，其中包含Context配置元素。
    * `directory`  - 主机应用程序基目录中Web应用程序上下文的目录名称。
    * `webapp.war`  - 位于主机应用程序基目录中的Web应用程序war文件的名称。

每个命令将以`text/plain`格式返回响应（即没有HTML标记的纯ASCII），使人和程序都能轻松阅读）。响应的第一行将以OK或FAIL开头，指示请求的命令是否成功。如果失败，第一行的其余部分将包含遇到的问题的描述。一些命令包括如下所述的附加信息行。

国际化注 -  Manager应用程序在资源包中查找其消息字符串，因此可能已为您的平台翻译了字符串。以下示例显示了消息的英文版本。

## 远程部署应用程序存档（WAR）

```s
http://localhost:8080/manager/text/deploy?path=/foo
```
在HTTP PUT请求中指定为Web应用程序归档（WAR）文件为请求体，将其安装到相应虚拟主机的`appBase`目录中，然后启动，从中导出添加到appBase的WAR文件的名称。稍后可以使用`/undeploy`命令取消部署应用程序（并删除相应的WAR文件）。

该命令由HTTP PUT请求执行。

`.WAR`文件可以包括Tomcat特定的部署配置，在`/META-INF/context.xml`中包含Context配置XML文件。

URL参数包括：

* `update`：设置为true时，将首先取消部署任何现有更新。默认值设置为false。
* `tag`：指定标记名称，这允许将已部署的webapp与标记或标签相关联。如果取消部署Web应用程序，则可以在需要时仅使用标记重新部署它。
* `config`：格式文件中的Context配置“.xml”文件的URL：`/absolute/path/to/a/context.xml`。这必须是Web应用程序上下文配置“.xml”文件的`绝对路径`，该文件包含Context配置元素。

注 - 该命令与`/undeploy`命令逻辑相反。

如果安装和启动成功，您将收到如下响应：

```s
OK - Deployed application at context path /foo
```

否则，响应将以`FAIL`开头并包含错误消息。可能的问题原因包括：

* 应用程序已经存在于`path/foo`中
    * 所有当前运行的Web应用程序的上下文路径必须是唯一的。因此，必须使用此上下文路径取消部署现有Web应用程序，或为新应用程序选择其他上下文路径。可以将update参数指定为URL上的参数，值为true以避免此错误。在这种情况下，将在执行部署之前对现有应用程序执行取消部署。
* 遇到异常
    * 尝试启动新的Web应用程序时遇到异常。检查Tomcat日志以获取详细信息，但可能的解释包括解析`/WEB-INF/web.xml`文件时出现问题，或者在初始化应用程序事件侦听器和过滤器时遇到缺少的类。

## 从本地路径部署新应用程序
部署并启动一个新的Web应用程序，该应用程序附加到指定的上下文路径（任何其他Web应用程序都不能使用它）。此命令与`/undeploy`命令逻辑相反。

此命令由HTTP GET请求执行。可以使用许多不同的方法来使用deploy命令。

### 部署以前部署的Web应用程序

```s
http://localhost:8080/manager/text/deploy?path=/footoo&tag=footag
```

这可用于部署先前部署的Web应用程序，该应用程序已使用tag属性进行部署。请注意，Manager webapp的工作目录将包含以前部署的WAR;删除它会使部署失败。

### 按URL部署 目录或WAR
部署位于Tomcat服务器上的Web应用程序目录或`".war"`文件。如果未指定路径，则路径和版本将从目录名称或war文件名称派生。 `war`参数指定目录或Web应用程序归档（WAR）文件的URL（包括`file:`scheme）。引用WAR文件的URL支持的语法在`java.net.JarURLConnection`类的Javadocs页面上描述。仅使用引用整个WAR文件的URL。

在此示例中，位于Tomcat服务器上的目录`/path/to/foo`中的Web应用程序被部署为名为`/footoo`的Web应用程序上下文。

```s
http://localhost:8080/manager/text/deploy?path=/footoo&war=file:/path/to/foo
```

在此示例中，Tomcat服务器上的“.war”文件`/path/to/bar.war`被部署为名为`/bar`的Web应用程序上下文。请注意，如果没有路径参数，那么上下文路径默认为没有“.war”扩展名的Web应用程序归档文件的名称（如下为：`bar`）。

```s
http://localhost:8080/manager/text/deploy?war=file:/path/to/bar.war
```

### 从主机appBase部署 目录或war包
部署位于Host appBase目录中的Web应用程序目录或“.war”文件。路径和可选版本派生自目录或war文件名。

在此示例中，位于Tomcat服务器的Host appBase目录中名为`foo`的子目录中的Web应用程序被部署为名为`/foo`的Web应用程序上下文。请注意，使用的上下文路径是Web应用程序目录的名称。

```s
http://localhost:8080/manager/text/deploy?war=foo
```
在下面示例中，位于Tomcat服务器上的Host appBase目录中的“.war”文件bar.war被部署为名为`/bar`的Web应用程序上下文。

```s
http://localhost:8080/manager/text/deploy?war=bar.war
```

### 使用Context ".xml"配置文件进行部署
如果Host deployXML标志设置为true，则可以使用Context ".xml"配置文件和可选的`".war"`文件或Web应用程序目录来部署Web应用程序。使用上下文“.xml”配置文件部署Web应用程序时，不使用上下文路径。

Context配置“.xml”文件可以包含Web应用程序的有效XML，就像在Tomcat `server.xml`配置文件中配置它一样。这是一个例子：

```xml
<Context path="/foobar" docBase="/path/to/application/foobar">
</Context>
```

当可选的war参数设置为Web应用程序“.war”文件或目录的URL时，它将覆盖在上下文配置“.xml”文件中配置的任何docBase。

以下是使用Context配置“.xml”文件部署应用程序的示例。

```s
http://localhost:8080/manager/text/deploy?config=file:/path/context.xml
```

以下是使用Context配置“.xml”文件和位于服务器上的Web应用程序“.war”文件部署应用程序的示例。

```s
http://localhost:8080/manager/text/deploy
 ?config=file:/path/context.xml&war=file:/path/bar.war
```
### 部署说明
如果Host配置了`unpackWARs = true`并且您部署了war文件，则war将被解压缩到Host appBase目录中的目录中。

如果应用程序war或目录安装在Host appBase目录中，并且Host配置了`autoDeploy = true`，Context路径必须与目录名称或war文件名不匹配，而不是“.war”扩展名。

为了在不受信任的用户可以管理Web应用程序时的安全性，可以将Host `deployXML`标志设置为false。这可以防止不受信任的用户使用配置XML文件部署Web应用程序，并防止他们部署位于其主机appBase之外的应用程序目录或“.war”文件。

### 部署响应
如果安装和启动成功，您将收到如下响应：

```s
OK - Deployed application at context path /foo
```
否则，响应将以FAIL开头并包含错误消息。可能的问题原因包括：

* 应用程序已经存在于`path/foo`中
    * 所有当前运行的Web应用程序的上下文路径必须是唯一的。因此，必须使用此上下文路径取消部署现有Web应用程序，或为新应用程序选择其他上下文路径。可以将update参数指定为URL上的参数，值为true以避免此错误。在这种情况下，将在执行部署之前对现有应用程序执行取消部署。

* `docBase`不存在或不是可读目录
    * war参数指定的URL必须标识此服务器上包含Web应用程序的“解压缩”版本的目录，或包含此应用程序的Web应用程序归档（WAR）文件的绝对URL。更正war参数指定的值。

* 遇到异常
    * 尝试启动新的Web应用程序时遇到异常。检查Tomcat日志以获取详细信息，但可能的解释包括解析`/WEB-INF/web.xml`文件时出现问题，或者在初始化应用程序事件侦听器和过滤器时遇到缺少的类。

* 指定了无效的应用程序URL
    * 您指定的目录或Web应用程序的URL无效。此类URL必须以`file:`开头，WAR文件的URL必须以“.war”结尾。

* 指定了无效的上下文路径
    * 上下文路径必须以斜杠字符开头。要引用ROOT Web应用程序，请使用“/”。

* 上下文路径必须与目录或WAR文件名匹配：
    * 如果应用程序war或目录安装在Host appBase目录中，并且Host配置了`autoDeploy = true`，则Context路径必须与没有“.war”扩展名的目录名或war文件名匹配。

* 只能安装Host Web应用程序目录中的Web应用程序
    * 如果Host deployXML标志设置为false，则尝试在Host appBase目录之外部署Web应用程序目录或“.war”文件时，将发生此错误。

## 列出当前部署的应用程序
列出所有当前部署的Web应用程序的上下文路径，当前状态（运行或已停止）以及活动会话数。 启动Tomcat后立即执行的典型响应可能如下所示：

```s
$ curl -u jimo-script:jimo localhost:8080/manager/text/list
OK - Listed applications for virtual host [localhost]
/:running:0:ROOT
/spring-boot-pkg-war-0.0.1:running:0:spring-boot-pkg-war-0.0.1
/examples:running:0:examples
/host-manager:running:0:host-manager
/spring-boot-pkg-war:running:0:spring-boot-pkg-war
/manager:running:0:manager
/docs:running:0:docs
```

## 重新加载现有应用程序
```s
http://localhost:8080/manager/text/reload?path=/examples
```
发信号通知现有应用程序关闭并重新加载。当Web应用程序上下文不可重新加载并且您在`/WEB-INF/classes`目录中更新了类或属性文件，或者在`/WEB-INF/lib`目录中添加或更新了jar文件时，这非常有用。

如果此命令成功，您将看到如下响应：

```s
OK - Reloaded application at context path /examples
```

否则，响应将以FAIL开头并包含错误消息。可能的问题原因包括：

* 遇到异常
    * 尝试重新启动Web应用程序时遇到异常。检查Tomcat日志以获取详细信息。

* 指定了无效的上下文路径
    * 上下文路径必须以斜杠字符开头。要引用ROOT Web应用程序，请使用“/”。

* `path/foo`没有上下文
    * 您指定的上下文路径上没有已部署的应用程序。

* 未指定上下文路径
    * path参数是必需的。

* 在路径`/foo`上部署的WAR不支持重新加载
    * 当前，直接从WAR文件部署Web应用程序时，不支持应用程序重新加载（以获取对类或web.xml文件的更改）。它仅在从解压缩目录部署Web应用程序时才有效。如果您使用的是WAR文件，则应取消部署，然后再使用update参数部署或部署应用程序以获取更改。

实践练习：

```s
$ curl -u jimo-script:jimo localhost:8080/manager/text/reload?path=/spring-boot-pkg-war
OK - Reloaded application at context path [/spring-boot-pkg-war]
$ curl -u jimo-script:jimo localhost:8080/manager/text/reload?path=/xxx
FAIL - No context exists named [&#47;xxx]
```

## 列出OS和JVM属性
```s
http://localhost:8080/manager/text/serverinfo
```

列出有关Tomcat版本，操作系统和JVM属性的信息。

如果发生错误，响应将以FAIL开头并包含错误消息。可能的问题原因包括：

* 遇到异常
    * 尝试枚举系统属性时遇到异常。检查Tomcat日志以获取详细信息。

```s
$ curl -u jimo-script:jimo localhost:8080/manager/text/serverinfo

OK - Server info
Tomcat Version: [Apache Tomcat/9.0.24]
OS Name: [Linux]
OS Version: [5.0.0-25-generic]
OS Architecture: [amd64]
JVM Version: [1.8.0_222-8u222-b10-1ubuntu1~18.04.1-b10]
JVM Vendor: [Private Build]
```

## 列出可用的全局JNDI资源

```s
http://localhost:8080/manager/text/resources[?type=xxxxx]
```

列出可在上下文配置文件的资源链接中使用的全局JNDI资源。如果指定类型请求参数，则该值必须是您感兴趣的资源类型的完全限定Java类名称（例如，您将指定`javax.sql.DataSource`以获取所有可用JDBC数据源的名称）。如果未指定类型请求参数，则将返回所有类型的资源。

根据是否指定了类型请求参数，正常响应的第一行将是：

```s
OK - Listed global resources of all types
```
要么
```s
OK - Listed global resources of type xxxxx
```

每个资源后跟一行。每行由冒号字符（“：”）分隔的字段组成，如下所示：

* 全局资源名称 - 此全局JNDI资源的名称，该资源将在`<ResourceLink>`元素的全局属性中使用。
* 全局资源类型 - 此全局JNDI资源的完全限定Java类名。

如果发生错误，响应将以FAIL开头并包含错误消息。可能的问题原因包括：

* 遇到异常
    * 尝试枚举全局JNDI资源时遇到异常。检查Tomcat日志以获取详细信息。

* 没有可用的全局JNDI资源
    * 您运行的Tomcat服务器已配置为没有全局JNDI资源。

实践：


```s
$ curl -u jimo-script:jimo localhost:8080/manager/text/resources
OK - 列出所有类型的全部资源
UserDatabase:org.apache.catalina.users.MemoryUserDatabase
```

## 会话统计

```s
http://localhost:8080/manager/text/sessions?path=/examples
```

显示Web应用程序的默认会话超时，以及在实际超时时间的一分钟范围内的当前活动会话数。例如，在重新启动Tomcat然后执行`/examples` Web应用程序中的一个JSP示例后，您可能会得到如下内容：

```s
OK - Session information for application at context path /examples
Default maximum session inactive interval 30 minutes
<1 minutes: 1 sessions
1 - <2 minutes: 1 sessions
```
实践：
```s
$ curl -u jimo-script:jimo localhost:8080/manager/text/sessions?path=/manager
OK - Session information for application at context path [/manager]
Default maximum session inactive interval is [30] minutes
```

## 过期会话
```s
http://localhost:8080/manager/text/expire?path=/examples&idle=num
```

显示会话统计信息（如上面的`/sessions`命令），并使空闲时间超过num分钟的会话到期。要使所有会话到期，请使用`＆idle = 0`。

```s
OK - Session information for application at context path /examples
Default maximum session inactive interval 30 minutes
1 - <2 minutes: 1 sessions
3 - <4 minutes: 1 sessions
>0 minutes: 2 sessions were expired
```

实际上`/sessions`和`/expire`是同一命令的同义词。不同之处在于存在空闲参数。

实践：
```s
$ curl -u jimo-script:jimo localhost:8080/manager/text/expire?path=/spring-boot-pkg-war&idle=1
[1] 4560
```


```s
```

```s
```

