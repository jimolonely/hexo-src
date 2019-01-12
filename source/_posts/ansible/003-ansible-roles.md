---
title: ansible 角色
tags:
  - ansible
  - linux
p: ansible/003-ansible-roles
date: 2019-01-10 17:46:14
---

角色是什么，看了再来说。

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

# 角色依赖
版本1.3中的新功能。

角色依赖性允许您在使用角色时自动引入其他角色。 角色依赖关系存储在角色目录中包含的meta / main.yml文件中，如上所述。 此文件应包含要在指定角色之前插入的角色和参数列表，例如示例roles / myapp / meta / main.yml中的以下内容：
```yml
---
dependencies:
  - role: common
    vars:
      some_parameter: 3
  - role: apache
    vars:
      apache_port: 80
  - role: postgres
    vars:
      dbname: blarg
      other_parameter: 12
```
角色依赖始终在包含它们的角色之前执行，并且可以是递归的。 依赖关系也遵循上面指定的复制规则。 如果另一个角色也将其列为依赖项，则不会根据上面给出的相同规则再次运行它。
```
永远记住，当使用allow_duplicates：true时，它需要在依赖角色meta / main.yml中，而不是父级。
```
例如，一个car角色依赖4个轮子：

```yml
---
dependencies:
- role: wheel
  vars:
     n: 1
- role: wheel
  vars:
     n: 2
- role: wheel
  vars:
     n: 3
- role: wheel
  vars:
     n: 4
```
轮子的作用取决于两个角色：轮胎和刹车。 然后，wheel的meta / main.yml将包含以下内容：
```yml
---
dependencies:
- role: tire
- role: brake
```
那么轮胎和刹车就需要可以重复的声明：
```yml
---
allow_duplicates: true
```
执行的顺序如下：
```yml
tire(n=1)
brake(n=1)
wheel(n=1)
tire(n=2)
brake(n=2)
wheel(n=2)
...
car
```
为什么wheel没有声明可重复呢？ 因为我们用了不同的参数呀！

# 在角色中集成模块和插件
这是一个高级主题，与大多数用户无关。

如果您编写自定义模块（请参阅[开发模块](https://docs.ansible.com/ansible/latest/dev_guide/developing_modules.html#developing-modules)？）或插件（请参阅[开发插件](https://docs.ansible.com/ansible/latest/dev_guide/developing_plugins.html#developing-plugins)），您可能希望将其作为角色的一部分进行分发。 一般来说，Ansible作为一个项目非常有兴趣将高质量的模块纳入ansible核心，因此这不应该是常态，但它很容易做到。

一个很好的例子就是如果你在一家名为AcmeWidgets的公司工作，并编写了一个帮助配置内部软件的内部模块，并且你希望组织中的其他人能够轻松使用这个模块 - 但你不想告诉所有人 如何配置他们的Ansible库路径。

除了角色的“任务”和“处理程序”结构外，添加名为“library”的目录。 在这个'library'目录中，直接在其中包含模块。

假设你有这个：
```yml
roles/
   my_custom_modules/
       library/
          module1
          module2
```
该模块可用于角色本身，以及在此角色之后调用的任何角色，如下所示：
```yml
- hosts: webservers
  roles:
    - my_custom_modules
    - some_other_role_using_my_custom_modules
    - yet_another_role_using_my_custom_modules
```
在一些限制下，这也可用于修改Ansible核心发行版中的模块，例如在生产版本中发布之前使用模块的开发版本。 但这并不总是可取的，因为API签名可能会在核心组件中发生变化，但并不总能保证能够正常工作。 它可以是一种方便的方式来携带针对核心模块的补丁，但是，如果你有充分的理由这样做。 当然，项目希望通过拉取请求尽可能将贡献引导回github。

可以使用相同的机制使用相同的模式在一个角色中嵌入和分发插件。 例如，对于过滤器插件：
```yml
roles/
   my_custom_filter/
       filter_plugins
          filter1
          filter2
```
然后可以在“my_custom_filter”之后调用的任何角色中使用模板或jinja模板。

# 角色搜索路径
Ansible将以下列方式搜索角色：

1. 相对于playbook文件的`role/`目录。
2. 默认情况下，在`/ etc / ansible / roles`中

在Ansible 1.4及更高版本中，您可以配置其他roles_path来搜索角色。 使用此选项可以将所有常见角色放到一个位置，并在多个playbook项目之间轻松共享。 有关如何在ansible.cfg中进行设置的详细信息，请参阅[配置Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_configuration.html#intro-configuration)。

# Ansible Galaxy
Ansible Galaxy是一个免费网站，用于查找，下载，评级和审查各种社区开发的Ansible角色，并且可以成为您自动化项目快速启动的绝佳方式。

客户端`ansible-galaxy`包含在Ansible中。 Galaxy客户端允许您从Ansible Galaxy下载角色，并且还提供了一个用于创建自己角色的出色默认框架。

阅读[Ansible Galaxy文档](https://galaxy.ansible.com/docs/)页面以获取更多信息


# 参考
[https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html#embedding-modules-and-plugins-in-roles](https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html#embedding-modules-and-plugins-in-roles)




