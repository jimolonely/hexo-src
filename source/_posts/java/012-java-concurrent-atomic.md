---
title: java并发-Atomic
tags:
  - java
p: java/012-java-concurrent-atomic
date: 2018-10-06 09:37:08
---

本节示例java Atomic原子操作类，很简单。

# 如果不使用原子操作
```java
public class AtomicTest {
	private static class Counter {
		private int c;

		public void incr() {
			c++;
		}

		public int getValue() {
			return c;
		}
	}

	public static void main(String[] args) throws InterruptedException {
		final Counter counter = new Counter();

		for (int i = 0; i < 1000; i++) {
			final Thread t = new Thread(() -> counter.incr());
			t.start();
		}
		Thread.sleep(3000);
		System.out.println("结果为：" + counter.getValue());
	}
}
```
结果是1000，但存在风险。

# 使用原子类
```java
private static class Counter {
    private AtomicInteger c = new AtomicInteger(0);

    public void incr() {
        c.incrementAndGet();
    }

    public int getValue() {
        return c.get();
    }
}
```

# 其他原子类
1. AtomicLong
2. AtomicBoolean
3. AtomicReference
4. AtomicIntegerArray
5. AtomicLongArray
6. AtomicReferenceArray
