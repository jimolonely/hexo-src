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
tomcat自带管理应用manager，需要做一些配置：



# Host管理

# 集群
[https://tomcat.apache.org/tomcat-8.5-doc/cluster-howto.html](https://tomcat.apache.org/tomcat-8.5-doc/cluster-howto.html)


# 负载均衡
[https://tomcat.apache.org/tomcat-8.5-doc/balancer-howto.html](https://tomcat.apache.org/tomcat-8.5-doc/balancer-howto.html)



# 参考
1. [https://tomcat.apache.org/tomcat-8.5-doc/introduction.html](https://tomcat.apache.org/tomcat-8.5-doc/introduction.html)



