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

# OOP
[https://jsfiddle.net/](https://jsfiddle.net/)
## ECMA5

ECMA5没有类的概念，类只是属性和函数的集合。

### 属性

[关于枚举属性](https://segmentfault.com/a/1190000007908692)

#### 属性类型：
1. configurable：删除属性重定义 or 修改属性配置
2. enumerable：for-in循环返回属性
3. writable：可修改**值**
4. value：默认undefined

例子：
```javascript
"use strict";

var person = {};
Object.defineProperty(person,"name",{
		configuration: false,
    value: "jimo",
    enumerable: false,
    writable: false
});
console.log(person);

// 修改值
person.name = "hehe";
console.log(person);

// 修改配置
Object.defineProperty(person,"name",{
		configuration: true,
    value: "tudou",
    enumerable: false,
    writable: false
});
console.log(person);

// 遍历属性
for(var p in person){
	console.log(p);
}
```
注意：在严格模式下的区别

#### 访问器属性：
1. configuration：修改，重定义
2. enumerable：遍历属性
3. get：读取时调用，默认undefined
4. set：写入时调用，默认undefined

例子：
```javascript
/* "use strict"; */

var person = {
   _name: "jimo"
};
console.log(person._name);

Object.defineProperty(person,"name",{
       configuration: true,
   //enumerable: false,
   get: function(){
       console.log("调用getter");
       return  this._name;
   },
   set: function(newName){
     console.log("调用setter");
     this._name = newName;
   }
});
console.log(person);

// 只定义了get或set
person.name = "hehe";
console.log(person.name);

// 修改配置
Object.defineProperty(person,"name",{
       configuration: true,
   value: "tudou",
});
console.log(person);

// 遍历属性
for(var p in person){
	console.log(p);
}
```

注意：
1. 可以只定义getter或setter其中一个
2. 支持这个方法：IE9+
3. value/writeable和get/set不能一起定义：`(index):37 Uncaught TypeError: Invalid property descriptor. Cannot both specify accessors and a value or writable attribute, #<Object>`
4. `_name`只是一种共识，不是强制的规定

#### 定义多个属性

```javascript
/* "use strict"; */

var person = {};

Object.defineProperties(person, {
   _name: {
   value: "jimo"
 },
 age: {
   value: 100
 },
 name: {
   get: function(){
       return this._name
   }
 }
});
console.log(person);
console.log(person.name);
```

#### 读取属性

```js
var person = {};

Object.defineProperties(person, {
   _name: {
   value: "jimo"
 },
 age: {
   value: 100
 },
 name: {
   get: function(){
       return this._name
   }
 }
});

// 单个
var desc = Object.getOwnPropertyDescriptor(person, "_name");
console.log(desc);

// 多个
var descs = Object.getOwnPropertyDescriptors(person);
console.log(descs);
// or 包括可枚举和不可枚举的
Object.getOwnPropertyNames(person).forEach(function(key){
    console.log(key,person[key]);
});

// 可以枚举的
for(var p in person){
	console.log(p);
}
```


一个原型链搜索的例子：
//TODO


## ES6

http://es6-features.org/#ClassDefinition
https://es6.ruanyifeng.com/#docs/class


# 函数表达式

什么是this：是**运行时**对象基于执行环境绑定的，注意是运行时，也就是说可以动态改变this。

```js
"use strict";

/* var tag = "window-age"; */

var object = {
	tag: "jimo",
  getFunc:function(){
  	var tag = "hehe";
  	return function(){
    	return tag;
    }
  }
}
```

## 模仿块级作用域
```js
"use strict";

function output(count){
	(function(){
  	for(var i=0;i<count;i++){
    	console.log(i);
    }
  })();

  // error
  console.log(i);
}

output(3);
```
等价于：
```js
"use strict";

function output(count){
	var func = function(){
  	for(var i=0;i<count;i++){
    	console.log(i);
    }
  };
  func();
  // error
  console.log(i);
}

output(3);
```

这种匿名闭包的好处：
1. 大型多人开发中避免命名冲突，不会搞乱全局作用域；
2. 减少内存占用，因为运行完会被立即回收；

## 私有变量
```js
"use strict";


function Person(){
	function getAge(){
  	return 100;
  }
	this.getName = function(){
  	return "jimo";
  }
}

var p = new Person();
console.log(p.getName());

Person.getName();
```


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
