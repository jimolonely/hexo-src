---
title: 2019-16-周报
tags:
  - week
  - life
p: life/014-weekly-learn
date: 2019-04-22 13:40:41
---

这是2019年第17周周报。

1. classloader工作原理

2. [乐观锁与悲观锁再学习](https://juejin.im/post/5b4977ae5188251b146b2fc8)

3. [锁优化](https://blog.csdn.net/StackFlow/article/details/79455880)

4. [java 信号量](https://www.cnblogs.com/whgw/archive/2011/09/29/2195555.html)

5. [transient关键字](https://www.cnblogs.com/chenpi/p/6185773.html):
    保证字段不被序列化，例如hashmap里的modCount，用来判断`ConcurrentModificationException`:
    ```java
    if (size > 0 && (tab = table) != null) {
        int mc = modCount;
        for (int i = 0; i < tab.length; ++i) {
            for (Node<K,V> e = tab[i]; e != null; e = e.next)
                action.accept(e);
        }
        if (modCount != mc)
            throw new ConcurrentModificationException();
    }
    ```
5. [理解线程池的原理，为什么要创建线程池？](https://blog.csdn.net/xiongyouqiang/article/details/79456030)



