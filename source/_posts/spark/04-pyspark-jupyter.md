---
title: 配置pyspark和jupyter一起使用
tags:
  - spark
  - pyspark
  - jupyter
  - python
p: spark/04-pyspark-jupyter
date: 2018-01-05 18:52:49
---
使用默认的pyspark会调用python命令行,但总是不太方便.
本文会讲解2种方法使用jupyter打开pyspark,加载spark的环境.

简直太简单.

# 本次环境
```shell
spark:2.2.0
python:3.6
jupyter:4.3.0
Arch linux
```
# 效果
{% asset_img 000.png %}

# 配置方法1

1. 配置环境变量:
```shell
export SPARK_HOME=/home/temp/spark-2.2.0-bin-hadoop2.7
export PATH=$SPARK_HOME/bin:$PATH

export PYSPARK_DRIVER_PYTHON=jupyter
export PYSPARK_DRIVER_PYTHON_OPTS='notebook'
```
2. 使变量生效后和原方法一样使用命令:
```shell
$ source .bashrc
$ pyspark
```
# 配置方法2

通过findspark这个库.

1. 先安装:
```shell
$ pip install findspark
```
2. 加载notebook
```shell
$ jupyter notebook
```
3. 通过导入使用:
```python
import findspark
findspark.init()
import pyspark
import random

sc = pyspark.SparkContext(appName="Pi")
num_samples = 100000000
def inside(p):     
  x, y = random.random(), random.random()
  return x*x + y*y < 1
count = sc.parallelize(range(0, num_samples)).filter(inside).count()
pi = 4 * count / num_samples
print(pi)
sc.stop()
```

本文翻译自:[https://blog.sicara.com/get-started-pyspark-jupyter-guide-tutorial-ae2fe84f594f](https://blog.sicara.com/get-started-pyspark-jupyter-guide-tutorial-ae2fe84f594f)
