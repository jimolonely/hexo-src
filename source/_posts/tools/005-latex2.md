---
title: 不得不会的latex2
tags:
  - latex
  - tool
p: tools/005-latex2
date: 2018-02-07 08:45:25
---
本文将使用10分钟入门latex.

# 环境介绍
使用texlive2017,vs code作为开发工具.

vscode的用户自定义配置如下,为了支持中文:
```json
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
    ]
```
安装的插件是:LaTeX Workshop.

# 最小结构
```latex
\documentclass{article}

\usepackage{xeCJK} %调用 xeCJK 宏包,支持中文

\begin{document}
  LaTEX（/ˈlɑːtɛx/，常被读作/ˈlɑːtɛk/或/ˈleɪtɛk/），文字形式写作LaTeX，是一种基于TEX的排版系统，
  由美国计算机科学家莱斯利·兰伯特在20世纪80年代初期开发，利用这种格式系统的处理，即使用户没有排版和程序设计的知识也可以充分发挥由TEX所提供的强大功能，不必一一亲自去设计或校对，能在几天，甚至几小时内生成很多具有书籍质量的印刷品。对于生成复杂表格和数学公式，这一点表现得尤为突出。因此它非常适用于生成高印刷质量的科技和数学、化学类文档。这个系统同样适用于生成从简单的信件到完整书籍的所有其他种类的文档。
\end{document}
```
# 增加标题,作者,日期
```latex
\title{Latex学习}
\author{jackpler \thanks{jimo}}
\date{2019-01-01} % 或则\today

\begin{document}
  \maketitle % 这才显示出来
```

# 粗体,斜体,下划线
```
由\underline{美国}计算机科学家\textbf{莱斯利·兰伯特}在\textit{20世纪80年代初期}开发
```
现在可以看下效果了:

{% asset_img 000.png %}

# 插入图片
```
\usepackage{graphicx}
\graphicspath{{images/}}

\begin{document}

  \includegraphics{0}
  
\end{document}
```
{% asset_img 001.png %}

# 图表标题,标签和引用
```
\begin{figure}[h]
    \centering
    \includegraphics[width=0.5\textwidth]{0}
    \caption{我的头像}
    \label{fig:me}
  \end{figure}

  请查看在\pageref{fig:me}页的Figure \ref{fig:me}
```
{% asset_img 002.png %}

# 列表
```
  \begin{itemize}
    \item 我是个男人
    \item 我不是个女人
  \end{itemize}

  \begin{enumerate}
    \item 我是个男人
    \item 我不是个女人
  \end{enumerate}
```
{% asset_img 003.png %}
# 数学公式
```
  物理学著名公式(行内): $E=m^2$

  行间公式: $$E=m^2$$

  $$T^{i_1 i_2 \dots i_p}_{j_1 j_2 \dots j_q} = T(x^{i_1},\dots,x^{i_p},e_{j_1},\dots,e_{j_q})$$
```
{% asset_img 004.png %}

