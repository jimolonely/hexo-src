---
title: skip list理解与java实现
tags:
  - java
  - data structure
p: algorithm/002-skip-list
date: 2019-02-26 13:49:14
---

本文学习跳跃表及其java代码实现。

# 概念

[论文来源](http://www.cl.cam.ac.uk/teaching/0506/Algorithms/skiplists.pdf)

学习其概念，看下面的文章：

[漫画算法：什么是跳跃表？](http://blog.jobbole.com/111731/)

[wiki](https://en.wikipedia.org/wiki/Skip_list)

[redis里跳跃表的应用](https://redisbook.readthedocs.io/en/latest/internal-datastruct/skiplist.html)

插入的动态图：

{% asset_img 000.gif %}

# 实现跳跃表

参考：[算法导论33】跳跃表（Skip list）原理与java实现](https://blog.csdn.net/brillianteagle/article/details/52206261)

SkipListNode
```java
import java.util.Objects;

/**
 * @author jimo
 * @date 19-2-26 下午4:03
 */
public class SkipListNode<T> {

	public int key;
	public T value;
	public SkipListNode<T> up, down, left, right;

	public static final int HEAD_KEY = Integer.MIN_VALUE;
	public static final int TAIL_KEY = Integer.MAX_VALUE;

	public SkipListNode(int key, T value) {
		this.key = key;
		this.value = value;
	}

	@Override
	public boolean equals(Object o) {
		if (this == o) {
			return true;
		}
		if (o == null || getClass() != o.getClass()) {
			return false;
		}
		SkipListNode<?> that = (SkipListNode<?>) o;
		return key == that.key &&
				Objects.equals(value, that.value);
	}

	@Override
	public int hashCode() {
		return Objects.hash(key, value);
	}

	@Override
	public String toString() {
		return "[" + key + "," + value + "]";
	}
}
```
SkipList:
```java
import java.util.Random;

import static com.jimo.structure.skiplist.SkipListNode.HEAD_KEY;
import static com.jimo.structure.skiplist.SkipListNode.TAIL_KEY;

public class SkipList<T> {

	private SkipListNode<T> head, tail;
	private int nodes;
	private int level;
	private Random random;
	private static final double PROBABILITY = 0.5;

	public SkipList() {
		random = new Random();
		head = new SkipListNode<>(HEAD_KEY, null);
		tail = new SkipListNode<>(TAIL_KEY, null);
		linkHorizontal(head, tail);
		level = 0;
		nodes = 0;
	}

	public boolean isEmpty() {
		return nodes == 0;
	}

	public int size() {
		return nodes;
	}

	private SkipListNode<T> findNode(int key) {
		SkipListNode<T> p = this.head;
		while (true) {
			while (p.right.key != TAIL_KEY && p.right.key <= key) {
				p = p.right;
			}
			if (p.down != null) {
				p = p.down;
			} else {
				break;
			}
		}
		return p;
	}

	public SkipListNode<T> search(int key) {
		SkipListNode<T> p = findNode(key);
		if (p.key == key) {
			return p;
		}
		return null;
	}

	public void put(int k, T v) {
		SkipListNode<T> p = findNode(k);
		if (k == p.key) {
			p.value = v;
			return;
		}
		SkipListNode<T> newNode = new SkipListNode<>(k, v);
		linkToRight(p, newNode);
		int currentLevel = 0;
		// 抛硬币
		while (random.nextDouble() < PROBABILITY) {
			if (currentLevel >= level) {
				level++;
				SkipListNode<T> p1 = new SkipListNode<>(HEAD_KEY, null);
				SkipListNode<T> p2 = new SkipListNode<>(TAIL_KEY, null);
				linkHorizontal(p1, p2);
				linkVertical(p1, head);
				linkVertical(p2, tail);
				head = p1;
				tail = p2;
			}
			// p移到上一层
			while (p.up == null) {
				p = p.left;
			}
			p = p.up;

			SkipListNode<T> e = new SkipListNode<>(k, null);
			linkToRight(p, e);
			linkVertical(e, newNode);
			newNode = e;
			currentLevel++;
		}
		nodes++;
	}

	/**
	 * n2 插在 n1后面
	 * @author jimo
	 * @date 19-2-26 下午4:19
	 */
	private void linkToRight(SkipListNode<T> n1, SkipListNode<T> n2) {
		n2.left = n1;
		n2.right = n1.right;
		n1.right.left = n2;
		n1.right = n2;
	}

	private void linkHorizontal(SkipListNode<T> n1, SkipListNode<T> n2) {
		n1.right = n2;
		n2.left = n1;
	}

	private void linkVertical(SkipListNode<T> n1, SkipListNode<T> n2) {
		n1.down = n2;
		n2.up = n1;
	}


	public void printByLevel() {
		SkipListNode<T> p = this.head;
		while (p != null) {
			SkipListNode<T> tmp = p;
			StringBuilder sb = new StringBuilder();
			while (p != null) {
				sb.append(p).append(" ");
				p = p.right;
			}
			System.out.println(sb.toString());
			p = tmp.down;
		}
	}

	@Override
	public String toString() {
		if (isEmpty()) {
			return "empty";
		}
		StringBuilder sb = new StringBuilder();
		SkipListNode<T> p = this.head;
		while (p.down != null) {
			p = p.down;
		}
		while (p.left != null) {
			p = p.left;
		}
		if (p.right != null) {
			p = p.right;
		}
		while (p.right != null) {
			sb.append(p);
			sb.append("\n");
			p = p.right;
		}
		return sb.toString();
	}
}

```
Test:
```java
public class Test {

	public static void main(String[] args) {
		SkipList<String> skipList = new SkipList<>();
		skipList.put(2, "like");
		skipList.put(1, "I");
		skipList.put(3, "Jimo");
		skipList.put(5, "much");
		skipList.put(4, "very");
		skipList.put(8, "I");
		skipList.put(6, ",");
		skipList.put(9, "do");
		skipList.put(7, "yes");
		skipList.put(6, "!");
		System.out.println(skipList);
		System.out.println(skipList.size());
		skipList.printByLevel();
	}
}
```
可能的结果：
```java
[1,I]
[2,like]
[3,Jimo]
[4,very]
[5,much]
[6,!]
[7,yes]
[8,I]
[9,do]

9
[-2147483648,null] [9,null] [2147483647,null] 
[-2147483648,null] [8,null] [9,null] [2147483647,null] 
[-2147483648,null] [2,null] [4,null] [6,null] [8,null] [9,null] [2147483647,null] 
[-2147483648,null] [1,I] [2,like] [3,Jimo] [4,very] [5,much] [6,!] [7,yes] [8,I] [9,do] [2147483647,null] 
```
