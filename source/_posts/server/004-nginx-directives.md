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
```
