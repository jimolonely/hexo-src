---
title: 安装gitlab服务器
tags:
  - linux
  - gitlab
  - git
p: git/003-install-gitlab-server
date: 2019-04-17 09:21:37
---

只是记录下曾经装过git服务器。

采用了gitlab。

# 参考

[官方文档](https://about.gitlab.com/install/#centos-7)已经写得很仔细了。

然后：注册用户，分配权限，建group，建项目，提交代码。

# 注意事项

1. 创建完项目后，默认只有所有者才有提交权限，在`settings/members`下加入开发者后，还需要修改`settings/repository`下的`Protected Branches`设置为开发者和所有者都有权merge。






