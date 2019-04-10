---
title: pgsql常用sql语句
tags:
  - sql
  - pgsql
p: db/008-pgsql-common-sqls
date: 2019-04-10 14:52:53
---

下面是一些常用pgsql的语句。

# 修改约束
采用3步走：
1. drop
2. 修改列
3. add

比如修改pgsql主键：
```sql
ALTER TABLE <table_name> DROP CONSTRAINT <table_name>_pkey;

ALTER TABLE <table_name> RENAME COLUMN <primary_key_candidate> TO id;

ALTER TABLE <table_name> ADD PRIMARY KEY (id);
```

1. 去掉null约束： `alter table xxx alter column xxxx drop not null;`
2. 更改类型： `alter table xxx alter column xxxx type varchar(100);`

# pgsql表间复制数据

```sql
Insert into Table2(field1,field2,…) select value1,value2,… from Table1
```


```sql

```
