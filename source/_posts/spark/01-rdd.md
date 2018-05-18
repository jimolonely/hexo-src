---
title: 理解RDD
tags:
  - spark
  - scala
p: spark/01-rdd
date: 2018-01-02 15:04:20
---
RDD虽然是spark抽象出来的概念,但不得不理解.

# 什么是RDD
RDD(resilient distributed datasets),弹性分布式数据集.
spark的核心概念,简单说就是分布式的元素集合.

# RDD操作
1. 转化操作:并不进行实际运算
```scala
scala> val lines = sc.textFile("README.md")
lines: org.apache.spark.rdd.RDD[String] = README.md MapPartitionsRDD[1] at textFile at <console>:2

scala> val pythonLines = lines.filter(line=>line.contains("Python"))
res3: org.apache.spark.rdd.RDD[String] = MapPartitionsRDD[2] at filter at <console>:27
``` 
2. 行动操作(Action):做实际运算
```scala
scala> pythonLines.count()
res5: Long = 3

scala> pythonLines.take(10).foreach(line=>println(line))
high-level APIs in Scala, Java, Python, and R, and an optimized engine that
## Interactive Python Shell
Alternatively, if you prefer Python, you can use the Python shell:
```
3. 惰性求值:在调用行动操作前不会开始计算.

# 常见操作
1. 常见转化操作
```
filter
map
flatMap
distinct
```
2. 伪集合操作
```
union
intersection
substract
cartesian
```
3. 行动操作
```
collect
count
take
top
reduce
fold
aggregate
foreach
```
# 持久化
由于RDD是惰性求值的,所以我们多次使用行动操作时每次都会重算,所以缓存起来比较好.
```scala
import org.apache.spark.storage.StorageLevel

val result = input.map(x=>x*x)
result.persist(StorageLevel.DISK_ONLY)
println(result.count())
println(result.collect().mkString(","))
```
持久化级别有几种:
```
MEMORY_ONLY
MEMORY_AND_DISK
DISK_ONLY
```
内存写不下会放到磁盘,spark使用的LRU算法.