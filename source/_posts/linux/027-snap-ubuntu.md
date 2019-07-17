---
title: snap应用商店
tags:
  - ubuntu
p: linux/027-snap-ubuntu
date: 2019-07-17 08:28:10
---

本文备注一下ubuntu推出的snap应用商店。

# 从哪里开始
1. 可以从ubuntu18.X+看到应用商店。

2. 或从[snap.io网站](https://snapcraft.io/)查看

# 可以干什么？

专为linux系统打造的应用商店，可以发布、下载最新的软件，而不用集成在源里。

支持主流的linux 系统

可以和github集成，做到持续发布

# 成为开发者

只需要一个ubuntu的单点登录账号即可，赶快注册，不然后面会麻烦。

[入门一个项目](https://docs.snapcraft.io/python-apps)

# 使用snap

snap list: 查看安装的应用
```shell
$ snap list
Name                    Version                     Rev   Tracking  Publisher           Notes
android-studio          3.4.2.0                     77    stable    snapcrafters        classic
core                    16-2.39.3                   7270  stable    canonical✓          core
core18                  20190709                    1066  stable    canonical✓          base
flameshot-app           v0.6.0+git37.8887b4e        188   stable    vitzy               -
gnome-3-26-1604         3.26.0.20190705             90    stable/…  canonical✓          -
```
更多命令参考： [https://docs.snapcraft.io/getting-started](https://docs.snapcraft.io/getting-started)




