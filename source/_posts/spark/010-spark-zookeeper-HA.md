---
title: spark+zookeeper高可用配置
tags:
  - spark
  - zookeeper
p: spark/010-spark-zookeeper-HA
date: 2019-10-07 15:08:21
---

本文讲解spark基于zookeeper的高可用配置。

上一篇：{% post_link spark/009-spark-history-conf spark历史服务配置 %}

# spark-env配置

spark-env.sh

```s
# 注释掉单击版
#SPARK_MASTER_HOST=localhost
#SPARK_MASTER_PORT=7077

# 修改为zookeeper管理master
SPARK_DAEMON_JAVA_OPTS="-Dspark.deploy.recoveryMode=ZOOKEEPER -Dspark.deploy.zookeeper.url=node1,node2,node3 -Dspark.deploy.zookeeper.dir=/spark"
```

# 启动zookeeper集群

# 启动spark

```s
$ sbin/start-all.sh
```
指定某些节点为master

```s
# node1
$ sbin/start-master.sh

# node2
$ sbin/start-master.sh
```
那么会有一个为standby状态，一旦有其他挂了，会被顶替。

# 使用

比如spark-shell使用：

```s
$ bin/spark-shell --master spark://node1:7077,node2:7077
```





