---
title: idea插件开发01-入门篇
tags:
  - idea
p: tools/020-idea-plugin-devlop
date: 2019-09-01 18:21:24
---

本文是开发idea插件的第一篇，包含对插件的基本认识和一个HelloWord示例。

# 插件的类型

[https://www.jetbrains.org/intellij/sdk/docs/basics/types_of_plugins.html](https://www.jetbrains.org/intellij/sdk/docs/basics/types_of_plugins.html)

基于IntelliJ平台的产品可以通过添加插件进行修改和调整，以实现自定义目的。所有可下载的插件都可以在[JetBrains插件库](https://plugins.jetbrains.com/)中找到。

最常见的插件类型包括：

* 自定义语言支持
* 框架集成
* 工具集成
* 用户界面附加组件

## 自定义语言支持
自定义语言支持提供了使用特定编程语言的基本功能。这包括：

* 文件类型识别
* 词法分析
* 语法突出显示
* 格式化
* 代码洞察和代码补全
* 检查和快速修复
* 意图行动

请参阅[自定义语言支持教程](https://www.jetbrains.org/intellij/sdk/docs/tutorials/custom_language_support_tutorial.html)以了解有关该主题的更多信息。

## 框架集成
框架集成包括改进的代码洞察功能，这些功能对于给定的框架是典型的，以及直接从IDE使用框架特定功能的选项。有时它还包括自定义语法或DSL的语言支持元素。

* 具体的代码见解
* 直接访问特定于框架的功能

请参阅[Struts 2插件](https://plugins.jetbrains.com/plugin/1698)作为框架集成的示例。

## 工具集成
通过工具集成，可以直接从IDE操作第三方工具和组件，而无需切换上下文。

这意味着：

* 实施其他行动
* 相关的UI组件
* 访问外部资源

请参阅[Gerrit集成插件](https://plugins.jetbrains.com/plugin/7272?pr=idea)作为示例。

## 用户界面附加组件
此类别中的插件会对IDE的标准用户界面应用各种更改。一些新添加的组件是交互式的并提供新功能，而其他组件仅限于视觉修改。[背景图像插件](https://plugins.jetbrains.com/plugin/72)可以作为示例。

# HelloWorld示例

[https://www.jetbrains.org/intellij/sdk/docs/tutorials/build_system/prerequisites.html](https://www.jetbrains.org/intellij/sdk/docs/tutorials/build_system/prerequisites.html)

## 1.建插件项目

1. 选择Gradle项目
2. 选择附加库和框架：Java 和 IntelliJ Platform Plugin

## 2.构建gradle项目

1. 认识gradle配置
2. 认识项目结构

## 3.写一个Action

```java
import com.intellij.openapi.actionSystem.AnAction;
import com.intellij.openapi.actionSystem.AnActionEvent;
import com.intellij.openapi.project.Project;
import com.intellij.openapi.ui.Messages;
import org.jetbrains.annotations.NotNull;

public class HelloAction extends AnAction {

    public HelloAction() {
        super("hello");
    }

    @Override
    public void actionPerformed(@NotNull AnActionEvent e) {

        Project project = e.getProject();
        Messages.showMessageDialog(project, "hello jimo", "Greeting", Messages.getInformationIcon());
    }
}
```
然后配置plugin.xml:

```xml
    <actions>
        <!-- Add your actions here -->
        <group id="jimo-Menu" text="Jimo-Menu" description="greeting menu">
            <add-to-group group-id="MainMenu" anchor="last"/>
            <action id="com.jimo.HelloAction" class="com.jimo.HelloAction"
                    text="Hello" description="say hello">
            </action>
        </group>
    </actions>
```

运行：

Gradle-->Tasks-->intellij-->runIde

这Hello按钮可能是禁用的，需要打开左侧project菜单栏才会启用。


