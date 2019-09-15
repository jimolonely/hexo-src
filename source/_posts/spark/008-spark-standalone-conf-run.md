---
title: spark standalone模式的配置与运行
tags:
  - spark
p: spark/008-spark-standalone-conf-run
date: 2019-09-15 08:11:01
---

# 修改配置

1. 从模板解析出配置来：
  ```s
  conf$ cp spark-defaults.conf.template spark-defaults.conf
  conf$ cp spark-env.sh.template spark-env.sh
  cp slaves.template slaves
  ```
2. 修改slaves配置，增加worker节点：我这里只有本机，就是localhost
  ```s
  conf$ cat slaves
  localhost
  # worker1
  # worker2
  ```
3. 修改spark-env.sh设置master：
  ```s
  43 # Options for the daemons used in the standalone deploy mode
  44 # - SPARK_MASTER_HOST, to bind the master to a different IP address or hostname
  45 # - SPARK_MASTER_PORT / SPARK_MASTER_WEBUI_PORT, to use non-default ports for the master
  46 SPARK_MASTER_HOST=localhost
  47 SPARK_MASTER_PORT=7077
  ```

# 启动服务

当我调用`start-all.sh`时，发现了ssh连接错误：
```s
$ sbin/start-all.sh 
starting org.apache.spark.deploy.master.Master, logging to /home/jack/workspace/spark/spark-2.4.4-bin-hadoop2.7/logs/spark-jack-org.apache.spark.deploy.master.Master-1-jack.out
localhost: ssh: connect to host localhost port 22: Connection refused
```

另外的启动方式：
```s
$ ./start-master.sh 
org.apache.spark.deploy.master.Master running as process 12891.  Stop it first.

$ ./start-slave.sh spark://localhost:7077
```


```s
```