---
title: webpack热更新失败-检测不到文件变化
tags:
  - js
  - webpack
p: js/008-webpack-hot-swap-failed-not-feel-change
date: 2019-05-19 12:50:03
---

本项目是一个使用webpack构建的vue项目，一切都正常，开始可以热更新，后来文件多了，发现直接删除磁盘上的东西可以热更新，
而在IDE里修改文件不行，经过思考，发现是一个参数决定了。

开发环境是ubuntu。

Webpack 的热部署功能是使用 inotify 来监视文件变化，其中 `fs.inotify.max_user_watches` 表示同一用户同时可以添加的watch数目（watch一般是针对目录，决定了同时同一用户可以监控的目录数量）

因此，查看了一下系统当前的 max_user_watches 值
```js
$ cat /proc/sys/fs/inotify/max_user_watches
8192
1
2
```
8192是默认值，可能是这个值太小，而我的app下的文件目录太多，于是试着修改一下
```js
echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p
```
修改后查看一下修改结果
```js
$ cat /proc/sys/fs/inotify/max_user_watches
524288
```

现在就可以了，估计windows下不会出现。

--------------------- 
作者：kongxx 
来源：CSDN 
原文：https://blog.csdn.net/kongxx/article/details/72515914 
版权声明：本文为博主原创文章，转载请附上博文链接！
