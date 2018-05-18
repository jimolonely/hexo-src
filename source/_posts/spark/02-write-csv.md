---
title: CSV data source does not support array<string> data type
tags:
  - spark
  - scala
p: spark/02-write-csv
date: 2018-01-03 11:04:46
---
运行spark程序,里面有将DataFrame的数据转为csv存储,
但因为数据里有Array类型,无法转换报错:
```
CSV data source does not support array<string> data type
```
# 例子数据
```
+----------+----------+-------------------+
|antecedent|consequent|         confidence|
+----------+----------+-------------------+
|   [C47_D]|    [C3_B]|0.35714285714285715|
|   [C47_D]|   [C13_A]|0.35714285714285715|
|   [C47_D]|   [C23_A]|0.35714285714285715|
|   [C47_D]|   [C24_D]|0.35714285714285715|
...
```
前面2个是数组.
# 解决办法
多种,下面看2种

1. 
```scala
import org.apache.spark.sql.functions.udf

val stringify = udf((vs: Seq[String]) => s"""${vs.mkString(",")}""")
    df.withColumn("antecedent", stringify($"antecedent"))
      .withColumn("consequent", stringify($"consequent"))
      .write.csv("/path/data/csv")
```
2. 
```scala
    case class Asso(antecedent: String, consequent: String, confidence: String)

    df.rdd.map { line => Asso(line(0).toString, line(1).toString, line(2).toString) }.
          toDF().write.csv("/path/data/csv")
```
