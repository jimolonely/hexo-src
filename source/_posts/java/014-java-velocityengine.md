---
title: java模板类：用代码生成代码
tags:
  - java
  - 元编程
p: java/014-java-velocityengine
date: 2018-10-10 14:46:49
---

尝尝用代码生成代码的元编程方式，写一个AI来编程把。

# 准备
```java
<dependency>
    <groupId>org.apache.velocity</groupId>
    <artifactId>velocity</artifactId>
    <version>1.7</version>
</dependency>
```
# 模板
新建一个以vm结尾的文件，里面放模板语法。

{% asset_img 000.png %}

```java
public class Person{
    #foreach ($filed in $fields)
    private String $filed;
    #end
}
```
关于这个语法，参看：[https://velocity.apache.org/engine/1.7/user-guide.html](https://velocity.apache.org/engine/1.7/user-guide.html).

# 编程
进行动态注入数据，生成代码
```java
import org.apache.velocity.Template;
import org.apache.velocity.VelocityContext;
import org.apache.velocity.app.VelocityEngine;
import org.apache.velocity.runtime.RuntimeConstants;
import org.apache.velocity.runtime.resource.loader.ClasspathResourceLoader;

import java.io.*;
import java.util.Arrays;
import java.util.List;

public class TestTemplate {

	public static void main(String[] args) throws IOException {
		final VelocityEngine velocityEngine = new VelocityEngine();
		velocityEngine.setProperty(RuntimeConstants.RESOURCE_LOADER, "classpath");
		velocityEngine.setProperty("classpath.resource.loader.class", ClasspathResourceLoader.class.getName());
		velocityEngine.init();

		final Template template = velocityEngine.getTemplate("template.vm");

		// 准备点数据,可能从配置文件读取
		List<String> fields = Arrays.asList("name", "age", "title", "content");

		final VelocityContext context = new VelocityContext();
		context.put("fields", fields);

		final StringWriter writer = new StringWriter();
		template.merge(context, writer);
		System.out.println(writer.toString());

		// 或者写入文件
		Writer fileWriter = new PrintWriter(new File("Person.java"));
		template.merge(context, fileWriter);
		fileWriter.flush();
	}
}
```
结果：
```java
public class Person{
        private String name;
        private String age;
        private String title;
        private String content;
}
```
