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
4. 可选：定时同步
    ```java
    # vim /etc/cron.daily/update-localrepos

    #!/bin/bash
    ##specify all local repositories in a single variable
    LOCAL_REPOS=”base centosplus extras updates”
    ##a loop to update repos one at a time 
    for REPO in ${LOCAL_REPOS}; do
    reposync -g -l -d -m --repoid=$REPO --newest-only --download-metadata --download_path=/var/www/html/repos/
    createrepo -g comps.xml /var/www/html/repos/$REPO/  
    done

    # chmod 755 /etc/cron.daily/update-localrepos
    ```

[参考](https://www.tecmint.com/setup-local-http-yum-repository-on-centos-7/)

## 同步需要的软件
同步整个库未免有点太多了， 一般我们只需要很少的部分。

可以使用yum的`--downloadonly`参数只下载不安装：
```python
# mkdir tmp
# yum install --downloadonly --downloaddir=tmp httpd
。。。
# cd tmp
[tmp]# ls
apr-1.4.8-3.el7_4.1.x86_64.rpm   httpd-2.4.6-88.el7.centos.x86_64.rpm        mailcap-2.1.41-2.el7.noarch.rpm
apr-util-1.5.2-6.el7.x86_64.rpm  httpd-tools-2.4.6-88.el7.centos.x86_64.rpm
```

# 建立本地库

也就是从文件夹下加载库：
```python
# cd /etc

# 备份
# cp -r yum.repos.d yum.repos.d-bak

# 删除原有配置
# rm -rf yum.repos.d/*

# 建立新的配置
# vim yum.repos.d/local.repo
```
新配置内容为：
```java
[centos7]
name=centos7-repo
baseurl=file:///var/www/html/repos/
enabled=1
gpgcheck=0
```
然后建立并启用仓库：
```python
# createrepo /var/www/html/repos/

# yum clean all

# yum repolist all
```

# 建立http库
一般来说，我们都不止一台机器需要用软件库，所以建在本地是不常用的，一般会搭建一个http服务提供下载。

当然建立http服务的方式有很多种，这里只是简单的静态资源转发服务，介绍nginx和httpd两种实现。

## nginx

1. 安装nginx就不说了

2. 修改配置，增加repo.conf:
    ```conf
    server {
        listen   80;
        server_name  ip/hostname;
        root   /var/www/html/repos;
        location / {
                index  index.php index.html index.htm;
                autoindex on;	#enable listing of directory index
        }
    }
    ```
3. 重新加载nginx配置： `# nginx -s reload`

## httpd

1. 安装httpd服务：
    ```shell
    # yum install httpd
    # systemctl status httpd
    # systemctl start httpd
    # chkconfig httpd on
    ```
2. 修改配置： httpd默认的静态资源存放在`/var/www/html`下，所以如果懒得修改，也可以直接使用，如果要修改，如下修改：
    ```xml
    # vi /etc/httpd/conf/httpd.conf

    DocumentRoot "/var/www/html/repo"

    <Directory "/var/www/html/repo">
      AllowOverride None
      Require all granted
    </Directory>  
    ```
3. 重启服务：
    ```shell
    # systemctl restart httpd
    ```

4. 访问ip即可


# 参考
1. [setup-local-yum-server-on-centos-7-guide](https://www.fosslinux.com/6749/setup-local-yum-server-on-centos-7-guide.htm)
2. [setup-local-http-yum-repository-on-centos-7](https://www.tecmint.com/setup-local-http-yum-repository-on-centos-7/)
3. [How to use yum to get all RPMs required, for offline use?
](https://unix.stackexchange.com/questions/259640/how-to-use-yum-to-get-all-rpms-required-for-offline-use)


