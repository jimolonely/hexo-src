---
title: '\r':command not found
tags:
  - shell
  - linux
p: shell/003-carriage-linechange
date: 2019-10-15 17:15:44
---

当然，这个由于操作系统之间的差异构成的回车换行符。

下面说说windows下的脚本拷到linux上出现这个问题时怎么解决：

# 1.直接替换掉

```s
sed -i 's/\r$//' filename
```

# 2.使用工具替换掉

```s
 # install dos2unix

 dos2unix test.sh
```
