---
title: ubuntu安装扩展/插件
tags:
  - ubuntu
  - linux
  - firefox
p: linux/020-ubuntu-install-extensions
date: 2019-03-19 08:19:47
---

本文翻译自[how-to-install-gnome-shell-extensions-on-ubuntu-18-04-bionic-beaver-linux](https://linuxconfig.org/how-to-install-gnome-shell-extensions-on-ubuntu-18-04-bionic-beaver-linux)

本文将介绍3种方式安装ubuntu下gnome的extentions。

# 1.从ubuntu仓库安装

```shell
$ sudo apt install gnome-shell-extensions
```
不过需要tweak-tool，18.x没有默认安装，需要手动：
```shell
$ sudo add-apt-repository universe
$ sudo apt install gnome-tweak-tool
```
{% asset_img 000.png %}

# 2.使用firefox安装

1. [安装firefox-gnome-shell扩展](https://addons.mozilla.org/en-US/firefox/addon/gnome-shell-integration/)

2. 安装chrome-gnome-shell: `$ sudo apt install chrome-gnome-shell`

3. 访问[gnome.org](https://extensions.gnome.org)选择需要的扩展，然后勾选为on即可：
    {% asset_img 001.png %}

# 3.从源码安装
当然，在能获取到源码的前提下。

// TODO


