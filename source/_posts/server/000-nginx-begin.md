---
title: nginx for beginners
tags:
  - linux
  - nginx
p: server/000-nginx-begin
date: 2018-08-29 15:15:08
---

这是nginx的入门一文。

# 前言
略
# 安装
略
# 入门指导
https://nginx.org/en/docs/beginners_guide.html

# 配置文件地址
/usr/local/nginx/conf, /etc/nginx, or/usr/local/etc/nginx.

{% asset_img 000.png %}

# 日志的位置
/usr/local/nginx/logs or /var/log/nginx
# 启动，停止和重新加载配置
## start
{% asset_img 001.png %}
## reload
重新加载配置文件
{% asset_img 002.png %}
## reopen
重新打开log文件
 {% asset_img 003.png %}
## quit
优雅的关闭
 {% asset_img 004.png %}
## stop
快速关闭
 {% asset_img 005.png %}
## quit和stop的区别
quit：相当于发送SIGQUIT信号，等待nginx工作线程完成才退出，很友好；
stop：相当于发送SIGTERM信号，要你强制退出。
{% asset_img 006.png %}
 
## 查看状态
 {% asset_img 007.png %}

https://nginx.org/en/docs/control.html

# 配置文件结构

[https://docs.nginx.com/nginx/admin-guide/basic-functionality/managing-configuration-files/](https://docs.nginx.com/nginx/admin-guide/basic-functionality/managing-configuration-files/)

nginx由模块组成，这些模块由配置文件中指定的指令控制。 指令分为简单指令和块指令。 一个简单的指令包括由空格分隔的名称和参数，以分号（;）结尾。 块指令与简单指令具有相同的结构，但它不是以分号结尾，而是以大括号（{和}）包围的一组附加指令结束。 如果块指令在大括号内包含其他指令，则称为上下文（示例：events，http，server和location）。

放置在任何上下文之外的配置文件中的指令被认为是在主上下文中。 事件和http指令驻留在主上下文中，服务器位于http中，位于服务器中。

＃符号后面的其余部分被视为评论。

我来翻译翻译上面的话：
```
主上下文
模块
	简单指令 ;
	块指令{}
		包含简单指令
		形成上下文(context)
# 评论
```

下面是分别描述
## 指令
以分号结尾的命令，包含在块中。
```
user             nobody;
error_log        logs/error.log notice;
worker_processes 1;
```
## 指定配置文件地址
nginx.conf可以包含单个模块的配置文件引用，配置文件位于/etc/nginx/conf.d
```
include conf.d/http;
include conf.d/stream;
include conf.d/exchange-enhanced;
```
## 上下文
一般来说有几种context:

1. events:通用连接处理
2. http:HTTP流量相关
3. mail：邮件流量相关
4. stream：TCP和UDP流量相关 

## 一个例子
```shell
user nobody; # a directive in the 'main' context

events {
    # configuration of connection processing
}

http {
    # Configuration specific to HTTP and affecting all virtual servers  

    server {
        # configuration of HTTP virtual server 1       
        location /one {
            # configuration for processing URIs starting with '/one'
        }
        location /two {
            # configuration for processing URIs starting with '/two'
        }
    } 
    
    server {
        # configuration of HTTP virtual server 2
    }
}

stream {
    # Configuration specific to TCP/UDP and affecting all virtual servers
    server {
        # configuration of TCP virtual server 1 
    }
}
```

# 服务静态内容
首先，我们会用到2个模块：http和server
```shell
http {
    server {
    }
}
```
然后再server里定义location指令，指定根路径和image路径
```
http {
server {
        location / {
            root /mnt/e/data/www;
        }

        location /images {
            root /mnt/e/data;
        }
    }
}
```
看下完整配置：
 {% asset_img 008.png %}

看下我们的静态资源：
 
{% asset_img 009.png %}

如果nginx在运行，需要重新加载下配置：
 {% asset_img 010.png %}

结果：
默认是在80端口
 
 {% asset_img 011.png %}
 
{% asset_img 012.png %}

{% asset_img 013.png %}

# 设置一个简单的代理服务器
这个例子将会在一个nginx配置文件里配置多个服务器，只是端口号不同而已。
看完整配置：

 {% asset_img 014.png %}

看下文件目录：

{% asset_img 015.png %}
 
重新加载配置。

我们访问被代理的8080服务器，没问题：
 
 {% asset_img 016.png %}

访问代理服务器80端口也可以：
 
 {% asset_img 017.png %}

接下来是关键：8080下没有静态资源的，只有代理服务器上有：
 
 {% asset_img 018.png %}
 
 {% asset_img 019.png %}

这就完成了一个简单的CDN服务器配置。

# 接下来学什么
也就是作为nginx管理员要学什么，也就是nginx可以做什么，也就是闲的无聊，下面就是了：

1. 负载均衡：HTTP，TCP/UDP
2. 内容缓存：CDN等
3. Web服务器：静态或动态的
4. 安全控制
5. 监控：log，活动等
6. 高可用：你懂的
7. 动态模块：cookie，GEOIP，Filter，JS等
8. 邮件代理服务器

其实上述涉及了一个核心概念：代理。

