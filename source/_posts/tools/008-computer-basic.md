---
title: 不得不知的计算机基础知识
tags:
  - tool
  - linux
p: tools/008-computer-basic
# date: 2018-03-25 15:54:09
---
不得不知的计算机基础知识.

# SSH原理
参考[SSH](http://www.ruanyifeng.com/blog/2011/12/ssh_remote_login.html)

# DevOps
作为IT人员,开发与运维之间的那些事不可不知.
参考[wiki](https://zh.wikipedia.org/wiki/DevOps)

# 进程终止信号
由一篇[漫画](http://turnoff.us/geek/dont-sigkill/)引起了我的好奇,看来必须要知道这些命令,不然漫画都看不懂.

| 信号 | 操作 | 影响 |
| --- | --- | --- |
| SIGINT | 在终端中敲入interrupt key（DELETE或ctrl+c） | 中断前台进程 |
| SIGKILL | kill -9 pid | 信号进程不能够捕获,强制结束进程pid |
| SIGTERM | kill pid | 它会导致一过程的终止，但是SIGKILL信号不同，它可以被捕获和解释（或忽略）的过程。因此，SIGTERM类似于问一个进程终止可好，让清理文件和关闭 |

# make命令
如果经常从源码编译软件,那肯定会用到make命令,而要学习make,除了man make之外,其makefile的语法学习是必不可少的.
下面是可以参考的学习文档.

1. [官方文档](http://www.gnu.org/software/make/manual/html_node/index.html#SEC_Contents)
2. [阮一峰写的](http://www.ruanyifeng.com/blog/2015/02/make.html)
3. [跟我一起写Makefile](https://seisman.github.io/how-to-write-makefile/)

# 开源协议
作为开源爱好者,怎么会不了解开源协议呢?常见的也就6种:
[GPL](http://www.gnu.org/licenses/quick-guide-gplv3.html),
[BSD](https://en.wikipedia.org/wiki/BSD_licenses),
[MIT](https://en.wikipedia.org/wiki/MIT_License),
[Apache](http://www.apache.org/licenses/LICENSE-2.0),
[LGPL](http://www.gnu.org/copyleft/lesser.html),
[Mozilla](https://www.mozilla.org/en-US/MPL/)

看到大多数都引用的[阮一峰翻译的那张图](http://www.ruanyifeng.com/blog/2011/05/how_to_choose_free_software_licenses.html).
现在GPL出到3.0版本,还需要重新学习下.

{% asset_img 000.png %}

# 视频文件格式
视频已经离不开生活,了解常见的视频文件格式还是很有必要的.
[wiki-视频文件格式](https://zh.wikipedia.org/wiki/%E8%A7%86%E9%A2%91%E6%96%87%E4%BB%B6%E6%A0%BC%E5%BC%8F)
[compare](https://en.wikipedia.org/wiki/Comparison_of_video_container_formats)

# 编码那些事
有没有好奇UTF-8是什么,UTF-8和UTF-16的区别是什么?走进字符集的世界,奠定表示的基础.
可以参考以下文章:
1. [阮大神的曾经](http://www.ruanyifeng.com/blog/2007/10/ascii_unicode_and_utf-8.html)
2. [RFC-UTF-8(3629)](http://www.rfcreader.com/#rfc3629)
3. [unicode官网](http://www.unicode.org/)
4. [查看中日韩汉字unicode编码](http://www.chi2ko.com/tool/CJK.htm)

大概结果就是:
1. 了解unicode的历史,从65535到一百多万的字符集;
2. UTF8和UTF16,UTF32都是unicode的实现,是编码方式;
3. UTF8并不是只有8位,可根据情况变化1到3个字节.


