---
title: 那些没用过的java命令行选项
tags:
  - java
p: java/042-java-command-line-args
date: 2019-04-09 10:13:44
---

当我们执行`java -help`时，会出现下面的选项：

```java
用法: java [-options] class [args...]
           (执行类)
   或  java [-options] -jar jarfile [args...]
           (执行 jar 文件)
其中选项包括:
    -d32	  使用 32 位数据模型 (如果可用)
    -d64	  使用 64 位数据模型 (如果可用)
    -server	  选择 "server" VM
                  默认 VM 是 server,
                  因为您是在服务器类计算机上运行。


    -cp <目录和 zip/jar 文件的类搜索路径>
    -classpath <目录和 zip/jar 文件的类搜索路径>
                  用 : 分隔的目录, JAR 档案
                  和 ZIP 档案列表, 用于搜索类文件。
    -D<名称>=<值>
                  设置系统属性
    -verbose:[class|gc|jni]
                  启用详细输出
    -version      输出产品版本并退出
    -version:<值>
                  警告: 此功能已过时, 将在
                  未来发行版中删除。
                  需要指定的版本才能运行
    -showversion  输出产品版本并继续
    -jre-restrict-search | -no-jre-restrict-search
                  警告: 此功能已过时, 将在
                  未来发行版中删除。
                  在版本搜索中包括/排除用户专用 JRE
    -? -help      输出此帮助消息
    -X            输出非标准选项的帮助
    -ea[:<packagename>...|:<classname>]
    -enableassertions[:<packagename>...|:<classname>]
                  按指定的粒度启用断言
    -da[:<packagename>...|:<classname>]
    -disableassertions[:<packagename>...|:<classname>]
                  禁用具有指定粒度的断言
    -esa | -enablesystemassertions
                  启用系统断言
    -dsa | -disablesystemassertions
                  禁用系统断言
    -agentlib:<libname>[=<选项>]
                  加载本机代理库 <libname>, 例如 -agentlib:hprof
                  另请参阅 -agentlib:jdwp=help 和 -agentlib:hprof=help
    -agentpath:<pathname>[=<选项>]
                  按完整路径名加载本机代理库
    -javaagent:<jarpath>[=<选项>]
                  加载 Java 编程语言代理, 请参阅 java.lang.instrument
    -splash:<imagepath>
                  使用指定的图像显示启动屏幕
有关详细信息, 请参阅 http://www.oracle.com/technetwork/java/javase/documentation/index.html。
```
显然，并不是所有选项都用过，本着探索的渴求，好奇那是什么。

上面很多已经解释过，但还是有一些需要特别说明下。

# -D<key>=value

这个选项使用频率也很高，用法很简单：
```java
public class Main {

    public static void main(String[] args) {
        System.out.println(System.getProperty("name"));
    }
}
```
命令行传参：

```java
$ java Main -Dname=jimo
```

# -ea/-da

`-ea/-da`: `enable assertion/disable assertion(启用/禁用断言)`

来源： assert是JDK1.4(+)中新增的关键字，其功能称作assertion。看下面例子：
```java
public class Main {

    public static void main(String[] args) {
        assert args.length == 1;
    }
}
```
编译后直接运行： `java Main` ok

启用断言： `java -ea Main`就会抛异常：
```java
Exception in thread "main" java.lang.AssertionError
	at com.jimo.cmd.Main.main(Main.java:10)
```

很多软件都开启了这个选项，比如idea IDE。

# -splash


