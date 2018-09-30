---
title: java并发-死锁
tags:
  - java
p: java/008-java-concurrent-deadlock
date: 2018-09-30 08:39:39
---
本文讲解死锁的概念和示例。

# 死锁是什么
死锁描述了两个或多个线程永远被阻塞，等待彼此的情况。当多个线程需要相同的锁但以不同的顺序获取它们时，会发生死锁。

# 代码示例
```java
/**
 * 演示死锁的由来：因为线程加锁的顺序不一致导致，相互等待对方持有的锁，形成死锁
 *
 * @author jimo
 * @date 2018/9/29 13:46
 */
public class DeadLockDemo {
	private final static Object LOCK1 = new Object();
	private final static Object LOCK2 = new Object();

	public static void main(String[] args) {
		new ThreadDemo1().start();
		new ThreadDemo2().start();
	}

	private static class ThreadDemo1 extends Thread {
		@Override
		public void run() {
			synchronized (LOCK1) {
				System.out.println("线程1持有lock1...");

				try {
					Thread.sleep(10);
				} catch (InterruptedException e) {
				}
				System.out.println("线程1等待lock2");

				synchronized (LOCK2) {
					System.out.println("线程1持有lock1和lock2");
				}
			}
		}
	}

	private static class ThreadDemo2 extends Thread {
		@Override
		public void run() {
			synchronized (LOCK2) {
				System.out.println("线程2持有lock2...");

				try {
					Thread.sleep(10);
				} catch (InterruptedException e) {
				}
				System.out.println("线程2等待lock1");

				synchronized (LOCK1) {
					System.out.println("线程2持有lock1和lock2");
				}
			}
		}
	}
}
```

运行结果：
{% asset_img 1.png %}

# 改正确
```java
/**
 * 演示死锁的由来：因为线程加锁的顺序不一致导致，相互等待对方持有的锁，形成死锁
 *
 * @author jimo
 * @date 2018/9/29 13:46
 */
public class DeadLockDemo {
	private final static Object LOCK1 = new Object();
	private final static Object LOCK2 = new Object();

	public static void main(String[] args) {
		new ThreadDemo1().start();
		new ThreadDemo2().start();
	}

	private static class ThreadDemo1 extends Thread {
		@Override
		public void run() {
			synchronized (LOCK1) {
				System.out.println("线程1持有lock1...");

				try {
					Thread.sleep(10);
				} catch (InterruptedException e) {
				}
				System.out.println("线程1等待lock2");

				synchronized (LOCK2) {
					System.out.println("线程1持有lock1和lock2");
				}
			}
		}
	}

	private static class ThreadDemo2 extends Thread {
		@Override
		public void run() {
			synchronized (LOCK1) {
				System.out.println("线程2持有lock1...");

				try {
					Thread.sleep(10);
				} catch (InterruptedException e) {
				}
				System.out.println("线程2等待lock2");

				synchronized (LOCK2) {
					System.out.println("线程2持有lock1和lock2");
				}
			}
		}
	}
}
```
结果：
{% asset_img 2.png %}
