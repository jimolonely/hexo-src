---
title: java后端跨域时自定义header字段
tags:
  - java
  - spring
p: java/066-java-cors-rewrite-header
date: 2019-09-12 14:37:10
---

在跨域时，后端可能需要往response header里增加点自定义字段，但是直接增加是不行的。

# 之前

```java
response.setHeader("token", "sdfsdfjdskjfhjdsf");
```

# 之后

```java
// 允许返回token在响应头中
response.setHeader("Access-Control-Expose-Headers", "token");
response.setHeader("token", "sdfsdfjdskjfhjdsf");
```




