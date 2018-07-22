---
title: pandas那些常用操作
tags:
  - python
  - pandas
p: python/007-use-pandas
date: 2018-04-15 11:33:00
---
pandas那些常用操作,不用不知道.

# groupby keep columns
就是经常需要按一列groupby,但是还想保留其他列.
之前:
```python
groupd  = df.groupby(['student_id'])
groupd = groupd.agg({'pmark':np.average})
groupd.head()
'''
pmark
53.827358
84.775641
81.977778
61.821591
55.774000
'''
```
之后:
```python
groupd  = df.groupby(['student_id'],as_index=False) # 保留列
groupd = groupd.agg({'pmark':np.average})
groupd.head()

'''
student_id	pmark
0	20122169	53.827358
1	20122639	84.775641
2	20130068	81.977778
3	20131649	61.821591
4	20131664	55.774000
'''
```
# value_counts()
计算DataFrame里某一列的值的个数:
```python
type(marks['sex'].value_counts())
# pandas.core.series.Series

sex_cnt = marks['sex'].value_counts()
dict(sex_cnt)
# {'女': 176, '男': 517}
```
# pandas条件选择
针对选择某些值满足条件的行
```python
# 大于90分为学霸
good = marks[marks['pmark']>90]
```
当需要判断某列的值是否在一个列表时可以用isin()
```python
code=['01','02']
dd = df[df['course_code'].isin(code)]
```

# 去重
[官网](https://pandas.pydata.org/pandas-docs/stable/generated/pandas.DataFrame.drop_duplicates.html),
可以指定列,否则为全部列.
```python
# 计算学院挂科人数
g = df[df['pmark']<60].drop_duplicates(subset=['student_id']).groupby('sex',as_index=False).agg({'pmark':'count'})
g.head()
```
# 给pandas增加列
```python
df = pandas.DataFrame.from_csv('my_data.csv')  # fake data
df['diff_A_B'] = df['A'] - df['B']

#or
df2 = df.assign(diff_col=df['A'] - df['B'])
```
更复杂一点,根据已有列且带有条件的生成:
```python
In [29]:
df['points'] = np.where( ( (df['gender'] == 'male') & (df['pet1'] == df['pet2'] ) ) | ( (df['gender'] == 'female') & (df['pet1'].isin(['cat','dog'] ) ) ), 5, 0)
df
'''
Out[29]:
     gender      pet1      pet2  points
0      male       dog       dog       5
1      male       cat       cat       5
2      male       dog       cat       0
3    female       cat  squirrel       5
4    female       dog       dog       5
5    female  squirrel       cat       0
6  squirrel       dog       cat       0
'''

# 或则
def f(x):
  if x['gender'] == 'male' and x['pet1'] == x['pet2']: return 5
  elif x['gender'] == 'female' and (x['pet1'] == 'cat' or x['pet1'] == 'dog'): return 5
  else: return 0

data['points'] = data.apply(f, axis=1)
```
# 删除pandas的列
pandas delete column.
```python
df = df.drop('column_name', 1) # 0代表维度行,1代表维度列
# or
df.drop(['column_name'], axis=1, inplace=True) # 就地
# or
df.drop(df.columns[[0, 1, 3]], axis=1)
```

# 重点学习groupby.apply()
[API](https://pandas.pydata.org/pandas-docs/stable/generated/pandas.core.groupby.GroupBy.apply.html)

例子1:将学生成绩数据按学号分组后把所有课程分数放在一个list里,再转为dict
```python
dd.groupby('student_id')['pmark'].apply(list).to_dict()
'''
{'001':[100,90,80],'002':[90,90,90]...}
'''
# or 直接转为list,返回二维数组
list(dd.groupby('student_id')['pmark'].apply(list))
```
# 迭代DataFrame
How to iterate over rows in a DataFrame in Pandas?
```python
In [18]: for index, row in df.iterrows():
   ....:     print row['c1'], row['c2']
```
# 列的字符串匹配
```python
# startswith
dataFrameOut = dataFrame[dataFrame['column name'].str.match('string')]
# contains
dataFrameOut = dataFrame[dataFrame['column name'].str.contains('string')]
```
# pandas如何处理数据库中blob保存的图片
会压缩成base64编码的字符串,解析遵循[]()标准.
```python
stu1['photo']
'''
0      /9j/4AAQSkZJRgABAQEAYABgAAD/2wBDAAgGBgcGBQgHBw...
1      /9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAgFBgcGBQgHBg...
2      /9j/4AAQSkZJRgABAQAAAQABAAD/2wBDABALDA4MChAODQ...
3      /9j/4AAQSkZJRgABAQAAAQABAAD/2wBDABALDA4MChAODQ...
4      /9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAMCAgMCAgMDAw...
'''
```
使用时:
```html
<img src="data:jpeg;base64,str"> <!--其中jpeg可能为png-->
```
