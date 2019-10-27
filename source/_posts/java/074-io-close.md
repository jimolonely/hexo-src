---
title: IO不close的问题
tags:
  - java
p: java/074-io-close
date: 2019-10-09 10:41:14
---

文件、网络的输入输出流如果没关闭，会有什么后果？

本文以文件写入为例，实践解释：

```java
  BufferedWriter writer = new BufferedWriter(new FileWriter(
          "D:\\data\\a.txt"));
  StringBuilder sb = new StringBuilder();
  for (int i=0;i<10000;i++>) {
      sb.setLength(0);

      for (int j=0;j<100;j++>) {
          sb.append(j+" ");
      }
      String str = sb.toString();
      writer.write(str);
      writer.newLine();
  }
```
以上写入10000行数据，但是结果却没有10000行，总是差一些，为啥？

如果最后加上一行：
```java
  writer.close();
```
那么结果就正确了。

很简单，所谓bufferedWriter，就是缓冲写，也就是会缓存到一定数量才写入文件，最后那一部分数据没写入文件，看close的源码就知道了：

```java
public void close() throws IOException {
    synchronized (lock) {
        if (out == null) {
            return;
        }
        try (Writer w = out) {
            flushBuffer();
        } finally {
            out = null;
            cb = null;
        }
    }
}

void flushBuffer() throws IOException {
    synchronized (lock) {
        ensureOpen();
        if (nextChar == 0)
            return;
        out.write(cb, 0, nextChar);
        nextChar = 0;
    }
}
```
重点就是flushBuffer方法，最后还有一步写。

因此，一定记得关闭输入输出流。


