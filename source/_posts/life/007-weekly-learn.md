---
title: 2019-10-周报
tags:
  - life
  - week
p: life/007-weekly-learn
date: 2019-03-04 16:31:45
---

2019年第10周学习。

1. 主要是关于架构方面的： redis和memcached比较， 缓存和数据库的读写

2. ES使用问题：
  1. 如何查询所有数据？ 将size设置为大于可以预见的最大条数， 大数据推荐用scan

3. ISAM是什么？ Indexed Sequential Access Method.

4. 如何拉起应用？ 虽然自己写了个shell脚本循环检测，但[supervisor](https://www.rddoc.com/doc/Supervisor/3.3.1/zh/configuration/)似乎更好用，专业。

5. SQL问题： [关于join和where的执行顺序](https://www.cnblogs.com/Jessy/p/3525419.html), 干脆复习一下[所有条件的执行顺序](https://blog.csdn.net/u014044812/article/details/51004754)
    还有就是`left join 和 left outer join 是一样的`：
    ```sql
    A LEFT JOIN B            A LEFT OUTER JOIN B
    A RIGHT JOIN B           A RIGHT OUTER JOIN B
    A FULL JOIN B            A FULL OUTER JOIN B
    A INNER JOIN B           A JOIN B
    ```

6. 啥是服务降级？ 和服务熔断的区别是什么？
  1. [服务降级](https://my.oschina.net/yu120/blog/1790398)
  2. 熔断这一概念来源于电子工程中的断路器（Circuit Breaker）.可以想象保险丝断路了。
  2. [区别-漫画熔断](https://juejin.im/post/5ad05373518825619d4d2f00)


7. pgsql表间复制数据： `Insert into Table2(field1,field2,…) select value1,value2,… from Table1`

8. {% java/030-spring-boot-build-source post_link 编译spring-boot源码 %}，准备学习
    1. 遇到maven相关的问题： [Properties in parent definition are prohibited](https://chenyongjun.vip/articles/98)
    2. {% post_link java/033-spring-boot-overview 第一篇-概览 %}

9. {% post_link java/031-java-process-memory-usage 研究java进程内存占用过高原因 %}

10. 开始研究quartz： {% post_link java/032-springboot-quartz spring-boot quartz %}

 




