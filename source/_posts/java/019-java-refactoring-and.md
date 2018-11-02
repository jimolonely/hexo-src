---
title: java重构和单元测试规范
tags:
  - java
p: java/019-java-refactoring-and
date: 2018-10-29 20:01:30
---

# 引言
报着希望来重构。
# 重构代码规范

## 重构目标

1. 让代码可读
2. 让代码可测
3. 消除代码警告

按照我们讨论过的《Java代码规范》进行重构代码，使代码变得可测。
需要进行以下修改：

以DictController为例

## 重构之前
```java

// controller

@ResponseBody
@RequestMapping("/selectModuleByService")
public Result selectModuleByService(HttpServletRequest request, HttpServletResponse response) {
    return dictService.selectModuleByService(request, response);
}

// service

@Autowired
private OmsLogServiceDictDao serviceDictDao;

@Override
public Result selectModuleByService(HttpServletRequest request, HttpServletResponse response) {

    Result result = new Result();
    List<OmsLogServiceDict> list = new ArrayList<>();

    try {
        String service = StringUtils.nullToString(request.getParameter("service"));
        if (!"".equals(service)) {
            list = serviceDictDao.selectByService(service);
        } else {
            list = serviceDictDao.selectAll();
        }
        result.setError_code(ResultConstants.SUCCESS);
        result.setError_message(ResultConstants.MESSAGE_NULL);
        result.setData(list);
    } catch (Exception e) {
        result.setError_code(ResultConstants.FAILED);
        result.setError_message(ResultConstants.MESSAGE_EXCEPTION);
        logger.error(ResultConstants.MESSAGE_EXCEPTION, e);
    }

    return result;
}
```
## 重构过程

### 参数提取到controller层
同时在controller层验证参数，然后传给service层：

#### 无需封装的情况
当参数个数`<=7`个时。

```java

//controller

@ResponseBody
@RequestMapping("/selectModuleByService")
public Result selectModuleByService(HttpServletRequest request, HttpServletResponse response) {
    String service = StringUtils.nullToString(request.getParameter("service"));
    return dictService.selectModuleByService(service);
}

// service

@Override
public Result selectModuleByService(String service) {
    Result result = new Result();
    List<OmsLogServiceDict> list = new ArrayList<>();

    try {
        if (!"".equals(service)) {
            list = serviceDictDao.selectByService(service);
        } else {
            list = serviceDictDao.selectAll();
        }
        result.setError_code(ResultConstants.SUCCESS);
        result.setError_message(ResultConstants.MESSAGE_NULL);
        result.setData(list);
    } catch (Exception e) {
        result.setError_code(ResultConstants.FAILED);
        result.setError_message(ResultConstants.MESSAGE_EXCEPTION);
        logger.error(ResultConstants.MESSAGE_EXCEPTION, e);
    }

    return result;
}
```
#### 需要封装参数

如果参数超过7个，则封装为`Query对象`,如下：

```java
@Override
public Result addCounterName(HttpServletRequest request, HttpServletResponse response) {
    Result result = new Result();
    String[] column = new String[]{"countername", "status", "title", "units", "originalUnits",
    "unitsFactor", "deviceName", "datatype", "precision", "ifgather", "ifclear", "validstart",
    "validend", "createtime", "memo", "num", "ctgroup"};
    try {
        String countername = StringUtils.nullToString(request.getParameter("countername"));
        String status = StringUtils.nullToString(request.getParameter("status"));
        String title = StringUtils.nullToString(request.getParameter("title"));
        String units = StringUtils.nullToString(request.getParameter("units"));
        String originalUnits = StringUtils.nullToString(request.getParameter("originalUnits"));
        String unitsFactor = StringUtils.nullToString(request.getParameter("unitsFactor"));
        String deviceName = StringUtils.nullToString(request.getParameter("deviceName"));
        String datatype = StringUtils.nullToString(request.getParameter("datatype"));
        String precision = StringUtils.nullToString(request.getParameter("precision"));
        String ifgather = StringUtils.nullToString(request.getParameter("ifgather"));
        String ifclear = StringUtils.nullToString(request.getParameter("ifclear"));
        String validstart = StringUtils.nullToString(request.getParameter("validstart"));
        String validend = StringUtils.nullToString(request.getParameter("validend"));
        String memo = StringUtils.nullToString(request.getParameter("memo"));
        long num = counterNameDao.getNum(0);

        String numStr = IntegerUtil.decimalToHLevelForLength(num + 1, 3);
        String ctgroup = StringUtils.nullToString(request.getParameter("ctgroup"));
        String createtime = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date());

        String[] value = new String[]{countername, status, title, units, originalUnits, unitsFactor,
            deviceName, datatype, precision, ifgather, ifclear, validstart, validend,
            createtime, memo, numStr, ctgroup};

        counterNameDao.addCounterName(countername, column, value);
        counterNameDao.getNum(1);
        result.setError_code(ResultConstants.SUCCESS);
        result.setError_message(ResultConstants.MESSAGE_NULL);
        result.setData("");
    } catch (Exception e) {
        result.setError_code(ResultConstants.FAILED);
        result.setError_message(ResultConstants.MESSAGE_EXCEPTION);
        logger.error(ResultConstants.MESSAGE_EXCEPTION, e);
    }
    return result;
}
```
然后，如果你发现该类还有一个或多个参数类似的方法：
```java
@Override
public Result modifyCounterName(HttpServletRequest request, HttpServletResponse response) {
    Result result = new Result();
    String[] column = new String[]{"countername", "status", "title", "units", "originalUnits", "unitsFactor",
     "deviceName", "datatype", "precision", "ifgather", "ifclear", "validstart", "validend",
     "updatetime", "num", "memo", "ctgroup"};
    try {
        String rowkey = StringUtils.nullToString(request.getParameter("rowkey"));
        String countername = StringUtils.nullToString(request.getParameter("countername"));
        String status = StringUtils.nullToString(request.getParameter("status"));
        String title = StringUtils.nullToString(request.getParameter("title"));
        String units = StringUtils.nullToString(request.getParameter("units"));
        String originalUnits = StringUtils.nullToString(request.getParameter("originalUnits"));
        String unitsFactor = StringUtils.nullToString(request.getParameter("unitsFactor"));
        String deviceName = StringUtils.nullToString(request.getParameter("deviceName"));
        String datatype = StringUtils.nullToString(request.getParameter("datatype"));
        String precision = StringUtils.nullToString(request.getParameter("precision"));
        String ifgather = StringUtils.nullToString(request.getParameter("ifgather"));
        String ifclear = StringUtils.nullToString(request.getParameter("ifclear"));
        String validstart = StringUtils.nullToString(request.getParameter("validstart"));
        String validend = StringUtils.nullToString(request.getParameter("validend"));
        String memo = StringUtils.nullToString(request.getParameter("memo"));
        String ctgroup = StringUtils.nullToString(request.getParameter("ctgroup"));
        String num = StringUtils.nullToString(request.getParameter("num"));
        String updatetime = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date());
        String[] value = new String[]{countername, status, title, units, originalUnits, unitsFactor,
             deviceName, datatype, precision, ifgather, ifclear, validstart, validend,
             updatetime, num, memo, ctgroup};

        counterNameDao.modifyCounterName(rowkey, countername, column, value);
        result.setError_code(ResultConstants.SUCCESS);
        result.setError_message(ResultConstants.MESSAGE_NULL);
        result.setData("");
    } catch (Exception e) {
        result.setError_code(ResultConstants.FAILED);
        result.setError_message(ResultConstants.MESSAGE_EXCEPTION);
        logger.error(ResultConstants.MESSAGE_EXCEPTION, e);
    }
    return result;
}
```
则可以按多的参数来封装，这样多个方法也可以复用：
```java
public class CounterQuery {
    private String rowKey;
	private String counterName;
	private String status;
	private String title;
	private String units;
	private String originalUnits;
	private String unitsFactor;
	private String deviceName;
	private String dataType;
	private String precision;
	private String ifGather;
	private String ifClear;
	private String validStart;
	private String validEnd;
	private String memo;
	private String ctGroup;
	private String num;

	public CounterQuery(String rowKey, String counterName, String status, String title, String units,
						String originalUnits, String unitsFactor, String deviceName, String dataType,
						String precision, String ifGather, String ifClear, String validStart, String validEnd,
						String memo, String ctGroup, String num) {
		this.rowKey = rowKey;
		this.counterName = counterName;
		this.status = status;
		this.title = title;
		this.units = units;
		this.originalUnits = originalUnits;
		this.unitsFactor = unitsFactor;
		this.deviceName = deviceName;
		this.dataType = dataType;
		this.precision = precision;
		this.ifGather = ifGather;
		this.ifClear = ifClear;
		this.validStart = validStart;
		this.validEnd = validEnd;
		this.memo = memo;
		this.ctGroup = ctGroup;
		this.num = num;
	}

    //getters
}
```

注意：

1. 提出的对象命名：根据业务场景的对象+Query，如上面的CounterQuery
2. 属性必须采用驼峰命名法，不能出现拼写错误下划线警告
3. 该类放在model包的query（需新建）包下

重构后的service层如下：
```java
@Override
public Result addCounterName(CounterQuery counter) {
    Result result = new Result();
    String[] column = new String[]{"countername", "status", "title", "units", "originalUnits", "unitsFactor",
            "deviceName", "datatype", "precision", "ifgather", "ifclear", "validstart", "validend",
            "createtime", "memo", "num", "ctgroup"};
    try {
        long num = counterNameDao.getNum(0);
        String numStr = IntegerUtil.decimalToHLevelForLength(num + 1, 3);
        String createtime = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date());

        String[] value = new String[]{counter.getCounterName(), counter.getStatus(), counter.getTitle(),
                counter.getUnits(), counter.getOriginalUnits(), counter.getUnitsFactor(),
                counter.getDeviceName(), counter.getDataType(), counter.getPrecision(),
                counter.getIfGather(), counter.getIfClear(), counter.getValidStart(), counter.getValidEnd(),
                createtime, counter.getMemo(), numStr, counter.getCtGroup()};

        counterNameDao.addCounterName(counter.getCounterName(), column, value);
        counterNameDao.getNum(1);
        result.setError_code(ResultConstants.SUCCESS);
        result.setError_message(ResultConstants.MESSAGE_NULL);
        result.setData("");
    } catch (Exception e) {
        result.setError_code(ResultConstants.FAILED);
        result.setError_message(ResultConstants.MESSAGE_EXCEPTION);
        logger.error(ResultConstants.MESSAGE_EXCEPTION, e);
    }
    return result;
}
```

controller现在负责接收参数：
```java
@RequestMapping("/addCounterName")
public Result addCounterName(HttpServletRequest request, HttpServletResponse response) {
    String countername = StringUtils.nullToString(request.getParameter("countername"));
    String status = StringUtils.nullToString(request.getParameter("status"));
    String title = StringUtils.nullToString(request.getParameter("title"));
    String units = StringUtils.nullToString(request.getParameter("units"));
    String originalUnits = StringUtils.nullToString(request.getParameter("originalUnits"));
    String unitsFactor = StringUtils.nullToString(request.getParameter("unitsFactor"));
    String deviceName = StringUtils.nullToString(request.getParameter("deviceName"));
    String datatype = StringUtils.nullToString(request.getParameter("datatype"));
    String precision = StringUtils.nullToString(request.getParameter("precision"));
    String ifgather = StringUtils.nullToString(request.getParameter("ifgather"));
    String ifclear = StringUtils.nullToString(request.getParameter("ifclear"));
    String validstart = StringUtils.nullToString(request.getParameter("validstart"));
    String validend = StringUtils.nullToString(request.getParameter("validend"));
    String memo = StringUtils.nullToString(request.getParameter("memo"));
    String ctgroup = StringUtils.nullToString(request.getParameter("ctgroup"));

    return counterNameService.addCounterName(new CounterQuery(null, countername, status,
            title, units, originalUnits, unitsFactor, deviceName, datatype, precision, ifgather,
            ifclear, validstart, validend, memo, ctgroup, null));
}
```

### 返回Map对象
对于service返回封装的Map对象是不推荐的，如下：`com.sinorail.base.service.impl.HomeServiceImpl#homeData`
```java
map.put("vcpus_used_Count", vcpus_used_Count + "");
map.put("vcpusCount", vcpusCount + "");

map.put("mem_used_Count", mem_used_Count);
map.put("memCount", memCount);
map.put("store", store);

map.put("node_cpu_max", node_cpu_max);
map.put("node_cpu_avg", node_cpu_avg);
map.put("activeVm_cpu_max", activeVm_cpu_max);
map.put("activeVm_cpu_avg", activeVm_cpu_avg);
```

需要封装成对象：`DTO(data transfer object)`：

1. 放在model包的dto包下
2. 封装的对象命名： 业务对象+DTO
3. 成员属性命名要符合规范


### service层的DAO采用构造注入
这种方式是推荐的：

1. 没有警告
2. 便于后面测试

```java
private final OmsLogServiceDictDao serviceDictDao;
private final OmsLogOpDictDao opDictDao;

@Autowired
public DictServiceImpl(OmsLogServiceDictDao serviceDictDao, OmsLogOpDictDao opDictDao) {
    this.serviceDictDao = serviceDictDao;
    this.opDictDao = opDictDao;
}
```
### 根据IDEA的阿里插件提示消除警告

#### 消除代码警告

比如，这个service的`new ArrayList<>()`是没有必要的，应该舍去：
```java
@Override
public Result selectModuleByService(String service) {
    Result result = new Result();
    List<OmsLogServiceDict> list;

    try {
        if (!"".equals(service)) {
            list = serviceDictDao.selectByService(service);
        } else {
            list = serviceDictDao.selectAll();
        }
        result.setError_code(ResultConstants.SUCCESS);
        result.setError_message(ResultConstants.MESSAGE_NULL);
        result.setData(list);
    } catch (Exception e) {
        result.setError_code(ResultConstants.FAILED);
        result.setError_message(ResultConstants.MESSAGE_EXCEPTION);
        logger.error(ResultConstants.MESSAGE_EXCEPTION, e);
    }

    return result;
}
```

#### 加上类和方法注释
标注修改的时间和人，采用以下格式：

```java
/**
 * @author jimo
 * @date 2018/10/29 10:10
 */
@Service
public class DictServiceImpl implements DictService {

    /**
     * <p>根据服务名查找服务，如果服务名为空，返回所有</p>
     *
     * @param service 服务名
     * @author jimo
     * @date 2018/10/29 10:10
     */
    @Override
    public Result selectModuleByService(String service) {
        Result result = new Result();
        List<OmsLogServiceDict> list;

        try {
            if (!"".equals(service)) {
                list = serviceDictDao.selectByService(service);
            } else {
                list = serviceDictDao.selectAll();
            }
            result.setError_code(ResultConstants.SUCCESS);
            result.setError_message(ResultConstants.MESSAGE_NULL);
            result.setData(list);
        } catch (Exception e) {
            result.setError_code(ResultConstants.FAILED);
            result.setError_message(ResultConstants.MESSAGE_EXCEPTION);
            logger.error(ResultConstants.MESSAGE_EXCEPTION, e);
        }

        return result;
    }
}
```

## 命名重构

1. mybatis的接口命名：XxxMapper（我们现在很多Dao，要不要改？）
2. 其他参考之前讨论过的命名方式

接下来是编写单元测试，测试重构后是否正确，我们对2层编写测试：

1. DAO层：包括pgsql，hbase，es等
2. service层

# 单元测试规范
依然接着上面。

如果测试环境有单独的配置文件，则需要声明：
```java
@RunWith(SpringRunner.class)
@SpringBootTest
@ActiveProfiles("test")
public class XxxTest {
}
```
配置文件以 `application-test.yml`命名。

使用`Ctrl+shift+T`生成测试类，需要以下几个注意点：

覆盖的范围，采用`BCDE`原则：

* B：Border，边界值测试，包括循环边界、特殊取值、特殊时间点、数据顺序等。
* C：Correct，正确的输入，并得到预期的结果。
* D：Design，与设计文档相结合，来编写单元测试。
* E：Error，强制错误信息输入（如：非法数据、异常流程、非业务允许输入等），并得
到预期的结果。

## 测试类和方法命名

1. 测试类命名采用在后面加`Test`的命名方式
2. 方法命名保持不变

```java
public class DictServiceImplTest {

	@Test
	public void selectModuleByService() {
	}
}
```

对于有些方法可以放在一起测的，只写一个方法就行，比如：
```java
public interface AssetMapper {

	Asset getAsset(@Param("id") String id);

	void batchInsert(@Param("assets") List<Asset> assets) throws Exception;
}
```
可以先插入再获取判断结果：
```java
@Test
@Transactional
@Rollback
public void batchInsert_getAsset() throws Exception {
    List<Asset> assets = new ArrayList<>();
    final Asset asset1 = new Asset();
    asset1.setId("id1");
    asset1.setIad_tag("tag-jimo");
    assets.add(asset1);

    final Asset asset2 = new Asset();
    asset2.setId("id2");
    asset2.setIad_tag("tag-jimo2");
    assets.add(asset2);

    mapper.batchInsert(assets);

    assertEquals("tag-jimo2", mapper.getAsset("id2").getIad_tag());
    assertEquals("tag-jimo", mapper.getAsset("id1").getIad_tag());
}
```
这个方法的命名采用方法名+下划线连接（//TODO这个讨论）

## DAO层

### 使用真的数据库

```java
@RunWith(SpringRunner.class)
@SpringBootTest
public class OmsLogServiceDictDaoTest {

	@Autowired
	private OmsLogServiceDictDao dictDao;

    @Test
	public void selectByService() {
		// Correct
		final List<OmsLogServiceDict> nova = dictDao.selectByService("nova");
		for (OmsLogServiceDict n : nova) {
			assertEquals("nova", n.getService());
		}

		// 不存在的数据
		final List<OmsLogServiceDict> list = dictDao.selectByService("jimo love jimo");
		assertEquals(0, list.size());

		// 不合法参数
		final List<OmsLogServiceDict> list2 = dictDao.selectByService(null);
		assertEquals(0, list2.size());
	}
}
```

对于有修改的操作，采用事务：
```java
@RunWith(SpringRunner.class)
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.NONE)
@EnableTransactionManagement
public class AssetMapperTest {

    @Test
    @Transactional
    @Rollback
    public void batchInsert() throws Exception {
        List<Asset> assets = new ArrayList<>();
        final Asset asset1 = new Asset();
        asset1.setId("id1");
        asset1.setIad_tag("tag-jimo");
        assets.add(asset1);

        final Asset asset2 = new Asset();
        asset2.setId("id2");
        asset2.setIad_tag("tag-jimo2");
        assets.add(asset2);

        mapper.batchInsert(assets);

        assertEquals("tag-jimo2", mapper.getAsset("id2").getIad_tag());
        assertEquals("tag-jimo", mapper.getAsset("id1").getIad_tag());
    }
}
```

### 使用内存数据库模拟

我们使用[h2内存数据库](http://www.h2database.com/html/features.html).然后集成在框架里。
以下是测试环境搭建过程：

#### 加入h2依赖

```java
<dependency>
    <groupId>com.h2database</groupId>
    <artifactId>h2</artifactId>
    <scope>test</scope>
</dependency>
```

#### 新增测试环境配置文件
复制一份`application-dev.yml`,重命名为：`application-test.yml`.内容只有数据库配置改变，以iad-web为例：
```yml
spring:
  application:
    name: iad-web
  #数据库连接
  datasource:
    url: jdbc:h2:mem:test;DB_CLOSE_DELAY=-1;MODE=PostgreSQL
#    url: jdbc:h2:mem:test;MODE=PostgreSQL;INIT=CREATE SCHEMA IF NOT EXISTS public;SCHEMA=public
    username:
    password:
    driverClassName: org.h2.Driver
    schema: classpath:sql/init-table.sql
    data: classpath:sql/data-asset.sql

  #     redis配置
  redis:
    database: 0
    host: 192.168.17.68
    port: 6379
    password:
    jedis:
      pool:
        max-wait: 1000
        max-active: 500
        max-idle: 300


# mybatis xml配置
mybatis:
  config-location: classpath:mybatis-config.xml
  mapper-locations: classpath:mappers/**/*.xml

#  elasticsearch
es:
  cluster-name: sinorail
  hosts: 192.168.17.57,192.168.17.64,192.168.17.65
  port: 9300

hbase:
  quorum: hadoop4:2181,hadoop5:2181,hadoop6:2181
  rootDir: /hbase

# 上传文件的临时目录
upload-temp-dir: E:\\
```

#### 准备测试数据

就目前阶段来说，我们可以直接从数据库导出一部分数据，然后稍微修改一下，就可以给h2用了。

看上面的配置文件，有一个初始数据表的sql：init-table.sql
```sql
DROP TABLE IF EXISTS assets_asset;
CREATE TABLE assets_asset (
  id varchar(255)  NOT NULL DEFAULT NULL::character varying,
  ip varchar(255)  DEFAULT NULL::character varying,
  name varchar(255)  DEFAULT NULL::character varying,
  hostname varchar(255)  DEFAULT NULL::character varying,
  is_delete varchar(10)  DEFAULT NULL::character varying,
  region varchar(255)  DEFAULT NULL::character varying,
  cloud_uuid varchar(255)  DEFAULT NULL::character varying,
  iad_tag varchar(255)  DEFAULT NULL::character varying,
  monitor_name varchar(255)  DEFAULT NULL::character varying,
  createtime varchar(50)  DEFAULT NULL::character varying,
  updatetime varchar(50)  DEFAULT NULL::character varying,
  host_type varchar(5)  DEFAULT NULL::character varying,
  cabinet_id varchar(100)  DEFAULT NULL::character varying,
  vm_uuid varchar(64)  DEFAULT NULL::character varying,
  role varchar(100)  DEFAULT NULL::character varying,
  az varchar(100)  DEFAULT NULL::character varying,
  code varchar(20)  DEFAULT NULL::character varying,
  ipmi_monitor_name varchar(100)  DEFAULT NULL::character varying,
  tags text
)
;
ALTER TABLE assets_asset ADD CONSTRAINT assets_asset_pkey PRIMARY KEY (id);
```

还有初始化数据的：data-asset.sql:

```sql
INSERT INTO assets_asset VALUES ('95c79372-ef67-4e13-8763-51de090b9d19', '192.168.17.81', 'sr-controller-1 192.168.17.81', 'sr-controller-1', '0', 'RegionFCsan', 'bc33ca7c-36a0-4b02-b81e-9b1862edf902', 'tag1', 'sr-controller-1-192.168.17.81', '2018-10-30 12:51:58.35294+08', '2018-10-30 12:51:58.35294+08', 'node', '7f482dc5-2e8d-4235-b154-3a989b5ff55c', NULL, 'controller', NULL, '1023', NULL, '[testtt3,quchunjian,openstack集群]');
INSERT INTO assets_asset VALUES ('9ce0d5f7-fb30-4879-8c0d-32b75f2df4a9', '192.168.68.10', 'openstack集群192.168.17.96_controller-2_457a6de0-43', NULL, '0', 'RegionFCsan', 'bc33ca7c-36a0-4b02-b81e-9b1862edf902', 'tag2', '9ce0d5f7-fb30-4879-8c0d-32b75f2df4a9', '2018-10-30 12:51:58.35294+08', '2018-10-30 12:51:58.35294+08', 'vm', '7f482dc5-2e8d-4235-b154-3a989b5ff55c', '457a6de0-43ba-4446-b2a4-68f7414c0631', 'others', NULL, '1023', NULL, '[]');
INSERT INTO assets_asset VALUES ('3725ce2d-ad04-4643-9a2d-be4be90295d6', '192.168.68.17', 'openstack集群192.168.17.96_xkjtest_7a488799-82', NULL, '0', 'RegionFCsan', 'bc33ca7c-36a0-4b02-b81e-9b1862edf902', NULL, '3725ce2d-ad04-4643-9a2d-be4be90295d6', '2018-10-30 12:51:58.35294+08', '2018-10-30 12:51:58.35294+08', 'vm', '7f482dc5-2e8d-4235-b154-3a989b5ff55c', '7a488799-826a-4849-ad23-46506c2df006', 'others', NULL, '1023', NULL, '[testtt3,testtt2]');
INSERT INTO assets_asset VALUES ('e0f3825a-538a-4a9b-9dfa-061cd5bf3209', '192.168.68.15', 'openstack集群192.168.17.96_xkjtest3-j349Yskc-0_e275d517-c2', NULL, '0', 'RegionFCsan', 'bc33ca7c-36a0-4b02-b81e-9b1862edf902', NULL, 'e0f3825a-538a-4a9b-9dfa-061cd5bf3209', '2018-10-30 12:51:58.35294+08', '2018-10-30 12:51:58.35294+08', 'vm', '7f482dc5-2e8d-4235-b154-3a989b5ff55c', 'e275d517-c2db-438b-b06e-51dec0a13e8b', 'others', NULL, '1023', NULL, '[]');
INSERT INTO assets_asset VALUES ('0bf59686-449b-413b-8d0f-b35aaa4c1039', '192.168.68.13', 'openstack集群192.168.17.96_kyf-mon-test_2bd4445a-d1', NULL, '0', 'RegionFCsan', 'bc33ca7c-36a0-4b02-b81e-9b1862edf902', NULL, '0bf59686-449b-413b-8d0f-b35aaa4c1039', '2018-10-30 12:51:58.35294+08', '2018-10-30 12:51:58.35294+08', 'vm', '7f482dc5-2e8d-4235-b154-3a989b5ff55c', '2bd4445a-d12f-4bcb-9738-83db13bdbad2', 'others', NULL, '1023', NULL, '[]');
INSERT INTO assets_asset VALUES ('7c4e03de-c08f-4fac-868a-c272fe075bd9', '192.168.68.7', 'openstack集群192.168.17.96_fdd-mon-test_abf88ee7-a5', NULL, '0', 'RegionFCsan', 'bc33ca7c-36a0-4b02-b81e-9b1862edf902', 'tag3', '7c4e03de-c08f-4fac-868a-c272fe075bd9', '2018-10-30 12:51:58.35294+08', '2018-10-30 12:51:58.35294+08', 'vm', '7f482dc5-2e8d-4235-b154-3a989b5ff55c', 'abf88ee7-a564-4d09-95a0-54176323b179', 'others', NULL, '1023', NULL, '[]');
INSERT INTO assets_asset VALUES ('edac0b31-0217-452d-8f71-ef663d4add67', '192.168.68.5', 'openstack集群192.168.17.96_勿删-iad-test-new_333ea8e0-73', NULL, '0', 'RegionFCsan', 'bc33ca7c-36a0-4b02-b81e-9b1862edf902', NULL, 'edac0b31-0217-452d-8f71-ef663d4add67', '2018-10-30 12:51:58.35294+08', '2018-10-30 12:51:58.35294+08', 'vm', '7f482dc5-2e8d-4235-b154-3a989b5ff55c', '333ea8e0-73b1-4fb9-ae43-c5922dcfe95a', 'others', NULL, '1023', NULL, '[testtt3,testtt2]');
INSERT INTO assets_asset VALUES ('f05b8971-027f-47dd-bc63-61f93a5f0e6e', '192.168.68.12', 'openstack集群192.168.17.96_controller-3_1f6b331f-40', NULL, '0', 'RegionFCsan', 'bc33ca7c-36a0-4b02-b81e-9b1862edf902', NULL, 'f05b8971-027f-47dd-bc63-61f93a5f0e6e', '2018-10-30 12:51:58.35294+08', '2018-10-30 12:51:58.35294+08', 'vm', NULL, '1f6b331f-40c4-4d35-97aa-697c8e986ed6', 'others', NULL, '1023', NULL, '[]');
INSERT INTO assets_asset VALUES ('caa53ba6-df04-40f5-b4da-5331c4c76374', '192.168.68.20', 'openstack集群192.168.17.96_xkjtest2_9deaa847-78', NULL, '0', 'RegionFCsan', 'bc33ca7c-36a0-4b02-b81e-9b1862edf902', 'tag3', 'caa53ba6-df04-40f5-b4da-5331c4c76374', '2018-10-30 12:51:58.35294+08', '2018-10-30 12:51:58.35294+08', 'vm', NULL, '9deaa847-7813-4f21-8599-bb0c085171a0', 'others', NULL, '1023', NULL, '[]');
INSERT INTO assets_asset VALUES ('a67a866b-eb74-4156-a847-06b93a006fa0', '192.168.68.19', 'openstack集群192.168.17.96_xkjtest3-j349Yskc-3_7cb018c8-0d', NULL, '0', 'RegionFCsan', 'bc33ca7c-36a0-4b02-b81e-9b1862edf902', 'tag2', 'a67a866b-eb74-4156-a847-06b93a006fa0', '2018-10-30 12:51:58.35294+08', '2018-10-30 12:51:58.35294+08', 'vm', NULL, '7cb018c8-0da0-4c74-834d-f20eb37b4448', 'others', NULL, '1023', NULL, '[]');
INSERT INTO assets_asset VALUES ('baa7e333-0578-412a-81f8-49cd870b48f8', '192.168.68.21', 'openstack集群192.168.17.96_xkjtest3-j349Yskc-4_33273ca7-58', NULL, '0', 'RegionFCsan', 'bc33ca7c-36a0-4b02-b81e-9b1862edf902', NULL, 'baa7e333-0578-412a-81f8-49cd870b48f8', '2018-10-30 12:51:58.35294+08', '2018-10-30 12:51:58.35294+08', 'vm', NULL, '33273ca7-58af-412f-b428-72da15df19cd', 'others', NULL, '1023', NULL, '[]');
```

**注意点：我们导出的数据如下：**
```sql
DROP TABLE IF EXISTS "public"."assets_asset";
```
**我们需要去除schema（也就是public）和双引号，直接替换或者写个程序转换，否则会出现语法错误**

#### 编写测试类

```java
@RunWith(SpringRunner.class)
@ActiveProfiles("test")
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.NONE)
public class AssetMapperTest {

	@Autowired
	private AssetMapper mapper;

	@Test
	public void getAsset() {
		final Asset asset = mapper.getAsset("95c79372-ef67-4e13-8763-51de090b9d19");
		assertEquals("192.168.17.81", asset.getIp());
	}

	@Test
	public void batchInsert() throws Exception {
		final Asset asset = new Asset();
		asset.setId("id1");
		asset.setIad_tag("tag-jimo");
		List<Asset> assets = new ArrayList<>();
		assets.add(asset);
		asset.setId("id2");
		assets.add(asset);

		mapper.batchInsert(assets);
		assertEquals(4, mapper.allIagtag().size());
	}

	@Test
	public void deleteAll_AllIadTag() {
		final List<Asset> assets = mapper.allIagtag();
		assertEquals(3, assets.size());

		mapper.deleteAll();
		assertEquals(0, mapper.allIagtag().size());
	}
}
```
上面的批量插入报语法错误，这也是没办法的事。但基本查询都没问题。

还有需要知道的是：
```java
// 使用测试的配置文件
@ActiveProfiles("test")
// 不加载web环境，跑起来更快
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.NONE)
```

### 具体怎么做？

**真实数据库有好处也有坏处：好处就是能得到最真实的结果。坏处就多了：比如**

1. 可能遇到冷启动（初始时没数据）
2. 不稳定（数据会不断变化，导致测试用例不能重复执行）
3. 还有一个就是慢。

**内存数据库固然不错，但并不能支持pgsql的所有语法，导致有些测试无法进行。**

而使用开发数据库来测是不稳定的，所以最好的办法就是有一套测试的数据库，内置一些数据来测试。

//TODO hbase, ES 等的数据构造

## Service层
这一层可以经过简化，不需要加载整个应用，所以需要用到Mock对象，这是Spring自带的，
通过模拟数据库DAO层的数据，我们只关注Service层的方法。

```java
import org.junit.runner.RunWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnitRunner;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.when;

@RunWith(MockitoJUnitRunner.class)
public class DictServiceImplTest {

	@InjectMocks
	private DictServiceImpl dictService;

	@Mock
	private OmsLogServiceDictDao dictDao;

	@Test
	public void selectModuleByService() {
		String service = "glance";
		final OmsLogServiceDict d1 = new OmsLogServiceDict();
		d1.setService(service);
		final OmsLogServiceDict d2 = new OmsLogServiceDict();
		d2.setService("xxx");

		// Correct
		when(dictDao.selectByService("glance")).thenReturn(Collections.singletonList(d1));
		assertEquals(1, ((List) dictService.selectModuleByService("glance").getData()).size());

		// Error
		when(dictDao.selectByService("nova")).thenThrow(IllegalArgumentException.class);
		assertEquals("1", dictService.selectModuleByService("nova").getError_code());

		// Border
		when(dictDao.selectByService("glance")).thenReturn(Arrays.asList(d1, d2));
		assertEquals(0, ((List) dictService.selectModuleByService("neutron").getData()).size());
	}
}
```

# 难点
1. 构造测试的数据
2. 保持测试代码的持久性

# 结语
祝大家好运！
