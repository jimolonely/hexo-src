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
# 用户友好的HTML界面
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

## 启动现有应用程序

```s
http://localhost:8080/manager/text/start?path=/examples
```
发出停止的应用程序信号以重新启动，并使其自身再次可用例如，如果应用程序所需的数据库暂时不可用，则停止和启动很有用。通常最好停止依赖此数据库的Web应用程序，而不是让用户不断遇到数据库异常。

如果此命令成功，您将看到如下响应：

```s
OK - Started application at context path /examples
```
否则，响应将以FAIL开头并包含错误消息。可能的问题原因包括：

* 遇到异常
    * 尝试启动Web应用程序时遇到异常。检查Tomcat日志以获取详细信息。

* 指定了无效的上下文路径
    * 上下文路径必须以斜杠字符开头。要引用ROOT Web应用程序，请使用“/”。

* path / foo没有上下文
    * 您指定的上下文路径上没有已部署的应用程序。

* 未指定上下文路径
    * path参数是必需的。

## 停止现有的应用程序

```s
http://localhost:8080/manager/text/stop?path=/examples
```
发信号通知现有应用程序使其自身不可用，但将其部署。应用程序停止时进入的任何请求都将看到HTTP错误404，此应用程序将在列表应用程序命令中显示为“已停止”。

如果此命令成功，您将看到如下响应：

```s
OK - Stopped application at context path /examples
```
否则，响应将以FAIL开头并包含错误消息。可能的问题原因包括：

* 遇到异常
    * 尝试停止Web应用程序时遇到异常。检查Tomcat日志以获取详细信息。

* 指定了无效的上下文路径
    * 上下文路径必须以斜杠字符开头。要引用ROOT Web应用程序，请使用“/”。

* path / foo没有上下文
    * 您指定的上下文路径上没有已部署的应用程序。

* 未指定上下文路径path参数是必需的。

## 取消部署现有应用程序

```s
http://localhost:8080/manager/text/undeploy?path=/examples
```
**警告 - 此命令将删除此虚拟主机的`appBase`目录（通常为“`webapps`”）中存在的所有Web应用程序源码。这将删除应用程序`.WAR`（如果存在），应用程序目录来自`unpacked`形式的部署或`.WAR`扩展以及`$CATALINA_BASE/conf/[enginename]/[hostname]/`目录中的XML Context定义。如果您只是想让应用程序停止服务，则应该使用`/stop`命令**。

发信号通知现有应用程序正常关闭自身，并将其从Tomcat中删除（这也使得此上下文路径可供以后重用）。此外，如果文档根目录存在于此虚拟主机的appBase目录（通常为“webapps”）中，则将其删除。此命令与/ deploy命令逻辑相反。

如果此命令成功，您将看到如下响应：

```s
OK - Undeployed application at context path /examples
```
否则，响应将以FAIL开头并包含错误消息。可能的问题原因包括：

* 遇到异常
    * 尝试取消部署Web应用程序时遇到异常。检查Tomcat日志以获取详细信息。

* 指定了无效的上下文路径
    * 上下文路径必须以斜杠字符开头。要引用ROOT Web应用程序，请使用“/”。

* 没有名为/ foo的上下文
    * 没有已指定名称的已部署应用程序。

* 未指定上下文路径path参数是必需的。

## 发现内存泄漏

```s
http://localhost:8080/manager/text/findleaks[?statusLine=[true|false]]
```
查找会触发完整垃圾回收（Full GC）的泄漏诊断。它应该在生产系统中极其谨慎地使用。

查找泄漏诊断尝试识别在停止，重新加载或取消部署时导致内存泄漏的Web应用程序。应始终使用分析器确认结果。诊断使用`StandardHost`实现提供的其他功能。如果使用不扩展`StandardHost`的自定义主机，它将无法工作。

从Java代码中明确触发完整的垃圾收集被记录为不可靠。此外，根据所使用的JVM，还有禁用显式GC触发的选项，如`-XX：+ DisableExplicitGC`。如果要确保诊断程序成功运行完整的GC，则需要使用GC日志记录，JConsole或类似工具进行检查。

如果此命令成功，您将看到如下响应：

```s
/leaking-webapp
```
如果您希望在响应中看到状态行，则在请求中包含`statusLine`查询参数，其值为`true`。

已停止，重新加载或取消部署的Web应用程序的每个上下文路径，但先前运行中的哪些类仍然加载到内存中，从而导致内存泄漏，将列在新行上。如果应用程序已多次重新加载，则可能会多次列出。

如果命令不成功，响应将以FAIL开头并包含错误消息。

实践：

```s
$ curl -u jimo-script:jimo localhost:8080/manager/text/findleaks?statusLine=true
OK - 没有发现内存泄漏
```

## 连接器SSL / TLS密码信息
```s
http://localhost:8080/manager/text/sslConnectorCiphers
```
SSL连接器/密码诊断列出了当前为每个连接器配置的SSL / TLS密码。 对于NIO和NIO2，列出了各个密码套件的名称。 对于APR，返回SSLCipherSuite的值。

响应将如下所示：
```s
OK - Connector / SSL Cipher information
Connector[HTTP/1.1-8080]
  SSL is not enabled for this connector
Connector[HTTP/1.1-8443]
  TLS_ECDH_RSA_WITH_3DES_EDE_CBC_SHA
  TLS_DHE_RSA_WITH_AES_128_CBC_SHA
  TLS_ECDH_RSA_WITH_AES_128_CBC_SHA
  TLS_ECDH_ECDSA_WITH_AES_128_CBC_SHA
  ...
```
实践：
```s
$ curl -u jimo-script:jimo localhost:8080/manager/text/sslConnectorCiphers
OK - Connector/SSL 密码.信息
Connector[HTTP/1.1-8080]
  不允许SSL连接
Connector[AJP/1.3-8009]
  不允许SSL连接
```

## 连接器SSL / TLS证书链信息
```s
http://localhost:8080/manager/text/sslConnectorCerts
```
SSL Connector / Certs诊断列出了当前为每个虚拟主机配置的证书链。

响应将如下所示：

```s
OK - Connector / Certificate Chain information
Connector[HTTP/1.1-8080]
SSL is not enabled for this connector
Connector[HTTP/1.1-8443]-_default_-RSA
[
[
  Version: V3
  Subject: CN=localhost, OU=Apache Tomcat PMC, O=The Apache Software Foundation, L=Wakefield, ST=MA, C=US
  Signature Algorithm: SHA256withRSA, OID = 1.2.840.113549.1.1.11
  ...
```
实践：
```s
$ curl -u jimo-script:jimo localhost:8080/manager/text/sslConnectorCerts
OK - Connector / Certificate Chain information
Connector[HTTP/1.1-8080]
不允许SSL连接
Connector[AJP/1.3-8009]
不允许SSL连接
```

## 连接器SSL / TLS可信证书信息
```s
http://localhost:8080/manager/text/sslConnectorTrustedCerts
```
SSL Connector / Certs诊断列出了当前为每个虚拟主机配置的可信证书。

响应将如下所示：
```s
OK - Connector / Trusted Certificate information
Connector[HTTP/1.1-8080]
SSL is not enabled for this connector
Connector[AJP/1.3-8009]
SSL is not enabled for this connector
Connector[HTTP/1.1-8443]-_default_
[
[
  Version: V3
  Subject: CN=Apache Tomcat Test CA, OU=Apache Tomcat PMC, O=The Apache Software Foundation, L=Wakefield, ST=MA, C=US
  ...
```

## 重新加载TLS配置
```s
http://localhost:8080/manager/text/sslReload?tlsHostName=name
```
重新加载TLS配置文件（证书和密钥文件，这不会触发重新解析`server.xml`）。 要为所有主机重新加载文件，请不要指定tlsHostName参数。
```s
$ curl -u jimo-script:jimo localhost:8080/manager/text/sslReload
FAIL - 重新加载TLS配制失败
```

## 线程转储
```s
http://localhost:8080/manager/text/threaddump
```
编写JVM线程转储。

响应将如下所示：
```s
OK - JVM thread dump
2014-12-08 07:24:40.080
Full thread dump Java HotSpot(TM) Client VM (25.25-b02 mixed mode):

"http-nio-8080-exec-2" Id=26 cpu=46800300 ns usr=46800300 ns blocked 0 for -1 ms waited 0 for -1 ms
   java.lang.Thread.State: RUNNABLE
        locks java.util.concurrent.ThreadPoolExecutor$Worker@1738ad4
        at sun.management.ThreadImpl.dumpThreads0(Native Method)
        at sun.management.ThreadImpl.dumpAllThreads(ThreadImpl.java:446)
        at org.apache.tomcat.util.Diagnostics.getThreadDump(Diagnostics.java:440)
        at org.apache.tomcat.util.Diagnostics.getThreadDump(Diagnostics.java:409)
        at org.apache.catalina.manager.ManagerServlet.threadDump(ManagerServlet.java:557)
        at org.apache.catalina.manager.ManagerServlet.doGet(ManagerServlet.java:371)
        at javax.servlet.http.HttpServlet.service(HttpServlet.java:618)
        at javax.servlet.http.HttpServlet.service(HttpServlet.java:725)
...
```
实践：
```s
$ curl -u jimo-script:jimo localhost:8080/manager/text/threaddump
OK - JVM thread dump
2019-08-21 15:17:32.786
打印全部线程 OpenJDK 64-Bit Server VM (25.222-b10 mixed mode):

"ajp-nio-8009-Acceptor" Id=48 cpu=69203 ns usr=0 ns blocked 0 for -1 ms waited 0 for -1 ms (running in native)
   java.lang.Thread.State: RUNNABLE
	at sun.nio.ch.ServerSocketChannelImpl.accept0(Native Method)
	at sun.nio.ch.ServerSocketChannelImpl.accept(ServerSocketChannelImpl.java:422)
	at sun.nio.ch.ServerSocketChannelImpl.accept(ServerSocketChannelImpl.java:250)
	- locked (a java.lang.Object@226a310c) index 2 frame sun.nio.ch.ServerSocketChannelImpl.accept(ServerSocketChannelImpl.java:250)
	at org.apache.tomcat.util.net.NioEndpoint.serverSocketAccept(NioEndpoint.java:463)
	at org.apache.tomcat.util.net.NioEndpoint.serverSocketAccept(NioEndpoint.java:73)
	at org.apache.tomcat.util.net.Acceptor.run(Acceptor.java:95)
	at java.lang.Thread.run(Thread.java:748)

"ajp-nio-8009-ClientPoller" Id=47 cpu=331431986 ns usr=250000000 ns blocked 0 for -1 ms waited 0 for -1 ms (running in native)
   java.lang.Thread.State: RUNNABLE
	at sun.nio.ch.EPollArrayWrapper.epollWait(Native Method)
	at sun.nio.ch.EPollArrayWrapper.poll(EPollArrayWrapper.java:269)
	at sun.nio.ch.EPollSelectorImpl.doSelect(EPollSelectorImpl.java:93)
	at sun.nio.ch.SelectorImpl.lockAndDoSelect(SelectorImpl.java:86)
	- locked (a sun.nio.ch.EPollSelectorImpl@56c54bf3) index 3 frame sun.nio.ch.SelectorImpl.lockAndDoSelect(SelectorImpl.java:86)
	at sun.nio.ch.SelectorImpl.select(SelectorImpl.java:97)
	at org.apache.tomcat.util.net.NioEndpoint$Poller.run(NioEndpoint.java:708)
	at java.lang.Thread.run(Thread.java:748)
...
```

## VM信息
```s
http://localhost:8080/manager/text/vminfo
```
编写有关Java虚拟机的一些诊断信息。

响应将如下所示：
```s
$ curl -u jimo-script:jimo localhost:8080/manager/text/vminfo
OK - VM信息
2019-08-21 15:19:23.113
运行时信息:
  vmName: OpenJDK 64-Bit Server VM
  vmVersion: 25.222-b10
  vmVendor: Private Build
  specName: Java Virtual Machine Specification
  specVersion: 1.8
  specVendor: Oracle Corporation
  managementSpecVersion: 1.2
  name: 1197@jack
  startTime: 1566366568078
  uptime: 5395096
  isBootClassPathSupported: true

操作系统信息:
  name: Linux
  version: 5.0.0-25-generic
  architecture: amd64
  availableProcessors: 12
  systemLoadAverage: 0.21

ThreadMXBean capabilities:
  isCurrentThreadCpuTimeSupported: true
  isThreadCpuTimeSupported: true
  isThreadCpuTimeEnabled: true
  isObjectMonitorUsageSupported: true
  isSynchronizerUsageSupported: true
  isThreadContentionMonitoringSupported: true
  isThreadContentionMonitoringEnabled: false

线程数:
  daemon: 32
  total: 35
  peak: 35
  totalStarted: 39
...
```

## 保存配置
```s
http://localhost:8080/manager/text/save
```
如果指定不带任何参数，则此命令将服务器的当前配置保存到`server.xml`。 如果需要，现有文件将重命名为备份。

如果使用与已部署的Web应用程序的路径匹配的path参数指定，则该Web应用程序的配置将保存到xmlBase中适当命名的`context.xml`文件中，以用于当前主机。

要使用该命令，必须存在`StoreConfig MBean`。 通常，这是使用[StoreConfigLifecycleListener](https://tomcat.apache.org/tomcat-9.0-doc/config/listeners.html#StoreConfig_Lifecycle_Listener_-_org.apache.catalina.storeconfig.StoreConfigLifecycleListener)配置的。

如果命令不成功，响应将以FAIL开头并包含错误消息。

实践：

```s
$ curl -u jimo-script:jimo localhost:8080/manager/text/save
FAIL - No StoreConfig MBean registered at [Catalina:type=StoreConfig]. 
Registration is typically performed by the StoreConfigLifecycleListener.
```

# 服务器状态
从以下链接中，您可以查看有关服务器的状态信息。 `manager-xxx`角色中的任何一个都允许访问此页面。

```s
http://localhost:8080/manager/status
http://localhost:8080/manager/status/all
```
以HTML格式显示服务器状态信息。
```s
http://localhost:8080/manager/status?XML=true
http://localhost:8080/manager/status/all?XML=true
```
以XML格式显示服务器状态信息。

首先，您有服务器和JVM版本号，JVM提供程序，操作系统名称和编号，后跟架构类型。

其次，有关于JVM的内存使用情况的信息。

然后，有关于Tomcat AJP和HTTP连接器的信息。两者都有相同的信息：

* 线程信息：最大线程数，最小和最大备用线程数，当前线程数和当前线程忙数。

* 请求信息：最大处理时间和处理时间，请求和错误计数，接收和发送的字节数。

* 显示阶段，时间，发送字节，字节接收，客户端，VHost和请求的表。表中列出了所有现有线程。以下是可能的线程阶段列表：

    * “解析和准备请求”：正在解析请求标头或正在进行读取请求主体的必要准备（如果已指定传输编码）。

    * “service”：线程正在处理请求并生成响应。此阶段遵循“解析和准备请求”阶段，并在“完成”阶段之前。此阶段始终至少有一个线程（服务器状态页面）。

    * “finishing”：请求处理结束。仍在输出缓冲区中的任何其余响应都将发送到客户端。如果适当保持连接活动，则此阶段之后是“保持活动”，如果“保持活动”不合适，则“准备好”。

    * “Keep-Alive”：如果客户端发送另一个请求，则线程会保持对客户端的连接打开。如果收到另一个请求，则下一阶段将是“解析和准备请求”。如果在保持活动超时之前没有收到请求，则连接将关闭，下一阶段将为“就绪”。

    * “ready”：线程处于静止状态并准备好使用。

如果您使用`/status/all`命令，则可以使用有关每个已部署Web应用程序的其他信息。

# 使用JMX代理Servlet
## 什么是JMX代理Servlet
JMX代理Servlet是一个轻量级代理，用于获取和设置tomcat内部.（或者通过MBean公开的任何类）其用法不是非常用户友好，但UI对于集成命令行脚本以监视和更改tomcat的内部非常有用。 您可以使用代理执行两项操作：获取信息和设置信息。 为了让您真正了解JMX代理Servlet，您应该对JMX有一个大致的了解。 如果您不知道JMX是什么，那么请准备好遭罪把。



```s
```

```s
```

<hr>

{% post_link server/010-tomcat9-doc-6-host-manager next: Tomcat9-文档5-主机管理 %}