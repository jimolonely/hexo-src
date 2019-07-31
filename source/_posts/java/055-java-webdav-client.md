---
title: java实现web-dav客户端
tags:
  - java
  - web-dav
p: java/055-java-webdav-client
date: 2019-07-28 22:37:43
---

本文源于在写一个APP时需要使用web-dav协议连接坚果云的存储API，于是寻找一个优秀的client。

# web-dav简介
这一部分请自己查询，如果要深究，看[RFC文档](http://www.webdav.org/specs/rfc4918.html)是个选择。

# 可用的客户端

slide、jackrabbit、webdavclient4j

https://www.ibm.com/developerworks/cn/java/j-lo-jackrabbit/index.html

https://jackrabbit.apache.org/archive/wiki/JCR/WebDAV_115513525.html

https://joinup.ec.europa.eu/svn/ames-web-service/trunk/AMES-WebDAV/ames-webdav/src/de/kp/ames/webdav/WebDAVClient.java

# 我采用的

Sardine,有2款，一款是google开源的，2011年转到下面这位仁兄开源的库：

作者在[github](https://github.com/lookfirst/sardine)上说了slide、jackrabbit、webdavclient4j都不是他要的，于是自己写了一个，并开源给大家使用，
就喜欢这种干脆的精神。

文档：https://github.com/lookfirst/sardine/wiki/UsageGuide

