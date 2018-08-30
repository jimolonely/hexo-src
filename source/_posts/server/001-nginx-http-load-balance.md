---
title: nginx-HTTP负载均衡
tags:
  - linux
  - nginx
  - load balance
p: server/001-nginx-http-load-balance
date: 2018-08-30 08:40:53
---

本文关于nginx的HTTP负载均衡。

# 前言
略
# 代理HTTP流量到一组服务器
无非就是来了HTTP请求，我应该发给谁（哪个服务器），分发的过程就是nginx做的事情，当然我们可以配置。

## 指定服务器
我们使用upstream来定义一组服务器，名字叫backend。**注意：下面的server不是server块，而是一条指令**。

```
http {
    upstream backend {
        server backend1.example.com weight=5;
        server backend2.example.com;
        server 192.0.0.1 backup;
    }
}
```
## 配置代理
也就很简单了，使用proxy_pass.
```
server {
    location / {
        proxy_pass http://backend;
    }
}
```
当然，根据不同的协议，还有其他选择： fastcgi_pass, memcached_pass, scgi_pass, or uwsgi_pass

## 完整配置
**默认情况，ngnix使用轮询（Round Robin）算法分配流量**
```
http {
    upstream backend {
        server backend1.example.com;
        server backend2.example.com;
        server 192.0.0.1 backup;
    }
    
    server {
        location / {
            proxy_pass http://backend;
        }
    }
}
```

# 负载均衡算法
nginx一共配备了5种算法，下面介绍。
## 1.Round Robin（轮询）
请求在服务器之间均匀分布，会考虑服务器权重。 默认情况下使用此方法（无需启动指令）： 
```shell
upstream backend {
   server backend1.example.com;
   server backend2.example.com;
}
```
## 2.Least Connections（最少连接数）
将请求发送到具有 **最少活动连接数** 的服务器，同时考虑服务器权重：
```shell
upstream backend {
    least_conn;
    server backend1.example.com;
    server backend2.example.com;
}
```
## 3.IP Hash
从客户端IP地址确定向其发送请求的服务器。 
在这种情况下，使用IPv4地址的前三个八位字节或整个IPv6地址来计算哈希值。 **该方法保证来自同一地址的请求到达同一服务器，除非它不可用**
```
upstream backend {
    ip_hash;
    server backend1.example.com;
    server backend2.example.com;
}
```
如果需要从负载平衡轮换中临时删除其中一个服务器，则可以使用 **down** 参数对其进行标记，以便保留客户端IP地址的当前哈希值。 
此服务器要处理的请求将自动发送到组中的下一个服务器：
```shell
upstream backend {
    server backend1.example.com;
    server backend2.example.com;
    server backend3.example.com down;
}
```
## 4.一般HASH
发送请求的服务器是从用户定义的 **键（键值对的键）** 确定的，该key可以是文本字符串，变量或他们的组合。

例如，key可以是配对的源IP地址和端口，也可以是本示例中的URI：
```shell
upstream backend {
    hash $request_uri consistent;
    server backend1.example.com;
    server backend2.example.com;
}
```
hash指令的可选参数 **consistent** 启用ketama一致哈希负载平衡。 根据用户定义的散列键值，请求均匀分布在所有上游(upstream)服务器上。 如果将上游服务器添加到上游组或从上游组中删除，则仅重新映射几个key，这在负载平衡缓存服务器或其他累积状态的应用程序的情况下 **最小化缓存未命中** 。
## 5.Least Time(最小时间，只在NGINX PLUS有)
对于每个请求，NGINX Plus选择具有最低平均延迟和最低活动连接数的服务器，其中最低平均延迟是根据包含的 **least_time** 指令中的参数计算的,参数如下：

1. header - 从服务器接收第一个字节的时间
2. last_byte - 从服务器接收完整响应的时间 

```shell
upstream backend {
    least_time header;
    server backend1.example.com;
    server backend2.example.com;
}
```
# 服务器权重
默认情况，weight都是1，每个服务器权重一样，但可以改变：
```
upstream backend {
    server backend1.example.com weight=5;
    server backend2.example.com;
    server 192.0.0.1 backup;
}
```
在上述示例中，backend1.example.com的权重为5; 其他两台服务器具有默认权重（1），但IP地址为192.0.0.1的服务器标记为 **备份服务器** ，除非其他两台服务器都不可用，否则不会接收请求。 
通过这种权重配置，每六个请求中就有五个发送到backend1.example.com，一个发送到backend2.example.com。

# 服务器慢启动
服务器慢启动功能可防止最近恢复的服务器被连接淹没，因为这可能会超时并导致服务器再次被标记为失败。

在NGINX Plus中，慢启动允许上游服务器在恢复或可用之后 **逐渐将其权重从零恢复到其标准值** 。 这可以使用server指令的slow_start参数来完成：
```
upstream backend {
    server backend1.example.com slow_start=30s;
    server backend2.example.com;
    server 192.0.0.1 backup;
}
```
时间值（此处为30秒）设置NGINX Plus将服务器连接数增加到最大值的时间。

**请注意，如果组中只有一个服务器，则忽略server指令的max_fails，fail_timeout和slow_start参数，并且永远不会将服务器视为不可用。**

# 启用会话保持
会话保持 意味着NGINX Plus识别用户会话并将给定会话中的所有请求路由到 **同一上游服务器** 。

NGINX Plus支持三种会话保持方法，使用sticky指令设置。 （对于使用NGINX OSS的会话持久性，请使用如上所述的hash或ip_hash指令。）

## 1.Sticky Cookie
NGINX Plus为来自上游组的第一个响应添加会话cookie，并识别发送响应的服务器。 客户端的下一个请求包含cookie值，NGINX Plus将请求路由到响应第一个请求的上游服务器：

```
upstream backend {
    server backend1.example.com;
    server backend2.example.com;
    sticky cookie srv_id expires=1h domain=.example.com path=/;
}
```
在该示例中，srv_id是cookie的名称。 可选的expires参数设置浏览器保留cookie的时间（此处为1小时）。 可选的domain参数定义为其设置cookie的域，可选的path参数定义cookie的设置路径。 这是最简单的会话持久性方法。
## 2.Sticky Route
NGINX Plus在收到第一个请求时为客户端分配“路由”。 将所有后续请求与server指令的route参数进行比较，以标识请求被代理到的服务器。 路由信息来自cookie或URI。

```
upstream backend {
    server backend1.example.com route=a;
    server backend2.example.com route=b;
    sticky route $route_cookie $route_uri;
}
```
## 3.Cookie learn
NGINX Plus首先通过检查请求和响应来查找会话标识符。 然后NGINX Plus“学习”哪个上游服务器对应哪个会话标识符。 通常，这些标识符在HTTP cookie中传递。 如果请求包含已经“学习”的会话标识符，NGINX Plus会将请求转发到相应的服务器：
```
upstream backend {
   server backend1.example.com;
   server backend2.example.com;
   sticky learn
       create=$upstream_cookie_examplecookie
       lookup=$cookie_examplecookie
       zone=client_sessions:1m
       timeout=1h;
}
```
在该示例中，其中一个上游服务器通过在响应中设置cookie EXAMPLECOOKIE来创建会话。

必需的create参数指定一个变量，指示如何创建新会话。 在该示例中，从上游服务器发送的cookie EXAMPLECOOKIE创建新会话。

lookup参数指定如何搜索现有会话。 在我们的示例中，在客户端发送的cookie EXAMPLECOOKIE中搜索现有会话。

zone参数指定共享内存区域，其中保留有关粘性会话的所有信息。 在我们的示例中，该区域名为client_sessions，大小为1兆字节。

这是一种比前两种方法更复杂的会话持久性方法，因为它不需要在客户端保留任何cookie：**所有信息都保存在服务器端的共享内存区域中** 。

# 限制连接数
使用NGINX Plus，可以通过使用max_conns参数指定最大数量来限制与上游服务器的连接数。

如果已达到max_conns限制，则将请求 **置于队列中** 以进行进一步处理，前提是还包括queue指令以设置可同时在队列中的最大请求数：
```
upstream backend {
    server backend1.example.com max_conns=3;
    server backend2.example.com;
    queue 100 timeout=70;
}
```
如果队列填满了请求，或者在可选的timeout参数指定的超时期间无法选择上游服务器，**则客户端会收到错误** 。

请注意，如果在其他工作进程中打开了空闲的keepalive连接，则会忽略max_conns限制。 因此，在与多个工作进程共享内存的配置中，与服务器的连接总数可能会超过max_conns值。

# 被动健康检查
当NGINX认为服务器不可用时，它会暂时停止向服务器发送请求，直到它再次被视为活动状态。 server指令的以下参数配置NGINX认为服务器不可用的条件：

* max_fails - 设置NGINX将服务器标记为不可用的连续失败尝试次数。
* fail_timeout - 必须先设置max_fails参数指定的失败尝试次数，fail_timeout为NGINX认为服务器不可用的时间长度。

默认值为1次尝试和10秒超时。 因此，如果服务器不接受或不响应（即一个）请求，NGINX会立即认为服务器不可用10秒钟。

以下示例显示如何设置这些参数：
```
upstream backend {
    server backend1.example.com;
    server backend2.example.com max_fails=3 fail_timeout=30s;
    server backend3.example.com max_fails=2;
}
```
# 积极健康检查
接下来是一些用于跟踪NGINX Plus中服务器可用性的更复杂功能。

定期向每个服务器发送特殊请求并检查满足某些条件的响应可以监视服务器的可用性。

要在nginx.conf文件中启用此类型的运行状况监视，请在将请求传递到上游组的位置包含health_check指令。 此外，上游组必须包含zone指令以定义共享内存区域，其中存储有关运行状况的信息：

```
http {
    upstream backend {
        zone backend 64k;
        server backend1.example.com;
        server backend2.example.com;
        server backend3.example.com;
        server backend4.example.com;
    }
    server {
        location / {
            proxy_pass http://backend;
            health_check;
        }
    }
}
```
* zone指令定义在工作进程之间共享的内存区域，用于存储服务器组的配置。 这使工作进程能够使用同一组计数器来跟踪来自上游服务器的响应。 上游组的动态配置也需要zone指令。
* 不带任何参数的health_check指令使用默认设置配置运行状况监视：NGINX Plus每5秒向后端组中的每个服务器发送一个请求。 如果发生任何通信错误或超时（或代理服务器以2_xx_或3_xx_之外的状态代码响应），则该服务器的运行状况检查将失败。 任何未通过运行状况检查的服务器都被认为是不健康的，并且NGINX Plus会停止向客户端发送请求，直到它再次通过运行状况检查。

可以使用health_check指令的参数覆盖默认行为。 这里，interval参数将运行状况检查之间的持续时间减少到5秒。 failure = 3参数表示在连续3次健康检查失败而不是默认值1之后服务器被认为是不健康的。使用pass参数，服务器需要通过2次连续检查（而不是1次）才能再次被视为健康。

要定义要请求的URI（此处为/ some / path）而不是默认值，请包含uri参数。 URI附加到服务器的域名或IP地址，由上游块中的server指令指定。 例如，对于上面配置的后端组中的第一个服务器，运行状况检查是对http://backend1.example.com/some/path的请求。

```
location / {
    proxy_pass http://backend;
    health_check interval=5 fails=3 passes=2 uri=/some/path;
}
```

最后，您可以设置响应必须满足NGINX Plus的自定义条件，以使服务器健康。 条件在匹配块中指定，然后由health_check指令的match参数引用。
```
http {
    # ...
    match server_ok {
        status 200-399;
        body !~ "maintenance mode";
    }
    
    server {
        # ...
        location / {
            proxy_pass http://backend;
            health_check match=server_ok;
        }
    }
}
```
如果响应中的状态代码在200到399范围内，并且响应正文与指定的正则表达式不匹配，则传递运行状况检查。

match指令使NGINX Plus能够检查状态，标题字段和响应正文。 使用此指令可以验证状态代码是否在指定范围内，响应包括标题，或者标题或正文与正则表达式匹配（以任何组合形式）。 match指令可以包含一个状态条件，一个正文条件和多个标题条件。 要使运行状况检查成功，响应必须满足匹配块中指定的所有条件。

例如，以下匹配块要求响应具有状态代码200，包含具有精确值text / html的Content-Type标头，并在正文中包含文本“Welcome to nginx！”：
```
match welcome {
    status 200;
    header Content-Type = text/html;
    body ~ "Welcome to nginx!";
}
```
在以下使用感叹号（！）的示例中，块匹配响应其中状态代码不是301,302,303和307，并且Refresh不在标题中。
```
match not_redirect {
    status ! 301-303 307;
    header ! Refresh;
}
```
还可以为NGINX Plus代理的非HTTP协议启用运行状况检查：FastCGI，memcached，SCGI和uwsgi。

# 与多个工作进程共享数据
如果上游块不包含zone指令，则每个工作进程都会保留其自己的服务器组配置副本，并维护自己的一组相关计数器。 计数器包括组中每个服务器的当前连接数以及将请求传递到服务器的失败尝试次数。 因此，无法动态修改服务器组配置。

当zone指令包含在上游块中时，上游组的配置保存在所有工作进程之间共享的内存区域中。 此方案是可动态配置的，因为工作进程访问组配置的相同副本并使用相同的相关计数器。

zone指令对于活动运行状况检查和上游组的动态重新配置是必需的。 但是，上游组的其他功能也可以从该指令的使用中受益。

例如，如果未共享组的配置，则每个工作进程都会维护自己的计数器，以便将请求传递给服务器（由max_fails参数设置失败）。 在这种情况下，每个请求只能访问一个工作进程。 当选择处理请求的工作进程无法将请求传输到服务器时，其他工作进程对此一无所知。 虽然某些工作进程可以认为服务器不可用，但其他人可能仍会向此服务器发送请求。 对于最终被视为不可用的服务器，fail_timeout参数设置的时间范围内的失败尝试次数必须等于max_fails乘以工作进程数。 另一方面，zone指令保证了预期的行为。

同样，如果没有zone指令，Least Connections负载平衡方法可能无法正常工作，至少在低负载下。 此方法将请求传递给具有最少活动连接数的服务器。 如果未共享组的配置，则每个工作进程使用其自己的计数器作为连接数，并可能将请求发送到另一个工作进程刚刚发送请求的同一服务器。 但是，您可以增加请求数以减少此影响。 在高负载下，请求在工作进程之间均匀分布，并且最少连接方法按预期工作。

### 设置zone大小
不可能推荐理想的内存区大小，因为使用模式差异很大。 所需的内存量取决于启用了哪些功能（例如会话持久性，运行状况检查或DNS重新解析）以及如何识别上游服务器。

例如，使用sticky_route会话持久性方法并启用单个运行状况检查，256 KB区域可以容纳有关指示的上游服务器数量的信息：
* 128台服务器（每台服务器定义为IP地址：端口对）
* 88个服务器（每个服务器定义为主机名：主机名解析为单个IP地址的端口对）
* 12个服务器（每个服务器定义为主机名：主机名解析为多个IP地址的端口对）

# 使用DNS配置HTTP负载均衡
可以使用DNS在运行时修改服务器组的配置。

对于在服务器指令中使用域名标识的上游组中的服务器，NGINX Plus可以监视对应DNS记录中IP地址列表的更改，并自动将更改应用于上游组的负载平衡，而无需 重启。 这可以通过将http块中的resolver指令和resolve参数包含在server指令中来完成：
```
http {
    resolver 10.0.0.1 valid=300s ipv6=off;
    resolver_timeout 10s;
    server {
        location / {
            proxy_pass http://backend;
        }
    }
    upstream backend {
        zone backend 32k;
        least_conn;
        # ...
        server backend1.example.com resolve;
        server backend2.example.com resolve;
    }
}
```
在该示例中，server指令的resolve参数告诉NGINX Plus定期将backend1.example.com和backend2.example.com域名重新解析为IP地址。

解析器指令定义NGINX Plus向其发送请求的DNS服务器的IP地址（此处为10.0.0.1）。默认情况下，NGINX Plus会以记录中的生存时间（TTL）指定的频率重新解析DNS记录，但您可以使用有效参数覆盖TTL值;在示例中，它是300秒或5分钟。

可选的ipv6 = off参数表示只有IPv4地址用于负载均衡，但默认情况下支持解析IPv4和IPv6地址。

如果域名解析为多个IP地址，则地址将保存到上游配置并进行负载平衡。在我们的示例中，服务器根据最小连接负载平衡方法进行负载平衡。如果服务器的IP地址列表已更改，NGINX Plus会立即在新的地址集中启动负载平衡。








# 总结

好吧，看到后面有点烦了。

[https://docs.nginx.com/nginx/admin-guide/load-balancer/http-load-balancer/](https://docs.nginx.com/nginx/admin-guide/load-balancer/http-load-balancer/)


