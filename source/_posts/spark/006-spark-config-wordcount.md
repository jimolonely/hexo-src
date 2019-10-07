---
title: spark：wordcount
tags:
  - spark
p: spark/006-spark-config-wordcount
date: 2019-09-14 20:18:46
---

本文是系列spark学习过程第一篇：wordcount, 将会认识目录结构、常用参数、运行示例。

# 目录结构

```s
spark-2.4.4-bin-hadoop2.7$ ll
总用量 136
drwxr-xr-x 13 jack jack  4096 8月  28 05:30 ./
drwxrwxr-x  3 jack jack  4096 9月  14 10:03 ../
drwxr-xr-x  2 jack jack  4096 8月  28 05:30 bin/
drwxr-xr-x  2 jack jack  4096 8月  28 05:30 conf/
drwxr-xr-x  5 jack jack  4096 8月  28 05:30 data/
drwxr-xr-x  4 jack jack  4096 8月  28 05:30 examples/
drwxr-xr-x  2 jack jack 12288 8月  28 05:30 jars/
drwxr-xr-x  4 jack jack  4096 8月  28 05:30 kubernetes/
-rw-r--r--  1 jack jack 21316 8月  28 05:30 LICENSE
drwxr-xr-x  2 jack jack  4096 8月  28 05:30 licenses/
-rw-r--r--  1 jack jack 42919 8月  28 05:30 NOTICE
drwxr-xr-x  9 jack jack  4096 8月  28 05:30 python/
drwxr-xr-x  3 jack jack  4096 8月  28 05:30 R/
-rw-r--r--  1 jack jack  3952 8月  28 05:30 README.md
-rw-r--r--  1 jack jack   164 8月  28 05:30 RELEASE
drwxr-xr-x  2 jack jack  4096 8月  28 05:30 sbin/
drwxr-xr-x  2 jack jack  4096 8月  28 05:30 yarn/

spark-2.4.4-bin-hadoop2.7/bin$ ll
总用量 56
drwxr-xr-x  2 jack jack 4096 9月  14 20:22 ./
drwxr-xr-x 13 jack jack 4096 8月  28 05:30 ../
-rwxr-xr-x  1 jack jack 1089 8月  28 05:30 beeline*
-rwxr-xr-x  1 jack jack 5440 8月  28 05:30 docker-image-tool.sh*
-rwxr-xr-x  1 jack jack 1933 8月  28 05:30 find-spark-home*
-rw-r--r--  1 jack jack 2025 8月  28 05:30 load-spark-env.sh
-rwxr-xr-x  1 jack jack 2987 8月  28 05:30 pyspark*
-rwxr-xr-x  1 jack jack 1030 8月  28 05:30 run-example*
-rwxr-xr-x  1 jack jack 3196 8月  28 05:30 spark-class*
-rwxr-xr-x  1 jack jack 1039 8月  28 05:30 sparkR*
-rwxr-xr-x  1 jack jack 3122 8月  28 05:30 spark-shell*
-rwxr-xr-x  1 jack jack 1065 8月  28 05:30 spark-sql*
-rwxr-xr-x  1 jack jack 1040 8月  28 05:30 spark-submit*
```

* bin: 操作
* sib: 启动关闭等

# bin/spark-submit

用法：
```s
Usage: spark-submit [options] <app jar | python file | R file> [app arguments]
Usage: spark-submit --kill [submission ID] --master [spark://...]
Usage: spark-submit --status [submission ID] --master [spark://...]
Usage: spark-submit run-example [options] example-class [example args]
```

其主要常用参数：

*  --master MASTER_URL : master的地址，有几种可选的：spark://host:port, mesos://host:port, yarn,
                              k8s://https://host:port, or local (Default: local[*])
* --deploy-mode DEPLOY_MODE： 集群还是客户端模式：client, cluster

* --class CLASS_NAME: 主类

* --name NAME

* --conf PROP=VALUE: 键值对配置

* --driver-memory MEM         Memory for driver (e.g. 1000M, 2G) (Default: 1024M)

* --executor-memory MEM       Memory per executor (e.g. 1000M, 2G) (Default: 1G).

下面是在几个模式下才有的参数：
```s
 Cluster deploy mode only:
  --driver-cores NUM          Number of cores used by the driver, only in cluster mode
                              (Default: 1).

 Spark standalone or Mesos with cluster deploy mode only:
  --supervise                 If given, restarts the driver on failure.
  --kill SUBMISSION_ID        If given, kills the driver specified.
  --status SUBMISSION_ID      If given, requests the status of the driver specified.

 Spark standalone and Mesos only:
  --total-executor-cores NUM  Total cores for all executors.

 Spark standalone and YARN only:
  --executor-cores NUM        Number of cores per executor. (Default: 1 in YARN mode,
                              or all available cores on the worker in standalone mode)
```

# SparkPi example

迭代一百次求Pi：
```s
$ bin/spark-submit \
> --class org.apache.spark.examples.SparkPi \
> --executor-memory 1G \
> --total-executor-cores 2 \
> ./examples/jars/spark-examples_2.11-2.4.4.jar \
> 100
```
结果：
```s
19/09/14 20:36:44 INFO Utils: Successfully started service 'SparkUI' on port 4040.
19/09/14 20:36:44 INFO SparkUI: Bound SparkUI to 0.0.0.0, and started at http://192.168.199.249:4040
...
19/09/14 20:36:49 INFO DAGScheduler: Job 0 finished: reduce at SparkPi.scala:38, took 4.783231 s
Pi is roughly 3.1414851141485114
19/09/14 20:36:49 INFO SparkUI: Stopped Spark web UI at http://192.168.199.249:4040
```

* 4040端口的临时界面
* 计算结果

# spark-shell

```s
$ bin/spark-shell
...
Spark context Web UI available at http://192.168.199.249:4040
Spark context available as 'sc' (master = local[*], app id = local-1568464941397).
...
```

* 4040的web界面
* 默认以`local[*]`模式启动

写一个wordcount：

```s
scala> sc.textFile("./README.md").flatMap(_.split(" ")).map((_,1)).reduceByKey(_+_).collect
```

保存为文件：
```s
scala> sc.textFile("./README.md").flatMap(_.split(" ")).map((_,1)).reduceByKey(_+_).saveAsTextFile("./out")
```
查看文件内容：
```s
$ ll out/
总用量 28
drwxr-xr-x  2 jack jack 4096 9月  14 20:48 ./
drwxr-xr-x 14 jack jack 4096 9月  14 20:48 ../
-rw-r--r--  1 jack jack 2103 9月  14 20:48 part-00000
-rw-r--r--  1 jack jack   28 9月  14 20:48 .part-00000.crc
-rw-r--r--  1 jack jack 1932 9月  14 20:48 part-00001
-rw-r--r--  1 jack jack   24 9月  14 20:48 .part-00001.crc
-rw-r--r--  1 jack jack    0 9月  14 20:48 _SUCCESS
-rw-r--r--  1 jack jack    8 9月  14 20:48 ._SUCCESS.crc
```

# submit进程和webUI

```s
$ jps
14501 SparkSubmit
16301 Jps
```

关于webUI，直接打开localhost:404去看就ok。


下一篇：{% post_link spark/007-spark-data-flow spark运行流程 %}

