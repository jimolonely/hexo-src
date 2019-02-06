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
### get/set方法
scala没有和java一样的get/set方法，但有下面的方式：
```scala
class Foo {

  def bar = ...

  def bar_=(bar: Bar) {
    ...
  }

  def isBaz = ...
}

val foo = new Foo
foo.bar             // accessor
foo.bar = bar2      // mutator
foo.isBaz           // boolean property
```
私有变量：
```scala
class Company {
  private var _name: String = _

  def name = _name

  def name_=(name: String) {
    _name = name
  }
}
```
### 括号
方法声明可以有、也可以没有括号：
```scala
def foo1() = ...

def foo2 = ...
```
但是，建议调用时和声明时一样。

```scala
// doesn't change state, call as birthdate
def birthdate = firstName

// updates our internal state, call as age()
def age() = {
  _age = updateAge(birthdate)
  _age
}
```
### 符号方法名
尽量避免，虽然可以用。例如：`a+b(), c::d, >>=`.

### 常量、值、变量、方法
类似java的`static final`, scala里常量的声明采用大写首字母的驼峰命名：
```scala
object Container {
  val MyConstant = ...
}
```
而其他命名如下：
```scala
val myValue = ...
def myMethod = ...
var myVariable
```
## 泛型
不像Java的泛型用T，scala使用从A开始的字母：
```scala
class List[A] {
  def map[B](f: A => B): List[B] = ...
}
```
或者：
```scala
// Right
class Map[Key, Value] {
  def get(key: Key): Value
  def put(key: Key, value: Value): Unit
}

// Wrong; don't use all-caps
class Map[KEY, VALUE] {
  def get(key: KEY): VALUE
  def put(key: KEY, value: VALUE): Unit
}
```
```scala
class Map[K, V] {
  def get(key: K): V
  def put(key: K, value: V): Unit
}
```
### 高级参数类型
```scala
class HigherOrderMap[Key[_], Value[_]] { ... }

def doSomething[M[_]: Monad](m: M[Int]) = ...
```

## 注解
应该是小写：
```scala
class cloneable extends StaticAnnotation

type id = javax.persistence.Id @annotation.target.field
@id
var id: Int = 0
```
## 简短的特殊性
在java里可能不是个好习惯，但scala里推荐：
```scala
def add(a: Int, b: Int) = a + b
```

# 类型

## 引用类型
// TODO

## 注解
```scala
value: Type
```
冒号写在value后面而不是Type前面是有原因的，如下：
```scala
value :::
```
可能会有Type是`::`的。
## Ascription
// TODO

## 函数类型
函数作为参数时，能省括号就省，一元参数时不加括号：
```scala
def foo(f: Int => String) = ...

def bar(f: (Boolean, Double) => List[String]) = ...
```
极端例子：
```scala
// wrong!
def foo(f: (Int) => (String) => (Boolean) => Double) = ...

// right!
def foo(f: Int => String => Boolean => Double) = ...
```
## 结构类型
低于50个字符就写在一行，否则分开：
```scala
// wrong!
def foo(a: { def bar(a: Int, b: Int): String; val baz: List[String => String] }) = ...

// right!
private type FooParam = {
  val baz: List[String => String]
  def bar(a: Int, b: Int): String
}

def foo(a: FooParam) = ...
```
内联：
```scala
def foo(a: { val bar: String }) = ...
```

# 块
## 大括号
左大括号必须和声明的语句在同一行：
```scala
def foo = {
  ...
}
```
## 小括号
很长的语句可以换行：
```scala
(this + is a very ++ long *
  expression)
```
条件语句：
```scala
(  someCondition
|| someOtherCondition
|| thirdCondition
)
```










