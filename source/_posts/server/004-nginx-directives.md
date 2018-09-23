---
title: nginx指令大全
tags:
  - nginx
p: server/004-nginx-directives
date: 2018-09-19 10:06:57
---

本文翻译自[官网](https://nginx.org/en/docs/http/ngx_http_core_module.html#directives)

# absolute_redirect on | off
```
默认：on
上下文：http,server,location
如果禁用，nginx发出的重定向将是相对的。
```
# aio on | off | threads[=pool]
```
默认：off
上下文：http,server,location
异步文件IO，针对FreeBSD和linux
```
# alias path
```
context: location
定义或替换指定路径

location /i/ {
    alias /data/w3/images/;
}
在请求 /i/top.gif时，会映射到 ：/data/w3/images/top.gif

alias可以包含除了$document_root和$realpath_root的变量

alias中可以使用正则，并且应该包含捕获
location ~ ^/users/(.+\.(?:gif|jpe?g|png))$ {
    alias /data/w3/images/$1;
}
```
alias和root有什么区别？

```
location /images/ {
    alias /data/w3/images/;
}
等价于：
location /images/ {
    root /data/w3;
}
```
# client_body_buffer_size
设置读取客户端请求正文的缓冲区大小。 如果请求主体大于缓冲区，则整个主体或仅其部分被写入临时文件。 默认情况下，缓冲区大小等于两个内存页。 x86和其他32位平台和x86-64为8k。 在其他64位平台上通常为16K。
```
client_body_buffer_size 8k | 16k;
context: http,location,server
```
# client_header_buffer_size
设置header的缓冲区大小，默认1k字节够用了，如果有些cookie很长，可以设大些。
# client_max_body_size
在header`Content-Length`中指定请求的body大小，超过1M会被返回`413(Request Entity Too Large)`,设置为0禁用这个检查，因为有些浏览器无法显示这个错误。
# connection_pool_size
每个连接的内存分配，对性能影响很小，应谨慎使用。默认32位是256字节，64位是512字节。
# default_type
```
默认：default_type text/plain;

mime-type有很多
```
# error_page
```
context: http,server,location

例子：
error_page 404 /404.html;
error_page 500 502 504 /50x.html;

动态改变响应码：
error_page 404 =200 /empty.gif;

转到指定location：
location / {
    error_page 404 = @fallback;
}
location @fallback {
    proxy_pass http://backend;
}

重定向处理：
error_page 403 http://example.html
客户端会收到302.
```
# http
运行于最外层的模块，里面指定server指令。
# internal
内部请求重定向，有条件限制，比如，error_page
```
error_page 404 /404.html;

location = /404.html {
    internal;
}

internal限制为10个，避免循环跳转。
```
# limit except
limit except methods(GET, HEAD, POST, PUT, DELETE, MKCOL, COPY, MOVE, OPTIONS, PROPFIND, PROPPATCH, LOCK, UNLOCK, or PATCH).

```
#除了 GET（包括HEAD）方法，其他禁用
limit except GET {
    allow 192.168.1.0/32;
    deny all;
}
```
# limit_rate
限制客户端每个链接的速率，默认为0，不限制。比如：
```
server {
    if($slow){
        set $limit_rate 4k;# 字节
    }
}
```
# limit_rate_after
初始化时限制速度，后面不管，如下，开始时加载快点，后面慢慢来：
```
location /flv/ {
    flv;
    limit_rate_after 500k;
    limit_rate 50k;
}
```
# lingering_close
控制nginx如何关闭链接：
1. on: 默认，等待客户端发数据，但只是启发性建议发更多数据；
2. always: 总是无条件的等待处理客户端数据；
3. off: 从不等待并且立即关闭链接，这个行为打破了协议，正常不应该使用。

# lingering_time
在`lingering_close`的影响下处理（读取或忽视）数据的最长时间，默认30s.
# lingering_timeout
在`lingering_close`的影响下等待数据到来的最长时间，默认5s.
# listen
```
default: listen *.80 | *.8000
context: server
```
//TODO
# location
```
syntax: location [= | ~ | ~* | ^* ] uri {...}
        location @name {...}
context: server, location
```
解释：
1. `~*`: 大小写不敏感
2. `~`: 大小写敏感
3. `^~`: 如果最长前缀有这个，则不检查正则；
4. `=`: 精确匹配，如果不匹配，则停止搜索；

## 匹配路径规则
先检查前缀匹配，且记住最长前缀，然后检查正则匹配，正则按声明的先后顺序检查，只要找到第一个匹配的就停止，然后使用正则，如果没有找到正则匹配，则使用前面的最长前缀，否则就只有404了。
## 例子
```
location = / {
    A
}
location / {
    B
}
location /doc/ {
    C
}
location ^~ /img/ {
    D
}
location ~* \.(gif|jpg|jpeg)$ {
    E
}
```
`/` ==> A

`/index.html` ==> B

`/doc/doc.html` ==> C

`/img/1.gif` ==> D

`/doc/1.jpg` ==> E

## 末尾加斜杠
？？//TODO

# merge_slashes
是否合并斜杠，默认`on`:

context: http,server
```
location /scripts/ {
    xxx /one.php;
}
```
# open_file_cache
```
open_file_cache off;
open_file_cache max=N [inactive=time];

缓存存什么：
    1.open file描述符，大小和修改次数
    2.目录存在的信息；
    3.文件被查找的次数，如"file not found","no read permission"


max: 缓存最大元素数量，LRU
inactive： 最大时间从缓存移除
```
# root
```
root path;
default: root html;
context: http,server,location
```
如果一个URI必须被改变，则应该用alias命令。
# server
一个虚拟服务器的配置模块，`listen`指令描述监听的地址或端口并接收链接，`server_name`指令列出所有的服务器名称。
详细见{% post_link server/005-how-nginx-handle-a-request nginx如何处理一个请求 %}.

# server_name
设置一个server的名称,可以有多个，因为匹配的站点可以有多个，但`listen`只有一个。
```
server {
    server_name example.com www.example.com
}
```
`*`通配符可以用在开头或结尾表示省略的名字：
```
server {
    server_name example.com *.example_name www.example.*
}
```
同样可以用正则：
```
server {
    server_name www.example.com ~^www\d+\.example\.com$
}
```
## server_name的匹配顺序
1. 明确的名称
2. 最长的通配符名开头的名字
3. 最长的通配符名结尾的名字
4. 按定义的顺序出现的第一个正则匹配的名字
