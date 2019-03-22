---
title: 2019-12-周报
tags:
  - life
  - week
p: life/009-weekly-learn
date: 2019-03-18 08:11:57
---

这是2019年第12周周报。

1. 练习leetcode

2. stream流处理的特点：
    1. 无存储：只是数据窗口
    2. 一次性： 消费完了就没了
    3. 惰性： 需要结果才计算
    4. 函数式编程
  

3. 如何理解流： 只需掌握3个步骤：
    1. 创建： 集合的.stream() , Stream.of(...)
    2. 中间步骤: filter, map, sort, limit/skip, distinct 
    3. 最终操作: forEach(), count(), collect()


4. @Resource,@Inject,@Autowired的区别： [参考](https://www.baeldung.com/spring-annotations-resource-inject-autowire)
    1. @Resource:
        1. name
        2. type
        3. qualifier
    2. @Inject:
        1. type
        2. qualifier
        3. name
    3. @Autowired: 顺序和@Inject一样，只是是spring自带的注解


5. [你怎么理解spring中的单例模式](https://dzone.com/articles/an-interview-question-on-spring-singletons):
    ```
    spring中的单例并不是只有一个实例，而是针对唯一的id只有一个实例对应，也就是引用是单例的。
    ```

6. [slf4j logger format 占位符写法](https://stackoverflow.com/questions/6371638/slf4j-how-to-log-formatted-message-object-array-exception)


7. mysql-datediff(date1,date2): `SELECT DATEDIFF("2017-06-25", "2017-06-27"); == (-2)`

8. [发现github上一个电子书库](https://github.com/yuanliangding/books)

9. {% post_link linux/020-ubuntu-install-extensions ubuntu安装扩展/插件 %}

10. {% post_link db/007-pgsql-updateset-ambiguous-column pgsql update set ambiguous column %}

11. {% post_link java/037-jar-java-cmdline 掌握java命令行编译打包 %}

12. 复习了hbase的写法，hbaseTemplate的使用

13. {% post_link maven/003-maven-reknown maven再学习 %}



