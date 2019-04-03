---
title: quartz初次使用踩坑记
tags:
  - java
  - quartz
p: java/041-quartz-problems
date: 2019-04-03 08:53:48
---

# 1.日志问题
一开始，导入quartz的包：
```xml
        <dependency>
            <groupId>org.quartz-scheduler</groupId>
            <artifactId>quartz</artifactId>
            <version>2.2.1</version>
        </dependency>
```
然后会发现日志无法打印：
```java
SLF4J: Failed to load class "org.slf4j.impl.StaticLoggerBinder".
SLF4J: Defaulting to no-operation (NOP) logger implementation
SLF4J: See http://www.slf4j.org/codes.html#StaticLoggerBinder for further details.
```
原因是没有slf4j的实现， quartz的pom包里只引入了api的包，没有实现：
```xml
    <dependency>
      <groupId>org.slf4j</groupId>
      <artifactId>slf4j-api</artifactId>
      <version>1.6.6</version>
      <scope>compile</scope>
    </dependency>
```
解决办法： 根据quartz版本的不同对应的slf4j的版本也不同，加入对应的实现包即可：
```xml
        <dependency>
            <groupId>org.slf4j</groupId>
            <artifactId>slf4j-simple</artifactId>
            <version>1.6.6</version>
        </dependency>
```
# 2.Job的可见性
一开始是这样：
```java
public class Lesson1 {

    public static void main(String[] args) throws SchedulerException {
        StdSchedulerFactory factory = new StdSchedulerFactory();
        Scheduler scheduler = factory.getScheduler();

        JobDetail jobDetail = newJob(HelloJob.class).withIdentity("myJob", "group1").build();

        SimpleTrigger trigger = newTrigger()
                .withIdentity("myTrigger", "group1")
                .startNow()
                .withSchedule(SimpleScheduleBuilder.simpleSchedule().withIntervalInSeconds(1).repeatForever())
                .build();

        scheduler.scheduleJob(jobDetail, trigger);

        scheduler.start();
    }

    class HelloJob implements Job {

        HelloJob() {
        }

        public void execute(JobExecutionContext jobExecutionContext) throws JobExecutionException {
            System.out.println("now is: " + System.currentTimeMillis());
        }
    }
}
```
然后运行就报错：
```java
139 [main] INFO org.quartz.impl.StdSchedulerFactory - Quartz scheduler version: 2.2.1
208 [MyScheduler_QuartzSchedulerThread] ERROR org.quartz.core.ErrorLogger - An error occured instantiating job to be executed. job= 'group1.myJob'
org.quartz.SchedulerException: Problem instantiating class 'com.jimo.Lesson1$HelloJob' [See nested exception: java.lang.InstantiationException: com.jimo.Lesson1$HelloJob]
	at org.quartz.simpl.SimpleJobFactory.newJob(SimpleJobFactory.java:58)
	at org.quartz.simpl.PropertySettingJobFactory.newJob(PropertySettingJobFactory.java:69)
	at org.quartz.core.JobRunShell.initialize(JobRunShell.java:127)
	at org.quartz.core.QuartzSchedulerThread.run(QuartzSchedulerThread.java:375)
Caused by: java.lang.InstantiationException: com.jimo.Lesson1$HelloJob
	at java.lang.Class.newInstance(Class.java:427)
	at org.quartz.simpl.SimpleJobFactory.newJob(SimpleJobFactory.java:56)
	... 3 more
Caused by: java.lang.NoSuchMethodException: com.jimo.Lesson1$HelloJob.<init>()
	at java.lang.Class.getConstructor0(Class.java:3082)
	at java.lang.Class.newInstance(Class.java:412)
	... 4 more
```
一查资料，发现是需要HelloJob为public的，改了之后依然报错。

解决办法：将HelloJob移到单独的java文件。并且是public的。


# Trigger类型

## SimpleTrigger

掌握核心概念：
1. 开始时间
2. 结束时间
3. 执行次数
4. 执行间隔
5. 错过策略

下面代码展示了所有：
```java
  newTrigger()
          .withIdentity("t1", "g1")
          .startAt(futureDate(5, DateBuilder.IntervalUnit.SECOND))
          .endAt(dateOf(10, 0, 0))
          .withSchedule(simpleSchedule()
                  .withRepeatCount(10)
                  .withIntervalInSeconds(2)
                  .withMisfireHandlingInstructionFireNow()
          )
          .forJob("job1", "g1")
          .build();
```
## CronTrigger
熟悉linux的cron当然很简单：

1. 开始、结束时间（可选）
2. Seconds
3. Minutes
4. Hours
5. Day-of-Month
6. Month（0-11，或者：JAN, FEB, MAR, APR, MAY, JUN, JUL, AUG, SEP, OCT, NOV, DEC）
7. Day-of-Week（ SUN, MON, TUE, WED, THU, FRI, SAT.或者： 1-7，1对应SUN）
8. Year (optional field)

或者，直接读CronTrigger的源码，注释里有很详细的例子。

有几个字符解释下：
1. `*` : 代表每（every），每天，每月，每年，是个正则符号
2. `?` : 用于`day-of-month , day-of-week`,代表不指定值，即当你指定了每周3执行，你不可能再指定每天或每个月的某一天嘛
3. `/,#,L,W` [请参考](http://www.quartz-scheduler.org/documentation/quartz-2.2.2/tutorials/tutorial-lesson-06.html)


https://docs.spring.io/spring-boot/docs/current/reference/html/boot-features-quartz.html

```java
```
```java
```
```java
```





