---
title: ansible 角色
tags:
  - ansible
  - linux
p: ansible/003-ansible-roles
date: 2019-01-10 17:46:14
---


# 角色目录结构

下面是一个例子：
```yml
site.yml
webservers.yml
fooservers.yml
roles/
   common/
     tasks/
     handlers/
     files/
     templates/
     vars/
     defaults/
     meta/
   webservers/
     tasks/
     defaults/
     meta/
```
角色期望文件位于某些目录名称中。 必须至少包含其中一个目录，但是排除任何未使用的目录是完全正确的。 在使用时，每个目录必须包含一个main.yml文件，其中包含相关内容：

1. tasks: 该角色执行的任务
2. handlers： 可用于任何地方的handlers
3. defaults： 该角色的默认变量
4. vars： 该角色的其他变量
5. files： 包括可被该角色部署的文件
6. templates： 可被该角色部署的模板
7. meta： 元数据

其他YAML文件可能包含在某些目录中。 例如，通常的做法是从`tasks / main.yml`文件中包含特定于平台的任务：
```yml
# roles/example/tasks/main.yml
- name: added in 2.4, previously you used 'include'
  import_tasks: redhat.yml
  when: ansible_facts['os_family']|lower == 'redhat'
- import_tasks: debian.yml
  when: ansible_facts['os_family']|lower == 'debian'

# roles/example/tasks/redhat.yml
- yum:
    name: "httpd"
    state: present

# roles/example/tasks/debian.yml
- apt:
    name: "apache2"
    state: present
```
# 使用角色
```yml
---
- hosts: webservers
  roles:
     - common
     - webservers
```

对于每个角色`'x'`定义了以下行为：

1. 如果存在`roles / x / tasks / main.yml`，则其中列出的任务将添加到play中。
2. 如果存在`roles / x / handlers / main.yml`，则其中列出的处理程序将添加到play中。
3. 如果存在roles / x / vars / main.yml，则其中列出的变量将添加到play中。
4. 如果存在roles / x / defaults / main.yml，则其中列出的变量将添加到play中。
5. 如果存在roles / x / meta / main.yml，则其中列出的任何角色依赖项将添加到角色列表（1.3及更高版本）。
6. 任何copy，script，template或include task（在角色中）都可以引用`roles / x / {files，templates，tasks} /（dir取决于任务）`中的文件，而无需相对或绝对地路径化它们。

以这种方式使用时，剧本的执行顺序如下：

1. play中定义的任何pre_tasks。
2. 到目前为止触发的任何处理程序都将运行。
3. 角色中列出的每个角色将依次执行。 角色meta / main.yml中定义的任何角色依赖关系都将首先运行，受标签过滤和条件限制。
4. play中定义的任何任务。
5. 到目前为止触发的任何处理程序都将运行。
6. play中定义的任何post_tasks。
7. 到目前为止触发的任何处理程序都将运行。

从Ansible 2.4开始，可以使用import_role或include_role将角色与任何其他任务内联使用：
```yml
---
- hosts: webservers
  tasks:
  - debug:
      msg: "before we run our role"
  - import_role:
      name: example
  - include_role:
      name: example
  - debug:
      msg: "after we ran our role"
```
角色名字可以是一个简单的名字，也可以是完整的路径：
```yml
---

- hosts: webservers
  roles:
    - role: '/path/to/my/roles/common'
```
角色可以接受其他关键字：
```yml
---

- hosts: webservers
  roles:
    - common
    - role: foo_app_instance
      vars:
         dir: '/opt/a'
         app_port: 5000
    - role: foo_app_instance
      vars:
         dir: '/opt/b'
         app_port: 5001
```
或者使用新的语法：
```yml
---

- hosts: webservers
  tasks:
  - include_role:
       name: foo_app_instance
    vars:
      dir: '/opt/a'
      app_port: 5000
  ...
```
也可以有条件的执行某个任务：
```yml
---

- hosts: webservers
  tasks:
  - include_role:
      name: some_role
    when: "ansible_facts['os_family'] == 'RedHat'"
```
最后，你可以在角色内将tag赋给任务：
```yml
---

- hosts: webservers
  roles:
    - role: bar
      tags: ["foo"]
    # using YAML shorthand, this is equivalent to the above
    - { role: foo, tags: ["bar", "baz"] }
```
新的语法：
```yml
---

- hosts: webservers
  tasks:
  - import_role:
      name: foo
    tags:
    - bar
    - baz
```

# 角色重复和执行
角色只会被执行一次，尽管被定义多次：
```yml
---
- hosts: webservers
  roles:
  - foo
  - foo
```
要想运行多次，有2个办法：
1. 给每次执行传递不同的参数
2. 在`meta/main.yml`里给角色声明`allow_duplicates: true`

例1：
```yml
---
- hosts: webservers
  roles:
  - role: foo
    vars:
         message: "first"
  - { role: foo, vars: { message: "second" } }
```
例2：
```yml
# playbook.yml
---
- hosts: webservers
  roles:
  - foo
  - foo

# roles/foo/meta/main.yml
---
allow_duplicates: true
```

# 角色默认变量
版本1.3中的新功能。

角色默认变量允许您为包含或相关角色设置默认变量（参见下文）。 要创建默认值，只需在角色目录中添加defaults / main.yml文件即可。 这些变量将具有可用变量的最低优先级，并且可以被任何其他变量轻松覆盖，包括库存变量。

```ymml
```
```ymml
```








# 参考
[]()



