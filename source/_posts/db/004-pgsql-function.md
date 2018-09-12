---
title: pgsql函数(存储过程)
tags:
  - pgsql
p: db/004-pgsql-function
date: 2018-09-11 12:47:47
---

pgsql里的函数就是存储过程，触发器会用到函数。

# 函数
```sql
CREATE OR REPLACE FUNCTION code_trigger_func1() RETURNS INT AS $$
DECLARE
	code VARCHAR;
	table_exist VARCHAR;
	sql_temp VARCHAR;
	t_name varchar;
BEGIN
	code := 'c00001';
	t_name := 'j_test_'||code;
-- 	code := NEW.code;
	-- 判断是否存在对应的表，否则新建,需要重建索引和主键
	select to_regclass(t_name) into table_exist;
	if table_exist is NULL THEN
-- 		create table xxxx() INHERITS old_table;
-- 		alter table xxxx add CONSTRAINT cons_xxxx PRIMARY KEY(id); 
		sql_temp := 'create table '||t_name||'() inherits (j_code);';
		EXECUTE(sql_temp);
		sql_temp := 'alter table '||t_name||' add CONSTRAINT j_cons_'||t_name||' PRIMARY KEY(code);';
		EXECUTE(sql_temp);
		raise notice 'existin: %', table_exist;
		raise notice 'table : % created', t_name;
	ELSE
		raise notice 'exist: %',table_exist;
	END IF;
	return 1;
END;
$$ LANGUAGE plpgsql;
```

# 一些常见问题
## 单引号嵌套
要在单引号里打印出单引号，比如`raise notice 'xxxx'`

正确写法：
```
'''yes''' --> 'yes'
```
也就是不是用`/`转义，而是用单引号转义.

## array_append
追加数据需要返回数组，否则报错：
```
arr := array_append(arr, 'ele');
```
打印数组：
```
raise notice '%s',array_to_string(arr, ',');
```



# 参考


