---
title: 手动安装texlive
tags:
  - latex
  - tool
  - texlive
p: tools/004-install-texlive
date: 2018-01-12 15:46:23
---
本文将手动安装texlive环境,从下载到配置.

# 下载
CTAN有各个安装源[https://ctan.org/mirrors](https://ctan.org/mirrors)

我使用清华的:
```shell
$ wget -c http://mirrors.tuna.tsinghua.edu.cn/CTAN/systems/texlive/Images/texlive2017-20170524.iso
```
下载有3个多GB.

# 安装
在安装前清除遗留程序,解压或挂载后在root下执行安装程序:
```shell
$ locate texlive | xargs rm -rf

$ sudo ./install-tl
```
这是个漫长的过程,大概要12分钟.

安装完后会提示各个路径:
```shell
Welcome to TeX Live!

Documentation links: /usr/local/texlive/2017/index.html
The TeX Live web site (https://tug.org/texlive/)
contains updates and corrections.

TeX Live is a joint project of the TeX user groups around the world;
please consider supporting it by joining the group best for you.
The list of groups is on the web at https://tug.org/usergroups.html.

Add /usr/local/texlive/2017/texmf-dist/doc/man to MANPATH.
Add /usr/local/texlive/2017/texmf-dist/doc/info to INFOPATH.
Most importantly, add /usr/local/texlive/2017/bin/x86_64-linux
to your PATH for current and future sessions.

Logfile: /usr/local/texlive/2017/install-tl.log
```
比如文档路径:/usr/local/texlive/2017/index.html

更重要的是环境变量:/usr/local/texlive/2017/bin/x86_64-linux
# 配置与测试
配置环境变量:追加.bashrc
```shell
export TEXLIVE=/usr/local/texlive/2017/bin/x86_64-linux
export PATH=$TEXLIVE:$PATH
```
测试:
```shell
$ tex --version
TeX 3.14159265 (TeX Live 2017)
kpathsea version 6.2.3
Copyright 2017 D.E. Knuth.
There is NO warranty.  Redistribution of this software is
covered by the terms of both the TeX copyright and
the Lesser GNU General Public License.
For more information about these matters, see the file
named COPYING and the TeX source.
Primary author of TeX: D.E. Knuth.
```
编辑个简单的文档保存为sample.tex:
```latex
\documentclass[12pt,a4paper]{report}

\title{Title}
\author{jackpler}
\date{\today}

\begin{document}
hello world!
\end{document}
```
然后测试:
```shell
$ latex sample.tex  # 编译一个测试文件
$ pdftex sample.tex # 生成测试文档的pdf文件
```
# tlmgr使用
现在texlive自带tlmgr包管理工具进行管理,方便了.
```shell
# 自动选择最近的仓库更新
$ sudo tlmgr option repository http://mirror.ctan.org/systems/texlive/tlnet    
# 更新宏包管理器
$ sudo tlmgr update --self  
# 更新所有已安装的宏包
$ sudo tlmgr update --all   
# 安装新包
$ sudo tlmgr install 包名
```
更多包在[CTAN](https://ctan.org)上去找.
# 更多学习
使用官方文档:[https://www.tug.org/texlive/doc/texlive-zh-cn/texlive-zh-cn.pdf](https://www.tug.org/texlive/doc/texlive-zh-cn/texlive-zh-cn.pdf)

完整的tlmgr命令文档[tlmgr](http://tug.org/texlive/doc/tlmgr.html)