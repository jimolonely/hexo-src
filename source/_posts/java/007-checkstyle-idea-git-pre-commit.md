---
title: 在git commit前自动检查checkstyle
tags:
  - java
  - checkstyle
p: java/007-checkstyle-idea-git-pre-commit
date: 2018-09-28 08:19:30
---

本文主要简介以下几个方面的内容：
1. idea的checkstyle插件安装
2. checkstyle自定义
3. 在commit前自动检查style

# check style是什么
github： https://github.com/checkstyle/checkstyle
官网： http://checkstyle.sourceforge.net/

参考资料（推荐）：http://insights.thoughtworkers.org/save-java-code-style-obsessive-compulsive-disorder/

# idea如何配置
我们使用idea相关插件：
https://github.com/jshiell/checkstyle-idea

## 安装插件

{% asset_img 000.png %}

装完重启后，会发现默认带有谷歌和sun公司的style：

{% asset_img 001.png %}

## 如何使用
选择一种方式，check就好：

{% asset_img 002.png %}

# 配置我们自己的style
阿里的style：
https://blog.csdn.net/KingBoyWorld/article/details/76082399

google style：
https://github.com/checkstyle/checkstyle/blob/master/src/main/resources/google_checks.xml


有关checkstyle的配置文件语法，参看官方文档：
http://checkstyle.sourceforge.net/config.html

//TODO
现在你应该学会了如何写配置，下面就是我们自己的style了，skr把。

然后导入idea的checkstyle插件里，以便实时检查：

{% asset_img 003.png %}

{% asset_img 004.png %}

# 如何在commit时自动检查
如果只是在IDEA里使用一下，对于自觉的程序员来说这当然就够了，但是即便是高手也会在某个阴暗的晚上抱着一种疲惫的心态和得过且过的态度想蒙混过关，最后连check一下都难得执行，于是，自动化的检查必须存在，如果检查不通过，不能提交代码。


这个过程分为3步：
## 1.准备好环境
1.  jdk与git环境配置
2.  checkstyle的jar包，虽然可以用maven，但是不想写在项目里。
3.  style xml配置文件，上面已写好
4.  pre-commit脚本，下面会写

在这里下载jar包：
https://github.com/checkstyle/checkstyle/releases

## 2. 了解git hook
我们要在git commit之前自动检查style，就需要利用git hook（钩子），查看文档：
https://git-scm.com/book/zh/v2/%E8%87%AA%E5%AE%9A%E4%B9%89-Git-Git-%E9%92%A9%E5%AD%90

{% asset_img 005.png %}

我们就需要pre-commit，只需要用shell，ruby，python或其他语言写好脚本，命名为pre-commit，放到hooks目录下就行了。
## 3. 如何自动关联
因为.git这个目录是不随项目文件一起提交的，所以不能实现共享，所以需要做一些配置，把脚本和jar包都放在项目下，为此，我建立了check-style目录来存放文件：

{% asset_img 006.png %}

然后现在有2种方法，可以拷贝pre-commit到.git/hooks目录下：
1.	手工拷贝，执行下面命令
`cp ./check-style/pre-commit ./.git/hooks/`

2.	使用maven复制自动在编译时复制文件

## 4.编写pre-commit脚本
步骤很简单，采用shell语言：
1.	得到要提交的文件：类似git status
2.	得到文件的全路径，只过滤出java文件
3.	对每个文件执行style check，记录结果
4.	如果结果不满意，则不执行git commit，返回非0

完整脚本如下：
```shell
#!/bin/bash
#@author:jimo#
#@func:pre-commit#
## cp ./check-style/pre-commit ./.git/hooks/

# 一个打印函数，前后加空行
function print(){
    echo ""
    echo "===========$*============"
    echo ""
}

print 避免NPE是程序员的基本修养！
print 开始style checking

wd=`pwd`
print "当前工作目录：$wd"

check_jar_path="$wd/check-style/checkstyle-8.12-all.jar"
check_xml_path="$wd/check-style/iad-checkstyle.xml"

# echo $check_jar_path $check_xml_path

# 清空temp文件
rm -f temp

is_err=0

for file in `git status --porcelain | sed s/^...// | grep '\.java$'`;do
    path="$wd/$file"
    print "检查文件：$path"
    re=`java -jar $check_jar_path -c $check_xml_path $path >> temp`
    err=`cat temp | grep "ERROR"`
    if [[ $err = *"ERROR"* ]];then
        print $err
        is_err=1
    fi
done

print "检查完成，祝你好运"

rm -f temp

if [ $is_err -ne 0 ]
then
    print "请先符合style才能提交！"
    exit 1
fi

exit 0
```

# 5.测试

{% asset_img 007.png %}

{% asset_img 008.png %}
