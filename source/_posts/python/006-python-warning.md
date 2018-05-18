---
title: python中的那些警告
tags:
  - python
p: python/006-python-warning
# date: 2018-04-03 15:02:27
---
python中的那些警告,有时警告不仅是编程风格的问题.

# This dictionary creation could be rewritten as a dictionary literal.
原:
```python
dic = {}
dic['aaa'] = 5
```
后:
```python
dic = dict()
dic['aaa'] = 5
```
why?
```python
# 因为你可能事先已经声明过dic了:
dic = {'aaa': 5}
```

