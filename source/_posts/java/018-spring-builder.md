---
title: spring中的builder模式
tags:
  - java
  - spring
p: java/018-spring-builder
date: 2018-10-25 08:46:45
---

本文学习Spring框架中使用的Builder模式，从模仿到应用（举个例子）。

# builder模式理解
[导读](http://www.runoob.com/design-pattern/builder-pattern.html).

所以，如果你读了上面的例子，会发现几个不变的东西：
1. 意图是什么： 就是你认为用户搞不清楚构造过程，只知道要构建哪些东西，只关注结果而不是过程的老板
2. 举个例子： 麦当劳的套餐组合，电脑的组装，构造一个文件等等

那么我们就可以开始了。

# Spring中的Builder

在IDEA里输入Builder，借助智能提示，我们可以找到很多spring里的Builder类，而且大多数是内部类，以下是一些例子：
```java
import org.springframework.boot.autoconfigure.condition.ConditionMessage;
import org.springframework.cache.interceptor.CachePutOperation;
import org.springframework.http.ContentDisposition;
import org.springframework.web.servlet.mvc.method.RequestMappingInfo;

import org.springframework.beans.factory.support.BeanDefinitionBuilder;
```

具体细节展示：
```java
public final class ConditionMessage {
    private String message;

    private ConditionMessage(String message) {
        this.message = message;
    }

    public static ConditionMessage.Builder forCondition(String condition, Object... details) {
        return (new ConditionMessage()).andCondition(condition, details);
    }

    public final class Builder {
        private final String condition;

        private Builder(String condition) {
            this.condition = condition;
        }

        public ConditionMessage foundExactly(Object result) {
            return this.found("").items(result);
        }
    }
}


public class ContentDisposition {

    private ContentDisposition(@Nullable String type, @Nullable String name, @Nullable String filename, @Nullable Charset charset, @Nullable Long size, @Nullable ZonedDateTime creationDate, @Nullable ZonedDateTime modificationDate, @Nullable ZonedDateTime readDate) {
        this.type = type;
        this.name = name;
        this.filename = filename;
        this.charset = charset;
        this.size = size;
        this.creationDate = creationDate;
        this.modificationDate = modificationDate;
        this.readDate = readDate;
    }

    public static ContentDisposition.Builder builder(String type) {
        return new ContentDisposition.BuilderImpl(type);
    }

    public interface Builder {
        ContentDisposition.Builder name(String var1);

        ContentDisposition.Builder filename(String var1);

        ContentDisposition.Builder filename(String var1, Charset var2);

        ContentDisposition.Builder size(Long var1);

        ContentDisposition.Builder creationDate(ZonedDateTime var1);

        ContentDisposition.Builder modificationDate(ZonedDateTime var1);

        ContentDisposition.Builder readDate(ZonedDateTime var1);

        ContentDisposition build();
    }
}


public final class RequestMappingInfo implements RequestCondition<RequestMappingInfo> {

    public static RequestMappingInfo.Builder paths(String... paths) {
        return new RequestMappingInfo.DefaultBuilder(paths);
    }

    public interface Builder {
        RequestMappingInfo.Builder paths(String... var1);

        RequestMappingInfo.Builder methods(RequestMethod... var1);

        RequestMappingInfo.Builder params(String... var1);

        RequestMappingInfo.Builder headers(String... var1);

        RequestMappingInfo.Builder consumes(String... var1);

        RequestMappingInfo.Builder produces(String... var1);

        RequestMappingInfo.Builder mappingName(String var1);

        RequestMappingInfo.Builder customCondition(RequestCondition<?> var1);

        RequestMappingInfo.Builder options(RequestMappingInfo.BuilderConfiguration var1);

        RequestMappingInfo build();
    }
}
```
我想敏感的人已经看出来这是一个统一的模式，模式如下：
1. Builder都是被构建类的内部类，且被构建类提供了一个静态创建Builder的方法
2. Builder会返回构建的类，可能通过`build()`方法，也可能其他方法
3. 构建过程有很多参数，如果参数少，直接用构造函数好一点，且参数可以有默认值，用户只需选择想要的参数

现在我们提取出这套模式代码：
```java
public class BuilderTemplate {

	private Object param1;
	private Object param2;
	// params...

	/**
	 * 构造函数,一般为private,也可能根据需要为public,取决于需求
	 *
	 * @author jimo
	 * @date 2018/10/25 9:48
	 */
	private BuilderTemplate(Object param1, Object param2) {
		this.param1 = param1;
		this.param2 = param2;
	}

	public static Builder builder(Object... params) {
		return new BuilderImpl();
	}

	private static class BuilderImpl implements Builder {
		Object param1;
		Object param2;
		// ...

		@Override
		public Builder method1(Object param1) {
			this.param1 = param1;
			return this;
		}

		@Override
		public Builder method2(Object param2) {
			this.param2 = param2;
			return this;
		}

		@Override
		public BuilderTemplate build() {
			// 也可能复杂一点的构造过程,比如有顺序之类的
			return new BuilderTemplate(param1, param2);
		}
	}

	// other methods

	public interface Builder {
		Builder method1(Object param1);

		Builder method2(Object param2);
		//...

		BuilderTemplate build();
	}
}
```
如何使用呢？我想大家已经很熟悉了：
```java
final BuilderTemplate template = BuilderTemplate.builder()
        .method1("1")
        .method2("2")
        .build();
// 调用template对象的其他方法
```

# 模仿到应用
假如我们开了个对象中介所，给广大男女找寻另一半，伟大的工作，哈。
关键来了：找对象的人只会提要求（身高，体重，美貌，家境等），而不知道如何去找这样的人，这个就交给我们了。

为了简化一点，我们暂时只定义以下4条件：
1. 身高（cm）
2. 年龄（范围）
3. 颜值（数字1-10）
4. 收入（最低）

当然有些人没有条件，只要是异性就行（鉴于我国法律还没有允许同性婚姻，暂时保持异性把），这样就可以什么条件都不传。

以下就是按照模板写的例子：
```java
import org.springframework.util.Assert;

import java.util.ArrayList;
import java.util.List;

/**
 * 婚姻中介所
 *
 * @author jimo
 * @date 2018/10/25 10:13
 */
public class MarriageAgency {
	private Description desc;

	public MarriageAgency(Description desc) {
		this.desc = desc;
	}

	/**
	 * @author jimo
	 * @date 2018/10/25 10:42
	 */
	public static Builder builder() {
		return new BuilderImpl();
	}

	/**
	 * 从数据库检索符合条件的对象
	 *
	 * @param client 想找对象的人
	 * @author jimo
	 * @date 2018/10/25 10:17
	 */
	public List<String> findMate(Description client) {
		desc.sex = client.sex == 0 ? 1 : 0;
		return new ArrayList<>();
	}

	/**
	 * 对象描述信息
	 *
	 * @author jimo
	 * @date 2018/10/25 10:36
	 */
	public static class Description {
		int height;
		Age age;
		int income;
		int beautiness;

		/**
		 * 0:男性,1:女性
		 */
		int sex;
	}

	private static class Age {
		int low;
		int high;

		public Age(int low, int high) {
			this.low = low;
			this.high = high;
		}
	}

	private static class BuilderImpl implements Builder {

		Description desc;

		@Override
		public Builder height(int height) {
			Assert.isTrue(height > 10 && height < 300, "这不是合法的人类高度");
			this.desc.height = height;
			return this;
		}

		@Override
		public Builder ageBetween(int low, int high) {
			this.desc.age = new Age(low, high);
			return this;
		}

		@Override
		public Builder income(int low) {
			this.desc.income = low;
			return this;
		}

		@Override
		public Builder beautiness(int value) {
			this.desc.beautiness = value;
			return this;
		}

		@Override
		public MarriageAgency build() {
			return null;
		}
	}

	public interface Builder {
		Builder height(int height);

		Builder ageBetween(int low, int high);

		Builder income(int low);

		Builder beautiness(int value);

		MarriageAgency build();
	}
}

```
使用：
```java
final MarriageAgency agency = MarriageAgency.builder()
        .ageBetween(20, 30)
        .beautiness(9)
        .height(160)
        .income(10000)
        .build();
agency.findMate(new Description());
```
