---
title: ES与Lucene原理理解总结
tags:
  - es
  - lucene
p: elasticsearch/007-lucene-es
date: 2019-07-01 10:44:20
---

# lucene中索引的过程

让我简单的描述成一句话：

Text --》 Token  --》 Analyze  --》 Filters  --》 （Term，count，docs）

Field在Document中

# lucene打分算法

首先了解boost单词： 愿意是促进，抬高，这里可以理解为权重。

TF、IDF算法


# 参考
https://doc.yonyoucloud.com/doc/mastering-elasticsearch/index.html


