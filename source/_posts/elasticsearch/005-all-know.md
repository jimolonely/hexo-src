---
title: ElasticSearch入门一文
tags:
  - java
  - elasticsearch
p: elasticsearch/005-all-know
---

# 一句话定义
使用lucene开源搜索引擎为基础，使用Ｊａｖａ编写并提供简单易用RESTful API，
并且能轻易横向扩展，支持ＰＢ级别大数据的应用．

能作甚：　数据仓库，数据分析引擎，全文搜索引擎等．

# 版本
1.X -> 2.X -> 5.X -> 6.X

[差异](https://www.elastic.co/guide/en/elasticsearch/reference/current/setup-upgrade.html)

# 安装
### 单节点安装
[下载](https://www.elastic.co/downloads/elasticsearch),解压即可．

打开127.0.0.1:9200得到：
```json
{
  "name" : "JPM5EYQ",
  "cluster_name" : "elasticsearch",
  "cluster_uuid" : "JG6IvmbgTmicNDFFBDDMCQ",
  "version" : {
    "number" : "6.3.1",
    "build_flavor" : "default",
    "build_type" : "tar",
    "build_hash" : "eb782d0",
    "build_date" : "2018-06-29T21:59:26.107521Z",
    "build_snapshot" : false,
    "lucene_version" : "7.3.1",
    "minimum_wire_compatibility_version" : "5.6.0",
    "minimum_index_compatibility_version" : "5.0.0"
  },
  "tagline" : "You Know, for Search"
}
```
### 安装HEAD插件
可以提供ＷＥＢ界面进行查看结果和操作．
[head](https://github.com/mobz/elasticsearch-head)

```shell
npm install
npm run start
open http://localhost:9100/
```
前提是打开了elasticsearch服务，并且修改下跨域问题．
config/elasticsearch.yml
```yml
http.cors.enabled: true
http.cors.allow-origin: "*"
```

{% asset_img 000.png %}


### 集群安装
ｍａｓｔｅｒ节点配置：config/elasticsearch
```yml
cluster.name: jimo
node.name: master
node.master: true
 
network.host: 127.0.0.1
```
slave节点只需要打开新的terminal,使用新的文件夹．配置如下：改改端口
```yml
cluster.name: jimo
node.name: slave1

network.host: 127.0.0.1

http.port: 8200
discovery.zen.ping.unicast.hosts: ["127.0.0.1"] # 用于发现master节点
```
**注意的就是：节点的elasticsearch目录不能相互ｃｏｐｙ**

{% asset_img 001.png %}

# 基本概念
1. 索引(Index)：还有相同属性的文档集合(图书索引，车辆索引等)

2. 类型(Type)：索引可以定义一个或多个类型，文档必须属于一个类型（科普类文学类的书，卡车小轿车）

3. 文档(Document)：文档是可以被索引的基本数据单位（每本书，每辆车）

4. 分片(Shards)：每个索引都有多个分片，每个分片是一个lucene索引

5. 备份(Replica)：拷贝一个分片就完成了分片的备份

6. 集群(Cluster)：节点的集合，每个集群有一个名字，通过名字识别不同集群

# 基本用法
## RESTful API格式
http://<ip>:<port>/<索引>/<类型>/<文档id>

操作：PUT/GET/POST/DELETE

## 基本操作
### 创建索引
1. 使用elasticsearch-head创建
{% asset_img 002.png %}

可以看到分片的分布，竖着看，细边框的是粗边框的备份
{% asset_img 003.png %}

查看其信息，发现mappings这一项：如果是空（"mappings": { }）的则代表是非结构化数据，否则可以自定义结构化结构．
下面给ｂｏｏｋ索引定义一个带有title字段的novel属性：
{% asset_img 004.png %}

２. 使用HTTP请求创建,推荐使用Postman,便于编写json
{% asset_img 005.png %}
{% asset_img 006.png %}


