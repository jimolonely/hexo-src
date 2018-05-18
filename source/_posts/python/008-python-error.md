---
title: python中的常见错误
tags:
  - python
p: python/008-python-error
# date: 2018-04-17 10:13:30
---
python中的常见错误.

# TypeError: Object of type 'int64' is not JSON serializable
一般这是numpy的int类型无法被json化,所以需要将numpy的int转为原生类型.
```python
# pandas返回的
sex_cnt = marks['sex'].value_counts()
type(sex_cnt['男']) # numpy.int64

# 3种转化方法
# examples using a.item()
type(np.float32(0).item()) # <type 'float'>
type(np.float64(0).item()) # <type 'float'>
type(np.uint32(0).item())  # <type 'long'>
# examples using np.asscalar(a)
type(np.asscalar(np.int16(0)))   # <type 'int'>
type(np.asscalar(np.cfloat(0)))  # <type 'complex'>
type(np.asscalar(np.datetime64(0, 'D')))  # <type 'datetime.datetime'>
type(np.asscalar(np.timedelta64(0, 'D'))) # <type 'datetime.timedelta'>
# 强制转化
int(np.int64(0))
```
# ValueError: unsupported format character 'xx' at index
```python
In [13]: s = "%jimo %s" % ('hehe')
---------------------------------------------------------------------------
ValueError                                Traceback (most recent call last)
<ipython-input-13-f5b56b452ab7> in <module>()
----> 1 s = "%jimo %s" % ('hehe')

ValueError: unsupported format character 'j' (0x6a) at index 1

In [14]: s = "%%jimo %s" % ('hehe')

In [15]: s
Out[15]: '%jimo hehe'
```
# TypeError: 'dict_items' object is not subscriptable
在python3中dict.keys()或items()返回的是个迭代器,所以不能slice.但可以转成list再迭代:
```python
list(d.keys())[2:4]
```
# tuple parameter unpacking is not supported in python 3
python3中tuple不能当做lambda参数.
```python
points = [ (1,2), (2,3)]
min(points, key=lambda (x, y): (x*x + y*y))

# way 1
min(points, key=lambda p: (lambda x,y: (x*x + y*y))(*p))

# way 2
min(points, key=lambda x_y: x_y[0] + x_y[1])

# way 3
def key(p): # more specific name would be better
    x, y = p
    return x**2 + y**3

result = min(points, key=key)
```
# 'str' object has no attribute 'decode'
这又是个版本问题,在python2.x中字符串有decode方法,而python3没有,因为
python3默认把字符串当成unicode处理,而python2不是.
因此当视图在python2环境下比较中文字符串时:
```python
s == '寂寞'
```
会出现警告:
```shell
UnicodeWarning: Unicode equal comparison failed to convert both arguments to Unicode
```
解决办法也很简单,只要s是utf8的话,将'寂寞'进行解码即可:
```python
s == '寂寞'.decode('utf-8')
```
而python3下则不需要.


