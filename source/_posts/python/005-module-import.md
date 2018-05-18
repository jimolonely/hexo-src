---
title: ModuleNotFoundError:No module named xxx
tags:
  - python
p: python/005-module-import
date: 2018-03-24 09:04:29
---
这是个常见问题.

# demo结构

{% asset_img 000.png %}

# 问题
我们在最外层main.py里引用任何包下的模块都是ok的.
```python
from pkg1.module1 import func1
from other import other
from pkg1.pkg11.module11 import func11
from pkg2.module2 import func2

def main():
    print('main')

other()
func1()
func11()
func2()
```
现在我们在module1里引用module2的函数:
```python
# module1.py

from pkg2.module2 import func2

func2()
```
就出现问题了:
```python
$ python module1.py 
Traceback (most recent call last):
  File "module1.py", line 6, in <module>
    from pkg2.module2 import func2
ModuleNotFoundError: No module named 'pkg2'
```
# 解决
既然找不到,就追加路径:
```python
import sys

sys.path.append('../')

from pkg2.module2 import func2

func2()
```
ok了.
# 说明
1. 一般来说,我们只会有一个入口文件,也就是main.py,只有单独运行module1.py时才需要这样做.
2. 不能出现循环引用,比如module2.py也引用module1的话,就行不通了.
3. pycharm这个IDE可以直接运行模块,而无需修改,除非要在命令行运行才需要改变路径.
4. 参考官方文档:[https://docs.python.org/3/tutorial/modules.html](https://docs.python.org/3/tutorial/modules.html)