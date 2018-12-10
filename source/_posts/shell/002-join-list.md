---
title: shell如何join数组
tags:
  - shell
p: shell/002-join-list
date: 2018-12-10 11:41:48
---

shell里如何使用某个分割符连接数组、List等

# 方法

## 1.使用local
[https://zaiste.net/how_to_join_elements_of_an_array_in_bash/](https://zaiste.net/how_to_join_elements_of_an_array_in_bash/)

## 2.使用python
一般在linux系统里都自带python。使用高级语言写起来当然更爽。



# 例子
```shell
#!/bin/bash

re=`netstat -anp | grep -E '::(8001|8003|8761|5557)' | awk '{print $7}' OFS="\n" | awk -F/ '{print $1}'`

function join { local IFS="$1"; shift; echo "$*"; }

# 以逗号连接
pids=`join , $re`
echo $pids

top -p $pids
```

