---
title: ubuntu下使用NVIDIA显卡
tags:
  - linux
  - ubuntu
  - nvidia
p: linux/025-ubuntu-use-navidia-card
date: 2019-07-14 12:39:18
---

放着一块好好的独立显卡不用，多浪费呀。

# 查看系统显卡

```shell
$ lspci -k | grep -A 2 -i "VGA"
00:02.0 VGA compatible controller: Intel Corporation Device 3e9b
	Subsystem: CLEVO/KAPOK Computer Device 8560
	Kernel driver in use: i915
--
01:00.0 VGA compatible controller: NVIDIA Corporation Device 1f91 (rev a1)
	Subsystem: CLEVO/KAPOK Computer Device 8560
	Kernel modules: nvidiafb, nouveau
```

一块是intel自带的，一块是NVIDIA的。

# 查看自己现在用的显卡

{% asset_img 000.png %}

# 更新NVIDIA驱动

首先添加驱动源：

```shell
sudo add-apt-repository ppa:graphics-drivers
sudo apt-get update
```

然后打开软件更新可以看到附加驱动有了：

{% asset_img 001.png %}

切换到官方驱动，点击应用更改：

{% asset_img 002.png %}

然后重启电脑， 重启完显卡已经切换到NVIDIA了：

{% asset_img 003.png %}

如果没有切换，可以手动切换：

```shell
$ sudo prime-select nvidia
$ sudo reboot
```

# NVIDIA管理
如下图，nvidia-settings 命令即可：

{% asset_img 004.png %}

# 参考
https://www.linuxbabe.com/desktop-linux/switch-intel-nvidia-graphics-card-ubuntu

https://medium.com/datadriveninvestor/install-tensorflow-gpu-to-use-nvidia-gpu-on-ubuntu-18-04-do-ai-71b0ce64ebc5

https://websiteforstudents.com/install-proprietary-nvidia-gpu-drivers-on-ubuntu-16-04-17-10-18-04/

