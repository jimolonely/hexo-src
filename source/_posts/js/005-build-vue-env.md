---
title: 构建vue js开发环境
tags:
  - js
  - vue
p: js/005-build-vue-env
date: 2019-04-24 18:57:00
---

本文记录下从npm开始的vue开发环境配置。

本文使用ubuntu18.04作为开发环境。

# npm配置

1. 关于{% post_link js/001-npms 如何使用npm安装插件不需要root权限的配置 %};

2. 设置npm为taobao镜像： 
    ```python
    $ npm config set registry https://registry.npm.taobao.org

    # 配置后可通过下面方式来验证是否成功
    $ npm config get registry
    # 或
    $ npm info express
    ```

# vue的配置

使用[超级脚手架vue-cli](https://cli.vuejs.org/zh/guide/#%E4%BB%8B%E7%BB%8D).




