---
title: ansible1-入门金殿
tags:
  - ansible
  - linux
p: ansible/000-ansible-fresh
date: 2019-01-02 16:38:38
---

入门总是简单的，看看你有多快。

关于ssh连接请查找相关知识。

# 一条命令格式
```
$ ansible PATTERNS -m MODULE -a PARAMS
```
只需要明白模式、模块、参数就可以实现命令行级别的使用了。

## PATTERNS
[patterns](https://docs.ansible.com/ansible/latest/user_guide/intro_patterns.html)

可以分为3个部分：
1. all/*， webservers[0-25]
2. 逻辑运算： &/！
3. 正则表达式：~正则， `~(web|db).*\.example\.com`

## MODULE
模块太多了，可以了解一下简单的：
[ad-hoc](https://docs.ansible.com/ansible/latest/user_guide/intro_adhoc.html)

大概有：
1. ping
2. shell
3. copy
4. file
5. yum/apt/...
6. user
7. git
8. service
9. setup

参数和模块对应。

# 连接方式
当然是ssh，只是连接方式有区别。
## SSH的key
不用说了。
## 密码登陆
加上`-k`选项。

# Ansible配置文件

1. 配置文件优先顺序
2. 有哪些配置属性

[ansible config](https://ansible-tran.readthedocs.io/en/latest/docs/intro_configuration.html)



