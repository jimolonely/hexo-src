---
title: idea常见问题
tags:
  - idea
p: tools/012-idea-question
date: 2018-12-14 09:30:49
---

# 如何不格式化注释
在使用`Ctrl+Alt+L`进行格式化时，不想格式化注释。

## 方法1
使用手动标注：
{% asset_img 000.png %}

然后就可以使用了：在不想注释的前后加上关闭，开启（为何要开启，因为关闭会影响后面所有代码）
```java
	// @formatter:off
	/**
	 * 判断x是否可以由list中的数字不重复相加得到
	 * <p>
	 * x = a + list
	 *          |
	 *          a1 + list1
	 *                  |
	 *                  a2 + list2
	 *                          ...
	 *                          an + y
	 * </p>
	 */
	// @formatter:on
	private boolean foundEqual(Integer x, List<Integer> list) {
		return false;
	}
```
## 方法2
直接禁用注释的格式化：这个影响是全局的，可能没那么可定制化。
以Java为例：
{% asset_img 001.png %}

有意思是吧，看自己的选择了。

# idea里markdown绘制UML图

[https://www.jetbrains.com/help/idea/markdown.html](https://www.jetbrains.com/help/idea/markdown.html)

这样下载：

{% asset_img 002.png %}

需要安装：Graphviz
[https://www.jianshu.com/p/6c4071eac339](https://www.jianshu.com/p/6c4071eac339)
https://www.jianshu.com/p/a6bd7e3048ef


## 其他选择
直接建立uml文件：

安装一个插件：plantuml integration.

[https://plugins.jetbrains.com/plugin/7017-plantuml-integration](https://plugins.jetbrains.com/plugin/7017-plantuml-integration)

绘制语法：[http://plantuml.com/](http://plantuml.com/)


