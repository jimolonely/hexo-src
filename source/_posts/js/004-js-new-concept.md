---
title: js高级编程必知
tags:
  - javascript
p: js/004-js-new-concept
date: 2018-10-19 14:18:22
---

下面是高级或冷门js知识。

# 1.`<script>`标签
看一般导入外部js文件的语法：
```html
<script src="/js/xxx.js"></script>
```
html不支持`/>`语法，但XHTML支持，所以XHTML里可以写：
```html
<script src="/js/xxx.js"/>
```
script的type属性默认为`text/javascript`，虽然已经过时，但大家都这样用所以成默认了。

noscript标签：会在下面的情况下显示(不过现在很少见了)
1. 浏览器不支持脚本
2. 浏览器禁用脚本
```html
<body>
    <noscript>请支持（启用）浏览器脚本</noscript>
</body>
```

# 2.严格模式
## 2.1 声明方式
在文件开始或方法内开始：
```javascript
"use strict";

function f(){
    "use strict";
    // TODO
}
```
## 2.2 那些严格的限制
1. 不能声明eval或arguments的变量
