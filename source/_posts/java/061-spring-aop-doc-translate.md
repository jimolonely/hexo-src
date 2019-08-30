---
title: spring aop文档阅读与翻译
tags:
  - java
  - spring
  - aop
p: java/061-spring-aop-doc-translate
date: 2019-08-30 10:42:55
---

本文翻译自Spring AOP文档： [https://docs.spring.io/spring/docs/current/spring-framework-reference/core.html#aop](https://docs.spring.io/spring/docs/current/spring-framework-reference/core.html#aop)

面向切面编程（AOP：Aspect-oriented Programming ）通过提供另一种思考程序结构的方式来补充面向对象编程（OOP）。 OOP中模块化的关键单元是类，而在AOP中，模块化单元是切面。 切面实现了跨越多种类型和对象的关注点（例如事务管理）的模块化。 （这些关注在AOP文献中通常被称为“横切”问题。）

Spring的一个关键组件是AOP框架。 虽然Spring IoC容器不依赖于AOP（意味着您不需要使用AOP），但AOP补充了Spring IoC以提供非常强大的中间件解决方案。

带有AspectJ切入点的Spring AOP
```java
Spring通过使用基于模式的方法或@AspectJ注解样式，提供了编写自定义切面的简单而强大的方法。 
这两种样式都提供完全类型的通知和使用AspectJ切入点语言，同时仍然使用Spring AOP进行编织。

本章讨论基于模式和@ AspectJ的AOP支持。 下一章将讨论较低级别的AOP支持。
```

AOP在Spring Framework中用于：

* 提供声明性企业服务。 最重要的此类服务是声明式事务管理。
* 让用户实现自定义切面，使用AOP补充他们的OOP。

> 如果您只对通用声明性服务或其他预先打包的声明性中间件服务（如池）感兴趣，则无需直接使用Spring AOP，并且可以跳过本章的大部分内容。

# 1.AOP概念
让我们首先定义一些中心AOP概念和术语。这些术语不是特定于Spring的。不幸的是，AOP术语不是特别直观。但是，如果Spring使用自己的术语，那将更加令人困惑。

* 切面(Aspect)：跨越多个类别的关注点的模块化。事务管理是企业Java应用程序中横切关注点的一个很好的例子。在Spring AOP中，切面是通过使用常规类（基于模式的方法）或使用`@Aspect`注解（@AspectJ样式）注解的常规类来实现的。
* 连接点(Join point)：程序执行期间的一个点，例如执行方法或处理异常。在Spring AOP中，连接点始终表示方法执行。
* 通知(Advice)：特定连接点的某个切面采取的操作。不同类型的advice包括“周围(around)”，“之前(before)”和“之后(after)”通知。 （advice类型将在后面讨论。）许多AOP框架（包括Spring）将通知建模为拦截器并在连接点周围维护一系列拦截器。
* 切入点(Pointcut)：匹配连接点的谓词。advice与切入点表达式相关联，并在切入点匹配的任何连接点处运行（例如，执行具有特定名称的方法）。由切入点表达式匹配的连接点的概念是AOP的核心，Spring默认使用AspectJ切入点表达式语言。
* 引入(introduction)：代表类型声明其他方法或字段。 Spring AOP允许您向任何advice的对象引入新接口（以及相应的实现）。例如，您可以使用introduction使bean实现IsModified接口，以简化缓存。 （introduction被称为AspectJ社区中的类型间声明）
* 目标对象(target object)：由一个或多个aspect通知的对象。也称为“通知对象(advised object)”。由于Spring AOP是使用运行时代理实现的，因此该对象始终是代理对象。
* AOP代理：由AOP框架创建的对象，用于实现aspect契约（通知方法执行等）。在Spring Framework中，AOP代理是JDK动态代理或CGLIB代理。
* 编织(weaving)：将aspect与其他应用程序类型或对象链接以创建通知对象(advised object)。这可以在编译时（例如，使用AspectJ编译器）、加载时间或在运行时完成。与其他纯Java AOP框架一样，Spring AOP在运行时执行编织。

Spring AOP包括以下类型的通知(advice)：

* before advice：在连接点之前运行但无法阻止执行流程进入连接点的通知（除非它抛出异常）。
* after returning advice：在连接点正常完成后运行的通知（例如，如果方法返回而不抛出异常）。
* after throwing advice：如果方法通过抛出异常退出，则执行通知。
* after (finally) advice：无论连接点退出的方式（正常或异常返回），都要执行通知。
* around advice：围绕连接点的通知，例如方法调用。 这是最有力的通知。 around通知可以在方法调用之前和之后执行自定义行为。 它还负责选择是继续 连接点 还是通过返回自己的返回值或抛出异常来加速通知方法的执行。

`around advice`是最普遍的通知。由于Spring AOP（如AspectJ）提供了全方位的通知类型，因此我们通知您使用可以实现所需行为的**最不强大**的通知类型。例如，如果您只需要使用方法的返回值更新缓存，那么最好实现`after returning advice`而不是`around advice`，尽管`around advice`可以完成同样的事情。使用最具体的通知类型可以提供更简单的编程模型，减少错误的可能性。例如，您不需要在用于around通知的JoinPoint上调用`proceed()`方法，因此，您无法调用它。

所有通知参数都是静态类型的，因此您可以使用相应类型的通知参数（例如，方法执行的返回值的类型）而不是Object数组。

由切入点匹配的连接点的概念是AOP的关键，它将其与仅提供拦截的旧技术区分开来。切入点使得通知可以独立于面向对象的层次结构进行定向。例如，您可以将一个提供声明性事务管理的通知应用于跨多个对象的一组方法（例如服务层中的所有业务操作）。

# 2.Spring AOP能力和目标
Spring AOP是用纯Java实现的。不需要特殊的编译过程。 Spring AOP不需要控制类加载器层次结构，因此适合在servlet容器或应用程序服务器中使用。

Spring AOP目前`仅支持方法执行连接点`（通知在Spring bean上执行方法）。虽然可以在不破坏核心Spring AOP API的情况下`添加对字段拦截的支持`，但未实现字段拦截。如果您需要通知字段访问和更新连接点，请考虑使用AspectJ等语言。

Spring AOP的AOP方法与大多数其他AOP框架的方法不同。目的不是提供最完整的AOP实现（尽管Spring AOP非常强大）。相反，目标是在AOP实现和Spring IoC之间提供紧密集成，以帮助解决企业应用程序中的常见问题。

因此，例如，Spring Framework的AOP功能通常与Spring IoC容器一起使用。通过使用普通bean定义语法来配置切面（尽管这允许强大的“自动代理”功能）。这是与其他AOP实现的重要区别。使用Spring AOP无法轻松或高效地完成某些操作，`例如通知非常细粒度的对象（通常是域对象）。在这种情况下，AspectJ是最佳选择。`但是，我们的经验是Spring AOP为适合AOP的企业Java应用程序中的大多数问题提供了出色的解决方案。

Spring AOP从未努力与AspectJ竞争，以提供全面的AOP解决方案。我们相信，基于代理的框架（如Spring AOP）和完整的框架（如AspectJ）都很有价值，而且它们是互补的，而不是竞争。 Spring将Spring AOP和IoC与AspectJ无缝集成，以在一致的基于Spring的应用程序架构中实现AOP的所有使用。此集成不会影响Spring AOP API或AOP Alliance API。 Spring AOP仍然向后兼容。有关Spring AOP API的讨论，请参阅以下章节。

*Spring框架的核心原则之一是非侵入性。这个想法是，您不应该被迫在您的业务或域模型中引入特定于框架的类和接口。但是，在某些地方，Spring Framework确实为您提供了将Spring Framework特定的依赖项引入代码库的选项。为您提供此类选项的基本原理是，在某些情况下，以这种方式阅读或编写某些特定功能可能更容易。但是，Spring Framework（几乎）总是为您提供选择：您可以自由决定哪种选项最适合您的特定用例或场景。
与本章相关的一个选择是选择哪种AOP框架（以及哪种AOP样式）。您可以选择AspectJ，Spring AOP或两者。您还可以选择`@AspectJ`注解样式方法或`Spring XML`配置样式方法。本章选择首先介绍`@AspectJ`风格的方法，这一事实不应被视为Spring团队倾向于采用Spring XML配置风格的@AspectJ注解风格方法。
请参阅选择要使用的AOP声明样式，以更全面地讨论每种样式的“为什么和为何”。*

# 3.AOP代理
Spring AOP默认使用标准JDK动态代理。 这使得任何接口（或接口集）都可以被代理。

Spring AOP也可以使用CGLIB代理。 这不仅可以代理接口也可以代理类。 默认情况下，如果业务对象未实现接口，则使用CGLIB。 由于优化的做法是编程接口而不是类，业务类通常实现一个或多个业务接口。 可以[强制使用CGLIB](https://docs.spring.io/spring/docs/current/spring-framework-reference/core.html#aop-proxying)，在那些需要通知未在接口上声明的方法或需要将代理对象作为具体类型传递给方法的情况下（希望很少见）。

掌握Spring AOP是基于代理的这一事实非常重要。 请参阅了解AOP代理，以全面了解此实现细节的实际含义。

# 4.支持@AspectJ

`@AspectJ`指的是将切面声明为使用注解注解的常规Java类的样式。 作为`AspectJ 5`版本的一部分，AspectJ项目引入了`@AspectJ`样式。 Spring使用AspectJ提供的库解释与AspectJ 5相同的注解，用于切入点解析和匹配。 但是，AOP运行时仍然是纯Spring AOP，并且不依赖于AspectJ编译器或weaver。

> 使用AspectJ编译器和weaver可以使用完整的AspectJ语言，并在使用AspectJ和Spring Applications中进行了讨论。

## 4.1.启用@AspectJ支持
要在Spring配置中使用@AspectJ切面，您需要启用Spring支持，以基于@AspectJ切面配置Spring AOP，并根据这些切面是否通知自动代理bean。 通过自动代理，我们的意思是，如果Spring确定bean被一个或多个切面通知，它会自动为该bean生成一个代理来拦截方法调用，并确保根据需要执行通知。

可以使用XML或Java样式配置启用@AspectJ支持。 在任何一种情况下，您还需要确保`AspectJ的aspectjweaver.jar`库位于应用程序的类路径中（版本1.8或更高版本）。 此库可在AspectJ分发的lib目录中或Maven Central存储库中找到。

### 使用Java配置启用@AspectJ支持

要使用Java `@Configuration`启用@AspectJ支持，请添加`@EnableAspectJAutoProxy`注解，如以下示例所示：

```java
@Configuration
@EnableAspectJAutoProxy
public class AppConfig {
}
```
### 使用XML配置启用@AspectJ支持

要使用基于XML的配置启用@AspectJ支持，请使用`aop：aspectj-autoproxy`元素，如以下示例所示：
```xml
<aop:aspectj-autoproxy/>
```
这假设您使用[基于XML架构的配置](https://docs.spring.io/spring/docs/current/spring-framework-reference/core.html#xsd-schemas)中描述的架构支持。 有关如何在aop命名空间中导入标记，请参阅[AOP架构](https://docs.spring.io/spring/docs/current/spring-framework-reference/core.html#xsd-schemas-aop)。

## 4.2.声明一个切面
在启用了`@AspectJ`支持的情况下，在应用程序上下文中定义的任何bean都具有`@AspectJ`切面的类（具有`@Aspect`注解），Spring会自动检测并用于配置Spring AOP。 接下来的两个示例显示了非常有用的切面所需的最小定义。

这两个示例中的第一个示例在应用程序上下文中显示了一个常规bean定义，该定义指向具有`@Aspect`批注的bean类：
```xml
<bean id="myAspect" class="org.xyz.NotVeryUsefulAspect">
    <!-- configure properties of the aspect here -->
</bean>
```
这两个示例中的第二个显示了`NotVeryUsefulAspect`类定义，该定义使用`org.aspectj.lang.annotation.Aspect`批注进行批注;
```java
package org.xyz;
import org.aspectj.lang.annotation.Aspect;

@Aspect
public class NotVeryUsefulAspect {

}
```
切面（使用`@Aspect`注解的类）可以包含方法和字段，与任何其他类相同。 它们还可以包含切入点，通知和引入（类型间）声明。

*通过组件扫描自动检测切面:
您可以在Spring XML配置中将切面类注册为常规bean，或者通过类路径扫描自动检测它们 - 与任何其他Spring管理的bean相同。 但是，请注意@Aspect注解不足以在类路径中进行自动检测。 为此，您需要添加单独的@Component注解（或者，根据Spring的组件扫描程序的规则，可以添加符合条件的自定义构造型注解）*

*与其他切面的切面通知？
在Spring AOP中，切面本身不能成为其他切面通知的目标。 类上的`@Aspect`注解将其标记为切面，因此将其从自动代理中排除。*

## 4.3.声明切入点
切入点确定感兴趣的连接点，从而使我们能够控制通知何时执行。 Spring AOP仅支持Spring bean的方法执行连接点，因此您可以将切入点视为匹配Spring bean上方法的执行。 切入点声明有两个部分：一个包含名称和任何参数的签名，以及一个精确确定我们感兴趣的方法执行的切入点表达式。在AOP的@AspectJ注解样式中，切入点签名由常规方法定义提供 ，并使用`@Pointcut`注解指示切入点表达式（用作切入点签名的方法必须具有void返回类型）。

一个示例可以帮助区分切入点签名和切入点表达式。 以下示例定义名为anyOldTransfer的切入点，该切入点与名为transfer的任何方法的执行相匹配：
```java
@Pointcut("execution(* transfer(..))")// the pointcut expression
private void anyOldTransfer() {}// the pointcut signature
```

形成`@Pointcut`注解值的切入点表达式是常规的AspectJ 5切入点表达式。有关AspectJ的切入点语言的完整讨论，请参阅[AspectJ编程指南](https://www.eclipse.org/aspectj/doc/released/progguide/index.html)（以及，对于扩展，[AspectJ 5开发人员的笔记本](https://www.eclipse.org/aspectj/doc/released/adk15notebook/index.html)）或AspectJ上的一本书（例如Eclipse AspectJ，Colyer等人，或AspectJ in Action） ，作者：Ramnivas Laddad）。

### 支持的切入点指示符

Spring AOP支持以下AspectJ切入点指示符（PCD）用于切入点表达式：

* `execution`：用于匹配方法执行连接点。这是使用Spring AOP时使用的主要切入点指示符。
* `within`：限制匹配某些类型中的连接点（使用Spring AOP时在匹配类型中声明的方法的执行）。
* `this`：限制匹配到连接点（使用Spring AOP时执行方法），其中bean引用（Spring AOP代理）是给定类型的实例。
* `target`：限制与连接点的匹配（使用Spring AOP时执行方法），其中目标对象（被代理的应用程序对象）是给定类型的实例。
* `args`：限制与连接点的匹配（使用Spring AOP时执行方法），其中参数是给定类型的实例。
* `@target`：限制与连接点的匹配（使用Spring AOP时执行方法），其中执行对象的类具有给定类型的注解。
* `@args`：限制与连接点的匹配（使用Spring AOP时执行方法），其中传递的实际参数的运行时类型具有给定类型的注解。
* `@within`：限制匹配到具有给定注解的类型中的连接点（使用Spring AOP时，使用给定注解在类型中声明的方法的执行）。
* `@annotation`：限制连接点的匹配，其中连接点的主题（在Spring AOP中执行的方法）具有给定的注解。

### 其他切入点类型

完整的AspectJ切入点语言支持Spring中不支持的其他切入点指示符：`call，get，set，preinitialization，staticinitialization，initialization，handler，adviceexecution，withincode，cflow，cflowbelow，if，@ this和@withincode`。 在Spring AOP解释的切入点表达式中使用这些切入点指示符会导致抛出`IllegalArgumentException`。

Spring AOP支持的切入点指示符集可以在将来的版本中进行扩展，以支持更多的AspectJ切入点指示符。

由于Spring AOP仅限制与方法执行连接点的匹配，因此前面对切入点指示符的讨论给出了比在AspectJ编程指南中找到的更窄的定义。 此外，AspectJ本身具有基于类型的语义，并且在执行连接点，`this`和`target`都引用相同的对象：执行该方法的对象。 Spring AOP是一个基于代理的系统，它区分代理对象本身（绑定到this）和代理后面的目标对象（绑定到target）。

> 由于Spring的AOP框架基于代理的特性，根据定义，目标对象内的调用不会被截获。对于JDK代理，只能拦截代理上的公共接口方法调用。使用CGLIB，代理上的公共和受保护方法调用被截获（如果需要，甚至是包可见的方法）。但是，通过代理进行的常见交互应始终通过公共签名进行设计。
> 请注意，切入点定义通常与任何截获的方法匹配。如果切入点严格意义上是公开的，即使在通过代理进行潜在非公共交互的CGLIB代理方案中，也需要相应地定义切入点。
> 如果您的拦截需要包括目标类中的方法调用甚至构造函数，请考虑使用Spring驱动的本机AspectJ编织而不是Spring的基于代理的AOP框架。这构成了具有不同特征的不同AOP使用模式，因此在做出决定之前一定要熟悉编织。

Spring AOP还支持另一个名为bean的PCD。 此PCD允许您将连接点的匹配限制为特定的命名Spring bean或一组命名的Spring bean（使用通配符时）。 bean PCD具有以下形式：
```java
bean(idOrNameOfBean)
```
`idOrNameOfBean`标记可以是任何Spring bean的名称。 提供了使用*字符的有限通配符支持，因此，如果为Spring bean建立了一些命名约定，则可以编写bean PCD表达式来选择它们。 与其他切入点指示符的情况一样，bean PCD可以与`&&`（and），`||`和`!`（否定）运算符一起使用 （or）。

> Bean PCD仅在Spring AOP中受支持，而在本机AspectJ编织中不受支持。 它是AspectJ定义的标准PCD的Spring特定扩展，因此不适用于@Aspect模型中声明的切面。
> bean PCD在实例级别（基于Spring bean名称概念）而不是仅在类型级别（基于编织的AOP受限）上运行。 基于实例的切入点指示符是Spring基于代理的AOP框架的一种特殊功能，它与Spring bean工厂紧密集成，通过名称可以自然而直接地识别特定的bean。

### 组合Pointcut表达式

您可以使用`&&，||, !`组合切入点表达式, 您还可以按名称引用切入点表达式。 以下示例显示了三个切入点表达式：
```java
// 如果方法执行连接点表示任何公共方法的执行，则anyPublicOperation匹配
@Pointcut("execution(public * *(..))")
private void anyPublicOperation() {} 

// 如果方法执行在交易模块中，则inTrading匹配
@Pointcut("within(com.xyz.someapp.trading..*)")
private void inTrading() {} 

// 如果方法执行表示交易模块中的任何公共方法，则transactionOperation匹配
@Pointcut("anyPublicOperation() && inTrading()")
private void tradingOperation() {} 
```

如前所示，最好从较小的命名组件构建更复杂的切入点表达式。 当按名称引用切入点时，将应用常规`Java可见性规则`（您可以看到相同类型的私有切入点，层次结构中的受保护切入点，任何位置的公共切入点等）。 可见性不会影响切入点匹配。

### 共享公共切入点定义

在使用企业应用程序时，开发人员通常希望从几个切面引用应用程序的模块和特定的操作集。我们通知定义一个“`SystemArchitecture`”切面，为此目的捕获常见的切入点表达式。 这样的切面通常类似于以下示例：
```java
package com.xyz.someapp;

import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Pointcut;

@Aspect
public class SystemArchitecture {

    /**
     * A join point is in the web layer if the method is defined
     * in a type in the com.xyz.someapp.web package or any sub-package
     * under that.
     */
    @Pointcut("within(com.xyz.someapp.web..*)")
    public void inWebLayer() {}

    /**
     * A join point is in the service layer if the method is defined
     * in a type in the com.xyz.someapp.service package or any sub-package
     * under that.
     */
    @Pointcut("within(com.xyz.someapp.service..*)")
    public void inServiceLayer() {}

    /**
     * A join point is in the data access layer if the method is defined
     * in a type in the com.xyz.someapp.dao package or any sub-package
     * under that.
     */
    @Pointcut("within(com.xyz.someapp.dao..*)")
    public void inDataAccessLayer() {}

    /**
     * A business service is the execution of any method defined on a service
     * interface. This definition assumes that interfaces are placed in the
     * "service" package, and that implementation types are in sub-packages.
     *
     * If you group service interfaces by functional area (for example,
     * in packages com.xyz.someapp.abc.service and com.xyz.someapp.def.service) then
     * the pointcut expression "execution(* com.xyz.someapp..service.*.*(..))"
     * could be used instead.
     *
     * Alternatively, you can write the expression using the 'bean'
     * PCD, like so "bean(*Service)". (This assumes that you have
     * named your Spring service beans in a consistent fashion.)
     */
    @Pointcut("execution(* com.xyz.someapp..service.*.*(..))")
    public void businessService() {}

    /**
     * A data access operation is the execution of any method defined on a
     * dao interface. This definition assumes that interfaces are placed in the
     * "dao" package, and that implementation types are in sub-packages.
     */
    @Pointcut("execution(* com.xyz.someapp.dao.*.*(..))")
    public void dataAccessOperation() {}

}
```
您可以在需要切入点表达式的任何位置引用此类切面中定义的切入点。 例如，要使服务层成为事务性的，您可以编写以下内容：
```xml
<aop:config>
    <aop:advisor
        pointcut="com.xyz.someapp.SystemArchitecture.businessService()"
        advice-ref="tx-advice"/>
</aop:config>

<tx:advice id="tx-advice">
    <tx:attributes>
        <tx:method name="*" propagation="REQUIRED"/>
    </tx:attributes>
</tx:advice>
```
基于模式的AOP支持中讨论了`<aop：config>`和`<aop：advisor>`元素。 事务管理中讨论了事务元素。

### 例子

Spring AOP用户可能最常使用执行切入点指示符。 执行表达式的格式如下：
```java
execution(modifiers-pattern? ret-type-pattern declaring-type-pattern?name-pattern(param-pattern)
            throws-pattern?)
```

除返回类型模式（前面代码片段中的`ret-type-pattern`）、名称模式和参数模式之外的所有部分都是可选的。返回类型模式确定方法的返回类型必须是什么才能匹配连接点。 `*`最常用作返回类型模式。它匹配任何返回类型。仅当方法返回给定类型时，完全限定类型名称才匹配。名称模式与方法名称匹配。您可以使用`*`通配符作为名称模式的全部或部分。如果指定声明类型模式，请包含尾随。将其加入名称模式组件。参数模式稍微复杂一些:`(）`匹配不带参数的方法，而`（..）`匹配任何数量（零个或多个）参数。 `（*）`模式匹配采用任何类型的一个参数的方法。 `（*，String）`匹配一个带有两个参数的方法。第一个可以是任何类型，而第二个必须是String。有关更多信息，请参阅AspectJ编程指南的语言语义部分。

以下示例显示了一些常见的切入点表达式：
```java
// 任何公共方法
execution(public * *(..))

// 执行名称以set开头的任何方法
execution(* set*(..))

// AccountService接口定义的任何方法
execution(* com.xyz.service.AccountService.*(..))

// service包中定义的任何方法
execution(* com.xyz.service.*.*(..))

// service包中的任何连接点（仅在Spring AOP中执行方法）：
within(com.xyz.service.*)

// 代理实现AccountService接口的任何连接点（仅在Spring AOP中执行方法）
this(com.xyz.service.AccountService)

// 目标对象实现AccountService接口的任何连接点（仅在Spring AOP中执行方法）
target(com.xyz.service.AccountService)

// 采用单个参数的任何连接点（仅在Spring AOP中执行方法）以及在运行时传递的参数是Serializable
args(java.io.Serializable)

// 目标对象具有@Transactional注解的任何连接点（仅在Spring AOP中执行方法）
@target(org.springframework.transaction.annotation.Transactional)

// 任何连接点（仅在Spring AOP中执行方法），其中目标对象的声明类型具有@Transactional注解
@within(org.springframework.transaction.annotation.Transactional)

// 任何连接点（仅在Spring AOP中执行方法），其中执行方法具有@Transactional注解：
@annotation(org.springframework.transaction.annotation.Transactional)

// 任何连接点（仅在Spring AOP中执行的方法），它接受一个参数，并且传递的参数的运行时类型具有@Classified注解
@args(com.xyz.security.Classified)

// 名为tradeService的Spring bean上的任何连接点（仅在Spring AOP中执行方法）：
bean(tradeService)

// Spring bean上的任何连接点（仅在Spring AOP中执行方法），其名称与通配符表达式* Service匹配
bean(*Service)
```
> 'this'更常用于绑定形式。 请参阅有关如何在通知正文中提供代理对象的[声明通知部分]()。
> 'target'更常用于绑定形式。 有关如何在通知体中提供目标对象的信息，请参阅[“声明通知”部分]()。
> 'args'更常用于绑定形式。 请参阅声明通知部分，了解如何在通知体中提供方法参数。

>请注意，此示例中给出的切入点与`execution（* *（java.io.Serializable））`不同。 如果在运行时传递的参数是Serializable，则args版本匹配，如果方法签名声明了Serializable类型的单个参数，则execution版本匹配。


### 写好切入点

在编译期间，AspectJ处理切入点以优化匹配性能。检查代码并确定每个连接点是否（静态地或动态地）匹配给定切入点是一个代价高昂的过程。 （动态匹配意味着无法通过静态分析完全确定匹配，并且在代码中放置测试以确定代码运行时是否存在实际匹配）。在第一次遇到切入点声明时，AspectJ会将其重写为匹配过程的最佳形式。这是什么意思？基本上，切入点在DNF（Disjunctive Normal Form析取范式）中重写，并且切入点的组件被排序，以便首先检查那些评估更便宜的组件。这意味着您不必担心了解各种切入点指示符的性能，并且可以在切入点声明中以任何顺序提供它们。

但是，AspectJ只能使用它所说的内容。为了获得最佳匹配性能，您应该考虑他们要实现的目标，并在定义中尽可能缩小匹配的搜索空间。现有的指示符自然分为三组：`kinded，scoping和contextual`：

* Kinded: 选择特定类型的连接点：`execution, get, set, call, handler`。
* scoping: 范围界定指示符选择一组感兴趣的连接点（可能是多种类型）：`within , withincode`
* contextual: 上下文指示符基于上下文匹配（并且可选地绑定）：`this，target, @annotation`

一个写得很好的切入点应至少包括前两种类型（`kinded和scoping`）。您可以包含上下文指示符以基于连接点上下文进行匹配，或者绑定该上下文以在通知中使用。由于额外的处理和分析，仅提供一个kinded指示符或仅提供上下文指示符，但可能会影响编织性能（使用的时间和内存）。范围界定指示符非常快速匹配，使用它们意味着AspectJ可以非常快速地解除不应进一步处理的连接点组。如果可能，一个好的切入点应该总是包含一个。

## 4.4.声明Advice
advice与切入点表达式相关联，并在切入点匹配的方法执行之前，之后或周围运行。 切入点表达式可以是对命名切入点的简单引用，也可以是在适当位置声明的切入点表达式。

### 在方法之前

您可以使用`@Before`注解在切面中的通知之前声明：
```java
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Before;

@Aspect
public class BeforeExample {

    @Before("com.xyz.myapp.SystemArchitecture.dataAccessOperation()")
    public void doAccessCheck() {
        // ...
    }
}
```
如果我们使用就地切入点表达式，我们可以重写前面的示例，如下例所示：
```java
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Before;

@Aspect
public class BeforeExample {

    @Before("execution(* com.xyz.myapp.dao.*.*(..))")
    public void doAccessCheck() {
        // ...
    }
}
```

### 在方法返回之后

返回通知后，匹配的方法执行正常返回。 您可以使用`@AfterReturning`注解声明它：
```java
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.AfterReturning;

@Aspect
public class AfterReturningExample {

    @AfterReturning("com.xyz.myapp.SystemArchitecture.dataAccessOperation()")
    public void doAccessCheck() {
        // ...
    }
}
```
> 您可以在同一切面拥有多个通知声明（以及其他成员）。 我们在这些示例中仅显示一个通知声明，以集中每个声明的效果。

有时，您需要在通知体中访问返回的实际值。 您可以使用绑定返回值的`@AfterReturning`形式来获取该访问权限，如以下示例所示：
```java
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.AfterReturning;

@Aspect
public class AfterReturningExample {

    @AfterReturning(
        pointcut="com.xyz.myapp.SystemArchitecture.dataAccessOperation()",
        returning="retVal")
    public void doAccessCheck(Object retVal) {
        // ...
    }
}
```
`returning`属性中使用的名称必须与`advice`方法中的参数名称相对应。 当方法执行返回时，返回值作为相应的参数值传递给`advice`方法。 返回子句还将匹配仅限于那些返回指定类型值的方法执行（在本例中为Object，它匹配任何返回值）。

请注意，在`after retuning advice`使用时，无法返回完全不同的引用。

### 在抛出异常后

抛出异常通知运行时，匹配的方法执行通过抛出异常退出。 您可以使用`@AfterThrowing`注解声明它，如以下示例所示：
```java
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.AfterThrowing;

@Aspect
public class AfterThrowingExample {

    @AfterThrowing("com.xyz.myapp.SystemArchitecture.dataAccessOperation()")
    public void doRecoveryActions() {
        // ...
    }
}
```
通常，您希望通知仅在抛出给定类型的异常时运行，并且您还经常需要访问通知体中的抛出异常。 您可以使用`throwing`属性来限制匹配（如果需要，请使用`Throwable`作为异常类型），并将抛出的异常绑定到`advice`参数。 以下示例显示了如何执行此操作：
```java
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.AfterThrowing;

@Aspect
public class AfterThrowingExample {

    @AfterThrowing(
        pointcut="com.xyz.myapp.SystemArchitecture.dataAccessOperation()",
        throwing="ex")
    public void doRecoveryActions(DataAccessException ex) {
        // ...
    }
}
```
`throwing`属性中使用的名称必须与advice方法中的参数名称相对应。 当通过抛出异常退出方法时，异常将作为相应的参数值传递给advice方法。 `throwing`子句还将匹配仅限于那些抛出指定类型异常的方法执行（在本例中为`DataAccessException`）。

### 之后（最后）通知

在匹配的方法执行退出之后（最终）通知运行之后。 它是使用`@After`注解声明的。 在通知必须准备好处理正常和异常返回条件。 它通常用于释放资源和类似目的。 以下示例显示了在`finally`通知之后如何使用：
```java
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.After;

@Aspect
public class AfterFinallyExample {

    @After("com.xyz.myapp.SystemArchitecture.dataAccessOperation()")
    public void doReleaseLock() {
        // ...
    }
}
```
### 围绕通知

最后一种通知是`around advice`。 周围的通知围绕匹配方法的执行运行。 它有机会在方法执行之前和之后完成工作，并确定何时，如何，甚至方法实际上都可以执行。 如果您需要以线程安全的方式（例如，启动和停止计时器）在方法执行之前和之后共享状态，则通常会使用`around通知`。 始终使用符合您要求的最不强大的通知形式（也就是说，如果之前的通知可以满足则不要使用around通知）。

使用`@Around`批注声明around通知。 advice方法的第一个参数必须是`ProceedingJoinPoint`类型。 在通知的主体内，在`ProceedingJoinPoint`上调用`proceed()`会导致执行基础方法。 proceed方法也可以传入`Object []`。 数组中的值在进行时用作方法执行的参数。

> 使用`Object []`调用时，`proceed`的行为与由AspectJ编译器编译的around通知的行为略有不同。对于使用传统AspectJ语言编写的周围通知，传递给proceed的参数数量必须与传递给around通知的参数数量（不是基础连接点所采用的参数数量）相匹配，并且传递给的值继续给定的参数位置取代了值绑定到的实体的连接点的原始值（如果现在没有意义，请不要担心）。 Spring采用的方法更简单，与其基于代理的仅执行语义更好地匹配。如果编译为Spring编写的`@AspectJ`切面并使用AspectJ编译器和weaver继续使用参数，则只需要了解这种差异。有一种方法可以编写在Spring AOP和AspectJ上100％兼容的切面，这将在下面的通知参数部分中讨论。

```java
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.ProceedingJoinPoint;

@Aspect
public class AroundExample {

    @Around("com.xyz.myapp.SystemArchitecture.businessService()")
    public Object doBasicProfiling(ProceedingJoinPoint pjp) throws Throwable {
        // start stopwatch
        Object retVal = pjp.proceed();
        // stop stopwatch
        return retVal;
    }
}
```

around通知返回的值是方法调用者看到的返回值。例如，一个简单的缓存切面可以从缓存中返回一个值（如果有的话），如果没有则调用`proceed()`。请注意，可以在around通知的正文中调用一次，多次或根本不调用。所有这些都是合法的。

### advice参数
Spring提供完全类型的通知，这意味着您在通知签名中声明了所需的参数（正如我们之前看到的返回和抛出示例），而不是一直使用`Object []`数组。我们将在本节后面的内容中看到如何使通知和其他上下文值可用。首先，我们来看看如何编写通用通知，以便了解通知目前通知的方法。

**访问当前JoinPoint**

任何通知方法都可以声明一个类型为`org.aspectj.lang.JoinPoint`的参数作为其第一个参数（注意，需要使用around advice来声明一个类型为`ProceedingJoinPoint`的第一个参数，它是JoinPoint的一个子类。JoinPoint接口提供了一个有用的方法数量：

* getArgs（）：返回方法参数。
* getThis（）：返回代理对象。
* getTarget（）：返回目标对象。
* getSignature（）：返回正在通知的方法的描述。
* toString（）：打印通知方法的有用描述。

有关更多详细信息，请参阅[javadoc](https://www.eclipse.org/aspectj/doc/released/runtime-api/org/aspectj/lang/JoinPoint.html)。

**将参数传递给通知**

我们已经看到了如何绑定返回的值或异常值（在返回之后和抛出通知之后使用）。 要使参数值可用于通知体，您可以使用`args`的绑定形式。 如果在`args`表达式中使用参数名称代替类型名称，则在调用通知时，相应参数的值将作为参数值传递。 一个例子应该使这更清楚。 假设您要通知执行以`Account`对象作为第一个参数的DAO操作，并且您需要访问通知体中的帐户。 你可以写下面的内容：
```java
@Before("com.xyz.myapp.SystemArchitecture.dataAccessOperation() && args(account,..)")
public void validateAccount(Account account) {
    // ...
}
```
切入点表达式的`args（account,..）`部分有两个目的。 首先，它将匹配仅限于那些方法至少采用一个参数的方法执行，而传递给该参数的参数是Account的实例。 其次，它通过account参数使实际的Account对象可用于通知。

另一种编写方法是声明一个切入点，它在匹配连接点时“提供”Account对象值，然后从通知中引用指定的切入点。 这看起来如下：
```java
@Pointcut("com.xyz.myapp.SystemArchitecture.dataAccessOperation() && args(account,..)")
private void accountDataAccessOperation(Account account) {}

@Before("accountDataAccessOperation(account)")
public void validateAccount(Account account) {
    // ...
}
```
有关更多详细信息，请参阅AspectJ编程指南。

代理对象（this），目标对象（target）和注解（`@within，@ target，@ annotation和@args`）都可以以类似的方式绑定。 接下来的两个示例显示如何匹配带有`@Auditable`注解的注解方法的执行并提取审计代码：

这两个示例中的第一个显示了`@Auditable`注解的定义：

```java
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.METHOD)
public @interface Auditable {
    AuditCode value();
}
```
这两个示例中的第二个显示了与`@Auditable`方法的执行相匹配的通知：
```java
@Before("com.xyz.lib.Pointcuts.anyPublicMethod() && @annotation(auditable)")
public void audit(Auditable auditable) {
    AuditCode code = auditable.value();
    // ...
}
```
**advice参数和泛型**

Spring AOP可以处理类声明和方法参数中使用的泛型。 假设您有一个如下所示的泛型类型：
```java
public interface Sample<T> {
    void sampleGenericMethod(T param);
    void sampleGenericCollectionMethod(Collection<T> param);
}
```
您可以通过在要拦截方法的参数类型中键入advice参数，将方法类型的拦截限制为某些参数类型：
```java
@Before("execution(* ..Sample+.sampleGenericMethod(*)) && args(param)")
public void beforeSampleMethod(MyType param) {
    // Advice implementation
}
```
此方法不适用于通用集合。 因此，您无法按如下方式定义切入点：
```java
@Before("execution(* ..Sample+.sampleGenericCollectionMethod(*)) && args(param)")
public void beforeSampleMethod(Collection<MyType> param) {
    // Advice implementation
}
```
为了使这项工作，我们必须检查集合的每个元素，这是不合理的，因为我们也无法决定如何一般地处理空值。 要实现与此类似的操作，您必须将参数键入`Collection <?>`并手动检查元素的类型。

**确定参数名称**

通知调用中的参数绑定依赖于切入点表达式中使用的名称与通知和切入点方法签名中声明的参数名称匹配。 参数名称不能通过Java反射获得，因此Spring AOP使用以下策略来确定参数名称：

* 如果用户已明确指定参数名称，则使用指定的参数名称。 通知和切入点注解都有一个可选的`argNames`属性，您可以使用该属性指定带注解的方法的参数名称。 这些参数名称在运行时可用。 以下示例显示如何使用argNames属性：
    ```java
    @Before(value="com.xyz.lib.Pointcuts.anyPublicMethod() && target(bean) && @annotation(auditable)",
        argNames="bean,auditable")
    public void audit(Object bean, Auditable auditable) {
        AuditCode code = auditable.value();
        // ... use code and bean
    }
    ```
    如果第一个参数是`JoinPoint`，`ProceedingJoinPoint`或`JoinPoint.StaticPart`类型，则可以从`argNames`属性的值中省略参数的名称。 例如，如果修改前面的通知以接收连接点对象，则argNames属性不需要包含它：
    ```java
    @Before(value="com.xyz.lib.Pointcuts.anyPublicMethod() && target(bean) && @annotation(auditable)",
            argNames="bean,auditable")
    public void audit(JoinPoint jp, Object bean, Auditable auditable) {
        AuditCode code = auditable.value();
        // ... use code, bean, and jp
    }
    ```
    对`JoinPoint，ProceedingJoinPoint和JoinPoint.StaticPart`类型的第一个参数的特殊处理对于不收集任何其他连接点上下文的通知实例特别方便。 在这种情况下，您可以省略argNames属性。 例如，以下通知无需声明argNames属性：
    ```java
    @Before("com.xyz.lib.Pointcuts.anyPublicMethod()")
    public void audit(JoinPoint jp) {
        // ... use jp
    }
    ```
* 使用`'argNames'`属性有点笨拙，因此如果未指定'argNames'属性，Spring AOP会查看该类的调试信息，并尝试从局部变量表中确定参数名称。 只要已使用调试信息（至少为“`-g:vars`”）编译类，就会显示此信息。 使用此标志进行编译的后果是：（1）您的代码稍微容易理解（逆向工程），（2）类文件大小略大（通常无关紧要），（3）优化删除未使用的本地 变量未由编译器应用。 换句话说，通过使用此标志构建，您应该不会遇到任何困难。
    > 如果即使没有调试信息，AspectJ编译器（ajc）也编译了`@AspectJ`切面，则无需添加argNames属性，因为编译器会保留所需的信息。

* 如果代码编译时没有必要的调试信息，Spring AOP会尝试推断绑定变量与参数的配对（例如，如果只有一个变量绑定在切入点表达式中，并且advice方法只接受一个参数，那么配对 很明显）。 如果给定可用信息，变量的绑定是不明确的，则抛出`AmbiguousBindingException`。

* 如果上述所有策略都失败，则抛出`IllegalArgumentException`。

**处理参数**

我们之前评论过，我们将描述如何使用在Spring AOP和AspectJ中一致工作的参数编写一个继续调用。 解决方案是确保通知签名按顺序绑定每个方法参数。 以下示例显示了如何执行此操作：
```java
@Around("execution(List<Account> find*(..)) && " +
        "com.xyz.myapp.SystemArchitecture.inDataAccessLayer() && " +
        "args(accountHolderNamePattern)")
public Object preProcessQueryPattern(ProceedingJoinPoint pjp,
        String accountHolderNamePattern) throws Throwable {
    String newPattern = preProcess(accountHolderNamePattern);
    return pjp.proceed(new Object[] {newPattern});
}
```
在许多情况下，无论如何都要执行此绑定（如前面的示例所示）。

### advice顺序
当多条通知都想在同一个连接点运行时会发生什么？ Spring AOP遵循与AspectJ相同的优先级规则来确定通知执行的顺序。

* 最高优先级的通知首先“进去”（before advice，优先级最高的advice首先运行）。
* 从连接点“出来”，最高优先级通知最后运行(after advice优先级越高越迟执行)。

当在不同切面定义的两条通知都需要在同一个连接点上运行时，除非另行指定，否则执行顺序是**不确定的**。您可以通过指定优先级来控制执行顺序。这是通过在方法类中实现`org.springframework.core.Ordered`接口或使用`Order`注解对其进行注解来以常规Spring方式完成的。给定两个切面，从`Ordered.getValue()`（或注解值）返回较低值的切面具有较高的优先级。

当在同一切面中定义的两条通知都需要在同一个连接点上运行时，排序是未定义的（因为无法通过反射为`javac`编译的类检索声明顺序）。考虑将这些通知方法折叠到每个切面类中每个连接点的一个通知方法中，或者将这些通知重构为可以在切面级别订购的单独切面类。



```java
```

```java
```

```java
```
```java
```

```java
```

```java
```





