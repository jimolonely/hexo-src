---
title: 配置hadoop环境变量
tags:
  - hadoop
  - linux
p: hadoop/000-config-environment
date: 2018-01-10 16:57:35
---
[下载](http://ftp.cuhk.edu.hk/pub/packages/apache.org/hadoop/common/current/hadoop-3.0.0.tar.gz)
完后的hadoop需要配置各个组件的的环境变量.

参考[wiki-hadoop](https://wiki.apache.org/hadoop/HowToSetupYourDevelopmentEnvironment)

# 在linux中
一般作为开发环境才需要配置.

以前是这样,打开.bashrc或者.bash_profile
```
export HADOOP_COMMON_HOME=xxx/hadoop-2.9.0/share/hadoop/common
export HADOOP_HDFS_HOME=xxx/hadoop-2.9.0/share/hadoop/hdfs
export HADOOP_MAPRED_HOME=xxx/hadoop-2.9.0/share/hadoop/mapreduce
export HADOOP_YARN_HOME=xxx/hadoop-2.9.0/share/hadoop/yarn
export PATH=$HADOOP_COMMON_HOME/bin:$HADOOP_HDFS_HOME/bin:$HADOOP_MAPRED_HOME/bin:$PATH
```
但是如果并没有安装hadoop,而只是下载了源码,其实那几个命令都在hadoop/bin下了,所以只需要配:
```
export HADOOP_HOME=/home/jimo/workspace/temp/hadoop/hadoop-3.0.0
export PATH=$HADOOP_HOME/bin:$PATH
```

# 其他配置

[配置IDEA的Hadoop开发环境](https://wiki.apache.org/hadoop/HadoopUnderIDEA)
[配置Eclipse的Hadoop开发环境](https://wiki.apache.org/hadoop/EclipseEnvironment)

