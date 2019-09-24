---
title: mysql decimal用法与问题
tags:
  - mysql
p: db/011-mysql-decimal
date: 2019-09-24 09:01:32
---

推荐用decimal来存数字，为什么？

# 数字类型decimal

[https://dev.mysql.com/doc/refman/5.6/en/fixed-point-types.html](https://dev.mysql.com/doc/refman/5.6/en/fixed-point-types.html)

`DECIMAL`和`NUMERIC`类型存储精确的数值数据值。当保留精确度非常重要时，例如使用货币数据，则使用这些类型。在MySQL中，NUMERIC被实现为DECIMAL，因此以下有关DECIMAL的说明同样适用于NUMERIC。

MySQL以`二进制格式`存储DECIMAL值。

在DECIMAL列声明中，可以（通常是）指定精度和小数位数。例如：
```s
salary DECIMAL(5,2)
```

在此示例中，5是精度，2是小数位。精度表示值存储的有效位数，小数位表示小数点后可存储的位数。

标准SQL要求DECIMAL（5,2）能够存储具有五位数字和两个小数的任何值，因此可以存储在薪水列中的值的范围是 **`-999.99`到`999.99`**。

在标准SQL中，语法DECIMAL（M）等效于DECIMAL（M，0）。同样，语法DECIMAL等效于DECIMAL（M，0），其中允许实现决定M的值。MySQL支持DECIMAL语法的这两种变体形式。 **M的默认值为10**。

如果小数位数为0，则DECIMAL值不包含小数点或小数部分。

DECIMAL的最大位数为65，但是给定DECIMAL列的实际范围可能受给定列的精度或小数位数的限制。如果为这样的列分配的值在小数点后的位数比指定刻度允许的位数多，则该值将转换为该刻度。 （精确的行为是特定于操作系统的，但是通常效果是将其截断为允许的位数。）

> 简单一句话：decimal(M,N)总共能存M位数，其中N位小数，剩下M-N位整数

如果有兴趣，可以研究下存储格式：[https://dev.mysql.com/doc/refman/5.6/en/precision-math-decimal-characteristics.html](https://dev.mysql.com/doc/refman/5.6/en/precision-math-decimal-characteristics.html)

# 场景

1. 存储金钱
2. 存储经纬度：[https://blog.csdn.net/wangqing_12345/article/details/57416370](https://blog.csdn.net/wangqing_12345/article/details/57416370)

# 常见问题

加入 字段类型为 decimal(10,6), 存储的值为：`100.12`, 实际数据库为：`100.120000`,但是比较时可以直接拿`100.12`去比较，不存在double或float的小数漂移问题。

```sql
select * from tb where col = 100.12
```

