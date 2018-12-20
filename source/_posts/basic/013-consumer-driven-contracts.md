---
title: 消费者驱动合同：一种服务进化模式
tags:
  - microservice
p: basic/013-consumer-driven-contracts
date: 2018-12-19 09:11:01
---

本文翻译自：[https://martinfowler.com/articles/consumerDrivenContracts.html](https://martinfowler.com/articles/consumerDrivenContracts.html)

本文讨论了发展服务提供商和消费者社区的一些挑战。 它描述了服务提供商更改合同的一部分时出现的一些耦合问题，特别是文档模式，并确定了两个易于理解的策略 - 添加模式扩展点并对接收到的消息执行“足够”验证 - 以减轻此类问题。 这两种策略都有助于保护消费者免受提供商合同的变更，但这些策略都不会让提供商深入了解其使用方式以及随着其发展必须维护的义务。 借鉴其中一种缓解策略的基于断言的语言 - “恰到好处”的验证策略 - 文章随后描述了“消费者驱动的合同”模式，该模式使提供商了解其消费者义务，并关注服务的发展 消费者要求的关键业务功能的交付。

# 服务进化的一个例子
为了说明我们在发展服务时遇到的一些问题，请考虑一个简单的ProductSearch服务，它允许消费者应用程序搜索我们的产品目录。 搜索结果具有以下结构：

图1：搜索结果模式
{% asset_img 000.png %}

搜索结果文档示例如下所示：
```xml
<?xml version="1.0" encoding="utf-8"?>
<Products xmlns="urn:example.com:productsearch:products">
  <Product>
    <CatalogueID>101</CatalogueID>
    <Name>Widget</Name>
    <Price>10.99</Price>
    <Manufacturer>Company A</Manufacturer>
    <InStock>Yes</InStock>
  </Product>
  <Product>
    <CatalogueID>300</CatalogueID>
    <Name>Fooble</Name>
    <Price>2.00</Price>
    <Manufacturer>Company B</Manufacturer>
    <InStock>No</InStock>
  </Product>
</Products>
```
ProductSearch服务目前由两个应用程序使用：内部营销应用程序和外部代理商的Web应用程序。 两个消费者在处理之前都使用XSD(XML结构定义 ( XML Schemas Definition ))验证来验证收到的文档。 内部应用程序使用CatalogueID，Name，Price和Manufacturer字段; 外部应用程序的CatalogueID，Name和Price字段。 既没有使用InStock字段：虽然考虑了营销应用程序，但它在开发生命周期的早期就被删除了。

我们可能发展服务的最常见方式之一是代表一个或多个消费者向文档添加其他字段。 根据提供商和消费者的实施方式，即使是这样的简单更改也会对业务及其合作伙伴产生代价高昂的影响。

在我们的示例中，在ProductSearch服务投入生产一段时间后，第二个经销商会考虑使用它，但要求将“描述”字段添加到每个产品中。由于消费者的构建方式，这种变化对提供商和现有消费者都有重大且代价高昂的影响，每种变化的成本都取决于我们如何实施变更。我们至少有两种方式可以在服务社区成员之间分配变更成本。首先，我们可以修改原始模式，并要求每个使用者更新其模式副本，以便正确验证搜索结果;改变系统的成本在这里分配给提供者 - 面对这样的变更请求，他们总是要做出某种改变 - 以及对更新的功能不感兴趣的消费者。或者，我们可以选择代表新的使用者向服务提供者添加第二个操作和模式，并代表现有的使用者维护原始操作和模式。现在，变更成本仅限于提供商，但代价是使服务更复杂，维护成本更高。

# 插曲：服务负担沉重
服务支持企业应用程序环境的主要优势在于提高了组织灵活性并降低了实施变更的总体成本。 SOA通过将高价值业务功能置于离散的可重用服务中，然后连接和编排这些服务以满足核心业务流程，从而提高组织敏捷性。它通过减少服务之间的依赖关系来降低更改成本，允许它们快速重新组合和调整以响应更改或计划外事件。

但是，如果企业的SOA使服务能够彼此独立地发展，那么企业只能充分实现这些优势。为了提高服务独立性，我们构建了共享契约的服务，而不是类型。即便如此，我们最终还是必须以与服务提供商相同的速度发展消费者，主要是因为我们已经让消费者依赖于提供商合同的特定版本。最后，服务提供商发现他们采取谨慎的方法来改变他们为消费者提供的合同的任何要素;这部分是因为他们无法预测或深入了解消费者实现合同的方式。在最坏的情况下，服务消费者通过在其内部逻辑中天真地表达整个文档模式来实现提供者合同并将自己耦合到提供者。

合同使服务独立;矛盾的是，他们还可能以不合需要的方式将服务提供商和消费者联系起来。在没有反省我们在SOA中实现的合同的功能和作用的情况下，我们将服务置于一种“隐藏”耦合的形式，我们很少能够以任何系统的方式解决这种耦合。缺乏对服务社区采用合同的方式的任何程序性见解，以及服务提供商和消费者对实施选择的限制缺乏，这些都破坏了SOA支持企业的所谓好处。简而言之，企业负担得起服务。

# 架构版本控制
通过查看模式版本控制问题，我们可以开始调查合同并解决困扰我们的ProductSearch服务的问题。 [WC3技术架构小组（TAG）](http://www.w3.org/2001/tag/doc/versioning)描述了许多版本控制策略，这些策略可能有助于我们以减轻耦合问题的方式发展我们的服务消息模式。这些策略的范围从过于宽松的无，它要求服务不能区分不同版本的模式，因此必须容忍所有变化，对于非常保守的大爆炸，这需要服务在它们收到意外版本的时候中止信息。

这两种极端情况都会带来妨碍业务价值交付并加剧系统总体拥有成本的问题。显式和隐含的“无版本控制”策略导致系统在其交互中变得不可预测，脆弱且下游变更成本高。另一方面，大爆炸战略带来紧密耦合的服务格局，其中架构变化会影响供应商和消费者，破坏正常运行时间，延缓发展并减少创收机会。

我们的示例服务社区有效地实施了一项大爆炸战略。考虑到与提高系统业务价值相关的成本，显然提供商和消费者将受益于更灵活的版本控制策略--TAG发现所谓的兼容策略 - 提供向后兼容的模式。在不断发展的服务环境中，向后兼容的模式使较新模式的使用者能够接受较旧模式的实例：构建为处理向后兼容请求的新版本的服务提供者，但仍然可以接受根据旧架构。另一方面，向前兼容的模式使旧模式的使用者能够处理更新模式的实例。这是现有ProductSearch消费者的关键点：如果搜索结果模式在首次投入生产时已经向前兼容，则消费者将能够处理新版本搜索结果的实例而不会破坏或需要修改。

# 扩展点
使模式向后兼容是一个众所周知的设计任务，最好用Must Ignore可扩展模式表达（参见[David Orchard](http://www.pacificspirit.com/Authoring/Compatibility/ExtendingAndVersioningXMLLanguages.html)和[Dare Obasanjo](http://msdn.microsoft.com/library/en-us/dnexxml/html/xml07212004.asp)撰写的论文）。 Must Ignore模式建议模式包含扩展点，这些扩展点允许将扩展元素添加到每个元素的类型和附加属性。 该模式还建议XML语言定义一个处理模型，指定消费者如何处理扩展。 最简单的模型要求消费者忽略他们无法识别的元素 - 因此模式的名称。 该模型还可能要求消费者处理具有“必须理解”标志的元素，或者如果他们无法理解它们则中止。

这是我们最初基于搜索结果文档的架构：
```xml
<?xml version="1.0" encoding="utf-8"?>
<xs:schema xmlns="urn:example.com:productsearch:products" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  elementFormDefault="qualified" 
  targetNamespace="urn:example.com:productsearch:products" 
  id="Products">
  <xs:element name="Products" type="Products" />
  <xs:complexType name="Products">
    <xs:sequence>
      <xs:element minOccurs="0" maxOccurs="unbounded" name="Product" type="Product" />
    </xs:sequence>
  </xs:complexType>
  <xs:complexType name="Product">
    <xs:sequence>
      <xs:element name="CatalogueID" type="xs:int" />
      <xs:element name="Name" type="xs:string" />
      <xs:element name="Price" type="xs:double" />
      <xs:element name="Manufacturer" type="xs:string" />
      <xs:element name="InStock" type="xs:string" />
    </xs:sequence>
  </xs:complexType>
</xs:schema>
```
现在让我们回滚一下时间，从服务的生命周期开始，指定一个向前兼容的，可扩展的模式：
```xml
<?xml version="1.0" encoding="utf-8"?>
<xs:schema xmlns="urn:example.com:productsearch:products" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  elementFormDefault="qualified" 
  targetNamespace="urn:example.com:productsearch:products" 
  id="Products">
  <xs:element name="Products" type="Products" />
  <xs:complexType name="Products">
    <xs:sequence>
      <xs:element minOccurs="0" maxOccurs="unbounded" name="Product" type="Product" />
    </xs:sequence>
  </xs:complexType>
  <xs:complexType name="Product">
    <xs:sequence>
      <xs:element name="CatalogueID" type="xs:int" />
      <xs:element name="Name" type="xs:string" />
      <xs:element name="Price" type="xs:double" />
      <xs:element name="Manufacturer" type="xs:string" />
      <xs:element name="InStock" type="xs:string" />
      <xs:element minOccurs="0" maxOccurs="1" name="Extension" type="Extension" />
    </xs:sequence>
  </xs:complexType>
  <xs:complexType name="Extension">
    <xs:sequence>
      <xs:any minOccurs="1" maxOccurs="unbounded" namespace="##targetNamespace" processContents="lax" />
    </xs:sequence>
  </xs:complexType>
</xs:schema>
```
此架构在每个产品的底部包含一个可选的Extension元素。 扩展元素本身可以包含目标命名空间中的一个或多个元素：

图2：可扩展的搜索结果模式
{% asset_img 001.png %}

现在，当我们收到向每个产品添加描述的更改请求时，我们可以发布一个新的模式，其中包含提供者插入扩展容器中的其他Description元素。 这允许ProductSearch服务返回包含产品描述的结果，并使用新模式的消费者来验证整个文档。 使用旧架构的消费者不会破坏，但他们不会处理描述。 新的结果文档如下所示：
```xml
<?xml version="1.0" encoding="utf-8"?>
<Products xmlns="urn:example.com:productsearch:products">
  <Product>
    <CatalogueID>101</CatalogueID>
    <Name>Widget</Name>
    <Price>10.99</Price>
    <Manufacturer>Company A</Manufacturer>
    <InStock>Yes</InStock>
    <Extension>
      <Description>Our top of the range widget</Description>
    </Extension>
  </Product>
  <Product>
    <CatalogueID>300</CatalogueID>
    <Name>Fooble</Name>
    <Price>2.00</Price>
    <Manufacturer>Company B</Manufacturer>
    <InStock>No</InStock>
    <Extension>
      <Description>Our bargain fooble</Description>
    </Extension>
  </Product>
</Products>
```
修改后的架构如下所示：
```xml
<?xml version="1.0" encoding="utf-8"?>
<xs:schema xmlns="urn:example.com:productsearch:products" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  elementFormDefault="qualified" 
  targetNamespace="urn:example.com:productsearch:products" 
  id="Products">
  <xs:element name="Products" type="Products" />
  <xs:complexType name="Products">
    <xs:sequence>
      <xs:element minOccurs="0" maxOccurs="unbounded" name="Product" type="Product" />
    </xs:sequence>
  </xs:complexType>
  <xs:complexType name="Product">
    <xs:sequence>
      <xs:element name="CatalogueID" type="xs:int" />
      <xs:element name="Name" type="xs:string" />
      <xs:element name="Price" type="xs:double" />
      <xs:element name="Manufacturer" type="xs:string" />
      <xs:element name="InStock" type="xs:string" />
      <xs:element minOccurs="0" maxOccurs="1" name="Extension" type="Extension" />
    </xs:sequence>
  </xs:complexType>
  <xs:complexType name="Extension">
    <xs:sequence>
      <xs:any minOccurs="1" maxOccurs="unbounded" namespace="##targetNamespace" processContents="lax" />
    </xs:sequence>
  </xs:complexType>
  <xs:element name="Description" type="xs:string" />
</xs:schema>
```
请注意，可扩展架构的第一个版本与第二个版本向前兼容，第二个版本与第一个版本向后兼容。 然而，这种灵活性是以增加复杂性为代价的。 可扩展的模式允许我们对XML语言进行无法预料的更改，但出于同样的原因，它们提供了可能永远不会出现的需求; 通过这样做，它们模糊了来自简单设计的表达能力，并通过将元信息容器元素引入域语言来挫败商业信息的有意义表示。

我们不会在这里进一步讨论模式可扩展性。 可以说，扩展点允许我们在不破坏服务提供商和消费者的情况下对模式和文档进行向后和向前兼容的更改。 但是，当我们需要制定表面上对合同的重大改变时，模式扩展不会帮助我们管理系统的演变。



