---
title: java并发-Condition
tags:
  - java
p: java/011-java-concurrent-condition
date: 2018-10-03 10:10:14
---

https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/locks/Condition.html

讲解Condition接口

# 代码示例
```java
import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

/**
 * <p>
 * Condition(条件)，可以使一个线程站厅执行，直到条件满足才继续。
 * 一般通过await()暂停当前线程（让出CPU），signal()通知其他线程
 * 竞争CPU
 * </p>
 * <p>
 * 下面是经典的生产消费者模型，我们使用2个条件：空和满来控制存和取
 * </p>
 *
 * @author jimo
 * @date 2018/10/3 9:22
 */
public class ConditionDemo {

	public static void main(String[] args) throws InterruptedException {
		final MyQueue queue = new MyQueue(8);
		final Producer producer = new Producer(queue);
		final Consumer consumer = new Consumer(queue);

		producer.start();
		consumer.start();

		producer.join();
		consumer.join();
	}

	private static class MyQueue {
		private final Lock lock = new ReentrantLock();
		private final Condition full = lock.newCondition();
		private final Condition empty = lock.newCondition();

		private final Object[] items;
		private int current;
		private int getIndex;
		private int putIndex;

		private MyQueue(int capacity) {
			this.items = new Object[capacity];
		}

		void put(Object item) throws InterruptedException {
			lock.lock();
			try {
				// 生产满了，不满足空的条件，所以等待被消费
				while (current >= items.length) {
					empty.await();
				}
				items[putIndex] = item;
				putIndex = (putIndex + 1) % items.length;
				current++;

				// 通知消费者
				full.signal();
			} finally {
				lock.unlock();
			}
		}

		Object get() throws InterruptedException {
			lock.lock();
			try {
				// 不满足满的条件，只能暂停下来，等待生产
				while (current <= 0) {
					full.await();
				}
				Object item = items[getIndex];
				getIndex = (getIndex + 1) % items.length;
				current--;

				// 满足空的条件，通知生产者可以生产了
				empty.signal();
				return item;
			} finally {
				lock.unlock();
			}
		}
	}

	private static class Producer extends Thread {
		private final MyQueue queue;

		private Producer(MyQueue queue) {
			this.queue = queue;
		}

		@Override
		public void run() {
			String[] numbers = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"};
			try {
				for (String number : numbers) {
					queue.put(number);
					System.out.println("Producer: " + number);
				}
				queue.put(null);
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
		}
	}

	private static class Consumer extends Thread {
		private final MyQueue queue;

		public Consumer(MyQueue queue) {
			this.queue = queue;
		}

		@Override
		public void run() {
			try {
				Object number = queue.get();
				while (number != null) {
					System.out.println("Consumer: " + number);
					number = queue.get();
				}
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
		}
	}
}

```
结果：
```java
Producer: 1
Consumer: 1
Producer: 2
Consumer: 2
Producer: 3
Consumer: 3
Producer: 4
Consumer: 4
Producer: 5
Consumer: 5
Producer: 6
Consumer: 6
Producer: 7
Consumer: 7
Producer: 8
Consumer: 8
Producer: 9
Consumer: 9
Producer: 10
Consumer: 10
Producer: 11
Consumer: 11
Producer: 12
Consumer: 12
```
