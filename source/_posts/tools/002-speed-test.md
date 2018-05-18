---
title: 如何测网速
tags:
  - tool
  - linux
p: tools/002-speed-test
date: 2018-01-11 09:34:41
---
有一些很简单的方法可以测网速,windows就不说了,360搞定,主要说下linux下.

# 1.通过web在线测试
访问[http://www.speedtest.net/](http://www.speedtest.net/)

点击Go即可.

{% asset_img 000.png %}

# 2.通过命令
不用那么麻烦,装一个speed-test命令搞定.

### 2.1 安装方法很多:
```
pip install speedtest-cli

easy_install speedtest-cli

pip install git+https://github.com/sivel/speedtest-cli.git
or
git clone https://github.com/sivel/speedtest-cli.git
python speedtest-cli/setup.py install

wget -O speedtest-cli https://raw.github.com/sivel/speedtest-cli/master/speedtest_cli.py
chmod +x speedtest-cli
```

### 2.2 测试网速:直接用命令
```shell
[jimo@jimo-pc ~]$ speedtest-cli
Retrieving speedtest.net configuration...
Testing from China Education and Research Network Center (222.18.40.107)...
Retrieving speedtest.net server list...
Selecting best server based on ping...
Hosted by University of Electronic Science and Technology of China (Chengdu) [0.92 km]: 11.835 ms
Testing download speed................................................................................
Download: 2.18 Mbit/s
Testing upload speed......................................................................................................
Upload: 6.14 Mbit/s
```
### 2.3 将结果分享:
```
$ speedtest-cli --share
Retrieving speedtest.net configuration...
Testing from China Education and Research Network Center (222.18.40.107)...
Retrieving speedtest.net server list...
Selecting best server based on ping...
Hosted by University of Electronic Science and Technology of China (Chengdu) [0.92 km]: 8.673 ms
Testing download speed................................................................................
Download: 2.03 Mbit/s
Testing upload speed......................................................................................................
Upload: 6.47 Mbit/s
Share results: http://www.speedtest.net/result/6954831465.png
```
访问链接查看结果:

{% asset_img 001.png %}

### 2.4 查看所有服务
后面是距离
```shell
$ speedtest-cli --list | head -n 10
Retrieving speedtest.net configuration...
 4575) China Mobile Group Sichuan (Chengdu, China) [0.92 km]
11444) University of Electronic Science and Technology of China (Chengdu, China) [0.92 km]
 2461) China Unicom (Chengdu, China) [0.92 km]
 4624) ChinaTelecom (Chengdu, China) [0.92 km]
 5726) China Unicom Chong Qing Branch (Chongqing, China) [270.20 km]
 5530) CCN (Chongqing, China) [270.20 km]
 3973) China Telecom (Lanzhou, China) [597.25 km]
 4690) China Unicom Lanzhou Branch Co.Ltd (Lanzhou, China) [597.25 km]
 5292) China Mobile Group Shaanxi Company Limited (Xi'an, China) [604.70 km]
```

其他用法查看帮助.

另外:上面的单位是Mbit,而不是MB,这两个相差了8倍的关系,所以我的下载速度是很慢的(300KB左右),因为被限速了...