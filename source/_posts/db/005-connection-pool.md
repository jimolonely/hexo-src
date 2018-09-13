---
title: 数据库连接池那些事
tags:
  - sql
p: db/005-connection-pool
date: 2018-09-13 14:22:49
---

数据库连接池必备知识。

# 基本概念
这还用说吗？

# 常见连接池
## HikariCP
```yml
spring:
  #数据库连接
  datasource:
    driver-class-name: org.postgresql.Driver
    url: jdbc:postgresql://xxx/db?charSet=utf-8
    username: root
    password: root
    # spring-boot2.0 默认连接池
    hikari:
      idle-timeout: 1200000 # 20min
      connection-timeout: 30000
      max-lifetime: 3600000 # 1h
      validation-timeout: 20000
      maximum-pool-size: 30
````
[详细配置看github](https://github.com/brettwooldridge/HikariCP#configuration-knobs-baby)

[看别人翻译的](http://www.zhz.gift/2018/01/30/HikariCP%20%E9%85%8D%E7%BD%AE%E8%AF%B4%E6%98%8E/)

## DBCP
```sql
dataSource: 要连接的 datasource (通常我们不会定义在 server.xml)
defaultAutoCommit: 对于事务是否 autoCommit, 默认值为 true
defaultReadOnly: 对于数据库是否只能读取, 默认值为 false
driverClassName:连接数据库所用的 JDBC Driver Class
maxActive: 可以从对象池中取出的对象最大个数，为0则表示没有限制，默认为8
maxIdle: 最大等待连接中的数量,设 0 为没有限制 （对象池中对象最大个数）
minIdle：对象池中对象最小个数
maxWait: 最大等待秒数, 单位为 ms, 超过时间会丟出错误信息
password: 登陆数据库所用的密码
url: 连接数据库的 URL
username: 登陆数据库所用的帐号
validationQuery: 验证连接是否成功, SQL SELECT 指令至少要返回一行
removeAbandoned: 是否自我中断, 默认是 false
removeAbandonedTimeout: 几秒后会自我中断, removeAbandoned 必须为 true
logAbandoned: 是否记录中断事件, 默认为 false
minEvictableIdleTimeMillis：大于0 ，进行连接空闲时间判断，或为0，对空闲的连接不进行验证；默认30分钟
timeBetweenEvictionRunsMillis：失效检查线程运行时间间隔，如果小于等于0，不会启动检查线程，默认-1
testOnBorrow：取得对象时是否进行验证，检查对象是否有效，默认为fals
etestOnReturn：返回对象时是否进行验证，检查对象是否有效，默认为false
testWhileIdle：空闲时是否进行验证，检查对象是否有效，默认为false
initialSize：初始化线程数
```
## C3P0
```
acquireIncrement: 当连接池中的连接耗尽的时候c3p0一次同时获取的连接数。Default: 3
acquireRetryAttempts: 定义在从数据库获取新连接失败后重复尝试的次数。Default: 30
acquireRetryDelay: 两次连接中间隔时间，单位毫秒。Default: 1000
autoCommitOnClose: 连接关闭时默认将所有未提交的操作回滚。Defaul t: false
automaticTestTable: c3p0将建一张名为Test的空表，并使用其自带的查询语句进行测试。如果定义了这个参数那么属性preferredTestQuery将被忽略。你不 能在这张Test表上进行任何操作，它将只供c3p0测试使用。Default: null
breakAfterAcquireFailure: 获取连接失败将会引起所有等待连接池来获取连接的线程抛出异常。但是数据源仍有效保留，并在下次调用getConnection()的时候继续尝试获取连 接。如果设为true，那么在尝试获取连接失败后该数据源将申明已断开并永久关闭。Default: false
checkoutTimeout：当连接池用完时客户端调用getConnection()后等待获取新连接的时间，超时后将抛出SQLException,如设为0则无限期等待。单位毫秒。Default: 0
connectionTesterClassName: 通过实现ConnectionTester或QueryConnectionT ester的类来测试连接。类名需制定全路径。Default: com.mchange.v2.c3p0.impl.Def aultConnectionTester
factoryClassLocation: 指定c3p0 libraries的路径，如果（通常都是这样）在本地即可获得那么无需设置，默认null即可Default: null
idleConnectionTestPeriod: 每60秒检查所有连接池中的空闲连接。Defaul t: 0
initialPoolSize: 初始化时获取三个连接，取值应在minPoolSize与maxPoolSize之间。Default: 3
maxIdleTime: 最大空闲时间,60秒内未使用则连接被丢弃。若为0则永不丢弃。Default: 0
maxPoolSize: 连接池中保留的最大连接数。Default: 15
maxStatements: JDBC的标准参数，用以控制数据源内加载的PreparedSt atements数量。但由于预缓存的statements属于单个connection而不是整个连接池。所以设置这个参数需要考虑到多方面的因素。如 果maxStatements与maxStatementsPerConnection均为0，则缓存被关闭。Default: 0
maxStatementsPerConnection: maxStatementsPerConnection定义了连接池内单个连接所拥有的最大缓存statements数。Default: 0
numHelperThreads：c3p0是异步操作的，缓慢的JDBC操作通过帮助进程完成。扩展这些操作可以有效的提升性能通过多线程实现多个操作同时被执行。Default: 3
overrideDefaultUser：当用户调用getConnection()时使root用户成为去获取连接的用户。主要用于连接池连接非c3p0的数据源时。Default: null
overrideDefaultPassword：与overrideDefaultUser参数对应使用的一个参数。Default: null
password：密码。Default: null
user：用户名。Default: null
preferredTestQuery：定义所有连接测试都执行的测试语句。在使用连接测试的情况下这个一显著提高测试速度。注意：测试的表必须在初始数据源的时候就存在。Default: null
propertyCycle：用户修改系统配置参数执行前最多等待300秒。Defaul t: 300
testConnectionOnCheckout：因性能消耗大请只在需要的时候使用它。如果设为true那么在每个connection提交 的时候都将校验其有效性。建议使用idleConnectio nTestPeriod或automaticTestTable等方法来提升连接测试的性能。Default: false
testConnectionOnCheckin：如果设为true那么在取得连接的同时将校验连接的有效性。Default: false
```
## BoneCP
```
acquireIncrement: 当连接池中的连接耗尽的时候c3p0一次同时获取的连接数。Default: 3
driveClass:数据库驱动
jdbcUrl:响应驱动的jdbcUrl
username:数据库的用户名
password:数据库的密码
idleConnectionTestPeriod:检查数据库连接池中控线连接的间隔时间，单位是分，默认值：240，如果要取消则设置为0
idleMaxAge:连接池中未使用的链接最大存活时间，单位是分，默认值：60，如果要永远存活设置为0
maxConnectionsPerPartition:每个分区最大的连接数
minConnectionsPerPartition:每个分区最小的连接数
partitionCount:分区数，默认值2，最小1，推荐3-4，视应用而定
acquireIncrement:每次去拿数据库连接的时候一次性要拿几个，默认值：2
statementsCacheSize:缓存prepared statements的大小，默认值：0
releaseHelperThreads:每个分区释放链接助理进程的数量，默认值：3，除非你的一个数据库连接的时间内做了很多工作，不然过多的助理进程会影响你的性能
```
## Druid
[https://github.com/alibaba/druid/wiki/DruidDataSource%E9%85%8D%E7%BD%AE%E5%B1%9E%E6%80%A7%E5%88%97%E8%A1%A8](https://github.com/alibaba/druid/wiki/DruidDataSource%E9%85%8D%E7%BD%AE%E5%B1%9E%E6%80%A7%E5%88%97%E8%A1%A8)
