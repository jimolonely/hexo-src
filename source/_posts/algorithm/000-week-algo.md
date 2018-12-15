---
title: week algorithm
tags:
  - java
  - algorithm
p: algorithm/000-week-algo
date: 2018-12-14 08:24:37
---

# 题目

## 1.超哥的大眼球（2018-12-13～2018-12-20）
超哥开了一个造仿真机器人的公司，最近新出了一个造机器人眼球的测试机，但是造出来的眼球大小不一，你知道造眼球的原料很贵的，为了不浪费，他想将这些眼球合并成2个最大的眼球，当然不是为了摸的，是用来做广告宣传。
问题来了，2个眼球必须一样大，且原来的单个小眼球不可分割，如果能够造成功，返回最大眼球的size，否则返回0。
例如：
输入小眼球数组(eyeball[n])：[1,1,2,3,6]，输出6（1，2，3合并为6,余下1）；
输入：[1,2]，返回0，不可造。

请大家帮助超哥吧^_^。

数据限制：
1. 1<= n <=20
2. 1<= eyeball[i] <=1000 (0<=i<n)
3. size<=5000(即眼球最大为5000)


# 答案

大脑就像肌肉，也是需要锻炼的，否则会卡在一个舒适区很难走出来，就像看抖音的人和想方设法制作抖音视频的人。
我们人类善于从已有知识中总结经验，这是目前和计算机的最大差别，但是人类的这个进化过程异常缓慢，几千年来
智力都还差不多，可能我是个进化的失败品把。

## 1.

复杂的东西可能很容易，简单的东西也可能很难理解。

```java
int bigEyeball(int[] eyes) {
		int maxSize = 0;
    // TODO
		return maxSize;
	}
```

### 让我们热身吧
你能想到的最直接的算法，实现它。

思考最大size的构成：
1. 可能就是其中一个小球的size： eye[i]
2. 可能是其中2个小球+起来的size： eye[i1] + eye[i2]
3. 可能是其中3个小球+起来的size： eye[i1] + eye[i2] + eye[i3]
4. 可能是其中**n-1(当然不可能是n个)**个小球+起来的size： eye[i] +...+ eye[n-1]

于是进一步思考：n-1不就等价于1个吗？ 于是猜测，只需要考虑一半的情况？（有待证明）这可是一个大的飞跃，直接奠定了计算机的基础！

然后我们可以求出以上每种情况的解，取最大即可。

于是：
```java
	int bigEyeball(int[] eyes) {
		int maxSize = 0;
		// 1
		maxSize = Math.max(maxSize, getMax1(eyes));
		// 2
		maxSize = Math.max(maxSize, getMax2(eyes));
		//...
		// 19
		maxSize = Math.max(maxSize, getMax19(eyes));
		
		return maxSize;
	}
```
没错，因为`n<=20`,所以我们只需要写19个方法。。。

#### 如何实现getMax1()
一个小球，这个问题不就变成了给定一个数组，判断其中一个数字能否由其他数字相加得到？
对把，那就简单了：
```java
	private int getMax1(int[] eyes) {
		int max = 0;
		for (int j = 0; j < eyes.length; j++) {
			if (foundEqual(eyes[j], removeIndex(eyes, j))) {
				max = Math.max(max, eyes[j]);
			}
		}
		return max;
	}
```

```java
	/**
	 * 移除arr中下标i对应的元素，返回一个新的数组
	 */
	private int[] removeIndex(int[] arr, int i) {
		int[] sub = new int[arr.length - 1];
		int k = 0;
		for (int j = 0; j < arr.length; j++) {
			if (i != j) {
				sub[k++] = arr[j];
			}
		}
		return sub;
	}
```

`boolean foundEqual(int x, int[] arr)`干什么： 判断x是否能由arr中的元素相加得到，是返回true.

现在，这个问题怎么办？ 依然采用复杂的思考方式，如下：
```java
	 * x = 0 + arr(n)
	 *          |
	 *          a1 + arr(n-1)
	 *                  |
	 *                  a2 + arr(n-2)
	 *                          ...
	 *                          an-1 + arr1
```
既然这样，一个递归完全能搞定了：
```java
	boolean foundEqual(int x, int[] arr) {
		if (x == 0) {
			return true;
		}
		if (x < 0) {
			return false;
		}
		if (arr.length == 1) {
			return x == arr[0];
		}
		for (int i = 0; i < arr.length; i++) {
			int[] sub = removeIndex(arr, i);
			boolean ok = foundEqual(x - arr[i], sub);
			if (ok) {
				return true;
			}
		}
		return false;
	}
```

那么这个问题就算完成了，谁都可以写出来，那它的时间复杂度是多少呢？ 

`f(n) = n*f(n-1) = n*(n-1)*f(n-2) = ... = n!`, 所以最坏是`O(n!)`

19!=1.22e+17, 如果每秒进行一亿次运算，大概要3.17年，还不算太长，谷歌还花了2年研究如何破解SHA-1呢。

#### 如何实现getMaxn()

现在，我们实现了`getMax1()`，那么`getMaxn()`怎么实现？

同样的思路，选择2个小球：
```java
	private int getMax2(int[] eyes) {
		int max = 0;
		for (int i = 0; i < eyes.length - 1; i++) {
			for (int j = i + 1; j < eyes.length; j++) {
				int[] sub = removeIndex(removeIndex(eyes, j), i);
				int x = eyes[i] + eyes[j];
				if (foundEqual(x, sub)) {
					max = Math.max(max, x);
				}
			}
		}
		return max;
	}
```

思考： 如果由2个小球构成，是否可等价于已经确定一个小球，剩下的变为一个小球问题？ 如果可以，那么就简单了：

```java
		for (int j = 0; j < eyes.length; j++) {
			int[] sub = removeIndex(eyes, j);
			//1
			max = Math.max(max, eyes[j] + getMax1(sub));
		}
```

可惜答案是no，比如[5,4,3,2,1]。

2个选择2个循环，3个也就需要3个，19个循环你写过吗？ 仔细一看，这也就是个组合问题，所以可以改成通用形式：

```java
	class Comb {
		int sum;
		int[] sub;
	}

	int bigEyeball(int[] eyes) {
		int maxSize = 0;
		// 每一种情况：从1到n-1
		for (int i = 1; i < eyes.length; i++) {
			// 求得这种情况下所有组合和子数组
			Comb[] c = getCombination(eyes, i);
			for (Comb comb : c) {
				if (foundEqual(comb.sum, comb.sub)) {
					maxSize = Math.max(maxSize, comb.sum);
				}
			}
		}
		return maxSize;
	}
```

关于`getCombination()`方法是可以实现的，也就是[m选n的组合问题](https://cgs1999.iteye.com/blog/2327664)，或参考[stackoverflow](https://stackoverflow.com/questions/29910312/algorithm-to-get-all-the-combinations-of-size-n-from-an-array-java)。

到此为止，热身运动做完了，可以开始正式活动了。

人天生具有很好的递归思维。

### 来段长跑吧
你觉得`n!`就很厉害了吗？ nonono， 再想想，一定可以想出更低复杂度的。

我们想得到2个球对把，不重复的选择，那么一个球的可能情况不就刚好3种情况：
1. 做成球1
2. 做成球2
3. 被抛弃

如果遍历出每个球的所有情况，也才 `3^20=3486784401`, 远低于`19!`。所以，这个简单：

```java
	int bigEyeball(int[] eyes) {
		int maxSize = 0;

		for (int i = 0; i < Math.pow(3, eyes.length); i++) {
			int k = i;
			int s1 = 0;
			int s2 = 0;
			for (int s : eyes) {
				if (k % 3 == 0) {
					// 加入球1
					s1 += s;
				} else if (k % 3 == 1) {
					// 加入球2
					s2 += s;
				} else {
					// 都不加入
				}
				k /= 3;
			}
			if (s1 == s2) {
				maxSize = Math.max(maxSize, s1);
			}
		}
		return maxSize;
	}
```

### 来几个专业动作



# 参考

[java8实现排列算法](https://dzone.com/articles/java-8-master-permutations)