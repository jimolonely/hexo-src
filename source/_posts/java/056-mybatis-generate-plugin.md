---
title: mybatis生成插件
tags:
  - java
  - mybatis
p: java/056-mybatis-generate-plugin
date: 2019-08-01 18:11:37
---

记录下mybatis的使用记录，以及文档大概内容。很多博客只是草草提到，连官网都没找到。

其实一切都在[官网文档](http://www.mybatis.org/generator/index.html)里说的很详细。

下面说一下常用实践，避免每次都查找。

# 项目

基于spring-boot应用开发。

maven pom.xml
```xml
    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>

            <plugin>
                <groupId>org.mybatis.generator</groupId>
                <artifactId>mybatis-generator-maven-plugin</artifactId>
                <version>1.3.7</version>
                <configuration>
                    <!--配置文件的位置-->
                    <configurationFile>src/main/resources/generator/generatorConfig.xml</configurationFile>
                    <verbose>true</verbose>
                    <overwrite>true</overwrite>
                </configuration>
            </plugin>
        </plugins>
    </build>
```
generatorConfig.xml配置文件：
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE generatorConfiguration
        PUBLIC "-//mybatis.org//DTD MyBatis Generator Configuration 1.0//EN"
        "http://mybatis.org/dtd/mybatis-generator-config_1_0.dtd">
<generatorConfiguration>
    <classPathEntry location="/home/jack/文档/iad/postgresql-42.2.5.jar"/>
    <context id="DB2Tables" targetRuntime="MyBatis3">
        <commentGenerator>
            <property name="suppressDate" value="true"/>
            <property name="suppressAllComments" value="true"/>
        </commentGenerator>
        <jdbcConnection driverClass="org.postgresql.Driver"
                        connectionURL="jdbc:postgresql://IP:5432/db_name"
                        userId="xxx"
                        password="xxx">
        </jdbcConnection>
        <javaTypeResolver>
            <property name="forceBigDecimals" value="false"/>
        </javaTypeResolver>
        <javaModelGenerator targetPackage="com.xx.job.model" targetProject="src/main/java">
            <property name="enableSubPackages" value="false"/>
            <property name="trimStrings" value="true"/>
        </javaModelGenerator>
        <sqlMapGenerator targetPackage="mappers.job" targetProject="src/main/resources">
            <property name="enableSubPackages" value="true"/>
        </sqlMapGenerator>
        <javaClientGenerator type="XMLMAPPER" targetPackage="com.xx.job.dao" targetProject="src/main/java">
            <property name="enableSubPackages" value="false"/>
        </javaClientGenerator>

        <table tableName="user_day" domainObjectName="UserDay" modelType="flat"
               enableSelectByPrimaryKey="false" enableSelectByExample="false"
               enableCountByExample="false"
               enableDeleteByExample="false"  enableDeleteByPrimaryKey="false"
               ></table>
    </context>
</generatorConfiguration>
```
要做几个修改：

1. 下载jdbc驱动：/home/jack/文档/iad/postgresql-42.2.5.jar

2. 修改数据库连接信息

3. 修改生成文件包名：分为mapper的xml和dao类, 其中javaClientGenerator是可选的

4. 声明`<table>`，需要详细说明：[http://www.mybatis.org/generator/configreference/table.html](http://www.mybatis.org/generator/configreference/table.html)
    1. domainObjectName: 类名
    2. modelType: 如果不是flat，主键会被提成父类
    3. 其他控制xml里生成语句的多少，个人觉得insert和update保留就好

5. 运行方式：可以直接点击idea的maven插件运行，也可以命令行：[http://www.mybatis.org/generator/running/runningWithMaven.html](http://www.mybatis.org/generator/running/runningWithMaven.html)





