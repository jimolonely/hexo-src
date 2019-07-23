---
title: java运行js脚本
tags:
  - java
  - js
p: java/050-java-run-js
date: 2019-07-23 13:42:16
---

java中运行脚本，有时候真的用得着。比如，写一个json的API服务器时，想让用户自己写js来生成返回值。

# 基本使用

这篇博客讲得很详细，就不多说了：

https://blog.csdn.net/jianggujin/article/details/51046122


# 解析返回值

但是如何解析返回值，特别是对象时，就需要注意一下：

```java
import com.alibaba.fastjson.JSONObject;
import jdk.nashorn.api.scripting.JSObject;

import javax.script.Invocable;
import javax.script.ScriptEngine;

@Test
public void testJs() throws ScriptException, NoSuchMethodException {
  ScriptEngineManager manager = new ScriptEngineManager();
  ScriptEngine engine = manager.getEngineByName("js");
  String code = "function data() { var a = [];for(var i=0;i<10;i++){a[i] = \"jimo\"+i;}return a;}";
  engine.eval(code);
  Invocable invocable = (Invocable) engine;
  Object data = invocable.invokeFunction("data");
  JSObject obj = (JSObject) data;
  if (obj.isArray()) {

  }
  String result = JSONObject.toJSONString(obj);
  System.out.println(result);
}
```

https://stackoverflow.com/questions/23089938/how-to-unbox-values-returned-by-javascript-nashorn-in-java-object/23093248


