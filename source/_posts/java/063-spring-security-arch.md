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



