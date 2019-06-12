---
title: gitlab定时备份配置
tags:
  - git
  - gitlab
p: git/005-gitlab-backup-config
date: 2019-06-12 16:19:54
---

在{% post_link git/003-install-gitlab-server 安装完gitlab server%} 后，备份是必不可少的。

# 常规备份

根据[官方文档](https://docs.gitlab.com/ee/raketasks/backup_restore.html#creating-a-backup-of-the-gitlab-system),我们只需要执行一个命令：
```java
$ sudo gitlab-rake gitlab:backup:create
```
就可以实现默认备份：
1. 备份目录： `/var/opt/gitlab/backups`
2. 备份内容： `repo,uploads,builds,artifacts,pages,lfs objects,container register images`
3. 打成tar包
4. 默认不删除以前的备份

对于一百多个仓库，备份花了一个多小时，大小8.5GB。还是挺慢的。

# 关于备份的配置
位于`/etc/gitlab/gitlab.rb`的配置文件里有关于备份（Backup Settings）的配置. 也可以查看[页面](https://docs.gitlab.com/omnibus/settings/backups.html).

## 指定备份目录
```java
gitlab_rails['backup_path'] = "/var/opt/gitlab/backups"
```
## 保存日志时间
针对本地备份文件有效，默认7天（604800秒）：
```java
gitlab_rails['backup_keep_time'] = 604800
```
## 跳过某些模块

默认所有都会备份：
```java
db (database)
uploads (attachments)
repositories (Git repositories data)
builds (CI job output logs)
artifacts (CI job artifacts)
lfs (LFS objects)
registry (Container Registry images)
pages (Pages content)
```
可以跳过：
```shell
sudo gitlab-rake gitlab:backup:create SKIP=db,uploads
```



# 定时备份

## 定时备份配置
每周日4点备份配置：
```java
sudo crontab -e -u root
0 4 * * 7  umask 0077; tar cfz /data/backups/$(date "+etc-gitlab-\%s.tgz") -C / etc/gitlab
```
恢复配置：
```java
sudo mv /etc/gitlab /etc/gitlab.$(date +%s)
sudo tar -xf etc-gitlab-1399948539.tar -C /
```

## 定时备份数据
每天早上2点生成备份：
```java
sudo su -
crontab -e
0 2 * * * /opt/gitlab/bin/gitlab-rake gitlab:backup:create CRON=1
```
CRON = 1环境设置告诉备份脚本在没有错误时禁止所有进度输出。建议使用此方法来减少cron垃圾邮件.

# 刷新配置生效
我们需要[reconfig来生效配置](https://docs.gitlab.com/ee/administration/restart_gitlab.html#omnibus-gitlab-reconfigure):

```java
sudo gitlab-ctl reconfigure
```

# 恢复备份
TODO

默认备份日志输出：
```java
# gitlab-rake gitlab:backup:create
2019-06-12 14:50:02 +0800 -- Dumping database ... 
Dumping PostgreSQL database gitlabhq_production ... [DONE]
2019-06-12 14:50:08 +0800 -- done
2019-06-12 14:50:08 +0800 -- Dumping repositories ...
 * logger/log ... [SKIPPED]
[SKIPPED] Wiki
 * yinjiaxin/suibian ... [SKIPPED]
[SKIPPED] Wiki
 * yinjiaxin/learngit ... [DONE]
[SKIPPED] Wiki
 * yuqin/yq ... [DONE]
[SKIPPED] Wiki
。。。
。。。
2019-06-12 15:05:44 +0800 -- done
2019-06-12 15:05:44 +0800 -- Dumping uploads ... 
2019-06-12 15:06:44 +0800 -- done
2019-06-12 15:06:44 +0800 -- Dumping builds ... 
2019-06-12 15:06:47 +0800 -- done
2019-06-12 15:06:47 +0800 -- Dumping artifacts ... 
2019-06-12 15:06:54 +0800 -- done
2019-06-12 15:06:54 +0800 -- Dumping pages ... 
2019-06-12 15:06:57 +0800 -- done
2019-06-12 15:06:57 +0800 -- Dumping lfs objects ... 
2019-06-12 15:07:00 +0800 -- done
2019-06-12 15:07:00 +0800 -- Dumping container registry images ... 
2019-06-12 15:07:00 +0800 -- [DISABLED]
Creating backup archive: 1560323223_2019_06_12_11.10.0-ee_gitlab_backup.tar ... done
Uploading backup archive to remote storage  ... skipped
Deleting tmp directories ... done
done
done
done
Deleting old backups ... skipping
```
