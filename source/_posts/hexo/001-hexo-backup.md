---
title: hexo换电脑或备份
tags:
  - hexo
p: hexo/001-hexo-backup
---
本文对hexo的源代码如何备份做一个方案的探讨.我们知道hexo生成的静态页面放在public目录下,
每次将这个目录推送到github上,但是hexo本身却没上传,如果换电脑就无力回天了.下面就是一些解决方案.

# 1.暴力备份
如果不嫌麻烦,每次更新博客后都手动将hexo源代码备份,即使是这样也需要知道哪些是必须备份的.
下面是所有文件:
```shell
[jimo@jimo-pc myblog]$ ls -lha
总用量 240K
drwxr-xr-x   8 jimo jimo 4.0K 12月 27 18:12 .
drwxr-xr-x  26 jimo jimo 4.0K 5月  16 21:29 ..
-rw-r--r--   1 jimo jimo 2.1K 4月  27 11:19 _config.yml
-rw-r--r--   1 jimo jimo  174 5月  17 20:20 db.json
drwxr-xr-x  13 jimo jimo 4.0K 5月  15 12:47 .deploy_git
-rw-r--r--   1 jimo jimo   65 12月 23 21:46 .gitignore
drwxr-xr-x 298 jimo jimo  12K 12月 23 22:14 node_modules
-rw-r--r--   1 jimo jimo  483 12月 23 22:14 package.json
-rw-r--r--   1 jimo jimo 106K 12月 23 22:14 package-lock.json
drwxr-xr-x  12 jimo jimo 4.0K 1月   1 15:48 public
drwxr-xr-x   2 jimo jimo 4.0K 12月 23 21:46 scaffolds
drwxr-xr-x   4 jimo jimo 4.0K 12月 27 18:10 source
drwxr-xr-x   3 jimo jimo 4.0K 12月 23 21:46 themes
-rw-r--r--   1 jimo jimo  73K 12月 23 21:46 yarn.lock
```
需要备份的有:
```shell
_config.yml，themes/，source/，scaffolds/，package.json，.gitignore
```
不需要的有: 到时候npm install再安装一遍即可.
```shell
.git/，node_modules/，public/，.deploy_git/，db.json
```
# 2.自动备份
既然要备份,为什么不做成自动的呢? 其实源码也可以push到github上嘛,那现在就有2个仓库,一个
用来存hexo源码,一个用来存博客.这样的话每次得2次push.

当然首先我肯定会想到写一个脚本,把这两步放在一起,大概如下:
backup.sh
```shell
#!/bin/bash

hexo g && hexo d # 先更新博客

# 再更新源码
git add .
git commit -m 'update'
git push
```
注意在.gitignore把不需要的过滤掉就行了.

# 3.持续集成
我们也可以把这2步交给持续集成的框架,常用的有[appveyor](https://www.appveyor.com/),[travis-ci](https://www.travis-ci.org/).

可以参考[这个博客](https://formulahendry.github.io/2016/12/04/hexo-ci/)

# 4.多分支同步
不需要2个仓库,使用同一个仓库的2个分之即可.

```
作者：CrazyMilk
链接：https://www.zhihu.com/question/21193762/answer/79109280
来源：知乎
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。

其实，Hexo生成的文件里面是有一个.gitignore的，所以它的本意应该也是想我们把这些文件放到GitHub上存放的。但是考虑到如果每个GitHub Pages都需要额外的一个仓库存放这些文件，就显得特别冗余了。这个时候就可以用分支的思路！一个分支用来存放Hexo生成的网站原始的文件，另一个分支用来存放生成的静态网页。最近我也用GitHub Pages搭建了一个独立博客，想到了这个方法，使用之后真的特别简洁。为了更直观地说明，奉上使用这种方法不同时候的流程：

一、关于搭建的流程
1. 创建仓库，http://CrazyMilk.github.io；
2. 创建两个分支：master 与 hexo；
3. 设置hexo为默认分支（因为我们只需要手动管理这个分支上的Hexo网站文件）；
4. 使用git clone git@github.com:CrazyMilk/CrazyMilk.github.io.git拷贝仓库；
5. 在本地http://CrazyMilk.github.io文件夹下通过Git bash依次执行npm install hexo、hexo init、npm install 和 npm install hexo-deployer-git（此时当前分支应显示为hexo）;
6. 修改_config.yml中的deploy参数，分支应为master；
7. 依次执行git add .、git commit -m "..."、git push origin hexo提交网站相关的文件；
8. 执行hexo g -d生成网站并部署到GitHub上。
这样一来，在GitHub上的http://CrazyMilk.github.io仓库就有两个分支，一个hexo分支用来存放网站的原始文件，一个master分支用来存放生成的静态网页。完美( •̀ ω •́ )y！

二、关于日常的改动流程在本地对博客进行修改（添加新博文、修改样式等等）后，通过下面的流程进行管理。
1. 依次执行git add .、git commit -m "..."、git push origin hexo指令将改动推送到GitHub（此时当前分支应为hexo）；2. 然后才执行hexo g -d发布网站到master分支上。
虽然两个过程顺序调转一般不会有问题，不过逻辑上这样的顺序是绝对没问题的（例如突然死机要重装了，悲催....的情况，调转顺序就有问题了）。
三、本地资料丢失后的流程当重装电脑之后，或者想在其他电脑上修改博客，可以使用下列步骤：
1. 使用git clone git@github.com:CrazyMilk/CrazyMilk.github.io.git拷贝仓库（默认分支为hexo）；
2. 在本地新拷贝的http://CrazyMilk.github.io文件夹下通过Git bash依次执行下列指令：npm install hexo、npm install、npm install hexo-deployer-git（记得，不需要hexo init这条指令）。
```

# 5.使用插件
可以更新使用最新的 hexo-deployer-git 插件，因为没有发布到 npm 的原因，必须得从 github 安装
```shell
npm install git+git@github.com:hexojs/hexo-deployer-git.git --save
```
在项目根目录下的 _config.yml 里面就可以这样配置
```
# _config.yaml
deploy:
  - type: git
    repo: git@github.com:<username>/<username>.github.io.git
    branch: master
  - type: git
    repo: git@github.com:<username>/<username>.github.io.git
    branch: src
    extend_dirs: /
    ignore_hidden: false
    ignore_pattern:
        public: .
```
这样，在每次写完博客的时候时候使用 hexo d 命令就能将所有其他文件发布到 src 分支换电脑的时候就能通过 git 重新下载下来整个项目，然后本地切换到远端的 src 分支
```
git checkout origin/src
```
就能重新获得所有的源文件，就能重新 hexo d 发布对于每一个从 git 下载下来的项目或者主题，最好把每个的 .git 文件夹删掉，否则得通过 submodule 的方式来安装。

# 6.总结
个人觉得方法2最简单也不容易出错.

以下是我的shell脚本
```shell
#!/bin/bash
#--------------------------------------------
# 提交博客脚本,同步hexo源码和推送博客修改到不同仓库
# author：jimolonely
# site：jimolonely.github.io
# slogan：shell is a way!
#--------------------------------------------

# 接受git commit 提交参数
msg="$*"

if [ -z "$msg" ];then
    msg=$(git status --short)
fi

hexo g
hexo d

git status
git add .
git commit -m "$msg"
git push
```
