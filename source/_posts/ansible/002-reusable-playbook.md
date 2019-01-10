---
title: 创建可重用playbook
tags:
  - ansible
  - linux
p: ansible/002-reusable-playbook
date: 2019-01-04 17:54:32
---

消除重复代码一直是程序员的目标，playbook也不例外。

当一个playbook内容变得很大时，你就会想拆分了。

拆分后，肯定要引入主剧本，这就有2种方式：`include/import`.

# 静态和动态引入
1. 静态：使用`import`引入的；
2. 动态：使用`include`引入的。

区别：

1. 静态引入的文件会在解析时被预处理，类似编译过程；
2. 动态引入的会在运行时才被处理

当遇到如`tags`,`when`等选项：
1. 静态引入会将他们copy到所有子任务
2. 而动态只会应用到当前任务

# 使用权衡
使用`include * vs. import *`有一些优点，用户在选择时应考虑一些权衡：

使用`include *`语句的主要优点是循环。当循环与include一起使用时，包含的任务或角色将对循环中的每个项执行一次。

与`import *`语句相比，使用`include *`确实有一些限制：

1. 仅存在于动态包含内的标记不会显示在--list-tags输出中。
2. 仅存在于动态包含内的任务不会显示在--list-tasks输出中。
3. 不能使用`notify`来触发来自动态包含内的处理程序名称（请参阅下面的注释）。
4. 不能使用`--start-at-task`在动态包含内的任务中开启执行。

与动态包含相比，使用`import *`也有一些限制：

1. 如上所述，循环根本不能与`import`一起使用。
2. 将变量用于目标文件或角色名称时，不能使用inventory中的变量（host/group变量等）。

# import_playbook使用

```yml
- import_playbook: webservers.yml
- import_playbook: databases.yml
```

# include/import_tasks使用

```yml
# common_tasks.yml
- name: placeholder foo
  command: /bin/foo
- name: placeholder bar
  command: /bin/bar
```
然后引入：
```yml
tasks:
- import_tasks: common_tasks.yml
# or
- include_tasks: common_tasks.yml
```
同时可以传递变量：
```yml
tasks:
- import_tasks: wordpress.yml
  vars:
    user_name: jimo
- import_tasks: wordpress.yml
  vars:
    user_name: jack
- import_tasks: wordpress.yml
  vars:
    user_name: lily
```

用到handler中，我们先定义一个handler.yml:

```yml
# more_handlers.yml
- name: restart apache
  service: name=apache state=restarted
```
引入例子：
```yml
handlers:
- include_tasks: more_handlers.yml
# or
- import_tasks: more_handlers.yml
```


# 参考

1. [https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse.html](https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse.html)
2. [https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_includes.html](https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_includes.html)


