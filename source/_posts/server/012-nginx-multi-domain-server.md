---
title: nginx多域名共用80端口
tags:
  - nginx
p: server/012-nginx-multi-domain-server
date: 2019-10-12 11:34:12
---

服务器一个IP映射了多个域名，他们共用80端口的配置。

其实非常简单，server_name设成不同的就行了。

```s
#应用一
server {
   listen 80;
   server_name app1.domain.com;
   location / {
      proxy_pass        http://app1/;
      proxy_redirect    off;
      proxy_set_header  Host  $host;
      proxy_set_header  X-Real-IP  $remote_addr;
      proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;
  }
}
#应用二
server {
   listen 80;
   server_name app2.domain.com;
   location / {
      proxy_pass        http://app2/;
      proxy_redirect    off;
      proxy_set_header  Host  $host;
      proxy_set_header  X-Real-IP  $remote_addr;
      proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;
  }
}

#负载均衡节点配置
upstream app1 {
     server 192.168.1.1;
     server 192.168.1.2;
     ip_hash;
 }
upstream app2 {
     server 192.168.1.3;
     server 192.168.1.4;
     ip_hash;
}
```


