---
title: ffmpeg常用命令
tags:
  - linux
  - tool
  - video
p: tools/010-ffmpeg
---
本问主要说明视频的一些参数和linux下ffmpeg的视频转换和压缩功能.

# 视频参数说明
通过ffmpeg查看视频信息,-i指定输入视频
```shell
]$ ffmpeg -i 1.mp4
Input #0, mov,mp4,m4a,3gp,3g2,mj2, from '1.mp4':
  Metadata:
    major_brand     : isom
    minor_version   : 512
    compatible_brands: isomiso2avc1mp41
    encoder         : Lavf57.83.100
  Duration: 00:09:59.03, start: 0.000000, bitrate: 15991 kb/s
    Stream #0:0(und): Video: h264 (High) (avc1 / 0x31637661), yuvj420p(pc), 1920x1080, 15923 kb/s, 30 fps, 30 tbr, 15360 tbn, 60 tbc (default)
    Metadata:
      handler_name    : VideoHandler
    Stream #0:1(und): Audio: aac (LC) (mp4a / 0x6134706D), 32000 Hz, mono, fltp, 69 kb/s (default)
    Metadata:
      handler_name    : SoundHandler
```
其中Stream 0就是视频流,下面是音频流,h264编码,1920*1080分辨率.
这个15923kb/s要特别说明:
```
码率(比特率): 每秒输入视频的比特数,越高视频越大,质量越高,所以计算视频大小的公式:
视频时长(秒)*码率,例如这个(忽略了音频的大小):
Size(video) = 60s*10 * (15923/8/1024/1024) = 1.13GB
```
那么视频压缩就是压缩码率,当然帧率也可以压,不过一般不这样干.
# ffmpeg压缩视频
计算好需要压缩的码率,我打算压缩5倍,设为3200kb/s:
```shell
# -b:v 代表视频码率,-b:a 代表音频的 
$ ffmpeg -i 1.mp4 -b:v 3200k 4.mp4

# 直接转换格式并压缩
$ ffmpeg -i MOVI0001.avi -b:v 3200k /home/jimo/视频/11.mp4
```
这样视频大概200多MB.



参考:[ffmpeg——关于视频压缩](https://www.cnblogs.com/liusx0303/p/7572050.html)