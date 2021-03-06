---
title: ElasticSearch入门一文
tags:
  - java
  - elasticsearch
p: elasticsearch/005-all-know
date: 2018-07-21 13:51:55
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

### 插入
文档插入：

指定ｉｄ插入
{% asset_img 007.png %}

或者自动生成ｉｄ插入．(注意POST方式和去掉id)
{% asset_img 008.png %}

在head中查看结果：
{% asset_img 009.png %}

### 修改
指定id通过URL修改
{% asset_img 010.png %}

通过脚本修改，支持的脚本语言有：内置的，js,python.
下面使用内置的修改：(**可看到，脚本可以灵活的使用参数**)
{% asset_img 011.png %}

### 删除
1. 删除文档
{% asset_img 012.png %}

2. 删除索引

使用head
{% asset_img 013.png %}

使用命令行：
{% asset_img 014.png %}

### 查询
先插入一些数据：
```json
{
	"title": "python之父",
	"author": "王麻子",
	"word_count": 1000,
	"publish_date": "2002-10-01"
},
{
	"title": "java",
	"author": "王三",
	"word_count": 2000,
	"publish_date": "2017-08-20"
},
{
	"title": "java入门",
	"author": "王四",
	"word_count": 5000,
	"publish_date": "2017-08-15"
},
{
	"title": "C++入门",
	"author": "王五",
	"word_count": 10000,
	"publish_date": "2000-09-20"
},
{
	"title": "java精通",
	"author": "李四",
	"word_count": 8000,
	"publish_date": "2010-09-20"
},
{
	"title": "java大法好",
	"author": "张三",
	"word_count": 3000,
	"publish_date": "2017-08-01"
},
{
	"title": "代码整洁之道",
	"author": "寂寞哥",
	"word_count": 5000,
	"publish_date": "1997-01-20"
},
{
	"title": "太极拳",
	"author": "赵牛",
	"word_count": 1000,
	"publish_date": "2005-08-20"
}
```
{% asset_img 015.png %}

1. 简单查询

Get查询
{% asset_img 016.png %}

POST查询所有数据：
{% asset_img 017.png %}

2. 条件查询

指定数据量：
{% asset_img 018.png %}

按条件并按日期降序排序：
{% asset_img 019.png %}

3. 聚合查询

按日期和字数聚合：
{% asset_img 020.png %}

统计：
{% asset_img 021.png %}
{% asset_img 022.png %}

或直接指定函数：
{% asset_img 023.png %}
{% asset_img 024.png %}

## 高级查询
### query
query context:
```
查询时除了判断文档是否满足查询条件外，还会
计算一个_score的字段来标识匹配程度，范围0-1

常用查询：
１．全文本查询：针对文本数据
２．字段级别查询：针对结构化数据，如日期，数字等
```
１．全文本查询

模糊查询
{% asset_img 019.png %}

定向查询: 如果使用match，那么java入门会被分成java和入门２个词
{% asset_img 025.png %}

多个关键字查询
{% asset_img 026.png %}

语法查询:fields省略可查询所有字段
{% asset_img 027.png %}

２．字段级别查询

指定值
{% asset_img 028.png %}

范围查询: 数字，日期呀
{% asset_img 029.png %}

### filter
filter context:
```
查询时只判断yes或no，不进行匹配程度判断．
```
{% asset_img 030.png %}

### 复合查询
结合查询和过滤．

1. 固定分数查询:通过boost指定分数，每个filter过滤出的结果都是这个分数
{% asset_img 031.png %}

2. 布尔查询
must:
{% asset_img 032.png %}

must_not:
{% asset_img 035.png %}

should:
{% asset_img 033.png %}

同时加上过滤：
{% asset_img 034.png %}

# 实战
集成spring-boot. [代码地址](https://github.com/jimolonely/codes/tree/master/spring-boot-elasticsearch-demo)

环境：Intellij IDE，JDK1.8

{% asset_img 043.png %}

1. 建一个spring-boot项目
2. pom.xml
```maven
    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-devtools</artifactId>
            <scope>runtime</scope>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>

        <!-- https://mvnrepository.com/artifact/org.elasticsearch.client/transport -->
        <dependency>
            <groupId>org.elasticsearch.client</groupId>
            <artifactId>transport</artifactId>
            <version>6.3.1</version>
        </dependency>
        <dependency>
            <groupId>org.apache.logging.log4j</groupId>
            <artifactId>log4j-api</artifactId>
            <version>2.7</version>
        </dependency>
        <dependency>
            <groupId>org.apache.logging.log4j</groupId>
            <artifactId>log4j-core</artifactId>
            <version>2.7</version>
        </dependency>
    </dependencies>
```
3. ESConfig配置TransportClient:
```java
@Configuration
public class ESConfig {

    @Bean
    public TransportClient client() throws UnknownHostException {
        final InetSocketTransportAddress nodeAddress =
                new InetSocketTransportAddress(InetAddress.getByName("localhost"), 9300);

        final Settings settings = Settings.builder().put("cluster.name", "jimo").build();

        final PreBuiltTransportClient client = new PreBuiltTransportClient(settings);
        client.addTransportAddress(nodeAddress);

        return client;
    }
}
```
4. 增删改查操作
```java
@RestController
@RequestMapping("/book/novel")
public class BookNovelController {

    private final TransportClient client;

    @Autowired
    public BookNovelController(TransportClient client) {
        this.client = client;
    }
    //...
}
```
查询:
```java

```
{% asset_img 037.png %}

增加：
```java
@PostMapping("/new")
public ResponseEntity addBook(
        @RequestParam("title") String title,
        @RequestParam("author") String author,
        @RequestParam("word_count") int wordCount,
        @RequestParam("publish_date")
        @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss")
                Date publishDate) {
    try {
        final XContentBuilder content = XContentFactory.jsonBuilder()
                .startObject()
                .field("title", title)
                .field("author", author)
                .field("word_count", wordCount)
                // .field("publish_date", publishDate.getTime())
                .endObject();
        final IndexResponse result = client.prepareIndex("book", "novel")
                .setSource(content).get();
        return new ResponseEntity(result.getId(), HttpStatus.OK);
    } catch (IOException e) {
        e.printStackTrace();
        return new ResponseEntity(HttpStatus.INTERNAL_SERVER_ERROR);
    }
}
```
{% asset_img 040.png %}

删除：
```java
@DeleteMapping
public ResponseEntity deleteBook(@RequestParam("id") String id) {
    final DeleteResponse response = client.prepareDelete("book", "novel", id).get();
    return new ResponseEntity(response.getResult(), HttpStatus.OK);
}
```
{% asset_img 039.png %}

修改：
```java
@PostMapping("/update")
public ResponseEntity updateBook(
        @RequestParam("id") String id,
        @RequestParam(name = "title", required = false) String title,
        @RequestParam(name = "author", required = false) String author) {
    final UpdateRequest updateRequest = new UpdateRequest("book", "novel", id);
    try {
        final XContentBuilder builder = XContentFactory.jsonBuilder().startObject();
        if (title != null) {
            builder.field("title", title);
        }
        if (author != null) {
            builder.field("author", author);
        }
        builder.endObject();
        updateRequest.doc(builder);
    } catch (IOException e) {
        e.printStackTrace();
        return new ResponseEntity(HttpStatus.INTERNAL_SERVER_ERROR);
    }
    try {
        final UpdateResponse updateResponse = client.update(updateRequest).get();
        return new ResponseEntity(updateResponse.getResult(), HttpStatus.OK);
    } catch (InterruptedException | ExecutionException e) {
        e.printStackTrace();
        return new ResponseEntity(HttpStatus.INTERNAL_SERVER_ERROR);
    }
}
```
{% asset_img 041.png %}

查询：
```java
@PostMapping("/query")
public ResponseEntity queryBook(
        @RequestParam(name = "author", required = false) String author,
        @RequestParam(name = "title", required = false) String title,
        @RequestParam(name = "gt_word_count", defaultValue = "0") Integer gtWordCount,
        @RequestParam(name = "lt_word_count", required = false) Integer ltWordCount) {
    final BoolQueryBuilder boolQuery = QueryBuilders.boolQuery();
    if (author != null) {
        boolQuery.must(QueryBuilders.matchQuery("author", author));
    }
    if (title != null) {
        boolQuery.must(QueryBuilders.matchQuery("title", title));
    }
    final RangeQueryBuilder rangeQuery = QueryBuilders.rangeQuery("word_count").from(gtWordCount);
    if (ltWordCount != null && ltWordCount >= gtWordCount) {
        rangeQuery.to(ltWordCount);
    }
    boolQuery.filter(rangeQuery);
    final SearchRequestBuilder builder = client.prepareSearch("book")
            .setTypes("novel")
            .setSearchType(SearchType.DFS_QUERY_THEN_FETCH)
            .setQuery(boolQuery)
            .setFrom(0)
            .setSize(10);

    System.out.println(builder);

    final SearchResponse response = builder.get();
    List<Map<String, Object>> result = new ArrayList<>();

    for (SearchHit hit : response.getHits()) {
        result.add(hit.getSource());
    }
    return new ResponseEntity(result, HttpStatus.OK);
}
```
{% asset_img 042.png %}

## 遇到的问题
参考：[blog](https://blog.csdn.net/napoay/article/details/53581027)

1. java.lang.ClassNotFoundException: org.elasticsearch.transport.Netty3Plugin
{% asset_img 036.png %}

2. failed to parse [publish_date]
{% asset_img 038.png %}
需要将date的fromat改为dateOptionalTime.**注意：数据类型是不能修改的，所以建立索引时就要考虑清除.**

# 总结
[官方的java客户端连接例子](https://www.elastic.co/guide/en/elasticsearch/client/java-rest/current/java-rest-overview.html)




