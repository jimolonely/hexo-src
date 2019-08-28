---
title: hbase shell里编码原理与解析
tags:
  - java
  - hbase
p: java/060-hbase-shell-hex-decode
date: 2019-08-28 11:02:30
---

1. hbase是以byte存储数据的
2. hbase shell展示时是经过编码的

看一个示例：
```java
ROW                                                   COLUMN+CELL                                                                                                                                                  
 A010n0\x00\x00\x00\x00]d\xE7\xB0\x00\x17\x00-\x00s\x column=cf1:count, timestamp=1566894387475, value=2                                                                                                           
 7F\xFF\xFF\xFF\xFF\xFF\xCC\x00\x00\x00\x04'                                                                                                                                                                       
 A010n0\x00\x00\x00\x00]d\xE7\xB0\x00\x17\x00-\x00s\x column=cf1:value, timestamp=1566894387475, value=12.900                                                                                                      
 7F\xFF\xFF\xFF\xFF\xFF\xCC\x00\x00\x00\x04'    
```
这里的rowkey经过了编码，让我们不能直接看明白。

# 产生原理

查看类`hbase-common-0.98.5-hadoop2.jar!/org/apache/hadoop/hbase/util/Bytes.class`下的`toStringBinary`方法：
```java
public static String toStringBinary(byte[] b, int off, int len) {
    StringBuilder result = new StringBuilder();
    if (off >= b.length) {
        return result.toString();
    } else {
        if (off + len > b.length) {
            len = b.length - off;
        }

        for(int i = off; i < off + len; ++i) {
            int ch = b[i] & 255;
            if ((ch < 48 || ch > 57) && (ch < 65 || ch > 90) 
              && (ch < 97 || ch > 122) && " `~!@#$%^&*()-_=+[]{}|;:'\",.<>/?".indexOf(ch) < 0) {
                result.append(String.format("\\x%02X", ch));
            } else {
                result.append((char)ch);
            }
        }

        return result.toString();
    }
}
```
注意其中的`String.format("\\x%02X", ch)`语句，这就是`\x`前缀的来源，其中

1. `%02`表示如果不够2位前面补0
2. `X`表示16进制

# 解析过程

明白了怎么产生的，就知道怎么解析了，根据上面的示例：`A010n0\x00\x00\x00\x00]d\xE7\xB0\x00\x17\x00-\x00s\x7F\xFF\xFF\xFF\xFF\xFF\xCC\x00\x00\x00\x04'`

1. `A010n0`: 是我们业务中的字符串，因此直接显示出来的
2. `\x`: 看起来很有规律，实际上`\x`后面跟的2个字符构成了16进制字符串，如`\xE7`表示`0xE7`
3. `\x00d]`, `\x00-`这些是例外吗？ 并不是，这应该分开来看：`\x00`,`d`,`]`,`\x00`,`-`, 而这里的单个字符需要先转为ASCII码，再转为16进制：
    1. `d`: ascii为100， 16进制为`0x64`
    2. `]`: ascii=93, `0x5d`
    3. `-`: ascii=45,`0x2D`
4. 于是上述解码之后为：`A010n0000000005d64E7B00017002d00737FFFFFFFFFFFCC0000000427`


下面是转成16进制的代码：
```java
private String toHex(String s) {
    String[] split = s.split("\\\\x");
    StringBuilder sb = new StringBuilder();
    for (String h : split) {
        if ("".equals(h)) {
            continue;
        }
        if (h.length() > 2) {
            sb.append(h, 0, 2);
            char[] chars = h.substring(2).toCharArray();
            for (char c : chars) {
                sb.append(Integer.toHexString((int) c));
            }
        } else {
            sb.append(h);
        }
    }
    return sb.toString();
}
```
解码成16进制之后还没完，再根据自己业务进行字节拆分再转换成整数、short或其他类型。

# 参考

1. [https://www.cnblogs.com/drwong/p/5622035.html](https://www.cnblogs.com/drwong/p/5622035.html)
2. [转换工具网站](https://sites.google.com/site/nathanlexwww/tools/utf8-convert)



