---
title: shell常用操作
tags:
  - shell
  - linux
p: shell/001-shell-common-use
date: 2018-04-01 13:51:55
---
shell那些常用操作.

# 字符串为空判断
注意有引号
```shell
str=

if [ -z "$str" ];then
    echo "is empty"
fi

if [ -n "$str" ];then
    echo "not empty"
```
