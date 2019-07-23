---
title: ubuntu制作启动图标
tags:
  - ubuntu
p: linux/028-ubuntu-application-launcher
date: 2019-07-23 08:46:06
---

手动添加快捷方式。

# 手动编辑

```java
jack@jack:~/software/idea/bin$ cat idea.desktop 
#!/usr/bin/env xdg-open

[Desktop Entry]
Version=19.0
Type=Application
Terminal=false
Exec=/home/jack/software/idea/bin/idea.sh
Name=idea
Comment=idea
Icon=/home/jack/software/idea/bin/idea.png
```

# 设置可执行权限

# 点击运行

允许：trust the launch


参考：[https://linuxconfig.org/how-to-create-desktop-shortcut-launcher-on-ubuntu-18-04-bionic-beaver-linux](https://linuxconfig.org/how-to-create-desktop-shortcut-launcher-on-ubuntu-18-04-bionic-beaver-linux)