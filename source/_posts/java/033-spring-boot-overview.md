---
title: spring-boot概览
tags:
  - java
  - spring-boot
p: java/033-spring-boot-overview
date: 2019-03-07 20:23:29
---

在一头扎入源码之前，还是对整个模块的结构和功能有个了解，避免一头雾水。

根据[springboot github 首页](https://github.com/spring-projects/spring-boot)介绍，有下面的模块。

# spring-boot

主库提供支持Spring Boot其他部分的功能，包括：

1. 在SpringApplication类，提供静态便捷方法，可以很容易写一个独立的Spring应用程序。它唯一的工作是创建和刷新适当的SpringApplicationContext
2. 可选择容器的嵌入式Web应用程序（Tomcat，Jetty或Undertow）
3. 一流的外部化配置支持
4. 便利ApplicationContext初始化程序，包括支持合理的日志记录默认值

# spring-boot-autoconfigure
Spring Boot可以根据类路径的内容 配置常见应用程序的大部分内容。单个@EnableAutoConfiguration注释会触发Spring上下文的自动配置。

自动配置尝试推断用户可能需要的bean。例如，如果 HSQLDB在类路径上，并且用户尚未配置任何数据库连接，则他们可能希望定义内存数据库。当用户开始定义自己的bean时，自动配置将退居回来。

# spring-boot-starters
启动器是一组方便的依赖关系描述符，您可以在应用程序中包含这些描述符。您可以获得所需的所有Spring和相关技术的一站式服务，而无需搜索示例代码并复制粘贴的依赖描述符。例如，如果您想开始使用Spring和JPA进行数据库访问，只需spring-boot-starter-data-jpa在项目中包含依赖项，那么您就可以了。

# spring-boot-cli
Spring命令行应用程序编译并运行Groovy源代码，这使得编写最少的代码以使应用程序运行得非常容易。Spring CLI还可以监视文件，在更改时自动重新编译和重新启动。

# spring-boot-actuator
通过执行器(actuator)端点，您可以监控应用程序并与之交互。执行器提供执行器端点所需的基础结构。它包含对执行器端点的注解支持。开箱，该模块提供了许多端点包括HealthEndpoint，EnvironmentEndpoint，BeansEndpoint等等。

# spring-boot-actuator-autoconfigure
这提供了基于类路径的内容和一组属性的执行器端点的自动配置。例如，如果Micrometer位于类路径上，它将自动配置MetricsEndpoint。它包含通过HTTP或JMX公开端点的配置。就像Spring Boot AutoConfigure一样，当用户开始定义自己的bean时，这将会消失。

# spring-boot-test
此模块包含在测试应用程序时可能有用的核心项和注解。

# spring-boot-test-autoconfigure
与其他Spring Boot自动配置模块一样，spring-boot-test-autoconfigure为基于类路径的测试提供自动配置。它包含许多注解，可用于自动配置需要测试的应用程序段。

# spring-boot-loader
Spring Boot Loader提供了秘密调试，允许您构建可以使用的单个jar文件`java -jar`。通常，您不需要spring-boot-loader直接使用 ，而是使用 Gradle或 Maven插件。

# spring-boot-devtools
spring-boot-devtools模块提供额外的开发时间功能，例如自动重启，以获得更流畅的应用程序开发体验。运行完全打包的应用程序时会自动禁用开发人员工具。

