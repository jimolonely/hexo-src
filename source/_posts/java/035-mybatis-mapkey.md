---
title: mybatis中的mapkey
tags:
  - java
  - mybatis
p: java/035-mybatis-mapkey
date: 2019-03-15 10:21:50
---

mybatis中有一个注解，虽然不能满足要求，但可以将就。

# 问题
有如下sql：
```xml
select service_role, count(asset_id) from asset_role group by service_role;
```
结果如下：
{% asset_img 001.png %}

本来想使用如下方法映射：
```java
Map<String, Integer> groupByServiceRole();

assertEquals(2, (long) map2.get("hadoop"));
assertEquals(1, (long) map2.get("spark"));
```
然而完全不是这样。这样返回的value还是个map。

# mapkey
使用了mapkey注解后，返回的key还是个map，结果如下：

{% asset_img 000.png %}

这样也好办，多加一级map：

```java
@MapKey("service_role")
Map<String, Map<String, Object>> groupByServiceRole();

Map<String, Map<String, Object>> map2 = dao.groupByServiceRole();
assertEquals(2, (long) map2.get("hadoop").get("count"));
assertEquals(1, (long) map2.get("spark").get("count"));
```
