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

# shell-chdir
```yml
shell: xxx
args:
  chdir: path
```

# 变量比较
一开始以为需要使用：`{{var}}=='dsdd'`

后来发现只需要： `var=="dsdd"`

```yml
tasks:
  - name: compare
    when: var=="jimo"
```

# find-kill-pid
```yml
    - name: find running pid
      shell: ps -ef | grep -v grep | grep xxx | awk '{print $2}'
      register: pid

    - name: kill process
      shell: "kill -9 {{item}}"
      with_items: "{{pid.stdout_lines}}"
```

# replace
```yml
- name: replace
  replace:
    path: path
    regexp: old
    replace: new
```

# unarchive
解压包，从src到dest：
```yml
- name: unarchive
  unarchive:
    src: "本地地址/xxx.tar.gz"
    dest: "远程地址"
    remote_src: false
```
2个地方需要注意：
1. remote_src=true代表src是远程的，默认是本地的
2. xxx.tar.gz 解压后会在远程地址创建一个xxx的目录，所以，远程就不要手动创建

# 设置自己的变量set_fact

[文档](https://docs.ansible.com/ansible/latest/modules/set_fact_module.html)

```yml
  tasks:
    # 设置变量
    - set_fact:
        JAR_DIR: "{{playbook_dir}}/iad-jars"
    - debug:
        msg: "jar dir: {{JAR_DIR}}"
```

# 获取主机IP

```
"inventory_hostname": "192.168.17.70", 
"inventory_hostname_short": "192"
```

```yml
- debug: var=hostvars
  tags:
    - debug
```

# 判断文件是否存在
```yml
- name: check if application-prod.yml exists
  stat:
    path: /home/application-prod.yml
  register: application_prod

- fail:
    msg: "application-prod.yml not exist on /home/"
  when: application_prod.stat.exists == False
```

# 只运行一次
假如，我在一个组下需要pull最新代码，而这个组里有多个机器，那么他们会并发执行，
但是git 模块只需要执行一次，否则会报错，这时候就需要执行一次：
```yml
- name: pull code
  git: repo="" dest=""
  run_once: true
```
