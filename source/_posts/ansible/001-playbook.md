---
title: ansible-playbook
tags:
  - ansible
  - linux
p: ansible/001-playbook
date: 2019-01-03 12:34:58
---

在入门了之后就开始进阶把。

本文来自[playbooks简介](https://docs.ansible.com/ansible/latest/user_guide/playbooks_intro.html)

先理解3个东西：

1. playbook（剧本）
2. tasks（任务）
3. handler（处理）

理解他们都是什么，关系是什么，怎么用。

# playbook

只有一个剧本：
```yml
---
- hosts: webservers
  vars:
    http_port: 80
    max_clients: 200
  remote_user: root
  tasks:
  - name: ensure apache is at the latest version
    yum:
      name: httpd
      state: latest
  - name: write the apache config file
    template:
      src: /srv/httpd.j2
      dest: /etc/httpd.conf
    notify:
    - restart apache
  - name: ensure apache is running
    service:
      name: httpd
      state: started
  handlers:
    - name: restart apache
      service:
        name: httpd
        state: restarted
```
有多个剧本：
```yml
---
- hosts: webservers
  remote_user: root

  tasks:
  - name: ensure apache is at the latest version
    yum:
      name: httpd
      state: latest
  - name: write the apache config file
    template:
      src: /srv/httpd.j2
      dest: /etc/httpd.conf

- hosts: databases
  remote_user: root

  tasks:
  - name: ensure postgresql is at the latest version
    yum:
      name: postgresql
      state: latest
  - name: ensure that postgresql is started
    service:
      name: postgresql
      state: started
```

一眼就能看懂对把，还是学下基础知识。

# 基础

## Host和User
hosts: 遵循pattern模式
```yml
---
- hosts: webservers
  remote_user: root
```
remote_user可以为每个任务独有：

```yml
---
- hosts: webservers
  remote_user: root
  tasks:
    - name: test connection
      ping:
      remote_user: yourname
```
激活权限提升

```yml
---
- hosts: webservers
  remote_user: yourname
  become: yes
```
或者单独指定：
```yml
---
- hosts: webservers
  remote_user: yourname
  tasks:
    - service:
        name: nginx
        state: started
      become: yes
      become_method: sudo
```
切换用户：

```yml
---
- hosts: webservers
  remote_user: yourname
  become: yes
  become_user: postgres
```
提升：
```yml
---
- hosts: webservers
  remote_user: yourname
  become: yes
  become_method: su
```

如果需要指定密码，使用`--ask-become-pass`.

对主机排序，改变运行顺序：

```yml
- hosts: all
  order: sorted
  gather_facts: False
  tasks:
    - debug:
        var: inventory_hostname
```

## Task列表

1. 顺序执行
2. 冥等性： 执行一次和多次结果一样
3. name属性：可读性输出

```yml
tasks:
  - name: make sure apache is running
    service:
      name: httpd
      state: started
```
直接写命令，参数这些很自由：
```yml
tasks:
  - name: enable selinux
    command: /sbin/setenforce 1
```
shell和command关心返回值，也就是短路运算：
```yml
tasks:
  - name: run this command and ignore the result
    shell: /usr/bin/somecommand || /bin/true
# or
tasks:
  - name: run this command and ignore the result
    shell: /usr/bin/somecommand
    ignore_errors: True
```
太长的命令可以缩进换行：
```yml
tasks:
  - name: Copy ansible inventory file to client
    copy: src=/etc/ansible/hosts dest=/etc/ansible/hosts
            owner=root group=root mode=0644
```
使用变量：
```yml
tasks:
  - name: create a virtual host file for {{ vhost }}
    template:
      src: somefile.j2
      dest: /etc/httpd/conf.d/{{ vhost }}
```

## Hnadler
状态改变时执行的操作。

例如：文件内容改变时，重启2个服务
```yml
- name: template configuration file
  template:
    src: template.j2
    dest: /etc/foo.conf
  notify:
     - restart memcached
     - restart apache
```
相应的2个handler定义如下：
```yml
handlers:
    - name: restart memcached
      service:
        name: memcached
        state: restarted
    - name: restart apache
      service:
        name: apache
        state: restarted
```
在2.2版本后，可以使用listen，这样只需要notify一次： 通过监听主题
```yml
handlers:
    - name: restart memcached
      service:
        name: memcached
        state: restarted
      listen: "restart web services"
    - name: restart apache
      service:
        name: apache
        state:restarted
      listen: "restart web services"

tasks:
    - name: restart everything
      command: echo "this task will restart the web services"
      notify: "restart web services"
```

## 执行playbook
并行度10，fork 10：
```shell
ansible-playbook playbook.yml -f 10
```


再看一个复合例子：
```yml
$ cat playbook.yml 
- name: top playbook
  hosts: all
  tasks:
  - name: ping ping
    ping: 
  - include: tasks/echo1.yml the_user=root
  - include: tasks/echo2.yml
  handlers:
      - include: handlers/handlers.yml
```

输出结果的方式
