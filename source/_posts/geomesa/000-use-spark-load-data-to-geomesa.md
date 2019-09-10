---
title: 使用spark加载数据到geomesa
tags:
  - java
  - spark
  - geomesa
p: geomesa/000-use-spark-load-data-to-geomesa
date: 2019-09-10 08:06:23
---

本文做个加载数据的笔记。

# 建一张表

注意里面的geo_mbr是Point类型，也就是点坐标。
```sql
create table tb_test(
  province_name string:index=true,
  province_code string:index=true,
  city_name string,
  city_code string,
  county_name string,
  county_code string,
  geo_mbr Point:index=true:srid=4326,
  hab_index double,
  work_index double,
  visit_index double,
  pop_index double,
  etl_date Date,
  version string
)
```

# 


```sql
```

```sql
```

```sql
```

```sql
```

