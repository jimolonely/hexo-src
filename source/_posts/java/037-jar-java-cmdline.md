---
title: 掌握java命令行编译打包
tags:
  - java
p: java/037-jar-java-cmdline
date: 2019-03-20 09:29:06
---

设想遇到这样一种情况： 你被派到一个网络环境封闭、只有shell访问的linux系统去修改代码，你的代码是以jar包形式运行的，
你要改的地方很少，就一行代码，你会怎么做？

现在程序员都使用Eclipse或IDEA等集成开发工具， 几乎已经忘了命令行如何编译、打包，虽然这个不是天天遇到，但遇到了
就是体现差距的地方了。

ok，针对上面的场景，我们创建一个实验环境。

# 实践过程
我们的环境下有一个jar包（关于这个jar包怎么来的，请参加下面# 关于源文件以及打包过程）：
```java
$ ls
Hello.jar
```
查看下jar包内容：
```java
$ jar -tf Hello.jar 
META-INF/
META-INF/MANIFEST.MF
com/
com/jimo/
com/jimo/test/
com/jimo/test/Test.class
com/jimo/Hello.class
```

要改文件，肯定得解压出来呀：
```java
$ jar -xvf Hello.jar 
  已创建: META-INF/
  已解压: META-INF/MANIFEST.MF
  已创建: com/
  已创建: com/jimo/
  已创建: com/jimo/test/
  已解压: com/jimo/test/Test.class
  已解压: com/jimo/Hello.class
```

```java
$ tree
.
├── com
│   └── jimo
│       ├── Hello.class
│       └── test
│           └── Test.class
├── Hello.jar
└── META-INF
    └── MANIFEST.MF
```
然后替换新的jar包即可。


# 关于源文件以及打包过程
目录结构：
```shell
$ tree com/
com/
└── jimo
    ├── Hello.java
    └── test
        └── Test.java
```
源文件内容：
```java
$ cat com/jimo/Hello.java 
package com.jimo;

import com.jimo.test.Test;

public class Hello {
    
    public static void main(String[]args){
        System.out.println("Hello, Jimo!");
        Test.print();
    }
}

//-------------------------------------------

$ cat com/jimo/test/Test.java 
package com.jimo.test;

public class Test {
    
    public static void print(){
        System.out.println("This is Test!");
    }
}
```

编译： `-d`选项指定编译后文件存放目录
```shell
$ mkdir target

$ javac -d target/ com/jimo/*.java

$ ls
com  target

$ tree target/
target/
└── com
    └── jimo
        ├── Hello.class
        └── test
            └── Test.class
```
打包成jar包：
```shell
# 首先进入target目录
$ cd target

# 打包
$ jar cvf Hello.jar com
'已添加清单
正在添加: target/com/(输入 = 0) (输出 = 0)(存储了 0%)
正在添加: target/com/jimo/(输入 = 0) (输出 = 0)(存储了 0%)
正在添加: target/com/jimo/test/(输入 = 0) (输出 = 0)(存储了 0%)
正在添加: target/com/jimo/test/Test.class(输入 = 405) (输出 = 286)(压缩了 29%)
正在添加: target/com/jimo/Hello.class(输入 = 474) (输出 = 317)(压缩了 33%)
```
现在我们运行下jar包：发现报错了
```shell
$ java -jar Hello.jar 
Hello.jar中没有主清单属性
```
既然没有主清单文件，我们就创建一个，核心就是指定主类：
```shell
target$ cat manifest 

Manifest-Version: 1.0
Created-By: jimo
Main-Class: com.jimo.Hello
```

然后重新打包运行：
```shell
$ jar cvfm Hello.jar manifest com
已添加清单
正在添加: com/(输入 = 0) (输出 = 0)(存储了 0%)
正在添加: com/jimo/(输入 = 0) (输出 = 0)(存储了 0%)
正在添加: com/jimo/test/(输入 = 0) (输出 = 0)(存储了 0%)
正在添加: com/jimo/test/Test.class(输入 = 405) (输出 = 286)(压缩了 29%)
正在添加: com/jimo/Hello.class(输入 = 474) (输出 = 317)(压缩了 33%)

target$ java -jar Hello.jar 
Hello, Jimo!
This is Test!
```

看下最后的结构：
```java
$ tree
.
├── com
│   └── jimo
│       ├── Hello.java
│       └── test
│           └── Test.java
└── target
    ├── com
    │   └── jimo
    │       ├── Hello.class
    │       └── test
    │           └── Test.class
    ├── Hello.jar
    └── manifest
```

# 最后
1. [Working with Manifest Files](https://docs.oracle.com/javase/tutorial/deployment/jar/manifestindex.html)

2. [关于MANIFEST.MF文件的解释](https://www.cnblogs.com/EasonJim/p/6485677.html)



