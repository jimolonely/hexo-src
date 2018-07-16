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



