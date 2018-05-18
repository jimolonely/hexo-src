---
title: adb使用root权限调试
tags:
  - android
  - linux
p: android/000-adb-root
date: 2018-03-06 15:22:57
---
使用adb root调试Android手机.

# 使用环境
使用Google手机模拟器.查看下设备:
```shell
$ adb devices
List of devices attached
emulator-5554	device
```
直接用adb shell进入调试时会发现permission denied:
```shell
$ adb shell
generic_x86:/ $ pwd
/
generic_x86:/ $ ls
ls: ./ueventd.rc: Permission denied
ls: ./ueventd.ranchu.rc: Permission denied
ls: ./init.zygote32.rc: Permission denied
acct  bugreports  cache  charger  config  d  data  default.prop  dev  etc  mnt  oem  proc  root  sbin  sdcard  storage  sys  system  var  vendor
```
解决办法,先切换到root用户:
```shell
$ adb root
restarting adbd as root
$ adb root
adbd is already running as root
```
再进入就ok了:
```shell
$ adb shell
generic_x86:/ # whoami
root
generic_x86:/ # ls data
adb  app-asec       app-private    bootchart     data   lost+found  misc     nativetest   property        system     tombstones  var     
anr  app-ephemeral  backup         cache         drm    media       misc_ce  ota          resource-cache  system_ce  user        vendor  
app  app-lib        benchmarktest  dalvik-cache  local  mediadrm    misc_de  ota_package  ss              system_de  user_de
```
# 注意事项
要在实体机上使用时必须root手机才行.