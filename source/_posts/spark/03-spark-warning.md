---
title: spark挖坑详解
tags:
  - java
p: spark/03-spark-warning
date: 2018-01-03 20:20:05
---
这是一些官方文档没给完的坑.

# 命令行参数

1. 指定jdbc驱动

打开shell
```shell
[jimo@jimo-pc spark-2.2.0-bin-hadoop2.7]$ bin/spark-shell --driver-class-path /home/jimo/lib/sqljdbc42.jar
```
运行submit
```shell
[jimo@jimo-pc spark-2.2.0-bin-hadoop2.7]$ bin/spark-submit --class "CodeDataFromRDB" --master local[1] --driver-class-path /home/jimo/lib/sqljdbc42.jar /home/jimo/target/scala-2.11/aprioritest_2.11-0.1.jar
```


# spark jdbc
官方地址:

例子代码:
```scala
    val spark = SparkSession.builder().appName(s"${this.getClass.getSimpleName}").getOrCreate()

    import spark.implicits._

    //连接数据库
    val connProperties = new Properties()
    connProperties.put("user", "xxx")
    connProperties.put("password", "xxx")
    val dbUrl = "jdbc:sqlserver://host:1433;databaseName=mydb"
    //构造成绩表DF
    var tableName = "exam_mark"
    val markDF = spark.read.jdbc(dbUrl, tableName, connProperties)
    markDF.createOrReplaceTempView(tableName)
    //学生记录
    tableName = "student_record"
    val studentRecordDF = spark.read.jdbc(dbUrl, tableName, connProperties)
    studentRecordDF.createOrReplaceTempView(tableName)

    val dataDF = spark.sql("select student_id,course_code,cast((CASE when mark>=90 then 'A' " +
      "when mark>=80 then 'B' when mark>=70 then 'C' when mark>=60 then 'D' else 'E' end) as String) as mark from exam_mark " +
      "where mark<>0 and student_id like '2014%' and student_id in(" +
      "select student_id from student_record where speciality_code='0408')")
```
就上面那段sql语句的坑:

1. 为什么要cast,因为不这样mark得出的结果是null
2. cast as String,在sqlserver里是cast as varchar,然而这样也行.

上面得出的结果是:
```scala
    dataDF.show(10)
    
    +----------+-----------+----+
    |student_id|course_code|mark|
    +----------+-----------+----+
    |2014112198|    0471024|   D|
    |2014112198|    3223700|   B|
    |2014112198|    7047924|   B|
    |2014112198|    3273526|   A|
```
# RDD 到 DataSet

# 分区的问题

下面这样写会产生200个txt文件
```scala
markDS.write.text("/home/data/d.txt")
```
可以这样:
```scala
markDS.repartition(1).write.text("/home/data/d.txt")
```
还有一些是coalesce()

他们的区别是什么?

# map之后的结果包含括号的问题

# 去除某一列的重复元素
原数据:
```python
marks = spark.sql("select distinct(student_id),mark1,mark2,mark3,mark4,mark5,mark6 as reault from mark")
marks.show(5)

+----------+-----+-----+-----+-----+-----+------+
|student_id|mark1|mark2|mark3|mark4|mark5|reault|
+----------+-----+-----+-----+-----+-----+------+
|  19990520| 80.0| 89.0| 67.0| 82.0| 64.0|  87.0|
|  20011181| 76.0| 82.0| 68.0| 60.0| 58.0|  60.0|
|  20011181| 76.0| 82.0| 68.0| 60.0| 65.0|  60.0|
|  20011181| 76.0| 82.0| 44.0| 60.0| 58.0|  60.0|
|  20011181| 76.0| 82.0| 44.0| 60.0| 65.0|  60.0|
+----------+-----+-----+-----+-----+-----+------+
```
要去除student_id这一列的重复值:
```python
marks = marks.dropDuplicates(['student_id'])
```