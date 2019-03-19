---
title: pgsql update set ambiguous column
tags:
  - pgsql
p: db/007-pgsql-updateset-ambiguous-column
date: 2019-03-19 17:27:51
---

本文从一个问题出发，引申出pgsql的隐藏信息。

# 问题
执行下面的sql：
```sql
insert into region (region, cloud_uuid, controllerinfo,createTime, is_select )
values ('r','c','cc',now(),'1')
ON CONFLICT("cloud_uuid","region") DO UPDATE SET
  region='r',cloud_uuid='c',
  controllerinfo='cc',createTime=now(),
  is_select=(case when is_select='0' then '0' else '1' end);
```
然后：
```
[42702] ERROR: column reference "is_select" is ambiguous
```

# 原因
很明显，when后面的is_select被多个表引用，源于这是一个插入更新，会把原来的数据和要插入的数据分开:
```
ON CONFLICT DO UPDATE中的SET和WHERE子句可以使用表的名称（或别名）访问现有行，
并使用excluded表访问将要插入的行。
```
所以： 访问要插入数据，使用excluded.columnxxx, 访问原来的数据，使用表或其别名.columnxxx

[column-reference-is-ambiguous-when-upserting-element-into-table](https://dba.stackexchange.com/questions/161127/column-reference-is-ambiguous-when-upserting-element-into-table)

# 解决
确定自己要引用的表，我这里是原来的表。
```sql
insert into region (region, cloud_uuid, controllerinfo,createTime, is_select )
values ('r','c','cc',now(),'1')
ON CONFLICT("cloud_uuid","region") DO UPDATE SET
  region='r',cloud_uuid='c',
  controllerinfo='cc',createTime=now(),
  is_select=(case when region.is_select='0' then '0' else '1' end);
```


