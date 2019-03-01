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
