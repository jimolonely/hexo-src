---
title: 不得不会的latex
tags:
  - latex
  - tool
p: tools/000-latex
date: 2018-01-01 13:51:55
---
# 1.什么是latex

LaTEX（/ˈlɑːtɛx/，常被读作/ˈlɑːtɛk/或/ˈleɪtɛk/），文字形式写作LaTeX，是一种基于TEX的排版系统，由美国计算机科学家莱斯利·兰伯特在20世纪80年代初期开发，利用这种格式系统的处理，即使用户没有排版和程序设计的知识也可以充分发挥由TEX所提供的强大功能，不必一一亲自去设计或校对，能在几天，甚至几小时内生成很多具有书籍质量的印刷品。对于生成复杂表格和数学公式，这一点表现得尤为突出。因此它非常适用于生成高印刷质量的科技和数学、化学类文档。这个系统同样适用于生成从简单的信件到完整书籍的所有其他种类的文档。

参看[wiki](https://zh.wikipedia.org/wiki/LaTeX)

# 2.latex可以做什么
1. 书籍排版
2. 论文
3. 数学符号
4. 化学公式
5. 五线谱
6. 象棋
7. 电路图

只要有相应的语法规则和宏包,就可以表示出来.

# 3.编写latex的工具
可以参考wiki做的对比:[https://en.wikipedia.org/wiki/Comparison_of_TeX_editors](https://en.wikipedia.org/wiki/Comparison_of_TeX_editors)

也有在线的网页版本(个人免费),[shareLatex](https://cn.sharelatex.com/user/subscription/plans)

常用的在linux:Texmaker,TeXstuio.

和一些加插件的编辑器: sublime,visual studio,atom,emacx,vim等.

更多参考知乎:[知乎](https://www.zhihu.com/question/19954023)

使用vscode时需要注意,需要先安装texlive环境.
windows环境没问题,linux下有多个包:

{% asset_img 001.png %}

安装上面最基本就可以了,后面还可增加.

# 4.让vscode支持中文
## 4.1
其他配置都不用改,直接修改文档:

1. 最前面加上:
```latex
%!TEX program = pdflatex
```
2. 在要使用中文的地方加上:
```latex
\begin{CJK}{UTF8}{bsmi}
Hello World! 有没有改错,这就是中文
\end{CJK}
```
然而这种方法会出现字体支持不全的情况,简体中文很多都没有.
## 4.2
这个方法需要安装xelatex,一般都有了.

然后设置编译环境:
```
"latex-workshop.latex.toolchain": [
        {
            "command": "xelatex",
            "args": [
                "-synctex=1",
                "-interaction=nonstopmode",
                "-file-line-error",
                "-pdf",
                "%DOC%"
            ]
        }
    ],
"editor.fontFamily": "'Droid Sans Fallback','Droid Sans Mono', 'monospace', monospace"
```
文档中声明:
```
\usepackage{xeCJK} %调用 xeCJK 宏包
```
如果中文不能正常显示,那么就需要手动指定字体:
```
\setCJKmainfont{Droid Sans Fallback} %设置 CJK 主字体为Droid Sans Fallback
```
如果没有对应的字体,就需要下载了.

最后一个简单的例子:
```latex
\documentclass[30pt,a4paper]{article}
\usepackage{xeCJK} %调用 xeCJK 宏包
\setCJKmainfont{Droid Sans Fallback} %设置 CJK 主字体为 Droid Sans Fallback

\title{ hehe第一篇 latex}
\author{jimo \thanks{latex}}
\date{\today}

\begin{document}

\maketitle

中文求显示,有没有搞错,这就是中文

First document. This is a
simple example, with no extra parameters or packages included.

% 注释不会显示

\textbf{bold} \underline{underline} \textbf{\textit{italic-bold}}

\end{document}
```
# 5.先看一张图

{% asset_img 000.png %}