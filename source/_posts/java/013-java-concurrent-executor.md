---
title: java并发-Executor解析
tags:
  - java
p: java/013-java-concurrent-executor
date: 2018-10-10 08:05:39
---

推荐用线程池来创建线程，但首先了解所有线程池的接口Executor。

# Executor概览
## Executor接口
先看看Executor的代码，非常简单，只有一个方法：
```java
public interface Executor {

    /**
     * Executes the given command at some time in the future.  The command
     * may execute in a new thread, in a pooled thread, or in the calling
     * thread, at the discretion of the {@code Executor} implementation.
     *
     * @param command the runnable task
     * @throws RejectedExecutionException if this task cannot be
     * accepted for execution
     * @throws NullPointerException if command is null
     */
    void execute(Runnable command);
}
```
## Executor的继承层次结构
子接口：
ExecutorService, ScheduledExecutorService

实现类：
AbstractExecutorService, ForkJoinPool, ScheduledThreadPoolExecutor, ThreadPoolExecutor

# Executor是干嘛的
他是：执行提交的Runnable任务的对象的接口。那使用它有什么好处呢？

此接口提供了一种将任务提交与每个任务的运行机制分离的方法，包括线程使用，调度等的详细信息。通常使用Executor而不是显式创建线程。 例如，不是为一组任务调用`new Thread(new(RunnableTask())).start()`，而是使用：
```java
Executor executor = anExecutor的实现类;
executor.execute(new RunnableTask1());
executor.execute(new RunnableTask2());
```
# 我们来实现Executor
先不管JDK实现了怎样的Executor，因为后面的文章还会提到，我们只需要看看我们怎么实现。
## 最简单的同步执行
这个实际上只是进行了封装，没有实际意义。
```java
public class DirectExecutor implements Executor {

	@Override
	public void execute(Runnable command) {
		command.run();
	}
}
```
## 异步执行
下面的代码创建了一个新的线程来运行任务，和普通的new Thread没什么区别：
```java
public class ThreadPerTaskExecutor implements Executor {
	@Override
	public void execute(Runnable command) {
		new Thread(command).start();
	}
}
```
## 更真实一点
上面的例子仅仅是说明有这样的可能，作为教学可以，但现实世界不可能这么简单，我们实现这个Executor都是出于某方面目的，比如固定大小线程池，优先级调用等等。

下面是一个复合的Executor，接收一个Executor，然后接收任务拿给第二个Executor执行，顺序执行任务，使用队列实现：
```java
public class SerialExecutor implements Executor {
	final private Queue<Runnable> tasks = new ArrayDeque<>();
	final Executor executor;
	private Runnable current;

	public SerialExecutor(Executor executor) {
		this.executor = executor;
	}

	@Override
	public synchronized void execute(Runnable r) {

		// new 一个Runnable，在里面直接执行新的任务,然后执行下一个
		// 这一个新的Runnable追加到队列里，并没立即执行
		tasks.offer(() -> {
			try {
				r.run();
			} finally {
				scheduleNext();
			}
		});

		// 只有上一个任务执行完了，current才为null
		if (current == null) {

			// 直到这里才出列被executor执行
			scheduleNext();
		}
	}

	protected synchronized void scheduleNext() {
		if ((current = tasks.poll()) != null) {
			executor.execute(current);
		}
	}
}
```
# 最后
本文参考[官方文档](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/Executor.html).
