---
title: java并发-ExecutorService接口
  - java
p: java/015-java-concurrent-executor-service
date: 2018-10-11 08:02:55
---

ExecutorService依然是一个非常重要的接口，必须熟悉。

# ExecutorSerivice概览
我一直说，学习一个类就像了解一个人，它的前后今生，从哪里来，到哪里去，他来干什么。

对于接口，它只是规范了行为，而不用关注实现，所以更简单，我们就是要了解这些行为能干什么。

于是先看看行为。

## 接口行为
```java
public interface ExecutorService extends Executor {

    void shutdown();

    List<Runnable> shutdownNow();

    boolean isShutdown();

    boolean isTerminated();

    boolean awaitTermination(long timeout, TimeUnit unit)
        throws InterruptedException;

    <T> Future<T> submit(Callable<T> task);

    <T> Future<T> submit(Runnable task, T result);

    Future<?> submit(Runnable task);

    <T> List<Future<T>> invokeAll(Collection<? extends Callable<T>> tasks)
        throws InterruptedException;

    <T> List<Future<T>> invokeAll(Collection<? extends Callable<T>> tasks,
                                  long timeout, TimeUnit unit)
        throws InterruptedException;

    <T> T invokeAny(Collection<? extends Callable<T>> tasks)
        throws InterruptedException, ExecutionException;

    <T> T invokeAny(Collection<? extends Callable<T>> tasks,
                    long timeout, TimeUnit unit)
        throws InterruptedException, ExecutionException, TimeoutException;
}
```
看到上面的方法还挺多，仔细一看，也就是几个：`shutdown(), submit(), invokeXXX()`.

所以，看到这个接口能得到以下信息：
1. 它继承自Executor接口，增加了一些行为
2. 它可以控制线程的关闭，可以提交任务(集)
3. 如果你知道Future和Callable类，那应该知道这是异步任务，可以跟踪线程进度。

所以，ExecutorService的主要目的是管理任务的终止行为，可以单个，可以批量。现在，你肯定想知道那些方法有什么区别，这个看文档就好了。

## 接口实现
子接口：
ScheduledExecutorService

实现类：
AbstractExecutorService, ForkJoinPool, ScheduledThreadPoolExecutor, ThreadPoolExecutor

下面用到了一些实现，会在更后面的文中详细讲解。

# 代码示例

## 控制关闭示例
先当然是简单的例子，重在理解和使用。
```java
public class ExecutorServiceDemo1 {

	public static void main(String[] args) {
		final ExecutorService executor = Executors.newSingleThreadExecutor();
		executor.submit(new Task());
		System.out.println("关闭executor");
		executor.shutdown();
		try {
			// 等待5秒再跳到finally
			executor.awaitTermination(5, TimeUnit.SECONDS);
		} catch (InterruptedException e) {
			System.out.println("任务被中断");
		} finally {
			if (!executor.isTerminated()) {
				System.out.println("取消未完成的任务");

				// 立即关闭，不管当前正在执行的任务
				executor.shutdownNow();
			}

			System.out.println("关闭完成");
		}
	}

	private static class Task implements Runnable {

		@Override
		public void run() {
			final int duration = 7;
			try {
				System.out.println("我是一只在跑的小白兔...");
				TimeUnit.SECONDS.sleep(duration);
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
		}
	}
}
```
结果：
```java
关闭executor
我是一只在跑的小白兔...
取消未完成的任务
关闭完成
java.lang.InterruptedException: sleep interrupted
	at java.lang.Thread.sleep(Native Method)
	at java.lang.Thread.sleep(Thread.java:340)
	at java.util.concurrent.TimeUnit.sleep(TimeUnit.java:386)
	at com.jimo.executor.ExecutorServiceDemo1$Task.run(ExecutorServiceDemo1.java:44)
	at java.util.concurrent.Executors$RunnableAdapter.call(Executors.java:511)
	at java.util.concurrent.FutureTask.run(FutureTask.java:266)
	at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1149)
	at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
	at java.lang.Thread.run(Thread.java:748)
```
我们的任务睡眠了7秒，而executor最多等待5秒，所以会被中断，如果我们把时间改小：
```java
final int duration = 3;
```
则会正常结束：
```java
关闭executor
我是一只在跑的小白兔...
关闭完成
```
## 控制关闭示例2
下面的例子更加理论和详细：
```java
public class ExecutorServiceDemo2 {

	public static void main(String[] args) {
		final ExecutorService executor = Executors.newSingleThreadExecutor();
		executor.submit(new Task());
		shutdownAndAwaitTermination(executor);
	}

	private static void shutdownAndAwaitTermination(ExecutorService pool) {

		// 拒绝接受新的任务提交，但会等待之前的任务完成
		pool.shutdown();

		try {
			final int timeout = 3;
			// 等待3秒直到executor执行完，如果3秒后没执行完返回false
			if (!pool.awaitTermination(timeout, TimeUnit.SECONDS)) {

				// 立即关闭，取消当前正在执行的任务
				// 但是并不保证一定会终止线程，所以有下面的等待过程
				pool.shutdownNow();
				System.out.println("第一次中断");

				// 等待强制关闭后线程的结束,算是一个回复
				if (!pool.awaitTermination(timeout, TimeUnit.SECONDS)) {
					System.err.println("executor没有终止掉");
				}
			}
		} catch (InterruptedException e) {
			System.err.println("2次都没杀死");

			// 如果2次等待都没有终止，那么会抛出中断异常，所以下面再进行关闭
			pool.shutdownNow();

			// 保持中断状态
			Thread.currentThread().interrupt();
		}
	}

	private static class Task implements Runnable {

		@Override
		public void run() {
			final int duration = 4;
			try {
				System.out.println("我是一只在追小白兔的大灰狼...");
				TimeUnit.SECONDS.sleep(duration);
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
		}
	}
}
```
结果：
```java
我是一只在追小白兔的大灰狼...
第一次中断
java.lang.InterruptedException: sleep interrupted
	at java.lang.Thread.sleep(Native Method)
	at java.lang.Thread.sleep(Thread.java:340)
	at java.util.concurrent.TimeUnit.sleep(TimeUnit.java:386)
	at com.jimo.executor.ExecutorServiceDemo2$Task.run(ExecutorServiceDemo2.java:57)
	at java.util.concurrent.Executors$RunnableAdapter.call(Executors.java:511)
	at java.util.concurrent.FutureTask.run(FutureTask.java:266)
	at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1149)
	at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
	at java.lang.Thread.run(Thread.java:748)
```
很显然，这个任务在第一次时就成功中断，能力有限，没有构造出杀不死的线程，所以杀2次杀不死的运行结果无法展示。
## 现实的网络例子
下面是官网给出的例子：处理网络请求
```java
public class NetworkService implements Runnable {

	private final ServerSocket serverSocket;
	private final ExecutorService pool;

	public NetworkService(int port, int poolSize) throws IOException {
		serverSocket = new ServerSocket(port);

		// 一般需要限制处理请求的线程数
		pool = Executors.newFixedThreadPool(poolSize);
	}

	@Override
	public void run() {
		try {
			while (true) {
				pool.execute(new Handler(serverSocket.accept()));
			}
		} catch (IOException e) {
			pool.shutdown();
		}
	}

	private class Handler implements Runnable {

		private final Socket socket;

		private Handler(Socket socket) {
			this.socket = socket;
		}

		@Override
		public void run() {
			//TODO 接受网络请求并处理
		}
	}
}
```
## 子接口ScheduledThreadPoolExecutor
从名字可以看出此接口是和定时调度有关，确实，可以延迟和定期执行。
下面是接口，很简单：
```java
public interface ScheduledExecutorService extends ExecutorService {

    public ScheduledFuture<?> schedule(Runnable command,
                                   long delay, TimeUnit unit);

    public <V> ScheduledFuture<V> schedule(Callable<V> callable,
                                          long delay, TimeUnit unit);  

    public ScheduledFuture<?> scheduleAtFixedRate(Runnable command,
                                                long initialDelay,
                                                long period,
                                                TimeUnit unit);

    public ScheduledFuture<?> scheduleWithFixedDelay(Runnable command,
                                                     long initialDelay,
                                                     long delay,
                                                     TimeUnit unit);
}
```
下面的例子会说明区别和用法：
```java
public class ScheduledExecutorDemo {

	public static void main(String[] args) {
		System.out.println("now: " + new Date());
		final ScheduledExecutorService pool = Executors.newScheduledThreadPool(3);

		// 一次性任务，隔3秒执行
		pool.schedule(new DateTask("task1"), 3, TimeUnit.SECONDS);

		// 周期性：2+3*n秒执行，不会管任务是否执行完
		pool.scheduleAtFixedRate(new DateTask("task2"), 2, 3, TimeUnit.SECONDS);

		// 周期性: 2+3*n,上一次执行完到下一次开始之间等待3秒
		final ScheduledFuture<?> task3 =
				pool.scheduleWithFixedDelay(new DateTask("task3"), 2, 3, TimeUnit.SECONDS);

		// 在10秒后关闭
		pool.schedule(() -> {
			task3.cancel(true);
			pool.shutdown();
		}, 10, TimeUnit.SECONDS);
	}

	private static class DateTask implements Runnable {

		private String name;

		DateTask(String name) {
			this.name = name;
		}

		@Override
		public void run() {
			System.out.println(name + ": " + new Date());
			try {
				TimeUnit.SECONDS.sleep(1);
			} catch (InterruptedException e) {
			}
		}
	}
}
```
结果可以看出task3会逐渐比task2慢1，2，3...秒.
```java
now: Tue Oct 16 14:31:38 CST 2018
task2: Tue Oct 16 14:31:40 CST 2018
task3: Tue Oct 16 14:31:40 CST 2018
task1: Tue Oct 16 14:31:41 CST 2018
task2: Tue Oct 16 14:31:43 CST 2018
task3: Tue Oct 16 14:31:44 CST 2018
task2: Tue Oct 16 14:31:46 CST 2018
task3: Tue Oct 16 14:31:48 CST 2018
```

# 总结
参考：[文档](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/ExecutorService.html)
