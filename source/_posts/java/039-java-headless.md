---
title: 什么是Java Headless模式？
tags:
  - java
p: java/039-java-headless
date: 2019-03-26 07:58:42
---

在阅读spring-boot源码时遇到它开启了Headless模式，那么这是什么呢？

看一下[官网的文档](https://www.oracle.com/technetwork/articles/javase/headless-136834.html)

我将里面的关键点总结出来。

# 概念：什么是headless模式
headless模式是缺少显示设备，键盘或鼠标的系统配置。 听起来很意外，但实际上您可以在此模式下执行不同的操作，即使使用图形数据也是可以的。

# 使用场景
哪里适用？ 假设您的应用程序重复生成某个图像，例如，每次用户登录系统时都必须更改的图形授权代码。 创建图像时，您的应用程序既不需要显示也不需要键盘。
 现在让我们假设您的项目中有一台没有显示设备，键盘或鼠标的大型机或专用服务器。 理想的决定是使用它的强大计算能力来处理可视化等特征。 然后可以将在无头模式系统中生成的图像传递到有头（headful）系统以进一步渲染。

# 如何使用
`java.awt.Toolkit`和`java.awt.GraphicsEnvironment`类中的许多方法（字体，图像和printing除外）都需要显示设备，键盘和鼠标的可用性。 但是某些类（如Canvas或Panel）可以在无头模式下执行。 自J2SE 1.4平台以来，已经提供无头模式支持。

## 设置无头模式
要使用无头模式操作，您必须首先了解如何检查和设置与此模式相关的系统属性。 此外，您必须了解如何创建默认工具包以使用Toolkit类的无头实现。

## 系统属性设置

要设置无头模式，请使用setProperty（）方法设置适当的系统属性。 此方法使您可以为特定键指示的系统属性设置所需的值。
```java
System.setProperty（“java.awt.headless”，“true”）;
```
在此代码中，`java.awt.headless`是系统属性，true是分配给它的值。

如果计划在无头环境和传统环境中运行相同的应用程序，也可以使用以下命令行：
```java
java -Djava.awt.headless = true
```

## 检测无头模式

```java

GraphicsEnvironment ge = 
GraphicsEnvironment.getLocalGraphicsEnvironment(); 
boolean headlessCheck = ge.isHeadless();
```

# spring-boot中的使用
位于SpringApplication.java里：
```java
	private void configureHeadlessProperty() {
		System.setProperty(SYSTEM_PROPERTY_JAVA_AWT_HEADLESS, System.getProperty(
				SYSTEM_PROPERTY_JAVA_AWT_HEADLESS, Boolean.toString(this.headless)));
	}
```

# 参考
1. [什么是 java.awt.headless
](https://www.cnblogs.com/hzhuxin/p/8287090.html)



