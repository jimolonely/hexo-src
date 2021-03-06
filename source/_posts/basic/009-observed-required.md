---
title: 可观察需求
tags:
  - basic
p: basic/009-observed-required
date: 2018-12-10 09:35:10
---

本文翻译自：[https://martinfowler.com/bliki/ObservedRequirement.html](https://martinfowler.com/bliki/ObservedRequirement.html)

这是我最喜欢的软件开发报价之一：
```
需求是您在开始构建产品之前应该发现的事情。 在施工过程中发现需求，或者更糟糕的是，当客户开始使用您的产品时，发现需求非常昂贵且效率低下，我们将假设没有正确思考的人会这样做，并且不会再提及它。

 -  Suzanne和James Robertson
```

这是他们的书“掌握需求过程”第一版的开头段落。 正如普通读者可能猜到的那样，我的喜好与规则无关。 我喜欢这句话，因为它总结了瀑布价值体系的需求（事实上，“需求”一词本身就是瀑布式）。

敏捷方法违反了这一基本假设，意图在施工期间和交付后发现“要求”。 但即便是这种对上述圣人建议的无视，与目前许多领先网站的做法相比毫无意义。 这些站点通过观察用户在其站点上执行的操作以及使用该信息生成以下行中的新功能的想法来探索需求：

1. 看看人们试图对网站做些什么，并为他们提供更简单的方法。
2. 看看人们放弃做某事的地方，并寻找解决令他们感到沮丧的事情的方法。
3. 构建一个新功能，看看人们是否使用它。
4. 构建实验性功能并使其可供用户群的子集使用。 您不仅可以看到他们是否喜欢它，还可以评估它对服务器的负载程度。

要支持此类分析，您需要将用户日志记录行为添加到应用程序中，并构建一些工具来分析这些日志。许多日志记录在Web应用程序中免费显示，我怀疑这是人们开始这样做的主要推动力。但是，日志记录和分析可以进一步添加到应用程序中。

我没有在网上找到关于如何做到这一点的很多建议，我在实践中没有听到太多关于这样做的讨论。像许多事情一样，它需要集中精力花时间来构建监控功能，然后使用它来探索如何改进软件。此外，它远离传统软件流程，即使对于敏捷项目也是如此。

但这里有巨大的潜力。每个人都知道人们说他们想要什么和人们实际需要和使用的差异有多大。通过观察人们对您的应用程序实际执行的操作，您可以了解软件实际发生的情况 - 这可以为您提供比其他来源更直接的信息。因此，我认为更多的团队应该考虑将这种方法添加到他们的工具包中。


