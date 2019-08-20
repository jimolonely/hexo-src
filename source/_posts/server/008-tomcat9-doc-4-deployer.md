---
title: Tomcat9-文档3-部署
tags:
  - tomcat
p: server/008-tomcat9-doc-4-deployer
date: 2019-08-20 11:02:33
---

本文翻译自：[https://tomcat.apache.org/tomcat-9.0-doc/deployer-howto.html](https://tomcat.apache.org/tomcat-9.0-doc/deployer-howto.html)

{% post_link server/007-tomcat9-doc-2-setup prev: Tomcat9-文档2-安装 %}

# 介绍
部署是用于将Web应用程序（第三方WAR或您自己的自定义Web应用程序）安装到Tomcat服务器的过程中的术语。

Web应用程序部署可以在Tomcat服务器中以多种方式完成。

* 静态;在Tomcat启动之前设置Web应用程序
* 动态;通过直接操作已部署的Web应用程序（依赖于自动部署功能）或使用Tomcat Manager Web应用程序远程操作

[Tomcat Manager](https://tomcat.apache.org/tomcat-9.0-doc/manager-howto.html)是一个Web应用程序，可以交互使用（通过HTML GUI）或以编程方式（通过基于URL的API）来部署和管理Web应用程序。

有许多方法可以执行依赖Manager Web应用程序的部署。 Apache Tomcat为Apache Ant构建工具提供任务。 [Apache Tomcat Maven插件](https://tomcat.apache.org/maven-plugin.html)项目提供与Apache Maven的集成。还有一个名为`Client Deployer`的工具，可以从命令行使用，并提供其他功能，例如编译和验证Web应用程序以及将Web应用程序打包到Web应用程序资源（WAR）文件中。

# 安装
静态部署Web应用程序不需要安装，因为Tomcat提供了开箱即用的功能。虽然[Tomcat Manager手册](https://tomcat.apache.org/tomcat-9.0-doc/manager-howto.html)中详细说明了某些配置，但Tomcat Manager的部署功能也不需要任何安装。但是，如果您希望使用Tomcat客户端部署程序（TCD: tomcat client deployer），则需要安装。

TCD**未与**Tomcat核心发行版一起打包，因此必须从“下载”区域单独下载。下载通常标记为`apache-tomcat-9.0.x-deployer`。

TCD具有`Apache Ant 1.6.2+`和Java安装的先决条件。您的环境应定义指向Ant安装根目录的`ANT_HOME`环境值，以及指向Java安装的`JAVA_HOME`值。此外，您应该确保Ant的ant命令，并且`Java javac`编译器命令从您的操作系统提供的命令shell运行。

1. 下载TCD发行版
2. 不需要将TCD包提取到任何现有的Tomcat安装中，它可以被提取到任何位置。
3. 阅读使用[Tomcat客户端部署程序](#使用客户端部署程序包(TCD)进行部署)

# 关于上下文的概念
在谈论Web应用程序的部署时，需要理解Context的概念。 Context在Tomcat称之为Web应用程序。

为了在Tomcat中配置Context，需要一个`Context Descriptor`。上下文描述符只是一个XML文件，其中包含上下文的Tomcat相关配置，例如命名资源或会话管理器配置。在早期版本的Tomcat中，Context Descriptor配置的内容通常存储在Tomcat的主配置文件`server.xml`中，**但现在不建议这样做（尽管它目前仍然有效）**。

上下文描述符不仅帮助Tomcat知道如何配置上下文，而且其他工具（如Tomcat Manager和TCD）通常使用这些上下文描述符来正确执行其角色。

上下文描述符的位置是：

1. `$CATALINA_BASE/conf/[enginename]/[hostname]/[webappname].xml`
2. `$CATALINA_BASE/webapps/[webappname]/META-INF/context.xml`

（1）中的文件名为`[webappname].xml`，但（2）中的文件名为`context.xml`。如果没有为Context提供Context Descriptor，Tomcat将使用默认值配置Context。

# 在Tomcat启动时部署
如果您对使用Tomcat Manager或TCD不感兴趣，那么您需要将Web应用程序静态部署到Tomcat，然后启动Tomcat。为此类部署部署Web应用程序的位置称为每个主机指定的`appBase`。您可以将所谓的`exploded Web`应用程序（即非压缩的）复制到此位置，或压缩的Web应用程序资源`.WAR`文件。

仅当主机的`deployOnStartup属性为“true”`时，将在Tomcat启动时部署由主机（默认主机为“localhost”）`appBase`属性（默认appBase为`“$ CATALINA_BASE/webapps”`）指定的位置中的Web应用程序。

在这种情况下，Tomcat启动时将发生以下部署顺序：

1. 将首先部署任何上下文描述符。
2. 然后将部署未被任何上下文描述符引用的已解压Web应用程序。如果他们在appBase中有一个关联的`.WAR`文件，并且它比已解压的Web应用程序更新，则会删除展开的目录，并从`.WAR`重新部署该应用。
3. 将部署`.WAR`文件

# 在正在运行的Tomcat服务器上部署
可以将Web应用程序部署到正在运行的Tomcat服务器。

如果`Host autoDeploy属性为“true”`，则主机将根据需要动态部署和更新Web应用程序，例如，如果将新的`.WAR`放入`appBase`中。为此，主机需要启用后台处理，这是默认配置。

`autoDeploy设置为“true”`，正在运行的Tomcat将根据以下操作自动部署：

* 部署`.WAR`文件复制到`Host appBase`中。
* 部署已解压的Web应用程序，这些应用程序将复制到Host appBase中。
* 重新部署已在提供新`.WAR`时从`.WAR`部署的Web应用程序。在这种情况下，将删除先前解压的Web应用程序，并再次解压`.WAR`。请注意，如果配置`unpackWARs属性设置为“false”`，则不会发生解压，在这种情况下，Web应用程序将简单地重新部署为压缩存档。
* 如果更新了`/WEB-INF/web.xml`文件（或定义为WatchedResource的任何其他资源），则重新加载Web应用程序。
* 如果更新了部署Web应用程序的Context Descriptor文件，则重新部署Web应用程序。
* 如果更新Web应用程序使用的全局或每主机上下文描述符文件，则重新部署从属Web应用程序。
* 如果将上下文描述符文件（具有与先前部署的Web应用程序的上下文路径对应的文件名）添加到`$CATALINA_BASE/conf/[enginename]/[hostname]/`目录中，则重新部署Web应用程序。
* 如果删除了文档库（docBase），则取消部署Web应用程序。请注意，在Windows上，这假定启用了反锁定功能（请参阅上下文配置），否则无法删除正在运行的Web应用程序的资源。

请注意，也可以在加载程序中配置Web应用程序重新加载，在这种情况下，将跟踪已加载的类以进行更改。

# 使用Tomcat Manager进行部署
[Tomcat Manager]()包含在自己的手册页中。

# 使用客户端部署程序包(TCD)进行部署
最后，可以使用Tomcat Client Deployer实现Web应用程序的部署。这是一个包，可用于验证，编译，压缩到`.WAR`，以及将Web应用程序部署到生产或开发Tomcat服务器。应该注意，此功能使用Tomcat Manager，因此目标Tomcat服务器应该运行。

假设用户熟悉Apache Ant以使用TCD。 Apache Ant是一个脚本化的构建工具。 TCD预先打包了要使用的构建脚本。只需要对Apache Ant有一定的了解（本页前面列出的安装，熟悉使用操作系统命令shell和配置环境变量）。

TCD包括Ant任务，部署前用于JSP编译的Jasper页面编译器，以及验证Web应用程序上下文描述符的任务。验证器任务（类`org.apache.catalina.ant.ValidatorTask`）仅允许一个参数：已解压Web应用程序的基本路径。

TCD使用已解压Web应用程序作为输入（请参阅下面使用的属性列表）。编程部署的Web应用程序可以在`/META-INF/context.xml`中包含上下文描述符。

TCD包含一个即用型Ant脚本，具有以下目标：
* `compile`（默认值）：编译并验证Web应用程序。这可以独立使用，不需要运行Tomcat服务器。已编译的应用程序将仅在关联的`Tomcat X.Y.Z`服务器版本上运行，并且不保证可以在另一个Tomcat版本上运行，因为Jasper生成的代码取决于其运行时组件。还应注意，该目标还将自动编译位于Web应用程序的`/WEB-INF/classes`文件夹中的任何Java源文件。
* `deploy`：将Web应用程序（已编译或未编译）部署到Tomcat服务器。
* `undeploy`：取消部署Web应用程序
* `start`：启动Web应用程序
* `reload`：重新加载Web应用程序
* `stop`：停止Web应用程序

为了配置部署，请在TCD安装目录根目录中创建名为`deployer.properties`的文件。在此文件中，每行添加以下`name = value`对：

此外，您需要确保已为目标Tomcat Manager（TCD使用）设置了用户，否则TCD将不会使用Tomcat Manager进行身份验证，部署将失败。要执行此操作，请参阅Tomcat Manager页面。

* `build`：默认情况下，使用的构建文件夹是`${build}/webapp/${path}`（`${build}`，默认情况下，指向`${basedir}/build`）。在编译目标执行结束后，Web应用程序`.WAR`将位于`${build}/webapp/${path}.war`。
* `webapp`：包含将被编译和验证的已解压Web应用程序的目录。默认情况下，该文件夹是`myapp`。
* `path`：默认情况下`/myapp`，部署Web应用程序的上下文路径。
* `url`：正在运行的Tomcat服务器的Tomcat Manager Web应用程序的绝对URL，用于部署和取消部署Web应用程序。默认情况下，部署者将尝试访问在localhost上运行的Tomcat实例，位于`http://localhost:8080/manager/text`。
* `username`：Tomcat Manager用户名（用户应该具有manager-script的角色）
* `password`：Tomcat管理员密码。

<hr>

