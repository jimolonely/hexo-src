---
title: centos创建本地软件仓库
tags:
  - linux
  - centos
p: linux/023-create-local-repo-in-centos
date: 2019-04-18 17:57:23
---

本文讲解centos创建本地软件仓库（基于文件和基于http server）的方式。

# 准备软件库
既然建立自己的软件库，一定要有软件，从哪里来？ 来自其他库。

下面有2种方式： 全量和增量（我们需要的软件）。

## 同步整个centos仓库

下面的操作当然是在有网的情况下操作：

1. 安装需要的软件：
    ```java
    # yum install createrepo  yum-utils reposync
    ```
2. 存放软件地址：
    ```java
    # mkdir -p /var/www/html/repos/{base,centosplus,extras,updates}
    ```
3. 同步软件库：

    ```java
    # reposync -g -l -d -m --repoid=base --newest-only --download-metadata --download_path=/var/www/html/repos/
    # reposync -g -l -d -m --repoid=centosplus --newest-only --download-metadata --download_path=/var/www/html/repos/
    # reposync -g -l -d -m --repoid=extras --newest-only --download-metadata --download_path=/var/www/html/repos/
    # reposync -g -l -d -m --repoid=updates --newest-only --download-metadata --download_path=/var/www/html/repos/
    ```

[参考](https://www.tecmint.com/setup-local-http-yum-repository-on-centos-7/)

## 同步需要的软件
同步整个库未免有点太多了， 一般我们只需要很少的部分。


    ```java
    # mkdir -p /var/www/html/repos/{base,centosplus,extras,updates}
    ```
    ```java
    # mkdir -p /var/www/html/repos/{base,centosplus,extras,updates}
    ```

# 建立本地库



# 建立http库


# 参考
1. [setup-local-yum-server-on-centos-7-guide](https://www.fosslinux.com/6749/setup-local-yum-server-on-centos-7-guide.htm)
2. [setup-local-http-yum-repository-on-centos-7](https://www.tecmint.com/setup-local-http-yum-repository-on-centos-7/)



