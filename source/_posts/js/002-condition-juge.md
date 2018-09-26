---
title: js条件判断
tags:
  - js
p: js/002-condition-juge
date: 2018-09-25 10:35:49
---

js条件判断，看似简单，却暗藏玄机。

# ==与===

`===`比`==`多的一个就是数据类型的判断，很重要，建议用`===`.

# true/false

在js中哪些是true，哪些是false呢？

1.  `object(arr,class等)永远是`true`
2.  `undefiend` ==> `false`
3.  `null` ==> `false`
4.  Boolean条件
5.  数字：`+0,-0,0,NaN`为`false`,其余为true
6.  字符串：`''`为`false`，其余有长度的为`true`

# 对比分析

为什么不建议用`==`判断，下面见证：

```js
const cons = [{},undefined,null,-0,0,NaN,'']

for(let c1 of cons){
    for(let c2 of cons){
        if(c1!==c2){
            if(c1==c2){
                    console.log(`${c1}==${c2}`);
            }
            if(c1===c2){
                    console.log(`${c1}===${c2}`);
            }
            //console.log(`${c1}==${c2}-->${c1==c2} | ${c1}===${c2}-->${c1===c2}`);
        }
    }
}
```

结果：(`''`其实是看不到的哈)

    undefined==null
    null==undefined
    0==''
    -0==''
