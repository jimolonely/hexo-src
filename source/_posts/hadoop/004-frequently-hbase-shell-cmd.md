---
title: 常用的hbase shell命令
tags:
  - hbase
  - linux
p: hadoop/004-frequently-hbase-shell-cmd
date: 2019-01-09 08:54:38
---

本文记录一下经常在排查hbase问题时用到的 shell命令。

# list 查看有哪些表
```shell
> list
```

# 查询起始行

```shell
> scan 'table' , { STARTROW=>'', ENDROW=>'', LIMIT=>5 }
```


