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

2. 修改数据存储位置，位于：`/etc/gitlab/gitlab.rb`,
    找到：
    ```java
    # 默认
    # git_data_dirs({
    #   "default" => {
    #     "path" => "/mnt/nfs-01/git-data"
    #    }
    # })

    # 自己修改
    git_data_dirs({
      "default" => { "path" => "/var/opt/gitlab/git-data" },
      "nfs" => { "path" => "/mnt/nfs/git-data" },
      "cephfs" => { "path" => "/mnt/cephfs/git-data" }
    })
    ```
    然后使用命令：`sudo gitlab-ctl reconfigure` 重新加载配置.


3. 对于已经存在的git仓库，[导入参考文档](https://gitlab.com/gitlab-org/gitlab-ce/blob/master/doc/raketasks/import.md).
    注意：需要把仓库的所有权改为git用户：`sudo chown -R git:git /var/opt/gitlab/git-data/repository-import-<date>`
    


