---
title: 强大的pandoc
tags:
  - pandoc
  - tool
p: tools/017-pandoc
date: 2019-07-28 09:49:48
---

pandoc毫无疑问是一款强大的文件转换工具，这里表示一下可能会基于它做一些东西出来。

[https://pandoc.org/index.html](https://pandoc.org/index.html)

# docx转markdown，带图片

```shell
$ pandoc --extract-media ./ test.docx -f docx -t markdown -o 1.md
```


