---
title: linux-use-error
tags:
  - linux
p: linux/014-linux-use-error
date: 2018-07-28 08:04:39
---

those errors when using linux system.

# This partition cannot be modified because it contains a partition table; >please reinitialize layout of the whole device. (udisks-error-quark, 11)

已安装linux的U盘无法格式化，要求reinitialize layout

**Done:**
```
使用GParted

安装：sudo apt install gparted
安装完启动：sudo gparted

此时弹出软件的图形界面，在软件右上角选择自己的U盘设备（默认选中电脑硬盘）

然后选中Device - Create Partition Table
完成后选择Partition - New创建新分区表，选择磁盘格式为ntfs

确定后，点击工具栏中的勾，apply所有更改，完成后就OK了
```
