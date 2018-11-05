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
2. 不能删除未定义变量：`"use strict"; delete a;
VM786:1 Uncaught SyntaxError: Delete of an unqualified identifier in strict mode.`

# 数据类型
```java
Number(true)
1
Number(false)
0

```

# 内存
## 引用类型
值类型：基本类型

引用类型：对象

参数传递：值传递

typeof 与 instanceof

常用引用类型：
### Object
`var person = new Object() or var person = {}`

### Array
`var arrs = new Array() or var arr = [];`

```html  
var color = ["black"];
color[99] = "red";
console.log(color.length) == 100
```
检测数组：
```html
Array.isArray(value)
```
转换为字符串：
`toString() 和 toLocalString() `,后者调用数组元素的方法。

Array可以当栈用：`push() pop()`

也可以当队列用：`push() shift() or unshift() pop()`

重排序：`sort(compare_func) or reverse()`

数组切分、连接
`slice(begin,end), concat(arr)`

强大的删除、插入、替换方法：splice(...)

位置方法
`indexOf() , lastIndexOf()`

迭代方法
`every(func), filter(), forEach(), map(), some()`

缩小方法：`reduce(prev,curr,index,array)`

### Date对象

```html
new Date(Date.parse("2018-10-01"))
Mon Oct 01 2018 08:00:00 GMT+0800 (中国标准时间)

// 区别：月份、小时从0开始
new Date(Date.UTC(2018,10,1))
Thu Nov 01 2018 08:00:00 GMT+0800 (中国标准时间)
```

### RegExp对象
`var exp = / pattern / flags(i,g,m)`

### Function类型
实际上是对象类型。

没有重载




## 变量没有块级作用域
只有执行环境，没有var声明的变量成为全局变量。

有以下环境：
1. 函数环境
2. 全局环境（window）

```html
function bu(){
	var url = "jiko";
	with(url){
		var kk = url+"11";
	}
	function b2(){
		var cc = 1;
	}
	console.log(cc);
	return kk;
}
// Uncaught ReferenceError: cc is not defined
```


## 垃圾回收
1. 引用计数（废弃）
2. 标记清除



# 其他
## 为何null==undefined?
因为undefined派生自null。
## 那些true/false
{% asset_img 000.png %}

```java
// not applicable (不适用)
Boolean('n/a')
true

NaN==NaN
false
```
