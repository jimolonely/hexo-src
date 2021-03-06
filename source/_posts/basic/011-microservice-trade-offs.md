---
title: 微服务权衡
tags:
  - microservice
p: basic/011-microservice-trade-offs
date: 2018-12-11 08:48:57
---

本文翻译自：[https://martinfowler.com/articles/microservice-trade-offs.html](https://martinfowler.com/articles/microservice-trade-offs.html)

许多开发团队发现[微服务架构](https://martinfowler.com/articles/microservices.html)风格是单片架构的优秀方法。 但其他团队发现它们是一种影响生产力的负担。 与任何架构一样，微服务带来成本和收益。 要做出明智的选择，您必须了解这些并将其应用于您的特定背景。

## 微服务提供的好处......

* 强大的模块边界：微服务增强了模块化结构，这对大型团队尤为重要。

* 独立部署：简单的服务更易于部署，并且由于它们是自治的，因此在出错时不太可能导致系统故障。

* 技术多样性：通过微服务，您可以混合使用多种语言，开发框架和数据存储技术。

## ......但需要付出代价

* 分布式：分布式系统更难编程，因为远程调用很慢并且始终存在故障风险。

* 最终的一致性：对于分布式系统来说，保持强一致性非常困难，这意味着每个人都必须管理最终的一致性。

* 运维复杂性：您需要一个成熟的运营团队来管理大量服务，这些服务需要定期重新部署。

# 强大的模块边界
微服务的第一大好处是强大的模块边界。 这是一个重要的好处，但却是一个奇怪的好处，因为从理论上讲，为什么微服务应该具有比单块更强的模块边界。

那么强大的模块边界是什么意思呢？ 我想大多数人都会同意将软件分成模块是很好的：大块的软件彼此分离。 你希望你的模块工作，这样如果我需要更改系统的一部分，大多数时候我只需要了解该系统的一小部分来进行更改，我可以很容易地找到这个小部分。 良好的模块化结构在任何程序中都很有用，但随着软件规模的扩大，它会变得越来越重要。 也许更重要的是，随着开发团队的规模不断扩大，它变得越来越重要。

微服务的倡导者很快就会引入[康微法则](http://www.thoughtworks.com/insights/blog/demystifying-conways-law)，即软件系统的结构反映了构建它的组织的通信结构。对于规模较大的团队，特别是如果这些团队位于不同的地点，重要的是构建软件以识别团队间通信将比团队内的团队通信更频繁，更正式。微服务允许每个团队使用这种通信模式来管理相对独立的单元。

正如我之前所说，单片系统没有理由不具备良好的模块化结构。 [1]但是很多人观察到它似乎很少见，因此[泥大球](http://www.laputan.org/mud/)是最常见的架构模式。事实上，对单一应用的共同命运的这种挫败感正在驱使一些团队进入微服务。与模块的分离是有效的，因为模块边界是模块之间引用的障碍。麻烦的是，使用单片系统，通常很容易绕过障碍物。这样做可以成为快速构建功能的一种有用的战术捷径，但是做得很广泛会破坏模块化结构并破坏团队的工作效率。将模块放入单独的服务使得边界更加牢固，使得找到这些癌症变通方法变得更加困难。

这种耦合的一个重要方面是持久化数据。 微服务的一个关键特性是[分散数据管理](https://martinfowler.com/microservices.html#DecentralizedDataManagement)，它表示每个服务都管理自己的数据库，任何其他服务都必须通过服务的API才能获得它。 这消除了[集成数据库](https://martinfowler.com/bliki/IntegrationDatabase.html)，这是大型系统中令人讨厌的耦合的主要来源。

重要的是要强调，单片系统完全可能具有牢固的模块边界，但它需要规范。 同样地，你可以得到一个微型泥球，但它需要更多的努力，而且是错的。 我看待使用微服务的方式增加了你获得更好的模块化的可能性。 如果你对你的团队的纪律充满信心，那么这可能会消除这种优势，但随着团队的发展，它越来越难以保持纪律，就像维护模块边界变得更加重要一样。

如果你没有正确的界限，这种优势将成为一个障碍。这是[单片优先](https://martinfowler.com/bliki/MonolithFirst.html)策略的两个主要原因之一，以及为什么即使那些[更倾向于使用微服务运行](https://martinfowler.com/articles/dont-start-monolith.html)的人也会强调，只有通过一个易于理解的域才能这样做。

但是我还没有完成关于这一点的警告。在时间过去之后，您才能真正了解系统维护模块化的程度。因此，一旦我们看到微服务系统已经存在至少几年，我们就能真正评估微服务是否会带来更好的模块化。此外，早期采用者往往更有天赋，因此在我们评估普通团队编写的微服务系统的模块化优势之前还会有进一步的延迟。即使在那时，我们也必须接受普通团队编写普通软件，因此我们不必将结果与顶级团队进行比较，而是将所得到的软件与单片体系结构下的软件进行比较 - 这是一个棘手的反事实评估。

我现在所能继续的只是我从我认识的人那里听到的早期证据。他们的判断是维护模块要容易得多。

一个案例研究特别有趣。团队做出了错误的选择，在一个系统上使用微服务，这个系统不够复杂，无法覆盖[Microservice Premium](https://martinfowler.com/bliki/MicroservicePremium.html)。该项目陷入困境，需要获救，因此更多的人被投入到项目中。在这一点上，微服务架构变得有用，因为系统能够吸收开发人员的快速涌入，并且团队能够比单片系统下更容易地利用更大团队的人数数量。因此，该项目加速到比单块预期更高的生产力，使团队能够赶上。结果仍然是一个净负值，因为软件花费的工作时间比它们使用单​​块时所花费的工作时间更多，但微服务架构确实支持提升。

# 分布式
因此，微服务使用分布式系统来改善模块化。但是分布式软件有一个主要的缺点，即它是分布式的。一旦你玩分布式，就会产生一系列复杂性。我认为微服务社区并不像分布式对象运动那样天真，但复杂性仍然存在。

第一个是性能。你必须处在一个非常不寻常的地方才能看到进程中的函数调用现在变成性能热点，但是远程调用很慢。如果您的服务调用了六个远程服务，每个远程服务调用另外六个远程服务，这些响应时间会增加一些可怕的延迟特性。

当然，你可以做很多事情来缓解这个问题。首先，您可以增加调用的粒度，因此您可以减少调用的次数。这使您的编程模型变得复杂，您现在必须考虑如何批量处理服务间交互。它也只会让你到目前为止，因为你将不得不至少调用一次合作服务。

第二个缓解是使用异步。如果并行进行六次异步调用，那么现在只有最慢的调用而不是它们的延迟总和。这可能是一个巨大的性能提升，但另一个认知成本。异步编程很难：很难做到正确，而且更难调试。但是我听过的大多数微服务故事需要不同步才能获得可接受的性能。

在速度之后是可靠性。您希望进程内函数调用可以正常工作，但远程调用可能随时失败。有了很多微服务，还有更多潜在的失败点。聪明的开发人员知道这一点并[设计失败](https://martinfowler.com/articles/microservices.html#DesignForFailure)。令人高兴的是，异步协作所需的策略也很适合处理故障，结果可以提高弹性。然而，这并没有太大的补偿，每次远程调用失败的后果仍然带有额外的复杂性。

这只是[分布式计算的两大谬误](http://www.rgoarchitects.com/Files/fallacies.pdf)。

这个问题有一些警告。首先，随着它的发展，许多这些问题都会出现。很少有单片系统是真正独立的，通常还有其他系统，比如遗留系统。与它们交互涉及到网络并遇到同样的问题。这就是为什么许多人倾向于更快地移动到微服务来处理与远程系统的交互。这个问题也是经验有帮助的问题，一个技能更高的团队将能够更好地处理分布式。

但分布式总是一个成本。我总是不愿意玩分布式，并且认为太多人玩分布式玩的太快，因为他们低估了问题。

# 最终一致性
我相信你知道需要一点耐心的网站。 您对某些内容进行了更新，它会刷新您的屏幕并且更新不见了。 你等一两分钟，点击刷新，就在那里。

这是一个非常恼人的可用性问题，几乎可以肯定是由于最终一致性的危险。 粉红色节点收到了您的更新，但您的获取请求由绿色节点处理。 在绿色节点从粉红节点获取更新之前，您将陷入不一致的窗口。 最终它将是一致的，但在那之前你想知道是否出了什么问题。

像这样的不一致是足够刺激，但它们可能会更加严重。 业务逻辑最终可能会对不一致的信息做出决策，当发生这种情况时，很难诊断出错的原因，因为任何调查都会在不一致窗口关闭后很久发生。

微服务引入了最终的一致性问题，因为它们对分散的数据管理抱有很大的支持。使用整体应用，您可以在一个事务中一起更新一堆东西。微服务需要多个资源来更新，并且分布式事务不受欢迎（有充分理由）。所以现在，开发人员需要了解一致性问题，并在做任何代码后悔的事情之前弄清楚如何检测事情何时不同步。

整体应用并没有摆脱这些问题。随着系统的发展，需要使用缓存来提高性能，而缓存失效则是[另一个难题](https://martinfowler.com/bliki/TwoHardThings.html)。大多数应用程序需要[脱机锁](https://martinfowler.com/eaaCatalog/optimisticOfflineLock.html) 以避免长期存在的数据库事务。 外部系统需要无法与事务管理器协调的更新。 业务流程通常比你想象的更容忍不一致，因为企业往往更多地奖励可用性（业务流程长期以来对[CAP定理](http://ksat.me/a-plain-english-introduction-to-cap-theorem/)有本能的理解）。

因此，与其他分布式问题一样，整体应用并不能完全避免不一致问题，但它们确实会受到更少的影响，特别是当它们更小时。

# 独立部署
在我的整个职业生涯中，模块化边界与分布式系统的复杂性之间的权衡已经存在。但是，在过去的十年中，有一件事情发生了显着变化，即释放到生产中的作用。在二十世纪，生产版本几乎普遍是一个痛苦和罕见的事件，白天/晚上的周末转移，以获得一些尴尬的软件，它可以做一些有用的事情。但是现在，熟练的团队经常发布生产，许多组织实行[持续交付](https://martinfowler.com/bliki/ContinuousDelivery.html)，允许他们每天多次进行生产许可。
```
微服务是DevOps革命后的第一个架构

 - 尼尔福特
```
这种转变对软件行业产生了深远的影响，并且与微服务运动密切相关。部署大型整体应用的难度引发了一些微服务工作，其中部分整体块的微小变化可能导致整个部署失败。微服务的一个关键原则是[服务是组件](https://martinfowler.com/articles/microservices.html#ComponentizationViaServices)，因此可以独立部署。所以现在当你做出改变时，你只需要测试和部署一个小服务。如果搞砸了，你就不会打倒整个系统。毕竟，由于需求设计失败，即使组件完全失效也不应该阻止系统的其他部分工作，尽管有某种形式的优雅降级。

这种关系是双向的。由于许多微服务需要经常部署，因此必须让您的部署协同工作。这就是快速应用程序部署和快速配置基础架构是[微服务先决条件](https://martinfowler.com/bliki/MicroservicePrerequisites.html)的原因。对于除基础之外的任何事情，您需要持续交付。

持续交付的巨大好处是减少了创建和运行软件之间的周期时间。这样做的组织可以快速响应市场变化，并比竞争对手更快地推出新功能。

尽管许多人认为持续交付是使用微服务的一个原因，但必须要提到的是，即使是大型的单一应用也可以连续交付。 Facebook和Etsy是两个最着名的案例。在很多情况下，尝试的微服务架构在独立部署中失败，其中多个服务需要仔细协调它们的发布[2]。虽然我确实听到很多人认为使用微服务进行连续交付要容易得多，但我不太相信它们对模块化的实际重要性 - 尽管自然模块化确实与交付速度密切相关。

# 运维复杂性
能够快速部署小型独立单元对于开发来说是一个巨大的福音，但它给运维带来了额外的压力，因为现在有六个应用程序变成了数百个小型微服务。许多组织会发现处理这类快速变化的工具的难度令人望而却步。

这加强了持续交付的重要作用。虽然持续交付对于整体结构来说是一种有价值的技能，但是它几乎总是值得付出努力，但对于严格的微服务设置来说，它变得至关重要。没有持续交付促进的自动化和协作，就没有办法处理数十种服务。由于对管理这些服务和监控的需求增加，运维复杂性也增加了。如果微服务混合在一起，那么对单片应用程序有用的成熟度也是必要的。

微服务支持者喜欢指出，由于每项服务都较小，因此更容易理解。但危险在于没有消除复杂性，它只是转移到服务之间的互连。然后，这可以表现为增加的操作复杂性，例如跨越服务的困难调试行为。良好的服务边界选择将减少这个问题，但错误的界限会使情况变得更糟。

处理这种操作复杂性需要大量新技能和工具 - 最重要的是技能。工具仍然不成熟，但我的直觉告诉我，即使使用更好的工具，在微服务环境中技能的低标准也更高。

然而，对更好技能和工具的这种需求并不是处理这些操作复杂性最困难的部分。要有效地完成所有这些工作，您还需要介绍一种[devops文化](https://martinfowler.com/bliki/DevOpsCulture.html)：开发人员，运维人员以及参与软件交付的其他所有人之间的更好协作。文化变革很难，特别是在较大和较老的组织中。如果你不进行这种技术性的改变，你的整体应用程序将受到阻碍，你的微服务应用程序将受到创伤。

# 技术多样性
由于每个微服务都是一个可独立部署的单元，因此您可以自由选择技术。微服务可以用不同的语言编写，使用不同的库，并使用不同的数据存储。这允许团队为工作选择合适的工具，某些语言和库更适合某些类型的问题。

技术多样性的讨论通常集中在最佳工具上，但微服务的最大好处往往是更平淡的版本控制问题。在单块中，您只能使用单个版本的库，这种情况通常会导致有问题的升级。系统的一部分可能需要升级才能使用其新功能，但不能，因为升级会破坏系统的另一部分。处理库版本问题是随着代码库变大而成倍增加的问题之一。

这里有一种危险，即技术的多样性使开发组织不堪重负。我认识的大多数组织确实鼓励使用有限的技术。通过提供监控等常用工具来支持这种鼓励，使服务更容易适应一小部分常见环境。

不要低估支持实验的价值。使用单一系统，语言和框架的早期决策很难逆转。经过十年左右的时间，这些决定可能会使团队陷入尴尬的技术之中。微服务允许团队尝试新工具，并且如果优越的技术变得适用，还可以逐步迁移服务。

# 次要因素
我认为上面的项目是需要考虑的主要权衡因素。以下是我认为不太重要的一些事情。

微服务支持者经常说服务更容易扩展，因为如果一个服务获得大量负载，你可以扩展它，而不是整个应用程序。然而，我很难回想起一份体面的体验报告，它让我相信，与通过复制整个应用程序进行[千篇一律的扩展](http://paulhammant.com/2011/11/29/cookie-cutter-scaling/)相比，实际上这种选择性扩展更有效率。

微服务允许您分离敏感数据并为该数据添加更加谨慎的安全性。此外，通过确保微服务之间的所有流量都是安全的，微服务可能会更难以被攻破。随着安全问题变得越来越重要，这可能会成为使用微服务的主要考虑因素。即使没有这一点，主要是单片系统创建单独的服务来处理敏感数据也并不罕见。

对微服务的批评者谈到测试微服务应用程序比单片机更难。虽然这是一个真正的困难 - 分布式应用程序更复杂的一部分 - 但是有[很好的方法可以对微服务进行测试](https://martinfowler.com/articles/microservice-testing/)。这里最重要的是进行严格的测试，而测试单块和测试微服务之间的差异是次要的。

# 总结
任何架构的任何帖子都受到[一般建议的限制](https://martinfowler.com/bliki/LimitationsOfGeneralAdvice.html)。所以阅读这样的帖子不能为您做出决定，但这些文章可以帮助您确保考虑应该考虑的各种因素。这里的每个成本和收益对不同的系统都有不同的权重，甚至在成本和收益之间交换（强大的模块边界在更复杂的系统中是好的，但对简单系统来说是一个障碍）你做出的任何决定取决于将这些标准应用于你的背景，评估哪些因素对您的系统最重要，以及它们如何影响您的特定环境。此外，我们对微服务架构的体验相对有限。您通常只能在系统成熟后判断架构决策，并且了解了开发开始后多年的工作。我们还没有很多关于长寿命微服务架构的轶事。

有关微服务的更多信息，请从我的微服务资源指南开始，我在其中选择了有关微服务的内容，时间，方式和人员的最佳信息。

单块和微服务不是简单的二元选择。两者都是模糊定义，这意味着许多系统将位于模糊的边界区域。还有其他系统不适合任何一种类别。包括我自己在内的大多数人都谈论微服务而不是单块，因为将它们与更常见的风格进行对比是有意义的，但我们必须记住，有些系统不适合这两种类型。我认为单体和微观体是架构空间中的两个区域。它们值得命名，因为它们具有有用的讨论特征，但没有明智的架构师将它们视为对架构空间的全面划分。

也就是说，似乎被广泛接受的一个总体观点是[微服务高级版](https://martinfowler.com/bliki/MicroservicePremium.html)：微服务会降低生产力成本，只能在更复杂的系统中弥补。因此，如果您可以使用单片架构管理系统的复杂性，那么您就不应该使用微服务。

但微服务对话的数量不应该让我们忘记推动软件项目成功和失败的更重要的问题。诸如团队成员的质量，他们彼此协作的程度以及与领域专家的沟通程度之类的软因素将比是否使用微服务产生更大的影响。在纯粹的技术层面上，重点关注整洁代码、良好测试和对进化架构的关注等问题更为重要。



