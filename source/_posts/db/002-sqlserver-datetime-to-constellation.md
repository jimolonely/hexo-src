---
title: sqlserver中生日转星座
tags:
  - sqlserver
p: db/002-sqlserver-datetime-to-constellation
date: 2018-04-14 15:03:56
---
sqlserver中日期转星座.

# 开始
基本思想是先把日期转为字符串,再截取月份和天日.
```sql
select top 10 student_id,name,birthday,
constellation = CASE 
  WHEN SUBSTRING(CONVERT(VARCHAR, birthday, 112),5,4) BETWEEN 1222 AND 1231 OR SUBSTRING(CONVERT(VARCHAR, birthday, 112),5,4) BETWEEN 101 AND 119 THEN '魔羯座'  
  WHEN SUBSTRING(CONVERT(VARCHAR, birthday, 112),5,4) BETWEEN 120 AND 218 THEN '水瓶座'
  WHEN SUBSTRING(CONVERT(VARCHAR, birthday, 112),5,4) BETWEEN 219 AND 320 THEN '双鱼座'
  WHEN SUBSTRING(CONVERT(VARCHAR, birthday, 112),5,4) BETWEEN 321 AND 420 THEN '牡羊座'
  WHEN SUBSTRING(CONVERT(VARCHAR, birthday, 112),5,4) BETWEEN 421 AND 520 THEN '金牛座'
  WHEN SUBSTRING(CONVERT(VARCHAR, birthday, 112),5,4) BETWEEN 521 AND 621 THEN '双子座'
  WHEN SUBSTRING(CONVERT(VARCHAR, birthday, 112),5,4) BETWEEN 622 AND 722 THEN '巨蟹座'
  WHEN SUBSTRING(CONVERT(VARCHAR, birthday, 112),5,4) BETWEEN 723 AND 822 THEN '狮子座'
  WHEN SUBSTRING(CONVERT(VARCHAR, birthday, 112),5,4) BETWEEN 823 AND 922 THEN '处女座'  
  WHEN SUBSTRING(CONVERT(VARCHAR, birthday, 112),5,4) BETWEEN 923 AND 1022 THEN '天秤座'
  WHEN SUBSTRING(CONVERT(VARCHAR, birthday, 112),5,4) BETWEEN 1023 AND 1121 THEN '天蝎座'  
  WHEN SUBSTRING(CONVERT(VARCHAR, birthday, 112),5,4) BETWEEN 1122 AND 1221 THEN '射手座' 
END 
from students
```
结果:
{% asset_img 000.png %}

备注: 
关于```CONVERT(VARCHAR, birthday, 112)```可以参考{% post_link db/001-sqlserver-datetime-to-string 另一篇文章%}