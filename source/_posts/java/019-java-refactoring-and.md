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

接下来是编写单元测试，测试重构后是否正确，我们重构2层：

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

## DAO层

可以使用内存数据库模拟：https://blog.csdn.net/mn960mn/article/details/54644908

或者直接测：
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

//TODO 讨论下更好的方法？

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
