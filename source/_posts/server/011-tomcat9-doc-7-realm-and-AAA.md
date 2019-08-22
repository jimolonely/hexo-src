---
title: Tomcat9-文档6-realm和AAA
tags:
  - tomcat
p: server/011-tomcat9-doc-7-realm-and-AAA
date: 2019-08-22 10:18:14
---

本文翻译自：[https://tomcat.apache.org/tomcat-9.0-doc/realm-howto.html](https://tomcat.apache.org/tomcat-9.0-doc/realm-howto.html)

# 快速开始
本文档介绍如何通过连接到用户名，密码和用户角色的现有“数据库”来配置Tomcat以支持容器管理的安全性。 如果您使用的Web应用程序包含一个或多个`<security-constraint>`元素，并且`<login-config>`元素定义了用户需要如何对自身进行身份验证，则只需要关心这一点。 如果您不使用这些功能，则可以安全地跳过本文档。

有关容器管理安全性的基本背景信息，请参阅[Servlet规范（版本2.4）](https://wiki.apache.org/tomcat/Specifications)，第12节。

有关利用Tomcat的单点登录功能（允许用户在与虚拟主机关联的整个Web应用程序集中进行一次身份验证）的信息，请参阅[此处](https://tomcat.apache.org/tomcat-9.0-doc/config/host.html#Single_Sign_On)。

# 概览
## 什么是领域(realm)？
领域是用户名和密码的“数据库”，用于标识Web应用程序（或Web应用程序集）的有效用户，以及与每个有效用户关联的角色列表的枚举。您可以将角色视为类似于类Unix操作系统中的组，因为对具有特定角色的所有用户（而不是枚举关联用户名列表）授予对特定Web应用程序资源的访问权限。特定用户可以拥有与其用户名相关联的任意数量的角色。

尽管Servlet规范描述了应用程序声明其安全性要求的可移植机制（在`web.xml`部署描述符中），但是没有可定义servlet容器与关联用户和角色信息之间的接口的可移植API。但是，在许多情况下，需要将servlet容器“连接”到生产环境中已存在的某些现有认证数据库或机制。因此，Tomcat定义了一个Java接口（`org.apache.catalina.Realm`），它可以通过“插件”组件来实现，以建立此连接。提供了六个标准插件，支持与各种身份验证信息源的连接：

* [JDBCRealm](##JDBCRealm)  - 访问存储在关系数据库中的身份验证信息，通过JDBC驱动程序访问。
* DataSourceRealm  - 访问存储在关系数据库中的身份验证信息，通过命名的JNDI JDBC DataSource访问。
* JNDIRealm  - 访问存储在基于LDAP的目录服务器中的身份验证信息，通过JNDI提供程序访问。
* UserDatabaseRealm  - 访问存储在UserDatabase JNDI资源中的身份验证信息，该资源通常由XML文档（`conf/tomcat-users.xml`）支持。
* MemoryRealm  - 访问存储在内存中对象集合中的身份验证信息，该集合是从XML文档（`conf/tomcat-users.xml`）初始化的。
* JAASRealm  - 通过Java身份验证和授权服务（JAAS）框架访问身份验证信息。

也可以编写自己的Realm实现，并将其与Tomcat集成。为此，您需要：

* 实现`org.apache.catalina.Realm`，
* 将编译的域放在`$CATALINA_HOME/lib`中，
* 按照下面“配置领域”部分所述声明您的领域，
* 向[MBeans描述符](https://tomcat.apache.org/tomcat-9.0-doc/mbeans-descriptors-howto.html)声明你的领域。

## 配置领域
在深入了解标准Realm实现的细节之前，一般来说，了解Realm的配置方式非常重要。通常，您将在`conf/server.xml`配置文件中添加一个XML元素，如下所示：

```xml
<Realm className="... class name for this implementation"
       ... other attributes for this implementation .../>
```
`<Realm>`元素可以嵌套在以下任何一个`Container`元素中。 Realm元素的位置直接影响该Realm的“范围”（即哪些Web应用程序将共享相同的身份验证信息）：

* 在`<Engine>`元素内部 - 此Realm将在所有虚拟主机上的所有Web应用程序之间共享，除非它被嵌套在从属`<Host>`或`<Context>`元素内的Realm元素覆盖。
* 在`<Host>`元素内部 - 此Realm将在此虚拟主机的所有Web应用程序之间共享，除非它被嵌套在从属`<Context>`元素内的Realm元素覆盖。
* 在`<Context>`元素内 - 此Realm将仅用于此Web应用程序。

# 共同特征
## 摘要密码
对于每个标准`Realm`实现，用户的密码（默认情况下）以明文形式存储。在许多环境中，这是不合需要的，因为认证数据的临时观察者可以收集足够的信息以成功登录，并模仿其他用户。为避免此问题，标准实现支持摘要用户密码的概念。这允许对存储的密码版本进行编码（以不易翻转的形式），但`Realm`实现仍可用于身份验证。

当标准领域通过检索存储的密码并将其与用户提供的值进行比较进行身份验证时，您可以通过在`<Realm>`元素中放置[`CredentialHandler`](https://tomcat.apache.org/tomcat-9.0-doc/config/credentialhandler.html)元素来选择已摘要的密码。支持`SSHA，SHA或MD5`算法之一的简单选择是使用`MessageDigestCredentialHandler`。必须将此元素配置为`java.security.MessageDigest`类（`SSHA，SHA或MD5`）支持的摘要算法之一。选择此选项时，存储在Realm中的密码内容必须是密码的明文版本，由指定的算法摘要。

当调用Realm的`authenticate()`方法时，用户指定的（明文）密码本身被同一算法摘要，并将结果与​​Realm返回的值进行比较。相等匹配意味着原始密码的明文版本与用户提供的密码相同，因此应该授权该用户。

要计算明文密码的摘要值，可以使用两种便捷技术：

* 如果您正在编写需要动态计算摘要密码的应用程序，请调用`org.apache.catalina.realm.RealmBase`类的静态`Digest()`方法，并将明文密码，摘要算法名称和编码作为参数传递。此方法将返回已摘要的密码。
* 如果要执行命令行实用程序来计算摘要的密码，只需执行即可
    * `CATALINA_HOME/bin/digest.[bat|sh] -a {algorithm} {cleartext-password}`
    * 此明文密码的摘要版本将返回到标准输出。

如果使用具有DIGEST认证的摘要密码，则用于生成摘要的明文不同，摘要必须使用MD5算法的一次迭代而不使用盐。在上面的示例中，`{cleartext-password}`必须替换为`{username}:{realm}:{cleartext-password}`。例如，在开发环境中，这可能采用`testUser:Authentication required:testPassword`。 `{realm}`的值取自Web应用程序的`<login-config>`的`<realm-name>`元素。如果未在`web.xml`中指定，则使用`Authentication required`的默认值。

使用支持使用除平台默认值以外的编码的用户名和/或密码
```s
CATALINA_HOME/bin/digest.[bat|sh] -a {algorithm} -e {encoding} {input}
```
但需要注意确保输入正确传递到摘要器。摘要器返回`{input}:{digest}`。如果输入在返回中显示已损坏，则摘要将无效。

摘要的输出格式为`{salt}${iterations}${digest}`。如果salt长度为零且迭代计数为1，则输出将简化为`{digest}`。

`CATALINA_HOME/bin/digest.[bat|sh]`的完整语法是：

```s
CATALINA_HOME/bin/digest.[bat|sh] [-a <algorithm>] [-e <encoding>]
        [-i <iterations>] [-s <salt-length>] [-k <key-length>]
        [-h <handler-class-name>] <credentials>
```
* -a  - 用于生成存储凭证的算法。如果未指定，将使用处理程序的默认值。如果既未指定处理程序也未指定算法，则将使用默认值SHA-512
* -e  - 用于字符转换的任何字节的编码，可能是必需的。如果未指定，将使用系统编码（`Charset＃defaultCharset()`）。
* -i  - 生成存储的凭据时要使用的迭代次数。如果未指定，将使用`CredentialHandler`的默认值。
* -s  - 作为凭证​​的一部分生成和存储的salt的长度（以字节为单位）。如果未指定，将使用`CredentialHandler`的默认值。
* -k  - 生成凭证时创建的密钥的长度（以位为单位）（如果有）。如果未指定，将使用`CredentialHandler`的默认值。
* -h  - 要使用的`CredentialHandler`的完全限定类名。如果未指定，将依次测试内置处理程序（`MessageDigestCredentialHandler`，然后是`SecretKeyCredentialHandler`），并将使用第一个接受指定算法的处理程序。

## 示例应用
Tomcat附带的示例应用程序包括受安全约束保护的区域，利用基于表单的登录。要访问它，请将浏览器指向[http://localhost:8080/examples/jsp/security/protected/](http://localhost:8080/examples/jsp/security/protected/)并使用为默认`UserDatabaseRealm`描述的用户名和密码之一登录。

## manager应用
如果您希望使用Manager应用程序在正在运行的Tomcat安装中部署和取消部署应用程序，则必须将`“manager-gui”`角色添加到所选Realm实现中的至少一个用户名。这是因为管理器Web应用程序本身使用安全约束，该约束要求角色`“manager-gui”`访问该应用程序的HTML界面内的任何请求URI。

出于安全原因，默认Realm中没有用户名（即使用`conf/tomcat-users.xml`被赋予`“manager-gui”`角色。因此，在Tomcat管理员专门指定之前，没有人能够利用此应用程序的功能这个角色给一个或多个用户。

## realm日志
Realm记录的调试和异常消息将由与域的容器关联的日志记录配置记录：其周围的`Context，Host或Engine`。

# 标准realm实现
## JDBCRealm
### 介绍
JDBCRealm是Tomcat Realm接口的一个实现，它在通过JDBC驱动程序访问的关系数据库中查找用户。只要您的数据库结构符合以下要求，就可以使用大量的配置灵活性来适应现有的表名和列名：

* 必须有一个表，在下面引用为users表，其中包含该Realm应识别的每个有效用户的一行。
* users表必须至少包含两列（如果现有应用程序需要它，它可能包含更多列）：
    * 用户登录时由Tomcat识别的用户名。
    * 用户登录时由Tomcat识别的密码。此值可以明文或摘要 - 有关详细信息，请参阅下文。
* 必须有一个表，在下面引用为用户角色表，其中包含分配给特定用户的每个有效角色的一行。用户拥有零个，一个或多个有效角色是合法的。
* 用户角色表必须至少包含两列（如果现有应用程序需要，则可能包含更多列）：
    * Tomcat要识别的用户名（与users表中指定的值相同）。
    * 与此用户关联的有效角色的角色名称。

### 快速开始
要设置Tomcat以使用JDBCRealm，您需要执行以下步骤：

* 如果尚未执行此操作，请在数据库中创建符合上述要求的表和列。
* 配置供Tomcat使用的数据库用户名和密码，该用户名和密码至少具有对上述表的只读权限。 （Tomcat永远不会尝试写入这些表。）
* 将要使用的JDBC驱动程序的副本放在`$CATALINA_HOME/lib`目录中。请注意，只能识别JAR文件！
* 在`$CATALINA_BASE/conf/server.xml`文件中设置`<Realm>`元素，如下所述。
* 如果Tomcat已在运行，请重新启动它。

### realm元素属性
要配置JDBCRealm，您将创建一个`<Realm>`元素并将其嵌套在`$CATALINA_BASE/conf/server.xml`文件中，如上所述。 JDBCRealm的属性在[Realm](https://tomcat.apache.org/tomcat-9.0-doc/config/realm.html)配置文档中定义。

### 例
用于创建所需表的示例SQL脚本可能如下所示（根据特定数据库的需要调整语法）：

```sql
create table users (
  user_name         varchar(15) not null primary key,
  user_pass         varchar(15) not null
);

create table user_roles (
  user_name         varchar(15) not null,
  role_name         varchar(15) not null,
  primary key (user_name, role_name)
);
```
示例Realm元素包含（注释掉）在默认的`$CATALINA_BASE/conf/server.xml`文件中。 下面是使用名为“authority”的MySQL数据库的示例，该数据库使用上述表配置，并使用用户名“dbuser”和密码“dbpass”进行访问：
```xml
<Realm className="org.apache.catalina.realm.JDBCRealm"
      driverName="org.gjt.mm.mysql.Driver"
   connectionURL="jdbc:mysql://localhost/authority?user=dbuser&amp;password=dbpass"
       userTable="users" userNameCol="user_name" userCredCol="user_pass"
   userRoleTable="user_roles" roleNameCol="role_name"/>
```
### 补充说明
JDBCRealm根据以下规则运行：

* 当用户第一次尝试访问受保护资源时，Tomcat将调用此Realm的`authenticate()`方法。因此，您将立即反映您对数据库所做的任何更改（新用户，更改的密码或角色等）。
* 一旦用户通过身份验证，用户（及其相关角色）将在用户登录期间缓存在Tomcat中。 （对于基于FORM的身份验证，这意味着在会话超时或无效之前;对于BASIC身份验证，这意味着直到用户关闭其浏览器）。不会跨会话序列化保存和还原高速缓存的用户。对于已经过身份验证的用户的数据库信息的任何更改都将在下次用户再次登录时才会反映出来。
* 管理用户和用户角色表中的信息是您自己的应用程序的责任。 Tomcat不提供任何内置功能来维护用户和角色。


```sql
```

```sql
```

