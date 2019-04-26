---
title: 初次遇见webpack
tags:
  - js
  - webpack
p: js/006-webpack-first-view
date: 2019-04-26 09:24:51
---

本文是作者对webpack的一些初见。

# 基本概念
[官方文档](https://www.webpackjs.com/concepts/) 写得很详细，当读完之后，写下自己的见解。

1. 是什么？
    就一个js打包工具，包括js文件，css，html和其他资源。

2. 有哪些基本概念需要了解？
    无非：
    1. 入口： 指定js文件入口
    2. 出口： 打包存放位置
    3. loader： 对非js文件的转换工具
    4. plugin： 强大的插件，在整个生命周期（打包、压缩、环境变量）都可用

3. 支持多模式： 开发、生产、测试等

# 基本原理

建立一个依赖图。

# 基本使用
[参考官方文档](https://webpack.js.org/guides/getting-started)

跟着做很简单，注意1点，先安装npx： `npm install -g npx`.

结果：
```javascript
jack@jack:~/workspace/temp/webpack-demo$ ll
总用量 36
drwxr-xr-x   5 jack jack  4096 4月  26 10:02 ./
drwxr-xr-x   6 jack jack  4096 4月  26 09:35 ../
drwxr-xr-x   2 jack jack  4096 4月  26 10:00 dist/
drwxr-xr-x 318 jack jack 12288 4月  26 10:00 node_modules/
-rw-r--r--   1 jack jack   379 4月  26 10:02 package.json
drwxr-xr-x   2 jack jack  4096 4月  26 09:43 src/
-rw-r--r--   1 jack jack   163 4月  26 09:46 webpack.config.js
jack@jack:~/workspace/temp/webpack-demo$ tree dist/
dist/
├── index.html
└── main.js

0 directories, 2 files
jack@jack:~/workspace/temp/webpack-demo$ tree src/
src/
└── index.js

0 directories, 1 file
```




