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

# 返回上一步下一步
用于经常看源码。

由于不同操作系统不一样，所以需要去看自己的配置： keymap-->navigate--->back/forward

{% asset_img 003.png %}

如果冲突了，就需要排查系统快捷键或其他软件，或自己改一下idea的快捷键。

# idea如何查看类图
[https://www.jetbrains.com/help/idea/class-diagram.html](https://www.jetbrains.com/help/idea/class-diagram.html)

在包上右键，选择diagram.

# IDEA 设置代码行宽度

1. 在File->settings->Editor->Code Style

2. 有人会问，如果输入的代码超出宽度界线时，如何让IDE自动将代码换行？有两种方式！

3. 第一种，在上述的“Right margin (columns)”的下方，有“Wrap when typing reaches right margin”选项，选中它，是什么效果呢？

4. 随着输入的字符的增加，当代码宽度到达界线时，IDEA会自动将代码换行。

5. 第一种方式是在输入代码时触发，还有第二种方式，在File->settings->Code Style->Java中，选中“Wrapping and Braces”选项卡

6. 在“Keep when reformatting”中有一个“Ensure rigth margin is not exceeded”，选中它，是什么效果呢？

7. 从配置项的字面意思很容易理解，在格式化Java代码时，确保代码没有超过宽度界线。

8. 即输入的代码超出界线后

# IntelliJ强制更新Maven Dependencies

Intellj 自动载入Mave依赖的功能很好用，但有时候会碰到问题，导致pom文件修改却没有触发自动重新载入的动作，此时需要手动强制更新依赖。

如下： 

1. 手动删除Project Settings里面的Libraries内容；

2. 在Maven Project的试图里clean一下，删除之前编译过的文件；

3. 项目右键-》Maven-》Reimport

4. Ok， 此时发现依赖已经建立！ 


