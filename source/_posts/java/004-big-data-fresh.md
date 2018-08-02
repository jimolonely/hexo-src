---
title: Big Data Freshman
tags:
  - big data
p: java/004-big-data-fresh
date: 2018-08-02 07:18:26
---

下面是新手入门掌握的。

# 1.java基础

## 1.1 类和变量的初始化顺序
### 1.1.1 初始化顺序规则
1. 祖先的静态域或静态块
2. 当前类的静态域或静态块
3. 祖先的实例字段和初始化块
4. 初始化祖先实例字段后的祖先构造函数
5. 当前类的实例字段和初始化块
6. 当前类的构造函数

### 1.1.2 代码验证
[参看代码](https://github.com/jimolonely/codes/tree/master/java-basic/src/jimo/order)

## 1.2 集合


## 1.3 泛型

## 1.4 多线程

# 2.掌握常用设计模式
[参见设计模式](https://jimolonely.github.io/2018/07/23/java/003-design-pattern-type/)

# 3.Redis
熟悉redis基本功能，了解redis的应用场景。

# 4.hbase
1. 了解hbase的数据结构
2. 了解hbase的使用场景
3. 掌握hbase的基本常洵方式
## 4.1 hbase数据结构
[参考文档](https://hbase.apache.org/book.html#datamodel)

1. Table: HBase将数据组织到表中。 表名是字符串，由在文件系统路径中安全使用的字符组成;
2. Row: 在表中，数据根据其行存储。 行由行键唯一标识。 行键没有数据类型，并始终被视为byte[]（字节数组）;
3. Column Family: 行中的数据按列族分组。 列族也会影响HBase中存储的数据的物理排列。 因此，必须预先定义它们并且不容易修改。 表中的每一行都具有相同的列族，但行不需要在其所有族中存储数据。 列族是字符串，由可安全用于文件系统路径的字符组成;
4. Column Qualifier: 列族中的数据通过其列限定符或简称列来定位。 不需要事先指定列限定符。 列限定符不需要在行之间保持一致。 与行键一样，列限定符没有数据类型，并且始终被视为byte [];
5. Cell: 行键，列族和列限定符的组合唯一地标识单元格。 存储在单元中的数据称为该单元的值。 值也没有数据类型，并始终被视为byte [];
6. Timestamp: 单元格中的值是版本化的。 版本由其版本号标识，默认情况下是编写单元格的时间戳。 如果在写入期间未指定时间戳，则使用当前时间戳。 如果没有为读取指定时间戳，则返回最新的时间戳。 HBase保留的单元格值版本的数量是为每个列族配置的。 默认的单元版本数量为3。

**其可视化例子如下：**
{% asset_img 000.png %}

**其中一行的JSON格式如下图：**
{% asset_img 001.png %}

**访问数据时：**
{% asset_img 002.png %}

## 4.2 hbase使用场景

## 4.3 hbase基本查询方式
先按照[官方文档](https://hbase.apache.org/book.html#quickstart)做一遍，基本命令如下：
```shell
1. bin/start-hbase.sh
2. bin/hbase shell
3. create 'test', 'cf'
4. list 'test'
5. describe 'test'
6. put 'test', 'row1', 'cf:a', 'value1'
7. get 'test', 'row1'
8. scan 'test'
9. disable 'test' / enable 'test'
10. drop 'test'
11. quit
12. bin/stop-hbase.sh
```

# 5.elasticsearch
1. 熟悉elasticsearc的基本原理
2. 熟练使用elasticsearch-head插件

# 6.kafka
熟悉kafka的使用场景和原理

# 7.springMVC-mybatis
熟练掌握这个框架
# 8.spring cloud
了解spring-cloud框架及其各个组件的作用
# 9.linux
掌握linux的常用命令
# 10.git
掌握git的常用命令
# 11.mysql
熟练使用mysql
# 12.IDEA
熟练使用IDEA编辑器。

