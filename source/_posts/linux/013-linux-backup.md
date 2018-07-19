---
title: linux-backup
tags:
  - linux
p: linux/013-linux-backup
---

本文讲述备份系统要注意哪些方面．
关于重装系统应该做什么参看：[build-linux](http://jimolonely.github.io/2017/12/27/linux/000-build-mysystem/),[manjaro-build](http://jimolonely.github.io/2018/07/19/linux/001-linux-manjaro/)

# 同步
能同步的就同步了，不需要拷贝，比如以下的数据:
1. 浏览器书签：使用chrome或firefox都是可以的.
2. 云同步：比如百度云，坚果云等．推荐坚果云，速度快，实时同步．

# 代码
一般我的重要代码都是同步到github，重装系统前确定所有github项目都已经同步．

# 重要数据
以下目录需要查看：

1. book
2. software: democross,idea-pro(恢复时需要构建path)
3. VirtualBox VMs: 里面的虚拟机需要备份
4. workspace: 注意备份myblog. 其结构如下：
{% asset_img 000.png %}
{% asset_img 001.png %}

5. 视频,图片，文档

# 软件
1. wps
2. keepassx2
3. vim
4. vs
5. nutstore
6. VYM
7. dbeaver
8. idea,pycharm
9. wechat

另外：
1. git 需要配置ssh登录
2. maven和pip需要配置镜像

**便签：　内容需要同步**
