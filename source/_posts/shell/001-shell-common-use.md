---
title: shell常用操作
tags:
  - shell
  - linux
p: shell/001-shell-common-use
date: 2018-04-01 13:51:55
---
shell那些常用操作.

# 字符串为空判断
注意有引号
```shell
str=

if [ -z "$str" ];then
    echo "is empty"
fi

if [ -n "$str" ];then
    echo "not empty"
```

# 读取文件的某一行
比如读取第3行
```shell
$ sed -n '3p' fileName
```

# 数组作为函数参数
分2种情况：
1. 声明的数组
2. 脚本命令行参数

如下：
```shell
declare -a apps=("a" "b")

test_func() {
    arr=$1
    for app in ${arr[*]}
    do
        echo "[${app}]"
    done
}

# 接受参数
args=$@
if [[ -z "$args" ]];then
    echo "from inner"
    test_func "${apps[*]}"
else
    echo "from command line"
    test_func "${args[@]}"
fi
```
带参数运行时： `$ bash script.sh c d e`

如果只想截取部分list，比如从第二个开始：
```shell
args=${@:2}
```

# 文件相关判断

1. 文件夹是否存在： `[[ -d "${DIR}" ]]` 表示存在
2. 文件存在： `[[ -e "${file}" ]]`

