---
title: ansible实用写法
tags:
  - ansible
p: ansible/005-ansible-demo1
date: 2019-01-16 12:30:10
---

ansible一些常用知识。

# 全局变量
用在所有的组里的变量。

在hosts里指定所有的组，声明变量：
```
[all:vars]
global_var=xxx
```
# 取一个路径的文件名或目录
参考： [https://github.com/yteraoka/ansible-tutorial/wiki/path-filter](https://github.com/yteraoka/ansible-tutorial/wiki/path-filter)

文件名：
```yml
{{ path | basename }}
```

目录：
```yml
{{ path | dirname }}
```

# 变量比较
一开始以为需要使用：`{{var}}=='dsdd'`

后来发现只需要： `var=="dsdd"`

```yml
tasks:
  - name: compare
    when: var=="jimo"
```


