---
title: windows同时使用有线和无线网络
tags:
  - windows
p: tools/022-windows-wifi-eth-use-simultaneously
date: 2019-10-11 09:39:52
---


 windows同时使用有线和无线网络，是一项艺术。


 使用命令查看：

 ```s
route print
===========================================================================
接口列表
  8...8c 16 45 f3 f4 97 ......Intel(R) Ethernet Connection (4) I219-V
 15...3c 6a a7 d7 53 2a ......Intel(R) Dual Band Wireless-AC 8265
  4...3c 6a a7 d7 53 2b ......Microsoft Wi-Fi Direct Virtual Adapter
  3...3e 6a a7 d7 53 2a ......Microsoft Wi-Fi Direct Virtual Adapter #2
  9...3c 6a a7 d7 53 2e ......Bluetooth Device (Personal Area Network)
  1...........................Software Loopback Interface 1
===========================================================================

IPv4 路由表
===========================================================================
活动路由:
网络目标        网络掩码          网关       接口   跃点数
          0.0.0.0          0.0.0.0     10.13.xx.xxx     10.13.xxx.xxx     50
          0.0.0.0          0.0.0.0     10.13.xx.xxx      10.13.xx.xxx     25
 ```

 默认会发现跃点数是不一样的，我们改成一样的就可以了。


 网络共享--》右键--属性--》IPV4网络---》高级---》自定义跃点数

 