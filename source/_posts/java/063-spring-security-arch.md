---
title: spring security架构原理
tags:
  - java
  - spring
p: java/063-spring-security-arch
date: 2019-09-07 15:01:00
---

本文翻译自：[https://spring.io/guides/topicals/spring-security-architecture](https://spring.io/guides/topicals/spring-security-architecture)

# Spring-security架构

本指南是Spring Security的入门读物，可深入了解框架的设计和基本构建块。我们只介绍应用程序安全性的基础知识，但这样做可以清除使用Spring Security的开发人员所遇到的一些困惑。为此，我们将介绍使用过滤器在Web应用程序中应用安全性的方式，更常见的是使用方法注释。当您需要高级了解安全应用程序如何工作，如何自定义，或者您只需要学习如何考虑应用程序安全性时，请使用本指南。

本指南不是作为解决超过最基本问题的手册或秘诀（还有其他来源），但它对初学者和专家都很有用。 Spring Boot也引用了很多，因为它为安全应用程序提供了一些默认行为，了解它如何适应整体架构非常有用。所有原则同样适用于不使用Spring Boot的应用程序。

# 身份验证和访问控制

应用程序安全性可归结为两个或多或少独立的问题：身份验证（您是谁？）和授权（您可以做什么？）。 有时人们会说“访问控制”而不是“授权”，这可能会让人感到困惑，但以这种方式来思考是有帮助的，因为“授权”会在其他地方超载。 Spring Security的架构旨在将身份验证与授权分开，并为两者提供策略和扩展点。

## 认证

用于身份验证的主要策略接口是`AuthenticationManager`，它只有一个方法：
```java
public interface AuthenticationManager {

  Authentication authenticate(Authentication authentication)
    throws AuthenticationException;
}
```

AuthenticationManager可以在`authenticate()`方法中执行以下三种操作之一：

1. 如果它可以验证输入是否代表有效的主体，则返回`Authentication`（通常使用`authenticated = true`）。

2. 如果它认为输入表示无效的主体，则抛出`AuthenticationException`。

3. 如果无法决定，则返回null。

`AuthenticationException`是一个运行时异常。它通常由应用程序以通用方式处理，具体取决于应用程序的样式或用途。换句话说，通常不希望用户代码捕获并处理它。例如，Web UI将呈现一个页面，表明身份验证失败，后端HTTP服务将发送`401`响应，具有或不具有`WWW-Authenticate`标头，具体取决于上下文。

`AuthenticationManager`最常用的实现是`ProviderManager`，它委托一系列`AuthenticationProvider`实例。 `AuthenticationProvider`有点像`AuthenticationManager`，但它有一个额外的方法允许调用者查询它是否支持给定的身份验证类型：

```java
public interface AuthenticationProvider {

	Authentication authenticate(Authentication authentication)
			throws AuthenticationException;

	boolean supports(Class<?> authentication);

}
```
`supports()`方法中的`Class<?>`参数实际上是`Class<? extends Authentication>`（只会询问它是否支持将传递给`authenticate()`方法的内容）。 通过委派给`AuthenticationProviders`链，`ProviderManager`可以在同一个应用程序中支持多种不同的身份验证机制。 如果`ProviderManager`无法识别特定的身份验证实例类型，则会跳过它。

`ProviderManager`有一个可选的父级，如果所有提供者都返回null，它就可供参考。 如果父级不可用，则null验证会导致`AuthenticationException`。

有时，应用程序具有受保护资源的逻辑组（例如，与路径模式`/ api / **`匹配的所有Web资源），并且每个组可以具有其自己的专用`AuthenticationManager`。 通常，每个都是`ProviderManager`，并且它们共享父级。 然后，父级就是一种“全球”资源，充当所有provider的后备资源。

{% asset_img 000.png %}

## 自定义Authentication Manager

Spring Security提供了一些配置帮助程序，可以快速获取应用程序中设置的常见身份验证管理器功能。 最常用的帮助程序是`AuthenticationManagerBuilder`，它非常适合设置`内存，JDBC或LDAP用户详细信息`，或者用于添加自定义`UserDetailsService`。 以下是配置全局（父）`AuthenticationManager`的应用程序示例：

```java
@Configuration
public class ApplicationSecurity extends WebSecurityConfigurerAdapter {

   ... // web stuff here

  @Autowired
  public void initialize(AuthenticationManagerBuilder builder, DataSource dataSource) {
    builder.jdbcAuthentication().dataSource(dataSource).withUser("dave")
      .password("secret").roles("USER");
  }

}
```
此示例涉及Web应用程序，但`AuthenticationManagerBuilde`r的使用范围更广泛（有关如何实现Web应用程序安全性的更多详细信息，请参阅下文）。 请注意，`AuthenticationManagerBuilder`是`@Autowired`到`@Bean`中的方法 - 这是使它构建全局（父）`AuthenticationManager`的原因。 相反，如果我们这样做：

```java
@Configuration
public class ApplicationSecurity extends WebSecurityConfigurerAdapter {

  @Autowired
  DataSource dataSource;

   ... // web stuff here

  @Override
  public void configure(AuthenticationManagerBuilder builder) {
    builder.jdbcAuthentication().dataSource(dataSource).withUser("dave")
      .password("secret").roles("USER");
  }

}
```
（使用配置程序中的方法的`@Override`），然后`AuthenticationManagerBuilder`仅用于构建“本地”`AuthenticationManager`，它是全局的`AuthenticationManager`。 在Spring Boot应用程序中，您可以`@Autowired`全局的bean到另一个bean，但除非您自己明确地公开它，否则不能使用本地bean。

Spring Boot提供了一个默认的全局`AuthenticationManager`（只有一个用户），除非您通过提供自己的`AuthenticationManager`类型的bean来抢占它。 除非您主动需要自定义全局`AuthenticationManager`，否则默认设置足够安全，您不必担心它。 如果您执行构建`AuthenticationManager`的任何配置，您通常可以在本地执行您正在保护的资源，而不必担心全局默认值。

## 授权或访问控制

一旦身份验证成功，我们就可以继续授权，这里的核心策略是`AccessDecisionManager`。 框架提供了三个实现，并且所有三个委托给`AccessDecisionVoter`链，有点像`ProviderManager`委托给`AuthenticationProviders`。

`AccessDecisionVoter`考虑`Authentication `（表示主体）和使用`ConfigAttributes`修饰的安全对象：

```java
boolean supports(ConfigAttribute attribute);

boolean supports(Class<?> clazz);

int vote(Authentication authentication, S object,
        Collection<ConfigAttribute> attributes);
```
Object在`AccessDecisionManager`和`AccessDecisionVoter`的签名中是完全通用的 - 它表示用户可能想要访问的任何内容（Web资源或Java类中的方法是两种最常见的情况）。 `ConfigAttributes`也非常通用，表示安全对象的装饰，其中包含一些元数据，用于确定访问它所需的权限级别。 `ConfigAttribute`是一个接口，但它只有一个非常通用的方法并返回一个String，因此这些字符串以某种方式编码资源所有者的意图，表达允许谁访问它的规则。典型的`ConfigAttribute`是用户角色的名称（如`ROLE_ADMIN`或`ROLE_AUDIT`），它们通常具有特殊格式（如`ROLE_前缀`）或表示需要评估的表达式。

大多数人只使用`AffirmativeBased`的默认`AccessDecisionManager`（如果任何选民肯定地返回，则授予访问权限）。任何定制都倾向于在选民中发生，要么添加新的定制，要么修改现有定制的方式。

使用Spring表达式语言（SpEL）表达式的`ConfigAttributes`是很常见的，例如`isFullyAuthenticated()&& hasRole('FOO')`。这是由`AccessDecisionVoter`支持的，它可以处理表达式并为它们创建上下文。要扩展可处理的表达式范围，需要自定义实现`SecurityExpressionRoot`，有时还需要`SecurityExpressionHandler`。

# 网络安全

Web层中的Spring Security（用于UI和HTTP后端）基于Servlet过滤器，因此通常首先查看过滤器的作用是有帮助的。 下图显示了单个HTTP请求的处理程序的典型分层。

{% asset_img 001.png %}

客户端向应用程序发送请求，容器根据请求URI的路径决定哪些过滤器和哪个servlet应用于它。最多只有一个servlet可以处理单个请求，但是过滤器形成一个链，因此它们是有序的，实际上，如果过滤器想要处理请求本身，它可以否决链的其余部分。过滤器还可以修改下游过滤器和servlet中使用的请求和/或响应。过滤器链的顺序非常重要，Spring Boot通过两种机制对其进行管理：一种是类型为Filter的`@Beans`可以有`@Order`或者实现`Ordered`，另一种是它们可以成为`FilterRegistrationBean`的一部分。order作为其API的一部分。一些现成的过滤器定义了它们自己的常量，以帮助表明它们相对于彼此的顺序（例如，来自Spring Session的`SessionRepositoryFilter`的`DEFAULT_ORDER`为`Integer.MIN_VALUE + 50`，这告诉我们它喜欢早在链中，但它不排除其前的其他过滤器）。

Spring Security作为链中的单个Filter安装，其`concerete`类型是`FilterChainProxy`，原因很快就会显现出来。在Spring Boot应用程序中，安全筛选器是`ApplicationContext`中的`@Bean`，默认情况下会安装它，以便将其应用于每个请求。它安装在`SecurityProperties.DEFAULT_FILTER_ORDER`定义的位置，而该位置又由`FilterRegistrationBean.REQUEST_WRAPPER_FILTER_MAX_ORDER`（Spring Boot应用程序期望过滤器在包装请求时修改其行为所需的最大顺序）进行锚定。除此之外还有更多：从容器的角度来看，Spring Security是一个单独的过滤器，但在其中有一些额外的过滤器，每个过滤器都扮演着特殊的角色。这是一张图片：

{% asset_img 002.png %}
图2. Spring Security是一个单独的物理过滤器，但将处理委托给一系列内部过滤器

事实上，安全过滤器中甚至还有一层间接：它通常作为`DelegatingFilterProxy`安装在容器中，它不必是Spring` @Bean`。代理委托给`FilterChainProxy`，它始终是`@Bean`，通常具有固定名称`springSecurityFilterChain`。它是`FilterChainProxy`，它包含内部排列为过滤器链（或链）的所有安全逻辑。所有过滤器都具有相同的API（它们都实现了Servlet规范中的`Filter`接口），并且它们都有机会否决链的其余部分。

Spring Security可以在同一顶级`FilterChainProxy`中管理多个过滤器链，并且容器都是未知的。 Spring Security过滤器包含过滤器链列表，并将请求分派给与其匹配的第一个链。下图显示了基于匹配请求路径（`/ foo / **`匹配在`/ **`之前）发生的调度。这是非常常见的，但不是匹配请求的唯一方法。此调度过程的最重要特征是只有一个链处理请求。

{% asset_img 003.png %}
图3. Spring Security FilterChainProxy将请求分派给匹配的第一个链。

没有自定义安全配置的vanilla Spring Boot应用程序有几个（称为n）过滤器链，通常n = 6。 第一个（n-1）链只是为了忽略静态资源模式，比如`/ css / **`和`/ images / **`，以及`/error`视图（路径可以由具有安全性的用户控制。 `SecurityProperties`配置bean）。 最后一个链匹配捕获所有路径 `/ **`并且更活跃，包含用于身份验证，授权，异常处理，会话处理，标题写入等的逻辑。默认情况下，此链中总共有11个过滤器，但通常它 用户不必关心使用哪些过滤器以及何时使用过滤器。

>注意
>Spring安全内部的所有过滤器都不为容器所知，这一点很重要，尤其是在Spring Boot应用程序中，默认情况下，所有类型为`Filter`的`@Beans`都会自动注册到容器中。 因此，如果要向安全链添加自定义筛选器，则需要将其设置为`@Bean`，或者将其包装在显式禁用容器注册的`FilterRegistrationBean`中。

## 创建并自定义Filter链

Spring Boot应用程序（具有`/ **`请求匹配器的应用程序）中的默认回退筛选器链具有`SecurityProperties.BASIC_AUTH_ORDER`的预定义顺序。 您可以通过设置`security.basic.enabled = false`将其完全关闭，或者您可以将其用作后备并仅使用较低的顺序定义其他规则。 为此，只需添加一个类型为`WebSecurityConfigurerAdapter`（或`WebSecurityConfigurer`）的`@Bean`，并使用`@Order`修饰该类。 例

```java
@Configuration
@Order(SecurityProperties.BASIC_AUTH_ORDER - 10)
public class ApplicationConfigurerAdapter extends WebSecurityConfigurerAdapter {
  @Override
  protected void configure(HttpSecurity http) throws Exception {
    http.antMatcher("/foo/**")
     ...;
  }
}
```
此bean将导致Spring Security添加新的过滤器链并在回退之前对其进行排序。

与另一组资源相比，许多应用程序对一组资源具有完全不同的访问规则。例如，承载UI和支持API的应用程序可能支持基于cookie的身份验证，其中重定向到UI部件的登录页面，而基于令牌的身份验证具有401响应未经身份验证的API部件请求。每组资源都有自己的`WebSecurityConfigurerAdapter`，它具有唯一的顺序和自己的请求匹配器。如果匹配规则重叠，则最早的有序过滤器链将获胜。

## 请求匹配调度和授权

安全过滤器链（或等效的`WebSecurityConfigurerAdapter`）具有请求匹配器，用于决定是否将其应用于HTTP请求。一旦决定应用特定过滤器链，则不应用其他过滤器链。但是在过滤器链中，您可以通过在`HttpSecurity`配置器中设置其他匹配器来对授权进行更细粒度的控制。例：
```java
@Configuration
@Order(SecurityProperties.BASIC_AUTH_ORDER - 10)
public class ApplicationConfigurerAdapter extends WebSecurityConfigurerAdapter {
  @Override
  protected void configure(HttpSecurity http) throws Exception {
    http.antMatcher("/foo/**")
      .authorizeRequests()
        .antMatchers("/foo/bar").hasRole("BAR")
        .antMatchers("/foo/spam").hasRole("SPAM")
        .anyRequest().isAuthenticated();
  }
}
```
配置Spring Security最容易犯的错误之一就是忘记这些匹配器适用于不同的进程，一个是整个过滤器链的请求匹配器，另一个是选择要应用的访问规则。

## 将应用程序安全规则与执行器(Actuator)规则相结合

如果您将Spring Boot Actuator用于管理端点，您可能希望它们是安全的，并且默认情况下它们将是安全的。实际上，只要将Actuator添加到安全应用程序中，您就会获得仅适用于执行器端点的附加过滤器链。它由一个只匹配执行器端点的请求匹配器定义，它的`ManagementServerProperties.BASIC_AUTH_ORDER`顺序比默认的`SecurityProperties`回退过滤器少5，因此在回退之前会查询它。

如果您希望将应用程序安全规则应用于执行器端点，则可以添加比执行器端点更早排序的过滤器链以及包含所有执行器端点的请求匹配器。如果您更喜欢执行器端点的默认安全设置，那么最简单的方法是在执行器之后添加您自己的过滤器，但比回退更早（例如`ManagementServerProperties.BASIC_AUTH_ORDER + 1`）。例：
```java
@Configuration
@Order(ManagementServerProperties.BASIC_AUTH_ORDER + 1)
public class ApplicationConfigurerAdapter extends WebSecurityConfigurerAdapter {
  @Override
  protected void configure(HttpSecurity http) throws Exception {
    http.antMatcher("/foo/**")
     ...;
  }
}
```

>注意
>Web层中的Spring Security目前与Servlet API相关联，因此它仅在嵌入式或其他方式在servlet容器中运行应用程序时才真正适用。 但是，它不依赖于Spring MVC或Spring Web堆栈的其余部分，因此可以在任何servlet应用程序中使用，例如使用JAX-RS的应用程序。

# 方法安全

除了支持保护Web应用程序外，Spring Security还支持将访问规则应用于Java方法执行。 对于Spring Security，这只是一种不同类型的“受保护资源”。 对于用户来说，这意味着使用相同格式的`ConfigAttribute`字符串（例如角色或表达式）声明访问规则，但是在代码中的不同位置。 第一步是启用方法安全性，例如在我们的应用程序的顶级配置中：
```java
@SpringBootApplication
@EnableGlobalMethodSecurity(securedEnabled = true)
public class SampleSecureApplication {
}
```
然后我们可以直接装饰方法资源，例如
```java
@Service
public class MyService {

  @Secured("ROLE_USER")
  public String secure() {
    return "Hello Security";
  }

}
```
此示例是具有安全方法的服务。 如果Spring创建了这种类型的`@Bean`，那么它将被代理，并且调用者必须在实际执行该方法之前通过安全拦截器。 如果访问被拒绝，则调用者将获得`AccessDeniedException`而不是实际的方法结果。

还有其他注释可用于强制执行安全约束的方法，特别是`@PreAuthorize`和`@PostAuthorize`，它们允许您编写包含对方法参数和返回值的引用的表达式。

>提示
>将Web安全性和方法安全性结合起来并不罕见。 过滤器链提供用户体验功能，如身份验证和重定向到登录页面等，方法安全性可在更细粒度的级别提供保护。

# 使用线程
Spring Security基本上是线程绑定的，因为它需要使当前经过身份验证的主体可供各种下游消费者使用。 基本构建块是`SecurityContext`，它可能包含身份验证（当用户登录时，它将是一个明确验证的身份验证）。 您始终可以通过`SecurityContextHolder`中的静态便捷方法访问和操作`SecurityContext`，而`SecurityContextHolder`又可以简单地操作TheadLocal，例如：
```java
SecurityContext context = SecurityContextHolder.getContext();
Authentication authentication = context.getAuthentication();
assert(authentication.isAuthenticated);
```
用户应用程序代码执行此操作并不常见，但如果您需要编写自定义身份验证筛选器（例如，即使这样，Spring Security中的基类也可以在需要避免使用的地方使用） 使用`SecurityContextHolder`）。

如果需要访问Web端点中当前经过身份验证的用户，则可以在`@RequestMapping`中使用方法参数。 例如。
```java
@RequestMapping("/foo")
public String foo(@AuthenticationPrincipal User user) {
  ... // do stuff with user
}
```
如果您需要编写在不使用Spring Security时有效的代码（在加载`Authentication`类时需要更加防御），这有时会很有用。

## 异步处理方法安全

由于`SecurityContext`是线程绑定的，因此如果要进行任何调用安全方法的后台处理，例如 使用`@Async`，您需要确保传播上下文。 这归结为使用在后台执行的任务（`Runnable，Callable`等）包装`SecurityContext`。 Spring Security提供了一些帮助，使其更容易，例如`Runnable和Callable`的包装器。 要将`SecurityContext`传播到`@Async`方法，您需要提供`AsyncConfigurer`并确保`Executor`的类型正确：
```java
@Configuration
public class ApplicationConfiguration extends AsyncConfigurerSupport {

  @Override
  public Executor getAsyncExecutor() {
    return new DelegatingSecurityContextExecutorService(Executors.newFixedThreadPool(5));
  }

}
```

