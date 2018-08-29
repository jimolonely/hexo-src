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

