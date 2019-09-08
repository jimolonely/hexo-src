---
title: spring-boot starter原理
tags:
  - java
  - spring-boot
p: java/064-spring-boot-starter-priciple
date: 2019-09-08 07:53:22
---

在上一篇{% post_link java/057-spring-boot-starter-demo 自定义spring-boot starter步骤 %}中从实践角度写了spring-boot的starter demo，今天，从原理的角度来解析下starter的原理。

# 1.父pom文件

```xml
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>2.1.7.RELEASE</version>
        <relativePath/> <!-- lookup parent from repository -->
    </parent>
```

```xml
  <parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-dependencies</artifactId>
    <version>2.1.7.RELEASE</version>
    <relativePath>../../spring-boot-dependencies</relativePath>
  </parent>
```
这里面定义了几乎所有常用的依赖的版本和依赖管理声明、插件管理声明：
```xml
<properties>
    <activemq.version>5.15.9</activemq.version>
    <antlr2.version>2.7.7</antlr2.version>
    <appengine-sdk.version>1.9.76</appengine-sdk.version>
    <artemis.version>2.6.4</artemis.version>
    <aspectj.version>1.9.4</aspectj.version>
    <assertj.version>3.11.1</assertj.version>
    <atomikos.version>4.0.6</atomikos.version>
    <bitronix.version>2.1.4</bitronix.version>
    <build-helper-maven-plugin.version>3.0.0</build-helper-maven-plugin.version>
    <byte-buddy.version>1.9.16</byte-buddy.version>
    <caffeine.version>2.6.2</caffeine.version>
    <cassandra-driver.version>3.6.0</cassandra-driver.version>
    <classmate.version>1.4.0</classmate.version>
    <commons-codec.version>1.11</commons-codec.version>
    <commons-dbcp2.version>2.5.0</commons-dbcp2.version>
    <commons-lang3.version>3.8.1</commons-lang3.version>
    <commons-pool.version>1.6</commons-pool.version>
    <commons-pool2.version>2.6.2</commons-pool2.version>
    <couchbase-cache-client.version>2.1.0</couchbase-cache-client.version>
    <couchbase-client.version>2.7.7</couchbase-client.version>
    <derby.version>10.14.2.0</derby.version>
    <dom4j.version>1.6.1</dom4j.version>
    ...
```
你肯定会好奇，这么多依赖为什么并没有全部引入，导致我们的jar包异常庞大？这就是maven的依赖管理知识（dependencyManagement）了，只有子类声明了相应的依赖才会导入，而且不需要声明版本，因为spring-boot已经做了。

# 2.starter的本质

当我们引入以下依赖时，我们到底在干什么？
```xml
  <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-web</artifactId>
  </dependency>
```
根据官方文档：[https://docs.spring.io/spring-boot/docs/current/reference/htmlsingle/#using-boot-starter](https://docs.spring.io/spring-boot/docs/current/reference/htmlsingle/#using-boot-starter)，starter由2部门构成：

`spring-boot-starter` + `功能场景`，因此又叫`功能场景启动器`。

因此，starter的本质就是一个功能的依赖提取，比如`spring-boot-starter-web`：引入了tomcat、spring的webmvc等依赖
```xml
 <dependencies>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter</artifactId>
      <version>2.1.7.RELEASE</version>
      <scope>compile</scope>
    </dependency>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-json</artifactId>
      <version>2.1.7.RELEASE</version>
      <scope>compile</scope>
    </dependency>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-tomcat</artifactId>
      <version>2.1.7.RELEASE</version>
      <scope>compile</scope>
    </dependency>
    <dependency>
      <groupId>org.hibernate.validator</groupId>
      <artifactId>hibernate-validator</artifactId>
      <version>6.0.17.Final</version>
      <scope>compile</scope>
    </dependency>
    <dependency>
      <groupId>org.springframework</groupId>
      <artifactId>spring-web</artifactId>
      <version>5.1.9.RELEASE</version>
      <scope>compile</scope>
    </dependency>
    <dependency>
      <groupId>org.springframework</groupId>
      <artifactId>spring-webmvc</artifactId>
      <version>5.1.9.RELEASE</version>
      <scope>compile</scope>
    </dependency>
  </dependencies>
```

接下来你肯定要问这些依赖是如何被加载到程序中的，比如，我们没有显示声明tomcat依赖，但运行时会存在，这是如何加载的，下面就会说明。

# 3.@SpringBootApplication注解

该注解的代码如下：
```java
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
@Documented
@Inherited
@SpringBootConfiguration
@EnableAutoConfiguration
@ComponentScan(excludeFilters = { @Filter(type = FilterType.CUSTOM, classes = TypeExcludeFilter.class),
		@Filter(type = FilterType.CUSTOM, classes = AutoConfigurationExcludeFilter.class) })
```
我们分析每一个注解。

## @@SpringBootConfiguration

这是一个spring-boot项目的注解类，查看其定义：
```java
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
@Documented
@Configuration
public @interface SpringBootConfiguration {
}
```
事实上只是`@Configuration`的另一种声明，只是一个是spring的注解，一个是spring-boot的，那意义就很明确了：

声明在一个类上，标识这是一个配置类，也就是以前的一个spring的配置文件，而本质上，其也是一个componenet
```java
@Target({ElementType.TYPE})
@Retention(RetentionPolicy.RUNTIME)
@Documented
@Component
public @interface Configuration {
    @AliasFor(
        annotation = Component.class
    )
    String value() default "";
}
```

## @EnableAutoConfiguration
从意思上就知道这是一个允许自动配置的注解，啥是自动配置呢？

显然，我们以前使用spring会写一个个配置文件，而现在都不用写了，并不是不存在配置了，而是spring-boot帮我们做了，这就是自动配置。

而这个注解如何做到的呢，看源码：
```java
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
@Documented
@Inherited
@AutoConfigurationPackage
@Import(AutoConfigurationImportSelector.class)
public @interface EnableAutoConfiguration{}
```
这里又有2个注解，不要急，慢慢来。

### @AutoConfigurationPackage
显然，这是一个`允许自动配置包`的注解。

```java
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
@Documented
@Inherited
@Import(AutoConfigurationPackages.Registrar.class)
public @interface AutoConfigurationPackage {
}
```
到这里已经发现，`@Import`是一个spring底层注解，作用是给容器中导入一个组件，这里导入的组件由`AutoConfigurationPackages.Registrar`类指定，那我们就继续看。

```java
	static class Registrar implements ImportBeanDefinitionRegistrar, DeterminableImports {

		@Override
		public void registerBeanDefinitions(AnnotationMetadata metadata, BeanDefinitionRegistry registry) {
			register(registry, new PackageImport(metadata).getPackageName());
		}

		@Override
		public Set<Object> determineImports(AnnotationMetadata metadata) {
			return Collections.singleton(new PackageImport(metadata));
		}

	}
```
我们在这打个断点，如下：

{% asset_img 000.png %}

可以看到这个注解是在`SpringBootPkgWarApplication`类上注入的，运行的表达式结果为`com.jimo`包，也就是说，spring-boot会将所在主类（@SpringBootApplication标注的类）所在包下所有的组件扫描到容器中，也就是说：你在`com.jimo`外的包下声明的组件是不会被注入的，不信试试。

### @Import(AutoConfigurationImportSelector.class)
再看另一个注解：这个也是直接导入，不过是自动配置导入的选择器。

这个自动导入选择器的类定义如下：
```java
public class AutoConfigurationImportSelector implements DeferredImportSelector, BeanClassLoaderAware,
		ResourceLoaderAware, BeanFactoryAware, EnvironmentAware, Ordered{}
```
里面有一个方法：作用是返回一个全名称限制的类迭代器，这些类都是组件类
```java
		@Override
		public void process(AnnotationMetadata annotationMetadata, DeferredImportSelector deferredImportSelector) {
			Assert.state(deferredImportSelector instanceof AutoConfigurationImportSelector,
					() -> String.format("Only %s implementations are supported, got %s",
							AutoConfigurationImportSelector.class.getSimpleName(),
							deferredImportSelector.getClass().getName()));
			AutoConfigurationEntry autoConfigurationEntry = ((AutoConfigurationImportSelector) deferredImportSelector)
					.getAutoConfigurationEntry(getAutoConfigurationMetadata(), annotationMetadata);
			this.autoConfigurationEntries.add(autoConfigurationEntry);
			for (String importClassName : autoConfigurationEntry.getConfigurations()) {
				this.entries.putIfAbsent(importClassName, annotationMetadata);
			}
		}
```
我们进入`getAutoConfigurationEntry`这个方法：

```java
	protected AutoConfigurationEntry getAutoConfigurationEntry(AutoConfigurationMetadata autoConfigurationMetadata,
			AnnotationMetadata annotationMetadata) {
		if (!isEnabled(annotationMetadata)) {
			return EMPTY_ENTRY;
		}
		AnnotationAttributes attributes = getAttributes(annotationMetadata);
		List<String> configurations = getCandidateConfigurations(annotationMetadata, attributes);
		configurations = removeDuplicates(configurations);
		Set<String> exclusions = getExclusions(annotationMetadata, attributes);
		checkExcludedClasses(configurations, exclusions);
		configurations.removeAll(exclusions);
		configurations = filter(configurations, autoConfigurationMetadata);
		fireAutoConfigurationImportEvents(configurations, exclusions);
		return new AutoConfigurationEntry(configurations, exclusions);
	}
```

打个断点可以看到导入的一些配置类：总共有118个

{% asset_img 002.png %}

那么这些配置类从哪来的呢？ 进入`getCandidateConfigurations`方法：
```java
	protected List<String> getCandidateConfigurations(AnnotationMetadata metadata, AnnotationAttributes attributes) {
		List<String> configurations = SpringFactoriesLoader.loadFactoryNames(getSpringFactoriesLoaderFactoryClass(),
				getBeanClassLoader());
		Assert.notEmpty(configurations, "No auto configuration classes found in META-INF/spring.factories. If you "
				+ "are using a custom packaging, make sure that file is correct.");
		return configurations;
	}
```
最终可以跟踪到：`loadSpringFactories`方法
```java
	public static List<String> loadFactoryNames(Class<?> factoryClass, @Nullable ClassLoader classLoader) {
		String factoryClassName = factoryClass.getName();
		return loadSpringFactories(classLoader).getOrDefault(factoryClassName, Collections.emptyList());
	}

	private static Map<String, List<String>> loadSpringFactories(@Nullable ClassLoader classLoader) {
		MultiValueMap<String, String> result = cache.get(classLoader);
		if (result != null) {
			return result;
		}

		try {
			Enumeration<URL> urls = (classLoader != null ?
					classLoader.getResources(FACTORIES_RESOURCE_LOCATION) :
					ClassLoader.getSystemResources(FACTORIES_RESOURCE_LOCATION));
			result = new LinkedMultiValueMap<>();
			while (urls.hasMoreElements()) {
				URL url = urls.nextElement();
				UrlResource resource = new UrlResource(url);
				Properties properties = PropertiesLoaderUtils.loadProperties(resource);
				for (Map.Entry<?, ?> entry : properties.entrySet()) {
					String factoryClassName = ((String) entry.getKey()).trim();
					for (String factoryName : StringUtils.commaDelimitedListToStringArray((String) entry.getValue())) {
						result.add(factoryClassName, factoryName.trim());
					}
				}
			}
			cache.put(classLoader, result);
			return result;
		}
		catch (IOException ex) {
			throw new IllegalArgumentException("Unable to load factories from location [" +
					FACTORIES_RESOURCE_LOCATION + "]", ex);
		}
	}
```
这里有个常量：`public static final String FACTORIES_RESOURCE_LOCATION = "META-INF/spring.factories";`

到了这里，也就明白这个配置文件的作用了：

{% asset_img 003.ppng %}

另外，特别注意`loadFactoryNames`这个方法：
```java
	public static List<String> loadFactoryNames(Class<?> factoryClass, @Nullable ClassLoader classLoader) {
		String factoryClassName = factoryClass.getName();
		return loadSpringFactories(classLoader).getOrDefault(factoryClassName, Collections.emptyList());
	}
```
如果打个断电在这里，可以看看`factoryClassName`变量的变化，都是`spring.factories`里声明的各个组：
```java
# Initializers
org.springframework.context.ApplicationContextInitializer=\

# Application Listeners
org.springframework.context.ApplicationListener=\

# Auto Configuration Import Listeners
org.springframework.boot.autoconfigure.AutoConfigurationImportListener=\

# Auto Configuration Import Filters
org.springframework.boot.autoconfigure.AutoConfigurationImportFilter=\

# Auto Configure
org.springframework.boot.autoconfigure.EnableAutoConfiguration=\
...
```



