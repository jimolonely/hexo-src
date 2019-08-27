---
title: int和string转byte时的区别
tags:
  - java
  - basic
p: java/059-byte-int-string-utf8
date: 2019-08-27 15:36:10
---

计算机的一切基础都是在二进制上，为了让二进制模拟世间万物的字符，我们有了编码。从最初的ASCII编码，到如今风靡全球的Unicode编码，告诉我们一个道理：编码很重要。

本文是对处理byte类型问题时做的一个总结，原因在于：使用hbase时，为了节省rowkey的空间，我们对rowkey做了编码，里面存在数字，大家知道rowkey在hbase里是用字节存储的。
而一个ASCII字符1个字节，但2个字节可以表示1-65536个数字，如果用字符串来存，65536就需要5个字节，显然不合理，因此需要将整型转为byte类型。

很多没有接受计算机基础教育的程序员对这种问题模模糊糊也不在乎，但是即便是专业出生，也很少遇到这些问题，这种底层问题也很让人困扰，即便很简单，因此，就当是站在同一起跑线上了。

# string转byte

string转byte很简单，有原生方法：
```java
  byte[] bytes = "161".getBytes(StandardCharsets.UTF_8);
  for (byte b : bytes) {
      System.out.print(b + " ");
  }
  // 结果：49 54 49 
```
这里的结果很容易理解，但是也需要注意：我们传入的是UTF8编码，为什么得到的是ASCII码的结果？

很简单，这需要对UTF8编码有个了解： UTF会使用1、2 、3 、4个字节来表示一个字符，而最开始的`000000 - 00007F`的128个字符就是ASCII码，这就是兼容了。

再深入一点，查看`UTF_8.java`的源码：这里甚至对ASCII码进行了单独考虑来优化循环，看到`\u0080`了把，刚好是`7F`的后一个，说明ASCII码在前面。
```java
  public int encode(char[] sa, int sp, int len, byte[] da) {
      int sl = sp + len;
      int dp = 0;
      int dlASCII = dp + Math.min(len, da.length);

      // ASCII only optimized loop
      while (dp < dlASCII && sa[sp] < '\u0080')
          da[dp++] = (byte) sa[sp++];
          ...
```

# int转byte

假如让你把int转为字节数组，你会怎么做？

确实，JDK没有自带的工具类，但是这么简单的事情，自己写一个呗： 无非就是一个字节一个字节的强转，本质上byte也是数字嘛
```java
private byte[] toBytes(int val) {
    byte[] b = new byte[4];

    for (int i = 3; i > 0; --i) {
        b[i] = (byte) val;
        val >>>= 8;
    }

    b[0] = (byte) val;
    return b;
}
```
好，上面的代码是hbase客户端里的工具类实现，现在来测试一下：

```java
byte[] b3 = toBytes(33);
for (byte b : b3) {
    System.out.print(b + " ");
}
// 结果：0 0 0 33
```
看起来挺好理解，33的二进制为：`000...00(24个)00100001`, 8位一个字节，那么前面都是0了，没问题。

那接下来看下面的代码：
```java
byte[] b2 = toBytes(161);
for (byte b : b2) {
    System.out.print(b + " ");
}
// 结果：0 0 0 -95
```
what？`161`的二进制为：`000..00(24个)10100001`,最后8位为`10100001`,就是161，为啥打印出`-95`？

再看一下`-95`的二进制：`11011111`, 机智的你或许知道了，也许曾经听过java使用补码来存数字，但是现在才明白。

`-95`就是`161`的补码表示，如果只有8位的话。

正数的补码就是其本身，负数的补码：除符号位按位取反再+1.


# 总结

如果不缺钱、不缺存储空间，编码也许可以省略，毕竟增加了工作量和复杂度，就更容易出错。

