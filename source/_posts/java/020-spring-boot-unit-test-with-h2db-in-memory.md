---
title: spring-boot集成h2内存数据库进行单元测试
tags:
  - java
  - spring-boot
  - test
p: java/020-spring-boot-unit-test-with-h2db-in-memory
date: 2018-10-31 15:05:35
---
我们使用[h2内存数据库](http://www.h2database.com/html/features.html).然后集成在框架里。
以下是测试环境搭建过程：

# 加入h2依赖

```java
<dependency>
    <groupId>com.h2database</groupId>
    <artifactId>h2</artifactId>
    <scope>test</scope>
</dependency>
```

# 新增测试环境配置文件
复制一份`application-dev.yml`,重命名为：`application-test.yml`.内容只有数据库配置改变：
```java
spring:
  application:
    name: app
  #数据库连接
  datasource:
    url: jdbc:h2:mem:test;DB_CLOSE_DELAY=-1;MODE=PostgreSQL
#    url: jdbc:h2:mem:test;MODE=PostgreSQL;INIT=CREATE SCHEMA IF NOT EXISTS public;SCHEMA=public
    username:
    password:
    driverClassName: org.h2.Driver
    schema: classpath:sql/init-table.sql
    data: classpath:sql/data.sql

# mybatis xml配置
mybatis:
  config-location: classpath:mybatis-config.xml
  mapper-locations: classpath:mappers/**/*.xml
```

# 准备测试数据

看上面的配置文件，有一个初始数据表的sql：init-table.sql
```sql
drop table if exists asset;

create table asset (
  id serial ,
  name varchar(100),
  ip varchar(100),
  hostname varchar(100)
)
```

还有初始化数据的：data.sql:

```sql
insert into asset(name,ip,hostname) values('openstack','172.1.1.2','controller');
```

# 待测mapper
```java
@MapperScan(basePackages = {"com.jimo.mapper"})
@SpringBootApplication
public class TestDaoApplication {

	public static void main(String[] args) {
		SpringApplication.run(TestDaoApplication.class, args);
	}
}

public interface AssetMapper {
    void insert(Asset a);

	void delete(int id);

	List<Asset> selectAll();
}

public class Asset implements Serializable {

    private int id;

    private String ip;

    private String name;

    private String hostname;

    //getter/setter
}
```
对应的语句：
```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN" "http://mybatis.org/dtd/mybatis-3-mapper.dtd" >
<mapper namespace="com.jimo.mapper.AssetMapper">

    <delete id="delete">
        delete from asset where id=#{id}
    </delete>
    <insert id="insert">
        insert into asset(name,hostname,ip) set name=#{a.name},hostname=#{a.hostname},ip=#{a.ip}
    </insert>

    <select id="selectAll" resultType="com.jimo.model.Asset">
      SELECT  * from asset
    </select>

</mapper>
```

# 编写测试类

```java
@RunWith(SpringRunner.class)
// 使用测试环境配置
@ActiveProfiles("test")
// 不加载web环境，更快
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.NONE)
public class AssetMapperTest {

	@Autowired
	private AssetMapper mapper;

    @Test
    public void selectAll() {
        final List<Asset> assets = mapper.selectAll();
        assertEquals(1, assets.size());

        mapper.delete(1);
        assertEquals(0, mapper.selectAll().size());
    }
}
```
# 总结
h2内存数据库可以模拟多种数据库，但不是所有语法都满足，所以需要折中处理。

如果可以，还是使用一个测试的数据库环境最好。
