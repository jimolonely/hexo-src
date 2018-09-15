---
title: sbt那些事
tags:
  - scala
  - sbt
p: scala/002-sbt-shoud-know
date: 2018-09-15 14:13:33
---

sbt(scala build tool)是scala的构建工具，在使用过程中有些基础的要点。

# sbt的安装
注意修改maven镜像,位于`~/.sbt`,新建一个`repostories`文件，改为阿里云的镜像：
```
# cat ~/.sbt/repositories
[repositories]
local
aliyun: http://maven.aliyun.com/nexus/content/groups/public
jcenter: http://jcenter.bintray.com
typesafe: http://repo.typesafe.com/typesafe/ivy-releases/, [organization]/[module]/(scala_[scalaVersion]/)(sbt_[sbtVersion]/)[revision]/[type]s/[artifact](-[classifier]).[ext], bootOnly
```

# sbt console
运行`sbt console`就可以进入scala命令行。
## 帮助
```shell
scala> :help
All commands can be abbreviated, e.g., :he instead of :help.
:completions <string>    output completions for the given string
:edit <id>|<line>        edit history
:help [command]          print this summary or command-specific help
:history [num]           show the history (optional num is commands to show)
:h? <string>             search the history
:imports [name name ...] show import history, identifying sources of names
:implicits [-v]          show the implicits in scope
:javap <path|class>      disassemble a file or class name
:line <id>|<line>        place line(s) at the end of history
:load <path>             interpret lines in a file
:paste [-raw] [path]     enter paste mode or paste a file
:power                   enable power user mode
:quit                    exit the interpreter
:replay [options]        reset the repl and replay all previous commands
:require <path>          add a jar to the classpath
:reset [options]         reset the repl to its initial state, forgetting all session entries
:save <path>             save replayable session to a file
:sh <command line>       run a shell command (result is implicitly => List[String])
:settings <options>      update compiler options, if possible; see reset
:silent                  disable/enable automatic printing of results
:type [-v] <expr>        display the type of an expression without evaluating it
:kind [-v] <type>        display the kind of a type. see also :help kind
:warnings                show the suppressed warnings from the most recent line which had any
```

## 清空界面
`Ctrl+L`应该是个通用快捷键了。
## 重新加载
这是个常用的命令，毕竟你不想重新开一遍：
```scala
scala> :reset
Resetting interpreter state.
Forgetting this session history:

class Foo{}
object FooMaker{
def apply() = new Foo
}
...
```
## 退出
```shell
scala> :quit

[success] Total time: 10763 s, completed Sep 15, 2018 2:19:20 PM
```
