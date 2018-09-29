---
title: tomcat配置
tags:
  - tomcat
p: server/002-tomcat-config
date: 2018-09-10 07:57:11
---

tomcat目前是使用量最大的服务器，不得不学。

# 了解目录结构
* / bin - 启动，关闭和其他脚本。 * .sh文件（对于Unix系统）是* .bat文件的功能重复（对于Windows系统）。 由于Win32命令行缺少某些功能，因此这里有一些额外的文件。
* / conf - 配置文件和相关的DTD。 这里最重要的文件是server.xml。 它是容器的主要配置文件。
* / logs - 默认情况下，日志文件在此处。
* / webapps - 这是您的webapps的用武之地。

# 如何管理APP
[https://tomcat.apache.org/tomcat-8.5-doc/manager-howto.html](https://tomcat.apache.org/tomcat-8.5-doc/manager-howto.html)

## manager
manager就是管理app的页面，tomcat自带有，它能做的事情有以下几个：

//TODO

但我们直接访问时会发现权限问题：

{% asset_img 001.png %}

所以需要做一些配置：

我们会发现在`/webapps/manager/WEB-INF/web.xml`下有几个角色的定义：
```xml
120   <!-- Define a Security Constraint on this Application -->
121   <!-- NOTE:  None of these roles are present in the default users file -->
122   <security-constraint>
123     <web-resource-collection>
124       <web-resource-name>HTML Manager interface (for humans)</web-resource-name>
125       <url-pattern>/html/*</url-pattern>
126     </web-resource-collection>
127     <auth-constraint>
128        <role-name>manager-gui</role-name>
129     </auth-constraint>
130   </security-constraint>
131   <security-constraint>
132     <web-resource-collection>
133       <web-resource-name>Text Manager interface (for scripts)</web-resource-name>
134       <url-pattern>/text/*</url-pattern>
135     </web-resource-collection>
136     <auth-constraint>
137        <role-name>manager-script</role-name>
138     </auth-constraint>
139   </security-constraint>
140   <security-constraint>
141     <web-resource-collection>
142       <web-resource-name>JMX Proxy interface</web-resource-name>
143       <url-pattern>/jmxproxy/*</url-pattern>
144     </web-resource-collection>
145     <auth-constraint>
146        <role-name>manager-jmx</role-name>
147     </auth-constraint>
148   </security-constraint>
149   <security-constraint>
150     <web-resource-collection>
151       <web-resource-name>Status interface</web-resource-name>
152       <url-pattern>/status/*</url-pattern>
153     </web-resource-collection>
154     <auth-constraint>
155        <role-name>manager-gui</role-name>
156        <role-name>manager-script</role-name>
157        <role-name>manager-jmx</role-name>
158        <role-name>manager-status</role-name>
159     </auth-constraint>
160   </security-constraint>
```
分别是：
1. manager-gui — Access to the HTML interface.
2. manager-status — Access to the "Server Status" page only.
3. manager-script — Access to the tools-friendly plain text interface that is described in this document, and to the "Server Status" page.
4. manager-jmx — Access to JMX proxy interface and to the "Server Status" page.

当然，这几个权限各有各的风险，需要谨慎使用。我们必须使用至少其中一个角色，并设置用户名和密码才能访问管理页面。
因此，我们需要在`/conf/tomcat-users.xml`里进行用户添加：
```xml
<user username="jimo" password="jimo" roles="standard,manager-gui,manager-script,manager-status" />
```

https://stackoverflow.com/questions/38551166/403-access-denied-on-tomcat-8-manager-app-without-prompting-for-user-password


# Host管理

# 集群
[https://tomcat.apache.org/tomcat-8.5-doc/cluster-howto.html](https://tomcat.apache.org/tomcat-8.5-doc/cluster-howto.html)


# 负载均衡
[https://tomcat.apache.org/tomcat-8.5-doc/balancer-howto.html](https://tomcat.apache.org/tomcat-8.5-doc/balancer-howto.html)



# 参考
1. [https://tomcat.apache.org/tomcat-8.5-doc/introduction.html](https://tomcat.apache.org/tomcat-8.5-doc/introduction.html)
