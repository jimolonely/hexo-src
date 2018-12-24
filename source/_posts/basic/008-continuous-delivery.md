---
title: 持续发布
tags:
  - microservice
p: basic/008-continuous-delivery
date: 2018-12-09 18:58:17
---

本文翻译自：[https://martinfowler.com/bliki/ContinuousDelivery.html](https://martinfowler.com/bliki/ContinuousDelivery.html)

持续交付是一个软件开发规程，您可以通过这种方式构建软件，以便软件可以随时发布到生产环境中。

你在以下情况下是持续交付：[1]

1. 您的软件可在其整个生命周期内进行部署
2. 您的团队优先考虑保持软件可部署而不是处理新功能
3. 任何人都可以随时获得有关系统生产准备情况的快速自动反馈
4. 您可以根据需要对任何版本的软件执行一键部署

通过持续集成开发团队完成的软件，构建可执行文件，并对这些可执行文件运行自动化测试来检测问题，实现持续交付。 此外，您可以将可执行文件推送到越来越像生产环境中，以确保软件可以在生产中运行。 为此，您使用[部署管道](https://martinfowler.com/bliki/DeploymentPipeline.html)。

关键测试是，商业赞助商要求软件的当前开发版本可以立即投入生产 - 没有人会眨眼，更不用说恐慌了。

要实现持续交付，您需要：

1. 参与交付的每个人之间的密切协作工作关系（通常称为[DevOpsCulture](https://martinfowler.com/bliki/DevOpsCulture.html) [2]）。
2. 通常使用DeploymentPipeline广泛自动化交付流程的所有可能部分

持续交付有时与持续部署相混淆。 持续部署意味着每次更改都会通过管道并自动投入生产，从而导致每天都进行许多生产部署。 持续交付只是意味着您可以进行频繁部署，但可能选择不这样做，通常是因为企业更喜欢较慢的部署速度。 要进行持续部署，您必须进行持续交付。

[持续集成](https://martinfowler.com/articles/continuousIntegration.html)通常是指在开发环境中集成、构建和测试代码。持续交付以此为基础，处理生产部署所需的最后阶段。

持续交付的主要好处是：
1. 降低部署风险：由于您正在部署较小的更改，因此出现问题的可能性较小，如果出现问题则更容易解决。
2. 可信的进展：许多人通过跟踪已完成的工作来跟踪进度。如果“完成”意味着“开发人员宣称它已完成”，那么它比将其部署到生产（或类似生产）环境中更不可信。
3. 用户反馈：任何软件工作的最大风险是你最终构建了一些无用的东西。越早和越频繁地在真实用户面前获得工作软件，您就越快得到反馈，以找出它的真正价值（特别是如果您使用[ObservedRequirements](https://martinfowler.com/bliki/ObservedRequirement.html)）。

用户反馈确实要求您进行持续部署。如果您需要，但不希望将新软件添加到整个用户群，则可以部署到一部分用户。在我们最近的一个项目中，零售商首先将其新的在线系统部署到其员工，然后部署到受邀的优质客户，最后部署到所有客户。
