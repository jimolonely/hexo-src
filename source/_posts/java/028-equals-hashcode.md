---
title: 一段代码解释equals和hashcode
tags:
  - java
p: java/028-equals-hashcode
date: 2019-02-27 14:10:52
---

在面试或实际过程中，很可能会遇到这样的问题： 为什么重写equals时必须重写hashCode方法？
下面一段代码看了就明白了。

```java
import java.util.*;

public class HashEqual {

	static class A {
		int a;

		public A(int a) {
			this.a = a;
		}

		@Override
		public boolean equals(Object o) {
			if (this == o) {
				return true;
			}
			if (o == null || getClass() != o.getClass()) {
				return false;
			}
			A a1 = (A) o;
			return a == a1.a;
		}

		@Override
		public int hashCode() {
			Random r = new Random();
			int i = r.nextInt();
			System.out.println(i);
			return i;
		}
	}

	public static void main(String[] args) {
		A a1 = new A(1);
		A a2 = new A(1);

		System.out.println(a1.equals(a2));
		System.out.println(a1 == a2);

		HashSet<A> as = new HashSet<>();
		as.add(a1);
		as.add(a2);
		as.add(a2);
		System.out.println(as.size());
	}
}
```
可能结果：
```java
true
false
1394420845
420393756
-1924810276
3
```

1. `==`比较对象内存地址
2. 在使用hash的地方会调用hashcode()，比如HashMap,HashSet等他们相关的类




