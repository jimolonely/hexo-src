---
title: hbase-java操作
tags:
  - java
  - hbase
p: hadoop/002-hbase-java
date: 2018-09-05 17:02:47
---

本篇包括java客户端堆hbase的常用CRUD和过滤器使用。

# Maven配置
```maven
<dependencies>
    <!-- https://mvnrepository.com/artifact/org.apache.hbase/hbase-client -->
    <dependency>
        <groupId>org.apache.hbase</groupId>
        <artifactId>hbase-client</artifactId>
        <version>1.2.6</version>
    </dependency>

    <!-- https://mvnrepository.com/artifact/junit/junit -->
    <dependency>
        <groupId>junit</groupId>
        <artifactId>junit</artifactId>
        <version>4.12</version>
    </dependency>

</dependencies>
```
# 创建连接
```java
public class HBaseTest {
    private Admin admin;
    private final String tableName = "t_blog";
    private final String cf1 = "cf1";
    private final String cf2 = "cf2";

    /**
     * title为列名
     */
    private final String title = "title";

    private Table table;

    @Before
    public void init() throws IOException {
        Configuration configuration = HBaseConfiguration.create();
        configuration.set("hbase.zookeeper.property.clientPort", "2181");
        configuration.set("hbase.zookeeper.quorum", "hadoop6,hadoop5,hadoop4");
        Connection connection = ConnectionFactory.createConnection(configuration);
        admin = connection.getAdmin();
        table = connection.getTable(TableName.valueOf(tableName));
    }

    @After
    public void close() throws IOException {
        admin.close();
        table.close();
    }
}
```

# list
```java
/**
 * @func 列出所有表
 * @author jimo
 * @date 2018/8/17 14:45
 */
@Test
public void listTables() throws IOException {
    HTableDescriptor[] hTableDescriptors = admin.listTables();
    for (HTableDescriptor descriptor : hTableDescriptors) {
        System.out.println(descriptor.getNameAsString());
    }
    /**
     homedata
     testKfkBulkload
     */
}
```
# create table
```java
/**
 * @func 判断表是否存在
 * @author jimo
 * @date 2018/8/17 14:54
 */
public boolean isTableExists() throws IOException {
    return admin.tableExists(TableName.valueOf(tableName));
}

/**
 * @func 创建表
 * @author jimo
 * @date 2018/8/17 14:47
 */
@Test
public void createTable() throws IOException {
    TableName tableName = TableName.valueOf(this.tableName);
    HTableDescriptor hTableDescriptor = new HTableDescriptor(tableName);
    hTableDescriptor.addFamily(new HColumnDescriptor(cf1));
    hTableDescriptor.addFamily(new HColumnDescriptor(cf2));
    admin.createTable(hTableDescriptor);
    System.out.println(isTableExists());
}
```
# disable & enable
```java
/**
 * @func 禁用一张表
 * @author jimo
 * @date 2018/8/17 14:58
 */
@Test
public void disableTable() throws IOException {
    if (!admin.isTableDisabled(TableName.valueOf(tableName))) {
        admin.disableTable(TableName.valueOf(tableName));
    }
    System.out.println("已经disabled");
}

/**
 * @func enable一张表
 * @author jimo
 * @date 2018/8/17 15:00
 */
@Test
public void enableTable() throws IOException {
    if (!admin.isTableEnabled(TableName.valueOf(tableName))) {
        admin.enableTable(TableName.valueOf(tableName));
    }
    System.out.println("已经enabled");
}
```
# delete & add 列族
```java
/**
 * @func 加入列族
 * @author jimo
 * @date 2018/8/17 15:04
 */
@Test
public void addColumnFamilty() throws IOException {
    HColumnDescriptor title = new HColumnDescriptor("test");
    admin.addColumn(TableName.valueOf(tableName), title);
}

/**
 * @func 删除列族
 * @author jimo
 * @date 2018/8/17 15:09
 */
@Test
public void deleteColumnFamily() throws IOException {
    admin.deleteColumn(TableName.valueOf(tableName), Bytes.toBytes("test"));
}
```
# put data
```java
/**
 * @func 插入数据
 * @author jimo
 * @date 2018/8/17 15:21
 */
@Test
public void putData() throws IOException {
    Put r1 = new Put(Bytes.toBytes("row-key-0"));
    r1.addColumn(Bytes.toBytes(cf1), Bytes.toBytes(title), Bytes.toBytes("java入门"));
    table.put(r1);

    /*批量插入*/
    List<Put> puts = new ArrayList<>();
    for (int i = 0; i < 5; i++) {
        Put put = new Put(Bytes.toBytes("row-key-" + (i + 1)));
        put.addColumn(Bytes.toBytes(cf1), Bytes.toBytes(title), Bytes.toBytes("python教程-" + i));
        puts.add(put);
    }
    table.put(puts);
}
```
# get data
```java
/**
 * @func 根据row key获取数据
 * @author jimo
 * @date 2018/8/17 15:35
 */
@Test
public void getData() throws IOException {
    Get get = new Get(Bytes.toBytes("row-key-0"));
    Result result = table.get(get);

    /*简单方式：已知列族和列名*/
    byte[] resultValue = result.getValue(Bytes.toBytes(cf1), Bytes.toBytes("title"));
    System.out.println(Bytes.toString(resultValue));

    /*复杂方式：全部查出来*/
    printResult(result);
    /*
     java入门
     ColumnFamily: cf1
     columnName: title:
     column-key: 1534491212818,value: java入门
     */
}

/**
 * @func 解析并打印Result结果
 * @author jimo
 * @date 2018/8/17 16:00
 */
private void printResult(Result result) {
    NavigableMap<byte[], NavigableMap<byte[], NavigableMap<Long, byte[]>>> navigableMap = result.getMap();
    for (Map.Entry<byte[], NavigableMap<byte[], NavigableMap<Long, byte[]>>> entry : navigableMap.entrySet()) {
        System.out.println("ColumnFamily: " + Bytes.toString(entry.getKey()));
        NavigableMap<byte[], NavigableMap<Long, byte[]>> value = entry.getValue();
        for (Map.Entry<byte[], NavigableMap<Long, byte[]>> m : value.entrySet()) {
            System.out.println("columnName: " + Bytes.toString(m.getKey()) + ":");
            NavigableMap<Long, byte[]> mValue = m.getValue();
            for (Map.Entry<Long, byte[]> mm : mValue.entrySet()) {
                System.out.println("column-key: " + mm.getKey() + ",value: " + Bytes.toString(mm.getValue()));
            }
        }
    }
}
```
# scan
```java
/**
 * @func scan表
 * @author jimo
 * @date 2018/8/17 15:56
 */
@Test
public void scanTable() throws IOException {
    ResultScanner scanner = table.getScanner(new Scan());
    for (Result result : scanner) {
        printResult(result);
    }
    scanner.close();
    /*
    ColumnFamily: cf1
    columnName: title:
    column-key: 1534491212818,value: java入门
    ColumnFamily: cf1
    columnName: title:
    column-key: 1534491212955,value: python教程-0
    ColumnFamily: cf1
    columnName: title:
    column-key: 1534491212955,value: python教程-1
    ColumnFamily: cf1
    columnName: title:
    column-key: 1534491212955,value: python教程-2
    ColumnFamily: cf1
    columnName: title:
    column-key: 1534491212955,value: python教程-3
    ColumnFamily: cf1
    columnName: title:
    column-key: 1534491212955,value: python教程-4
     */
}
```
# update
```java
/**
 * @func 更新：类似于覆盖数据
 * @author jimo
 * @date 2018/8/17 16:06
 */
@Test
public void updateData() throws IOException {
    Put put = new Put(Bytes.toBytes("row-key-0"));
    put.addColumn(Bytes.toBytes(cf1), Bytes.toBytes(title), Bytes.toBytes("java进阶"));
    table.put(put);
}
```
# delete & truncate
```java
/**
 * @func 删除数据
 * @author jimo
 * @date 2018/8/17 16:10
 */
@Test
public void deleteData() throws IOException {
    Delete delete = new Delete(Bytes.toBytes("row-key-1"));
//        delete.addColumn(Bytes.toBytes(cf1), Bytes.toBytes(title));
//        delete.addFamily(Bytes.toBytes(cf1));
    table.delete(delete);
}

/**
 * @func 删除所有数据且不保留分割
 * @author jimo
 * @date 2018/8/17 16:04
 */
@Test
public void truncate() throws IOException {
    admin.truncateTable(TableName.valueOf(tableName), false);
}
```
# drop & shutdown
```java
/**
 * @func drop表, 记得先disable
 * @author jimo
 * @date 2018/8/17 15:13
 */
@Test
public void dropTable() throws IOException {
    admin.disableTable(TableName.valueOf(tableName));
    admin.deleteTable(TableName.valueOf(tableName));
}

/**
 * @func stop hbase
 * @author jimo
 * @date 2018/8/17 15:15
 */
@Test
public void shutdown() throws IOException {
    admin.shutdown();
}
```
# scan filters
## SingleColumnValueFilter
```java
/**
 * @func 单一列值过滤器，有多种比较符,会获取整行数据
 * @author jimo
 * @date 2018/8/17 22:09
 */
@Test
public void singleColumnFilter() throws IOException {
    SingleColumnValueFilter filter = new SingleColumnValueFilter(
            Bytes.toBytes(cf1),
            Bytes.toBytes(title),
            CompareFilter.CompareOp.EQUAL,
            Bytes.toBytes("python教程-3")
    );
    Scan scan = new Scan();
    scan.setFilter(filter);
    ResultScanner results = table.getScanner(scan);
    MyUtil.printResults(results);
}
```
## ColumnValueFilter
作为SingleColumnValueFilter的补充，在HBase-2.0.0版本中引入，ColumnValueFilter仅获取匹配的单元格，而SingleColumnValueFilter获取匹配的单元格所属的整个行（具有其他列和值）。
##ValueFilter
```java
/**
 * @func 准确搜索指定的列，避免无效的搜索其他列族，简单搜索推荐
 * @author jimo
 * @date 2018/8/17 23:19
 */
@Test
public void valueFilter() throws IOException {
    ValueFilter filter = new ValueFilter(
            CompareFilter.CompareOp.EQUAL,
            new BinaryComparator(Bytes.toBytes("python教程-4"))
    );
    Scan scan = new Scan();
    scan.addColumn(Bytes.toBytes(cf1), Bytes.toBytes(title));
    scan.setFilter(filter);
    ResultScanner results = table.getScanner(scan);
    MyUtil.printResults(results);
}
```
## RegexStringComparator
```java
/**
 * @func 正则过滤, 凡是以python开头的都可以，参考：
 * https://docs.oracle.com/javase/6/docs/api/java/util/regex/Pattern.html
 * @author jimo
 * @date 2018/8/20 8:14
 */
@Test
public void regexFilter() throws IOException {
    RegexStringComparator comparator = new RegexStringComparator("python.");
    SingleColumnValueFilter singleColumnValueFilter = new SingleColumnValueFilter(
            Bytes.toBytes(cf1),
            Bytes.toBytes(title),
            CompareFilter.CompareOp.EQUAL,
            comparator
    );
    Scan scan = new Scan();
    scan.setFilter(singleColumnValueFilter);
    ResultScanner results = table.getScanner(scan);
    MyUtil.printResults(results);
}
```
## SubStringFilter
```java
/**
 * @func 子串匹配
 * @author jimo
 * @date 2018/8/20 8:26
 */
@Test
public void subStringFilter() throws IOException {
    /*匹配 xxx教程-2xxx*/
    SubstringComparator comparator = new SubstringComparator("教程-2");
    SingleColumnValueFilter singleColumnValueFilter = new SingleColumnValueFilter(
            Bytes.toBytes(cf1),
            Bytes.toBytes(title),
            CompareFilter.CompareOp.EQUAL,
            comparator
    );
    Scan scan = new Scan();
    scan.setFilter(singleColumnValueFilter);
    ResultScanner results = table.getScanner(scan);
    MyUtil.printResults(results);
    /*
    ColumnFamily: cf1
    columnName: title:
    column-key: 1534491212955,value: python教程-2
     */
}
```
## BinaryPrefixFilter
```java
/**
 * @func 前缀匹配
 * @author jimo
 * @date 2018/8/20 8:42
 */
@Test
public void binaryPrefixFilter() throws IOException {
    BinaryPrefixComparator comparator = new BinaryPrefixComparator(Bytes.toBytes("python"));
    SingleColumnValueFilter singleColumnValueFilter = new SingleColumnValueFilter(
            Bytes.toBytes(cf1),
            Bytes.toBytes(title),
            CompareFilter.CompareOp.EQUAL,
            comparator
    );
    Scan scan = new Scan();
    scan.setFilter(singleColumnValueFilter);
    ResultScanner results = table.getScanner(scan);
    MyUtil.printResults(results);
}
```
## ColumnPrefixFilter
```java
/**
 * @func 匹配列名的前缀
 * @author jimo
 * @date 2018/8/20 8:48
 */
@Test
public void columnPrefixFilter() throws IOException {
    ColumnPrefixFilter filter = new ColumnPrefixFilter(Bytes.toBytes("titl"));
    Scan scan = new Scan();
    scan.addFamily(Bytes.toBytes(cf1));
    scan.setFilter(filter);
    scan.setBatch(10);
    ResultScanner rs = table.getScanner(scan);
    MyUtil.printResults(rs);
}
```

## MultipleColumnPrefixFilter
```java
/**
 * @func 匹配多个列名的前缀
 * @author jimo
 * @date 2018/8/20 9:00
 */
@Test
public void multiColumnPrefixFilter() throws IOException {
    byte[][] prefix = {Bytes.toBytes("my-column"), Bytes.toBytes("title")};
    MultipleColumnPrefixFilter filter = new MultipleColumnPrefixFilter(prefix);
    Scan scan = new Scan();
    scan.addFamily(Bytes.toBytes(cf1));
    scan.setFilter(filter);
    scan.setBatch(10);
    ResultScanner rs = table.getScanner(scan);
    MyUtil.printResults(rs);
}
```
## RowFilter
```java
/**
 * @func 行过滤器，可以加各种Comparator
 * @author jimo
 * @date 2018/8/20 9:18
 */
@Test
public void rowFilter() throws IOException {
    /*>=3的行,可以使用FilterList组合多个界限*/
    RowFilter beginRowFilter = new RowFilter(
            CompareFilter.CompareOp.GREATER_OR_EQUAL,
            new BinaryComparator(Bytes.toBytes(3))
    );
    Scan scan = new Scan();
    /*等价于：Scan scan = new Scan(Bytes.toBytes(1), Bytes.toBytes(10));*/
    scan.setFilter(beginRowFilter);
    scan.addFamily(Bytes.toBytes(cf1));
    ResultScanner scanner = table.getScanner(scan);
    MyUtil.printResults(scanner);
}
```
## FilterList
```java
/**
 * @func 过滤器列表
 * @author jimo
 * @date 2018/8/17 21:51
 */
@Test
public void filterList() throws IOException {
    FilterList filterList = new FilterList(FilterList.Operator.MUST_PASS_ALL);
//        new FilterList(FilterList.Operator.MUST_PASS_ALL);

    SingleColumnValueFilter filter1 = new SingleColumnValueFilter(
            Bytes.toBytes(cf1),
            Bytes.toBytes(title),
            CompareFilter.CompareOp.EQUAL,
            Bytes.toBytes("python教程2")
    );
    SingleColumnValueFilter filter2 = new SingleColumnValueFilter(
            Bytes.toBytes(cf1),
            Bytes.toBytes(title),
            CompareFilter.CompareOp.EQUAL,
            Bytes.toBytes("python教程3")
    );
    filterList.addFilter(filter1);
    filterList.addFilter(filter2);

    Scan scan = new Scan();
    scan.setFilter(filterList);
    ResultScanner results = table.getScanner(scan);
    MyUtil.printResults(results);
}
```
## FirstKeyOnlyFilter
```java
/**
 * @func 只取每一行的第一个KV，一般用于row count，如下(但这并不适合大表)
 * @author jimo
 * @date 2018/8/20 9:36
 */
@Test
public void firstKeyOnlyFilter() throws IOException {
    Scan scan = new Scan();
    scan.setFilter(new FirstKeyOnlyFilter());
    ResultScanner resultScanner = table.getScanner(scan);
    int totalRow = 0;
    for (Result result : resultScanner) {
        totalRow += result.size();
    }
    System.out.println("total rows: " + totalRow);
}
```
## PageFilter
```java
/**
 * @func 限制页数或用于分页
 * @author jimo
 * @date 18/8/20 10:34
 */
@Test
public void pageFilter() throws IOException {
    PageFilter pageFilter = new PageFilter(2);
    Scan scan = new Scan();
    scan.setStartRow(Bytes.toBytes("row-key-2"));
    scan.setStopRow(Bytes.toBytes("row-key-5"));
    scan.setFilter(pageFilter);
    ResultScanner results = table.getScanner(scan);
    for (Result result : results) {
        System.out.println(Bytes.toString(result.getRow()));
    }
}
```

# 最后-HbaseTemplate
HbaseTemplate是spring-data模块里对hbase操作的封装， 具体使用可以参考：
[hbaseTemplate use](https://www.programcreek.com/java-api-examples/index.php?api=org.springframework.data.hadoop.hbase.TableCallback)

[HBaseConnection](https://github.com/tguduru/Spring-HBase/blob/master/src/main/java/org/bigdata/hbase/spring/HBaseConnection.java)

# 参考
[http://hbase.apache.org/book.html#client_dependencies](http://hbase.apache.org/book.html#client_dependencies)

[http://www.corejavaguru.com/bigdata/hbase-tutorial/hbase-java-client-api-examples](http://www.corejavaguru.com/bigdata/hbase-tutorial/hbase-java-client-api-examples)

[http://hbase.apache.org/book.html#client.filter](http://hbase.apache.org/book.html#client.filter)

[https://hbase.apache.org/apidocs/org/apache/hadoop/hbase/client/Scan.html](https://hbase.apache.org/apidocs/org/apache/hadoop/hbase/client/Scan.html)


