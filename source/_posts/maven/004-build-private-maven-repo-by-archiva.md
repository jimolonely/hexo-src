---
title: 使用archiva搭建maven私有库
tags:
  - java
  - maven
  - archiva
p: maven/004-build-private-maven-repo-by-archiva
date: 2019-05-22 14:51:37
---

本文

# 搭建私有库的软件

从文档：[https://maven.apache.org/repository-management.html](https://maven.apache.org/repository-management.html)可看出
仓库管理软件很多，放在第一位的肯定是官方推荐的。

# 下载
https://archiva.apache.org/download.cgi

# 运行
```
./bin/archiva console (Linux, Mac, Solaris)

.\bin\archiva.bat console (Windows)
```
console的日志会打印在终端，还有以下参数： `console | start | stop | restart | status | dump`

默认是8080端口，访问 [http://localhost:8080](http://localhost:8080) 即可.

# 基本使用

1. 新建一个admin用户

2. 修改配置

默认是有2个仓库： internal和snapshot，访问[http://localhost:8080/repository/internal/](http://localhost:8080/repository/internal/)就可以
看到熟悉的软件列表。

3. [全局使用](https://archiva.apache.org/docs/2.2.4/userguide/using-repository.html)

直接修改`~/.m2/setting.xml`的mirror就行，全部依赖就会从本地去获取，本地没有再从中央仓库拉取：

```xml
<settings>
  <!-- omitted xml -->
  <mirrors>
    <mirror>
      <id>archiva.default</id>
      <url>http://repo.mycompany.com:8080/repository/internal/</url>
      <mirrorOf>external:*</mirrorOf>
    </mirror>
  </mirrors>
  <!-- omitted xml -->
</settings>
```


# 高级使用

修改中心仓库地址，改为更快的镜像：
{% asset_img 000.png %}




