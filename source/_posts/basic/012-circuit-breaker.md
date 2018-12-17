---
title: 断路器
tags:
  - microservice
p: basic/012-circuit-breaker
date: 2018-12-17 14:22:07
---

本文翻译自：[https://martinfowler.com/bliki/CircuitBreaker.html](https://martinfowler.com/bliki/CircuitBreaker.html)

软件系统通常对在不同进程中运行的软件进行远程调用，可能在网络上的不同机器上进行。内存中调用和远程调用之间的一个重大区别是远程调用可能会失败，或者在达到某个超时限制之前挂起而没有响应。如果在没有响应的供应商上有许多调用者，那么更糟糕的是，您可能会耗尽关键资源，导致跨多个系统的级联故障。在他出色的书“[发布它](https://www.amazon.com/gp/product/0978739213?ie=UTF8&tag=martinfowlerc-20&linkCode=as2&camp=1789&creative=9325&creativeASIN=0978739213)”中，Michael Nygard推广了断路器模式，以防止这种灾难性的级联。

断路器背后的基本思想非常简单。将受保护的函数调用包装在断路器对象中，该对象监视故障。一旦故障达到某个阈值，断路器就会跳闸，并且所有对断路器的进一步调用都会返回错误，而根本不会进行受保护的调用。通常，如果断路器跳闸，您还需要某种监控器警报。

{% asset_img 000.png %}

下面是Ruby中这种行为的一个简单示例，可以防止超时。

我设置了一个带有块（[Lambda](https://martinfowler.com/bliki/Lambda.html)）的断路器，这是受保护的调用。

```ruby
cb = CircuitBreaker.new {|arg| @supplier.func arg}
```
断路器 存储 块，初始化各种参数（用于阈值，超时和监视），并将断路器复位到其闭合状态。
```ruby
class CircuitBreaker...

  attr_accessor :invocation_timeout, :failure_threshold, :monitor
  def initialize &block
    @circuit = block
    @invocation_timeout = 0.01
    @failure_threshold = 5
    @monitor = acquire_monitor
    reset
  end
```
如果电路关闭，则调用断路器将调用底层块，但如果电路处于打开状态则返回错误
```ruby
# client code
    aCircuitBreaker.call(5)


class CircuitBreaker...

  def call args
    case state
    when :closed
      begin
        do_call args
      rescue Timeout::Error
        record_failure
        raise $!
      end
    when :open then raise CircuitBreaker::Open
    else raise "Unreachable Code"
    end
  end
  def do_call args
    result = Timeout::timeout(@invocation_timeout) do
      @circuit.call args
    end
    reset
    return result
  end
```
如果我们得到超时，则增加失败计数器，成功调用将其重置为零。

```ruby
class CircuitBreaker...

  def record_failure
    @failure_count += 1
    @monitor.alert(:open_circuit) if :open == state
  end
  def reset
    @failure_count = 0
    @monitor.alert :reset_circuit
  end
```
我确定断路器的状态，将故障计数与阈值进行比较
```ruby
class CircuitBreaker...

  def state
     (@failure_count >= @failure_threshold) ? :open : :closed
  end
```
这个简单的断路器避免在电路打开时进行受保护的调用，但是当事情再次发生时需要外部干预来重置它。 这是电子断路器的合理方法，但对于软件断路器，我们可以让断路器本身检测基础调用是否再次起作用。我们可以通过在适当的时间间隔后再次尝试受保护的调用来实现此自复位行为，并在成功时重置断路器。

{% asset_img 001.png %}

创建此类断路器意味着添加用于尝试重置的阈值并设置变量以保持最后一个错误的时间。
```ruby
class ResetCircuitBreaker...

  def initialize &block
    @circuit = block
    @invocation_timeout = 0.01
    @failure_threshold = 5
    @monitor = BreakerMonitor.new
    @reset_timeout = 0.1
    reset
  end
  def reset
    @failure_count = 0
    @last_failure_time = nil
    @monitor.alert :reset_circuit
  end
```
现在有第三个状态 - 半开 - 意味着电路准备好作为试验进行真正的通话，以查看问题是否已解决。
```ruby
class ResetCircuitBreaker...

  def state
    case
    when (@failure_count >= @failure_threshold) && 
        (Time.now - @last_failure_time) > @reset_timeout
      :half_open
    when (@failure_count >= @failure_threshold)
      :open
    else
      :closed
    end
  end
```
要求在半开状态下调用导致试用调用，如果成功则重置断路器，否则重启超时。
```ruby
class ResetCircuitBreaker...

  def call args
    case state
    when :closed, :half_open
      begin
        do_call args
      rescue Timeout::Error
        record_failure
        raise $!
      end
    when :open
      raise CircuitBreaker::Open
    else
      raise "Unreachable"
    end
  end
  def record_failure
    @failure_count += 1
    @last_failure_time = Time.now
    @monitor.alert(:open_circuit) if :open == state
  end
```

这个例子是一个简单的解释，在实践中断路器提供了更多的功能和参数化。通常，它们可以防止一系列保护调用可能引发的错误，例如网络连接故障。并非所有错误都应该使电路跳闸，有些应该反映正常故障并作为常规逻辑的一部分处理。

由于流量很大，您可能会遇到许多调用等待初始超时的问题。由于远程调用通常很慢，因此通常最好将每个调用放在不同的线程上，使用[未来或承诺](http://en.wikipedia.org/wiki/Futures_and_promises)在它们返回时处理结果。通过从线程池中建立这些线程，可以在线程池耗尽时安排电路中断。

该示例显示了一种简单的断路器跳闸方式 - 一个重置成功调用的计数。一种更复杂的方法可能会考虑错误的频率，一旦你获得50％的失败率就会绊倒。对于不同的错误，您可能也有不同的阈值，例如超时的阈值为10，连接失败的阈值为3。

我展示的示例是用于同步调用的断路器，但断路器对于异步通信也很有用。这里的一种常见技术是将所有请求放在队列中，供应商以其速度消耗 - 这是避免服务器过载的有用技术。在这种情况下，当队列填满时电路会中断。

断路器本身可以帮助减少可能出现故障的运营中的资源。您可以避免等待客户端的超时，并且断开的电路可以避免将负载放在苦苦挣扎的服务器上。我在这里谈论远程调用，这是断路器的常见情况，但它们可以用于任何你想要保护系统部件免受其他部分故障的情况。

断路器是一个有价值的监控场所。应记录断路器状态的任何变化，断路器应显示其状态的详细信息，以便进行更深入的监控。断路器行为通常是关于环境中更深层次问题的警告的良好来源。操作人员应该能够绊倒或重置断路器。

断路器本身很有价值，但使用它们的客户需要对断路器故障做出反应。与任何远程调用一样，您需要考虑在发生故障时该怎么做。它是否会使您正在执行的操作失败，或者您可以执行哪些操作？信用卡授权可以放在队列中以便稍后处理，可以通过显示一些足以显示的陈旧数据来减轻获取某些数据的失败。

