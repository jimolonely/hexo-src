---
title: java并发-工具类
tags:
  - java
p: java/009-concurent-tool-class
date: 2018-10-01 21:46:42
---

# ThreadLocal
看代码

```java
import java.util.Random;

/**
 * ThreadLocal变量是每个线程独有的变量，也就是只能由同一个线程修改获取，相当于每个线程都有一份拷贝
 * 下面的代码为了证明每个线程可以独自修改自己的ThreadLocal变量，相互不影响
 *
 * @author jimo
 * @date 2018/9/29 14:02
 */
public class ThreadLocalDemo {

	public static void main(String[] args) throws InterruptedException {
		final Thread t1 = new Thread(new RandomCounter("线程1"));
		final Thread t2 = new Thread(new RandomCounter("线程2"));
		final Thread t3 = new Thread(new RandomCounter("线程3"));

		t1.start();
		t2.start();
		t3.start();

		t1.join();
		t2.join();
		t3.join();
	}

	private static class RandomCounter implements Runnable {
		private final ThreadLocal<Integer> integerThreadLocal = new ThreadLocal<>();
		private String name;

		RandomCounter(String name) {
			this.name = name;
			Thread.currentThread().setName(name);
		}

		@Override
		public void run() {
			final Random random = new Random();
			for (int i = 0; i < 3; i++) {

				integerThreadLocal.set(random.nextInt(1000));
				System.out.println(name + ": 当前local值为：" + integerThreadLocal.get());
				integerThreadLocal.remove();
				try {
					Thread.sleep(1000);
				} catch (InterruptedException e) {
					e.printStackTrace();
				}
			}
		}
	}
}
```
运行的一个结果：
```java
线程2: 当前local值为：940
线程3: 当前local值为：789
线程1: 当前local值为：202
线程1: 当前local值为：474
线程3: 当前local值为：516
线程2: 当前local值为：819
线程1: 当前local值为：916
线程3: 当前local值为：50
线程2: 当前local值为：926
```
# ThreadLocalRandom
//TODO
