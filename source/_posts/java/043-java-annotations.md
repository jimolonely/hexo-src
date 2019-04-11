---
title: java常用注解
tags:
  - java
  - annotation
p: java/043-java-annotations
date: 2019-04-11 14:51:29
---

注解已经不可或缺，阅读源码经常遇到，如果不会将是一个障碍。
不妨从jdk自带注解开始。

当然，在讲任何一个注解前都会讲元注解（`@Document, @Retention, @Target`等）,实际上这是递归定义的。

# Nonnull
```java
package javax.annotation;
import javax.annotation.meta.When;

@Documented
@TypeQualifier
@Retention(RetentionPolicy.RUNTIME)
public @interface Nonnull {
    When when() default When.ALWAYS;

    public static class Checker implements TypeQualifierValidator<Nonnull> {
        public Checker() {
        }

        public When forConstantValue(Nonnull qualifierqualifierArgument, Object value) {
            return value == null ? When.NEVER : When.ALWAYS;
        }
    }
}

public enum When {
    ALWAYS,
    UNKNOWN,
    MAYBE,
    NEVER;

    private When() {
    }
}
```
标示一种类型为null的4种情况。

# TypeQualifierNickname
元注解：
```java
package javax.annotation.meta;

@Documented
@Target({ElementType.ANNOTATION_TYPE})
public @interface TypeQualifierNickname {
}
```
见[解释](https://aalmiray.github.io/jsr-305/apidocs/javax/annotation/meta/TypeQualifierNickname.html)：
> @TypeQualifierNickname 用于注解其他注解，并把它标注的注解标记为限定符别称，把@TypeQualifierNickname 所注解的注解X 应用到元素Y 上时，相当于把 注解 X上的注解（除去@TypeQualifierNickname） 都应用到元素Y 上了, 因此叫做注解X上除去 @TypeQualifierNickname 以外所有其他注解的别称，即类型限定符别称.

例子：查看一个spring里的注解@Nullable：
```java
package org.springframework.lang;

@Target({ElementType.METHOD, ElementType.PARAMETER, ElementType.FIELD})
@Retention(RetentionPolicy.RUNTIME)
@Documented
@Nonnull(when = When.MAYBE)
@TypeQualifierNickname
public @interface Nullable {
}
```
这个注解的含义： 标识目标可能为null，而因为`TypeQualifierNickname`的存在，当使用`@Nullable`时就和直接使用`@Nonnull`一样了，`@Nullable`
只是一个别名。



```java
```
```java
```
```java
```
```java
```


