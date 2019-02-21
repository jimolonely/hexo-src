---
title: 大数据进阶教程
tags:
  - scala
  - big data
p: spark/005-big-data-tutorial
date: 2019-02-03 22:17:20
---

记录大数据学习之路。

宗旨：在实践中学习。

拿到一个完整的项目，让项目代码变成你认为最好的样子，然后你就成为了King。

# 熟悉Scala语言

[https://docs.scala-lang.org/zh-cn/tour/tour-of-scala.html](https://docs.scala-lang.org/zh-cn/tour/tour-of-scala.html)

1. 语法初级了解
2. scala编码规范：
3. 语法高级使用

1.scala中函数和方法的区别

函数是一条语句：由参数+函数体组成
```scala
val addOne = (x: Int) => x + 1
```
方法：由def定义
```scala
def add(x: Int, y: Int): Int = x + y
println(add(1, 2)) // 3
```

object: 
1. 单例
2. 静态

提取器对象：

List.tail 方法返回的是：

for循环里的yield操作是什么原理

scala的协变和逆变，java不支持。

类型上下界： `:<`, `>:`.

内部类和java不一样的地方，内部类是不一样的实例。`OuterClass#InnerClass`

注意： 抽象类型、复合类型、自类型的定义和区别。

什么叫隐式参数？

隐式转换没懂： TODO

注意传值参数和传名参数的不同。

常用注解： `@deprecate, @tailrec(什么是尾递归？), @inline`.
注意： java定义的注解在java和scala中使用的差别， 关于默认值和明确表示

导包： 
1. 如何设置别名：`import users.{UserInfo => UI}`
2. scala 可以在任何地方导包
3. 从根包导入： `import _root_.users._`.


# spark
接着就可以开始拿spark练手了，一方面是熟悉scala语言，一方面学习spark。

1. spark-shell使用： [https://spark.apache.org/docs/latest/quick-start.html](https://spark.apache.org/docs/latest/quick-start.html)

2. scala版本问题导致的运行失败，需要在`SPARK_HOME/jars`下查看spark需要的scala版本，然后编译时使用相应的scala版本：[blog](https://blog.csdn.net/u013054888/article/details/54600229)

