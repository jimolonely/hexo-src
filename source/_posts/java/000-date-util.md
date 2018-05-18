---
title: Java中日期常用操作
tags:
  - java
p: java/000-date-util
date: 2018-03-22 15:42:32
---
java中常用日期操作.

# 取得一年中的第几周
```java
final Calendar calendar = Calendar.getInstance();
calendar.setFirstDayOfWeek(Calendar.MONDAY);
calendar.setTime(new Date());
return calendar.get(Calendar.WEEK_OF_YEAR);
```
# 取得第几月
```java
final Calendar calendar = Calendar.getInstance();
calendar.setTime(new Date());
return calendar.get(Calendar.MONTH);
```
# 取得一周的起始日期
```java
/**
* 起的话offset=0,终的话offset=1
*/
String getDayOfWeek(int year, int week, int offset) {
    Calendar c = Calendar.getInstance();

    c.set(Calendar.YEAR, year);
    c.set(Calendar.WEEK_OF_YEAR, week + offset);
    c.setFirstDayOfWeek(Calendar.MONDAY);
    c.set(Calendar.DAY_OF_WEEK, c.getFirstDayOfWeek());
    c.set(Calendar.HOUR, 0);
    c.set(Calendar.MINUTE, 0);
    c.set(Calendar.SECOND, 0);

    return formatDate(c.getTime());
}
```
# 取得一个月的起始日期
```java
public static String getFirstDayOfMonth(int month) {
    Calendar c = Calendar.getInstance();
    c.set(Calendar.MONTH, month - 1);
    c.set(Calendar.DAY_OF_MONTH, 1);
    return formatDate(c.getTime());
}

public static String getLastDayOfMonth(int month) {
    Calendar c = Calendar.getInstance();
    c.set(Calendar.MONTH, month);
    c.set(Calendar.DAY_OF_MONTH, 0);
    return formatDate(c.getTime());
}
```
# 取得偏移日期
```java
public static String getDateBefore(int distanceDay) {
    SimpleDateFormat dft = new SimpleDateFormat("yyyy-MM-dd");
    Date beginDate = new Date();
    Calendar date = Calendar.getInstance();
    date.setTime(beginDate);
    date.set(Calendar.DATE, date.get(Calendar.DATE) + distanceDay);
    Date endDate = null;
    try {
        endDate = dft.parse(dft.format(date.getTime()));
    } catch (ParseException e) {
        e.printStackTrace();
    }
    return dft.format(endDate);
}
```