---
title: java并发-Lock
tags:
  - java
p: java/010-concurrent-lock
date: 2018-10-02 19:15:53
---

[https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/locks/package-summary.html](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/locks/package-summary.html)
java.util.concurrent.locks.Lock接口用作类似于synchronized块的线程同步机制。 新的锁定机制比同步块更灵活，提供更多选项。 Lock和synchronized块之间的主要区别如下 ：

1. 保证顺序 - 同步块不提供任何顺序保证，等待线程将被授予访问权限。 锁接口处理它。

2. 无超时 - 如果未授予锁定，则同步块没有超时选项。 Lock接口提供了这样的选项。

3. 单个方法 - 同步块必须完全包含在单个方法中，而锁定接口的方法lock（）和unlock（）可以在不同的方法中调用。

# 代码示例
```java
package com.sinrail.lock;

import java.util.concurrent.ThreadLocalRandom;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

/**
 * <p>
 * ReentrantLock 可重入锁，锁和同步比起来有以下不同：
 * 1.保证序列：同步不能保证序列执行，除非锁整个方法
 * 2.超时机制：同步也没有
 * 3.单一方法：同步只能用于一个方法，而lock可以在不同的方法中lock和unlock
 *
 * <p>
 * 下面使用打印机的例子，一个打印任务必须执行完才能进行下一个，我们使用锁来保证顺序
 * </p>
 *
 * @author jimo
 * @date 2018/9/29 14:26
 */
public class LockDemo {
	/**
	 * 打印机
	 *
	 * @author jimo
	 * @date 2018/9/29 14:33
	 */
	private static class Printer {
		private final Lock lock = new ReentrantLock();

        public void print() {
			lock.lock();
			try {
				final int duration = ThreadLocalRandom.current().nextInt(1000);
				System.out.println(Thread.currentThread().getName() + ": 打印花费时间：" + duration + " ms");
				Thread.sleep(duration);
			} catch (InterruptedException e) {
			} finally {
				System.out.println(Thread.currentThread().getName() + ": 打印成功！");
				lock.unlock();
			}
		}

	private static class Task extends Thread {
		private Printer printer;

		public Task(String name, Printer printer) {
			super(name);
			this.printer = printer;
		}

		@Override
		public void run() {
			System.out.println(Thread.currentThread().getName() + ": 开始打印...");
			printer.print();
		}
	}

	public static void main(String[] args) {
		final Printer printer = new Printer();

		new Task("task 1", printer).start();
		new Task("task 2", printer).start();
		new Task("task 3", printer).start();
		new Task("task 4", printer).start();
	}
}
```
结果：
```java
task 2: 开始打印...
task 1: 开始打印...
task 3: 开始打印...
task 4: 开始打印...
task 2: 打印花费时间：641 ms
task 2: 打印成功！
task 1: 打印花费时间：662 ms
task 1: 打印成功！
task 3: 打印花费时间：590 ms
task 3: 打印成功！
task 4: 打印花费时间：481 ms
task 4: 打印成功！
```

假如没有锁，代码这样写：
```java
/**
 * 没有锁时
 */
public void print() {
	try {
		final int duration = ThreadLocalRandom.current().nextInt(1000);
		System.out.println(Thread.currentThread().getName() + ": 打印花费时间：" + duration + " ms");
		Thread.sleep(duration);
		System.out.println(Thread.currentThread().getName() + ": 打印成功！");
	} catch (InterruptedException e) {
	}
}
```
则得到的结果将不是顺序的：
```java
task 2: 开始打印...
task 1: 开始打印...
task 3: 开始打印...
task 4: 开始打印...
task 2: 打印花费时间：58 ms
task 1: 打印花费时间：38 ms
task 4: 打印花费时间：532 ms
task 3: 打印花费时间：849 ms
task 1: 打印成功！
task 2: 打印成功！
task 4: 打印成功！
task 3: 打印成功！
```
