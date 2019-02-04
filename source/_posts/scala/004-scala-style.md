---
title: scala编码规范风格
tags:
  - scala
p: scala/004-scala-style
date: 2019-02-04 08:53:27
---

本文翻译自: [https://docs.scala-lang.org/style/](https://docs.scala-lang.org/style/)

# 1.缩进
采用2个空格，而不是tab

```scala
// wrong!
class Foo {
    def fourspaces = {
        val x = 4
        ..
    }
}

// right!
class Foo {
  def twospaces = {
    val x = 2
    ..
  }
}
```

## 换行
换行一般是80个字符。

每个连续的行应该从第一行缩进两个空格。 还要记住，Scala要求每个“换行”要么具有未闭合的括号，要么以中缀方法结束，其中没有给出正确的参数：
```scala
val result = 1 + 2 + 3 + 4 + 5 + 6 +
  7 + 8 + 9 + 10 + 11 + 12 + 13 + 14 +
  15 + 16 + 17 + 18 + 19 + 20
```
如果没有这种尾随方式，Scala会在一行的末尾推断出一个分号，它有时会包装，有时甚至不会发出警告而抛弃编译。

## 有许多参数的方法
当调用一个有大量参数（5个或更多）的方法时，通常需要将方法调用包装到多行上。 在这种情况下，将每个参数单独放在一行上，从当前缩进级别缩进两个空格：
```scala
foo(
  someVeryLongFieldName,
  andAnotherVeryLongFieldName,
  "this is a string",
  3.1415)
```
当太长时，将方法名也换到下一行：
```scala
// right!
val myLongFieldNameWithNoRealPoint =
  foo(
    someVeryLongFieldName,
    andAnotherVeryLongFieldName,
    "this is a string",
    3.1415)

// wrong!
val myLongFieldNameWithNoRealPoint = foo(someVeryLongFieldName,
                                         andAnotherVeryLongFieldName,
                                         "this is a string",
                                         3.1415)
```
# 命名约定
一般来说，Scala使用驼峰命名法。
```scala
UpperCamelCase
lowerCamelCase
```
首字母缩略词应视为普通词：
```scala
使用：
Xhtml
maxId

而不是：
XHTML
maxID
```
编译器实际上不禁止名称（_）中的下划线，但强烈建议不要这样，因为它们在Scala语法中具有特殊含义。

## Classes/Traits
使用驼峰：
```scala
class MyFairLady
```
## Objects
对象名称类似于类名（上层驼峰案例）。

模仿包或函数时例外。 这并不常见。 例：
```scala
object ast {
  sealed trait Expr

  case class Plus(e1: Expr, e2: Expr) extends Expr
  ...
}

object inc {
  def apply(x: Int): Int = x + 1
}
```
## Package
Scala包应遵循Java包命名约定：
```scala
// wrong!
package coolness

// right! puts only coolness._ in scope
package com.novell.coolness

// right! puts both novell._ and coolness._ in scope
package com.novell
package coolness

// right, for package object com.novell.coolness
package com.novell
/**
 * Provides classes related to coolness
 */
package object coolness {
}
```
root

有时需要使用_root_完全限定导入。例如，如果另一个`net`包在范围内，那么要访问`net.liftweb`我们必须这样写：
```java
import _root_.net.liftweb._
```
不要过度使用_root_。通常，嵌套包解析是一件好事，对减少导入混乱很有帮助。使用_root_不仅会否定它们的好处，而且还会引入额外的混乱。

## 方法 
方法的名称应该使用小写开头的驼峰：
```scala
def myFairMethod = ...
```


