---
title: sqlserver中datetime转string
tags:
  - sqlserver
p: db/001-sqlserver-datetime-to-string
date: 2018-04-14 14:48:39
---
sqlserver中datetime转string.

# 解决
在[stackoverflow](https://stackoverflow.com/questions/74385/how-to-convert-datetime-to-varchar?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa)上很容易找到答案:
```sql
DECLARE @myDateTime DATETIME
SET @myDateTime = '2008-05-03 00:00:00'
SELECT CONVERT(VARCHAR, @myDateTime, 112) --20080503
```
# 更多的代码意思
```sql
DECLARE @now datetime
SET @now = GETDATE()
select convert(nvarchar(MAX), @now, 0) as output, 0 as style 
union select convert(nvarchar(MAX), @now, 1), 1
union select convert(nvarchar(MAX), @now, 2), 2
union select convert(nvarchar(MAX), @now, 3), 3
union select convert(nvarchar(MAX), @now, 4), 4
union select convert(nvarchar(MAX), @now, 5), 5
union select convert(nvarchar(MAX), @now, 6), 6
union select convert(nvarchar(MAX), @now, 7), 7
union select convert(nvarchar(MAX), @now, 8), 8
union select convert(nvarchar(MAX), @now, 9), 9
union select convert(nvarchar(MAX), @now, 10), 10
union select convert(nvarchar(MAX), @now, 11), 11
union select convert(nvarchar(MAX), @now, 12), 12
union select convert(nvarchar(MAX), @now, 13), 13
union select convert(nvarchar(MAX), @now, 14), 14
--15 to 19 not valid
union select convert(nvarchar(MAX), @now, 20), 20
union select convert(nvarchar(MAX), @now, 21), 21
union select convert(nvarchar(MAX), @now, 22), 22
union select convert(nvarchar(MAX), @now, 23), 23
union select convert(nvarchar(MAX), @now, 24), 24
union select convert(nvarchar(MAX), @now, 25), 25
--26 to 99 not valid
union select convert(nvarchar(MAX), @now, 100), 100
union select convert(nvarchar(MAX), @now, 101), 101
union select convert(nvarchar(MAX), @now, 102), 102
union select convert(nvarchar(MAX), @now, 103), 103
union select convert(nvarchar(MAX), @now, 104), 104
union select convert(nvarchar(MAX), @now, 105), 105
union select convert(nvarchar(MAX), @now, 106), 106
union select convert(nvarchar(MAX), @now, 107), 107
union select convert(nvarchar(MAX), @now, 108), 108
union select convert(nvarchar(MAX), @now, 109), 109
union select convert(nvarchar(MAX), @now, 110), 110
union select convert(nvarchar(MAX), @now, 111), 111
union select convert(nvarchar(MAX), @now, 112), 112
union select convert(nvarchar(MAX), @now, 113), 113
union select convert(nvarchar(MAX), @now, 114), 114
union select convert(nvarchar(MAX), @now, 120), 120
union select convert(nvarchar(MAX), @now, 121), 121
--122 to 125 not valid
union select convert(nvarchar(MAX), @now, 126), 126
union select convert(nvarchar(MAX), @now, 127), 127
--128, 129 not valid
union select convert(nvarchar(MAX), @now, 130), 130
union select convert(nvarchar(MAX), @now, 131), 131
--132 not valid
order BY style
```
结果:
```sql
output                   style
Apr 28 2014  9:31AM          0
04/28/14                     1
14.04.28                     2
28/04/14                     3
28.04.14                     4
28-04-14                     5
28 Apr 14                    6
Apr 28, 14                   7
09:31:28                     8
Apr 28 2014  9:31:28:580AM   9
04-28-14                     10
14/04/28                     11
140428                       12
28 Apr 2014 09:31:28:580     13
09:31:28:580                 14
2014-04-28 09:31:28          20
2014-04-28 09:31:28.580      21
04/28/14  9:31:28 AM         22
2014-04-28                   23
09:31:28                     24
2014-04-28 09:31:28.580      25
Apr 28 2014  9:31AM          100
04/28/2014                   101
2014.04.28                   102
28/04/2014                   103
28.04.2014                   104
28-04-2014                   105
28 Apr 2014                  106
Apr 28, 2014                 107
09:31:28                     108
Apr 28 2014  9:31:28:580AM   109
04-28-2014                   110
2014/04/28                   111
20140428                     112
28 Apr 2014 09:31:28:580     113
09:31:28:580                 114
2014-04-28 09:31:28          120
2014-04-28 09:31:28.580      121
2014-04-28T09:31:28.580      126
2014-04-28T09:31:28.580      127
28 جمادى الثانية 1435  9:31:28:580AM    130
28/06/1435  9:31:28:580AM    131
```
然后根据自己需要选择就行了.

