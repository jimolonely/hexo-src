---
title: spark历史服务配置
tags:
  - spark
p: spark/009-spark-history-conf
date: 2019-10-07 14:35:15
---

本文配置spark的历史服务，记录历史日志。

上一篇：{% post_link spark/008-spark-standalone-conf-run spark standalone模式的配置与运行 %}

# 写日志配置

conf/spark-defaults.conf
```s
spark.master                     spark://localhost:7077
spark.eventLog.enabled           true
spark.eventLog.dir                  /home/jack/workspace/spark/log-dir
```

# 读日志配置
spark-env.sh
```s
SPARK_HISTORY_OPTS="-Dspark.history.ui.port=18080 -Dspark.history.retainedApplication=30 -Dspark.history.fs.logDirectory=/home/jack/workspace/spark/log-dir"
```

# 开启历史服务

```s
$ sbin/start-history-server.sh 
starting org.apache.spark.deploy.history.HistoryServer, logging to /home/jack/workspace/spark/spark-2.4.4-bin-hadoop2.7/logs/spark-jack-org.apache.spark.deploy.history.HistoryServer-1-jack.out

$ jps
30340 HistoryServer
30506 Jps
```

查看日志可以看到成功了：
```s
 16 19/10/07 14:50:51 INFO FsHistoryProvider: History server ui acls disabled; users with admin permissions: ; groups with admin permissions
 17 19/10/07 14:50:51 INFO Utils: Successfully started service on port 18080.
 18 19/10/07 14:50:52 INFO HistoryServer: Bound HistoryServer to 0.0.0.0, and started at http://10.13.112.16:18080
```

# 验证

启动spark
```s
$ sbin/start-all.sh
```
跑一个应用
```s
$ bin/spark-submit \
 --class org.apache.spark.examples.SparkPi \
 --master spark://localhost:7077 \
 --executor-memory 1G \
 --total-executor-cores 2 \
 ./examples/jars/spark-examples_2.11-2.4.4.jar \
 100
```

然后去看界面就有了，同时日志目录下有一个日志文件：

```s
~/workspace/spark/log-dir$ ll
总用量 240
drwxrwxr-x 2 jack jack   4096 10月  7 14:57 ./
drwxrwxr-x 4 jack jack   4096 10月  7 14:40 ../
-rwxrwx--- 1 jack jack 236566 10月  7 14:57 app-20191007145723-0000*
```






