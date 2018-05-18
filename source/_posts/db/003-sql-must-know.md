---
title: sql中最重要的原理
tags:
  - sql
p: db/003-sql-must-know
date: 2018-04-18 10:17:02
---
经过时间的沉淀和项目的练习,才知道哪些关键sql原理不得不知.

# sql的执行顺序
1. from子句组装来自不同数据源的数据；
2. where子句基于指定的条件对记录行进行筛选；
3. group by子句将数据划分为多个分组；
4. 使用聚集函数进行计算；
5. 使用having子句筛选分组；
6. 计算所有的表达式；
7. select 的字段；
8. 使用order by对结果集进行排序。
```
(8)SELECT (9) DISTINCT (11) <TOP_specification> <select_list>
(1) FROM <left_table>
(3) <join_type> JOIN <right_table>
(2) ON <join_condition>
(4) WHERE <where_condition>
(5) GROUP BY <group_by_list>
(6) WITH {CUBE | ROLLUP}
(7) HAVING <having_condition>
(10) ORDER BY <order_by_list>
```
# 18-04-19
今天早上来已经跑完了,新增了上千个文件.

