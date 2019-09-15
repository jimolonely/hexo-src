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
这个解决办法参看：{% post_link linux/031-ubuntu-ssh-connection-refuesd ubuntu localhost:ssh:connect to host localhost port 22:Connection refused %}

另外的启动方式：单个启动
```s
$ ./start-master.sh 
org.apache.spark.deploy.master.Master running as process 12891.  Stop it first.

$ ./start-slave.sh spark://localhost:7077
```

我还是修改完ssh来启动：
```s
$ sbin/start-all.sh 
starting org.apache.spark.deploy.master.Master, logging to /home/jack/workspace/spark/spark-2.4.4-bin-hadoop2.7/logs/
spark-jack-org.apache.spark.deploy.master.Master-1-jack.out
localhost: starting org.apache.spark.deploy.worker.Worker, logging to /home/jack/workspace/spark/spark-2.4.4-bin-hadoop2.7/logs/
spark-jack-org.apache.spark.deploy.worker.Worker-1-jack.out
```

检查启动结果：

```s
$ jps
23479 Worker
23304 Master
23851 Jps
```

# 运行Pi示例

比之前local模式多了个`--master spark://localhost:7077`

```s
$ bin/spark-submit \
 --class org.apache.spark.examples.SparkPi \
 --master spark://localhost:7077 \
 --executor-memory 1G \
 --total-executor-cores 2 \
 ./examples/jars/spark-examples_2.11-2.4.4.jar \
 100
```

结果都差不多，但是我们有一个界面，运行在8080端口，可以查看结果：

{% asset_img 000.png %}

# 通过spark-shell提交任务

```s
$ bin/spark-shell --master spark://localhost:7077
```
这时候我们看一下进程：
```s
$ jps
27680 CoarseGrainedExecutorBackend
27571 SparkSubmit
28212 Jps
23479 Worker
23304 Master
```
会发现有一个`CoarseGrainedExecutorBackend`, 这个executorBackend的出现代表spark已经申请了资源，虽然还没执行任务，具体流程请参考：
{% post_link spark/007-spark-data-flow spark运行流程 %}

# 模拟报错

给一个不存在的文件：
```s
scala> sc.textFile("xxx").flatMap(_.split(" ")).map((_,1)).reduceByKey(_+_).collect
org.apache.hadoop.mapred.InvalidInputException: Input path does not exist: file:/home/jack/workspace/spark/spark-2.4.4-bin-hadoop2.7/xxx
```

