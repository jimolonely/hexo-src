---
title: mybatis+pgsql返回插入(更新)后的主键id
tags:
  - java
  - mybatis
  - pgsql
p: java/mybatis-pgsql-return-insert-id
date: 2019-07-24 19:55:39
---

当需要返回插入后的主键id时，需要特别注意。

# pgsql返回插入id
在pgsql中存在相应的语法，在插入后，可以返回一个列的值：即`returning id`
```sql
insert into api(id, uri, method_id, type, "desc", ignore_param, project_id)
values (4, '/test', 1, 'normal', null, false, 1)
returning id;
```

然后，在mybatis的xml中这样是行不通的：

# mybatis+pgsql

```xml
    <insert id="addOrUpdate">
        insert into api(uri, method_id, type, "desc", ignore_param, project_id)
        values ( #{api.uri}, #{api.methodId}, #{api.type}, #{api.desc}, #{api.ignoreParam}, #{api.projectId})
        returning id
    </insert>
```
```java
int addOrUpdate(@Param("api") Api api);
```
这样返回的依然是更新条数1.

因为mybatis的插入语句的返回值不是这样的，需要人家的方法才行：

```xml
    <insert id="addOrUpdate" useGeneratedKeys="true" keyProperty="id">
        insert into api(uri, method_id, type, "desc", ignore_param, project_id)
        values (#{api.uri}, #{api.methodId}, #{api.type}, #{api.desc}, #{api.ignoreParam}, #{api.projectId})
    </insert>
```
也就是使用：`useGeneratedKeys="true" keyProperty="id"`, 注意，这个`keyProperty="id"`里的id是要返回的主键列，和实体类的属性要对应。

于是，调用的java
代码变成了这样：
```java
Api api = new Api();
dao.addOrUpdate(api);
int id = api.getId();
```

# 插入或更新操作

再附一个重复id就更新的情况，如果id是0，代表插入：
```xml
    <insert id="addOrUpdate" useGeneratedKeys="true" keyProperty="id">
        insert into api(id, uri, method_id, type, "desc", ignore_param, project_id)
        values (
        <choose>
            <when test="api.id == 0">
                nextval('api_id_seq')
            </when>
            <otherwise>
                #{api.id}
            </otherwise>
        </choose>
        , #{api.uri}, #{api.methodId}, #{api.type}, #{api.desc}, #{api.ignoreParam}, #{api.projectId})
        on conflict (id) do update set uri=#{api.uri},
        method_id=#{api.methodId},
        type=#{api.type},
        "desc"=#{api.desc},
        ignore_param= #{api.ignoreParam},
        project_id= #{api.projectId}
    </insert>
```

参考：[https://cofcool.github.io/tech/2017/11/06/Mybatis-insert-get-id](https://cofcool.github.io/tech/2017/11/06/Mybatis-insert-get-id)



