---
title: nginx如何处理一个请求
tags:
  - nginx
p: server/005-how-nginx-handle-a-request
date: 2018-09-23 17:17:00
---

nginx如何处理一个请求? 简单但不失为一个值得过问的问题。仔细一想，nginx本身不处理业务，只是提供一个请求的转发，所以问题变成：nginx如何转发一个请求？

下面基于几种情况说明：基于命名和基于IP的。

# 基于命名的服务器
假设有下面的全部监听80端口的服务映射：
```shell
server {
    listen      80;
    server_name example.org www.example.org;
    ...
}

server {
    listen      80;
    server_name example.net www.example.net;
    ...
}

server {
    listen      80;
    server_name example.com www.example.com;
    ...
}
```
这时候来了一个请求，nginx如何选择哪一个响应呢？ 可以这样计算：

1. 检查请求的`Host`字段，如果匹配，则ok；
2. 否则使用默认服务器，这里是第一个。

如何指定默认服务器？如下：
```
server {
    listen      80 default_server;
    server_name example.net www.example.net;
    ...
}
```
## 如果不希望处理Host为空的请求呢？
可以直接配置返回[444-CONNECTION CLOSED WITHOUT RESPONSE](https://httpstatuses.com/444)：
```
server {
    listen      80;
    server_name "";
    return      444;
}
```
# 基于域名和IP混合的服务器
如果既有IP又有服务器名称，如下：有几个虚拟主机在不同的地址上监听
```
server {
    listen      192.168.1.1:80;
    server_name example.org www.example.org;
    ...
}

server {
    listen      192.168.1.1:80;
    server_name example.net www.example.net;
    ...
}

server {
    listen      192.168.1.2:80;
    server_name example.com www.example.com;
    ...
}
```
1. 首先测试请求的IP地址和端口是否匹配某个server配置块中的listen指令配置;
2. 接着测试请求的`Host`头是否匹配这个server块中的某个server_name的值;
3. 如果`Host`没有找到，nginx将把这个请求交给默认虚拟主机处理

例如，一个从`192.168.1.1:80`端口收到的访问`www.example.com`的请求将被监听`192.168.1.1:80`端口的默认虚拟主机处理，本例中就是第一个服务器，因为这个端口上没有定义名为`www.example.com`的虚拟主机。

默认服务器是监听端口的属性，所以不同的监听端口可以设置不同的默认服务器：
```
server {
    listen      192.168.1.1:80;
    server_name example.org www.example.org;
    ...
}

server {
    listen      192.168.1.1:80 default_server;
    server_name example.net www.example.net;
    ...
}

server {
    listen      192.168.1.2:80 default_server;
    server_name example.com www.example.com;
    ...
}
```

# 为什么可以`listen`多个IP？
我得出的结论是：有多个网卡，每个网卡的IP不同。

我们知道，一个请求的`Host`可以是域名，也可以是IP，如果直接访问nginx服务器的IP，那么Host就是IP，如果加上了端口，则`Host=IP:port`，于是这样就解释得通了。

当我们只写端口时：`listen 80;`，nginx会监听所有网卡的流量，于是所有80端口的请求都到这个server块来了。



[how nginx handle a request](https://nginx.org/en/docs/http/request_processing.html)
