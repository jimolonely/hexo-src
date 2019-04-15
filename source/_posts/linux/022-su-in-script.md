---
title: 带密码的sudo和su命令
tags:
  - shell
  - linux
p: linux/022-su-in-script
date: 2019-04-15 14:42:54
---

有时，迫不得已，我们需要在脚本中执行sudo或su命令，虽然这不安全，但切实可行。

# sudo
sudo非常简单，因为其自己就可以：
```shell
$ echo rootPass | sudo -S cmd
```
`-S` 代表从标准输入读取密码。

# su
我们常用做法是`su - root`,这时需要输入密码。要怎么在脚本中指定呢？稍微复杂一点。

## 方式1

```shell
su - username <<!
enterpasswordhere
enter commands to run as the new user
!

#######例子#######

su - root <<! >/dev/null 2>&1
root-password
whoami > /dev/tty
ls > /dev/tty
!
```
他是把结果输入到tty，也就是终端，如果我想获取结果呢？

可以写入临时文件：
```shell
su - root <<! >/dev/null 2>&1
root-password
whoami > /tmp/result
ls > /tmp/result
!
```
加入我采用的java程序链接ssh获取输出，这种方式可行：

```java
ShellExecutor executor = new ShellExecutor(ssh);
String s = executor.execute("cd ~ && echo 'su - root <<! >/dev/null 2>&1' > su_temp.sh" +
        " && echo '$1' >> su_temp.sh" +
        " && echo 'cd $2' >> su_temp.sh" +
        " && echo '$3 > /tmp/result' >> su_temp.sh" +
        " && echo ! >> su_temp.sh" +
        " && sh su_temp.sh develop@2wsx#EDC@2019 /etc ls" +
        " && rm -f su_temp.sh " +
        " && cat /tmp/result");
System.out.println(s);
```
## 方式2
```shell
#!/usr/bin/expect -f
#Usage: script.sh cmd user pass

set cmd [lindex $argv 0];
set user [lindex $argv 1];
set pass [lindex $argv 2];

log_user 0
spawn su -c $cmd - $user
expect "Password: "
log_user 1
send "$pass\r"
expect "$ "

```
运行：
```shell
./runas.sh "ls -l" bob 1234
```

# 参考
1. [Is there a single line command to do `su`?](https://askubuntu.com/questions/354838/is-there-a-single-line-command-to-do-su)
2. [Run SU with password command line argument](https://coderwall.com/p/0wgrwq/run-su-with-password-command-line-argument)





