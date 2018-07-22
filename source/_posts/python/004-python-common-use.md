---
title: python中的常用操作
tags:
  - python
p: python/004-python-common-use
date: 2018-03-12 10:36:29
---
真的很常用诶.

# 对dict排序
```python
>>> from collections import OrderedDict

>>> # regular unsorted dictionary
>>> d = {'banana': 3, 'apple':4, 'pear': 1, 'orange': 2}

>>> # dictionary sorted by key -- OrderedDict(sorted(d.items()) also works
>>> OrderedDict(sorted(d.items(), key=lambda t: t[0]))
OrderedDict([('apple', 4), ('banana', 3), ('orange', 2), ('pear', 1)])

>>> # dictionary sorted by value
>>> OrderedDict(sorted(d.items(), key=lambda t: t[1]))
OrderedDict([('pear', 1), ('orange', 2), ('banana', 3), ('apple', 4)])

>>> # dictionary sorted by length of the key string
>>> OrderedDict(sorted(d.items(), key=lambda t: len(t[0])))
OrderedDict([('pear', 1), ('apple', 4), ('orange', 2), ('banana', 3)])
```
简单点:
```python
d = {2:3, 1:89, 4:5, 3:0}
sd = sorted(d.items())

for k,v in sd:
    print k, v
'''
1 89
2 3
3 0
4 5
'''
```
# 统计list中元素个数
```python
In [1]: from collections import Counter

In [2]: a = [1,2,34,3,2,5,6,1,1]

In [3]: Counter(a)
Out[3]: Counter({1: 3, 2: 2, 3: 1, 5: 1, 6: 1, 34: 1})
```
# 那些解析
解析json字符串
```python
import json
j = json.loads('{"one" : "1", "two" : "2", "three" : "3"}')
print j['two']
```
写入和读取python数据结构到文件:
```python
# Writing JSON data
with open('data.json', 'w') as f:
    json.dump(data, f)

# Reading data back
with open('data.json', 'r') as f:
    data = json.load(f)
```
对于中文,如果想写入文件时不进行编码,可以指定ensure_ascii=False
```python
json.dump(obj,f,ensure_ascii=False)
```
# python里计时
```python
import time

start = time.time()
print("hello")
end = time.time()
print(end - start)
```
# slice dict
dict本来不能像list那样slice,但itertools可以:
```python
In [14]: a = {'a':1,'b':2}

In [15]: a[:]
---------------------------------------------------------------------------
TypeError                                 Traceback (most recent call last)
<ipython-input-15-6ced218e2c37> in <module>()
----> 1 a[:]

TypeError: unhashable type: 'slice'

In [16]: import itertools

In [17]: dict(itertools.islice(a.items(),1))
Out[17]: {'a': 1}
```
# 检查NAN
```python
>>> import math
>>> x=float('nan')
>>> math.isnan(x)
True
```
# 快速清除文件内容
```python
open('file.txt','w).close()
```
# 列出文件夹内容与正则过滤
```python
In [1]: import os

In [2]: os.listdir('./')
Out[2]:
['0307_nodes.txt',
 '0307_links.txt',
 '0901_nodes.txt',
 '0901_links.txt'
]
```
其实python提供有过滤的库函数fnmatch,glob等
```python
path = "/home/relation-data-2015/"
files = fnmatch.filter(os.listdir(path),'*_single_links.txt')
files
'''
['0101_single_links.txt',
 '0901_single_links.txt',
 '0201_single_links.txt',
 '0307_single_links.txt',
 '0402_single_links.txt',
 '0215_single_links.txt',
 '0408_single_links.txt',
 '0501_single_links.txt']
'''
```
# sorted函数
```python
In [4]: l = [{'a':1},{'a':4},{'a':2}]

In [5]: sorted(l,key=lambda d:d['a'])
Out[5]: [{'a': 1}, {'a': 2}, {'a': 4}]
```
注意,这并不会改变原有列表:
```python
In [6]: l
Out[6]: [{'a': 1}, {'a': 4}, {'a': 2}]

In [7]: l = sorted(l,key=lambda d:d['a'])

In [8]: l
Out[8]: [{'a': 1}, {'a': 2}, {'a': 4}]
```
# 修改dict的key值
```python
In [1]: d = {'女': 176, '男': 517}

In [2]: d['female'] = d.pop('女')

In [3]: d
Out[3]: {'female': 176, '男': 517}
```
# 取得dict的第一个key
```python
# way 1
my_dict = {'foo': 'bar'}
next(iter(my_dict)) # outputs 'foo'

# way 2
list(my_dict.keys())[0]
```
# 取得list里最频繁项

[stackoverflow-python-most-common-element-in-a-list](https://stackoverflow.com/questions/1518522/python-most-common-element-in-a-list)
```python
# way 1
from collections import Counter

def Most_Common(lst):
    data = Counter(lst)
    return data.most_common(1)[0][0]

# way 2
def most_common(lst):
    data = Counter(lst)
    return max(lst, key=data.get)

# way 3
>>> from statistics import mode
>>> mode([1, 2, 2, 3, 3, 3, 3, 3, 4, 5, 6, 6, 6])
3

# way 4
def most_common(lst):
    return max(set(lst), key=lst.count)
```
# 删除连续空格只保留一个
1. 用2个空格替换成一个空格,需要循环替换
```python
a = '1    3   5'
while a.find('  ') != -1:
    a = a.replace('  ', ' ')
```
2. 先分开再用join
```python
' '.join(s.split())
```
# 日期操作
获得年月日
```python
from datetime import datetime
today = datetime.today()
today.day/month/year
```
计算日期之间的月份差
```python
from datetime import datetime,date

def month_delta(start_date, end_date=datetime.now().date()):
    """
    返回 end_date  - start_date  的差值
        :param start_date:
        :param end_date:
        :return:  month_delta   int
    """
    flag = True
    if start_date > end_date:
        start_date, end_date = end_date, start_date
        flag = False
    year_diff = end_date.year - start_date.year
    end_month = year_diff * 12 + end_date.month
    delta = end_month - start_date.month
    # return -delta if flag is False else delta
    return abs(delta)
```
