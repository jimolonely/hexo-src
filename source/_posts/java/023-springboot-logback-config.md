---
title: spring-boot logback日志配置
tags:
  - java
  - spring
  - log
p: java/023-springboot-logback-config
date: 2019-01-18 13:44:06
---

参考[文档](https://logback.qos.ch/manual/appenders.html#SizeBasedTriggeringPolicy)

看一下常用配置：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration scan="true" scanPeriod="60 seconds" debug="false">

    <contextName>route-log</contextName>

    <property name="logback.logdir" value="/var/log/xxx"/>
    <property name="logback.appname" value="xxx-app"/>

    <!--输出到控制台 ConsoleAppender-->
    <appender name="consoleLog" class="ch.qos.logback.core.ConsoleAppender">
        <!--展示格式 layout-->
        <layout class="ch.qos.logback.classic.PatternLayout">
            <pattern>
                <pattern>%d %-5level [%thread] %logger{36} %line - %msg%n</pattern>
            </pattern>
        </layout>
        <filter class="ch.qos.logback.classic.filter.ThresholdFilter">
             <level>INFO</level>
        </filter>
    </appender>

    <!--Info以及以上的日志-->
    <appender name="fileInfoUpLog" class="ch.qos.logback.core.rolling.RollingFileAppender">
        <!--如果只是想要 Info 级别的日志，只是过滤 info 还是会输出 Error 日志，因为 Error 的级别高，
        所以我们使用下面的策略，可以避免输出 Error 的日志-->

        <!--<filter class="ch.qos.logback.classic.filter.LevelFilter">-->
            <!--&lt;!&ndash;过滤 Error&ndash;&gt;-->
            <!--<level>ERROR</level>-->
            <!--&lt;!&ndash;匹配到就禁止&ndash;&gt;-->
            <!--<onMatch>DENY</onMatch>-->
            <!--&lt;!&ndash;没有匹配到就允许&ndash;&gt;-->
            <!--<onMismatch>ACCEPT</onMismatch>-->
        <!--</filter>-->


        <filter class="ch.qos.logback.classic.filter.ThresholdFilter">
            <level>INFO</level>
        </filter>

        <!--日志名称，如果没有File 属性，那么只会使用FileNamePattern的文件路径规则
            如果同时有<File>和<FileNamePattern>，那么当天日志是<File>，明天会自动把今天
            的日志改名为今天的日期。即，<File> 的日志都是当天的。
        -->
        <File>${logback.logdir}/${logback.appname}.log</File>

        <rollingPolicy class="ch.qos.logback.core.rolling.SizeAndTimeBasedRollingPolicy">
            <!-- rollover monthly -->
            <fileNamePattern>${logback.logdir}/${logback.appname}-%d{yyyy-MM}.%i.log</fileNamePattern>
            <!-- each file should be at most 100MB, keep 30 days worth of history, but at most 200MB -->
            <maxFileSize>100MB</maxFileSize>
            <maxHistory>30</maxHistory>
            <totalSizeCap>200MB</totalSizeCap>
        </rollingPolicy>

        <!--日志输出编码格式化-->
        <encoder>
            <charset>UTF-8</charset>
            <pattern>%d %-5level [%thread] %logger{36} %line - %msg%n</pattern>
        </encoder>
    </appender>


    <!--<appender name="fileErrorLog" class="ch.qos.logback.core.rolling.RollingFileAppender">-->
        <!--&lt;!&ndash;如果只是想要 Error 级别的日志，那么需要过滤一下，默认是 info 级别的，ThresholdFilter&ndash;&gt;-->
        <!--<filter class="ch.qos.logback.classic.filter.ThresholdFilter">-->
            <!--<level>Error</level>-->
        <!--</filter>-->
        <!--&lt;!&ndash;日志名称，如果没有File 属性，那么只会使用FileNamePattern的文件路径规则-->
            <!--如果同时有<File>和<FileNamePattern>，那么当天日志是<File>，明天会自动把今天-->
            <!--的日志改名为今天的日期。即，<File> 的日志都是当天的。-->
        <!--&ndash;&gt;-->
        <!--<File>${logback.logdir}/error.${logback.appname}.log</File>-->
        <!--&lt;!&ndash;滚动策略，按照时间滚动 TimeBasedRollingPolicy&ndash;&gt;-->
        <!--<rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">-->
            <!--&lt;!&ndash;文件路径,定义了日志的切分方式——把每一天的日志归档到一个文件中,以防止日志填满整个磁盘空间&ndash;&gt;-->
            <!--<FileNamePattern>${logback.logdir}/error.${logback.appname}.%d{yyyy-MM-dd}.log</FileNamePattern>-->
            <!--&lt;!&ndash;只保留最近90天的日志&ndash;&gt;-->
            <!--<maxHistory>90</maxHistory>-->
            <!--&lt;!&ndash;用来指定日志文件的上限大小，那么到了这个值，就会删除旧的日志&ndash;&gt;-->
            <!--&lt;!&ndash;<totalSizeCap>1GB</totalSizeCap>&ndash;&gt;-->
        <!--</rollingPolicy>-->
        <!--&lt;!&ndash;日志输出编码格式化&ndash;&gt;-->
        <!--<encoder>-->
            <!--<charset>UTF-8</charset>-->
            <!--<pattern>%d [%thread] %-5level %logger{36} %line - %msg%n</pattern>-->
        <!--</encoder>-->
    <!--</appender>-->

    <!--指定最基础的日志输出级别-->
    <root level="INFO">
        <!--appender将会添加到这个loger-->
        <appender-ref ref="consoleLog"/>
        <appender-ref ref="fileInfoUpLog"/>
        <!--<appender-ref ref="fileErrorLog"/>-->
    </root>
</configuration>
```
假如要压缩，达到一定大小后压缩，直接改文件名即可：

```xml
<appender name="FILE"
    class="ch.qos.logback.core.rolling.RollingFileAppender">
    <File>${LOGDIR}/filename.log</File>
    <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
        <!-- rollover daily -->
        <FileNamePattern>${LOGDIR}/file.%d{yyyy-MM-dd}.%i.log.gz
        </FileNamePattern>
        <!-- keep 30 days' worth of history -->
        <MaxHistory>30</MaxHistory>
        <!-- or whenever the file size reaches 10MB -->
        <timeBasedFileNamingAndTriggeringPolicy
            class="ch.qos.logback.core.rolling.SizeAndTimeBasedFNATP">
            <maxFileSize>10MB</maxFileSize>
        </timeBasedFileNamingAndTriggeringPolicy>
    </rollingPolicy>
    <encoder class="ch.qos.logback.classic.encoder.PatternLayoutEncoder">
        <Pattern>%date [%thread] %-5level %logger{36} - %msg%n
        </Pattern>
    </encoder>
</appender>
```
上面的代码将在当天压缩文件, 如果日志文件大小超过10MB。

