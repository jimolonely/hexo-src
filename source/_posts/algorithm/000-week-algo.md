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

当然，这并不是唯一的一种暴力求解方法，还可以利用数组: 这个思想的解释见下面一节。
```java
		Ball[] state = new Ball[(int) Math.pow(3, eyes.length)];
		int t = 0;
		state[t++] = new Ball(0, 0);
		for (int size : eyes) {
			int end = t;
			for (int i = 0; i < end; i++) {
				Ball b = state[i];
				// 放入s1
				state[t++] = new Ball(b.s1 + size, b.s2);
				// 放入s2
				state[t++] = new Ball(b.s1, b.s2 + size);
				// 不放，舍去
			}
		}
		for (Ball b : state) {
			if (b.s1 == b.s2) {
				maxSize = Math.max(maxSize, b.s1);
			}
		}
```

### 找个捷径穿过去
我们有`3^N`种可能的状态，每个小球x要么放入s1，要么放入s2，要么不放，为了方便计算，我们用数字表示，分别对应：+x，-x 或 0。

为了加快速度，我们先单独求解每一半，然后将它们结合起来。例如，如果我们有球[1,2,3,6]，那么前两个球最多可以创建九种状态：
`[0 + 0,1 + 0,0 - 1,2 + 0,0 - 2，3 + 0，1 - 2,2 - 1,0 - 3]`，后两个球也可以创造9个状态。
我们将每个状态存储为正项的总和，以及负项的绝对值之和。例如，`+ 1 + 2 -3 -4`变为（3,7）。
我们也将差值`3  -  7`称为该状态的增量，因此该状态的增量为-4。
 
我们的下一个目标是将总和为0的增量的状态 结合起来。状态的大小将是正项的总和， 我们希望获得最大大小。请注意，对于每个增量，我们只关心大小最大的状态。

算法
1. 将球分成两半：左右两侧。
2. 对于每一半，使用暴力计算上面定义的可达状态。然后，对于每个状态，记录增量和最大分数。
3. 现在，我们有一个左右两半的[（增量，分数）]信息。我们将找到总增量为0的最大总分。

如何计算每一半的状态：就是上一节的第二种暴力方法
```java
	private Map<Integer, Integer> cal(int[] sizes) {
		Ball[] state = new Ball[(int) Math.pow(3, sizes.length)];
		int t = 0;
		state[t++] = new Ball(0, 0);
		for (int size : sizes) {
			int end = t;
			for (int i = 0; i < end; i++) {
				Ball b = state[i];
				// 放入s1
				state[t++] = new Ball(b.s1 + size, b.s2);
				// 放入s2
				state[t++] = new Ball(b.s1, b.s2 + size);
				// 不放，舍去
			}
		}
		// ...
	}
```
这个求解的结果如下：以[1,2,3,6]为例，下面是前半段[1,2]的状态集：
```java
Ball{s1=0, s2=0}
Ball{s1=1, s2=0}
Ball{s1=0, s2=1}
Ball{s1=2, s2=0}
Ball{s1=0, s2=2}
Ball{s1=3, s2=0}
Ball{s1=1, s2=2}
Ball{s1=2, s2=1}
Ball{s1=0, s2=3}
```
接着求解增量状态：
```java
		Map<Integer, Integer> map = new HashMap<>(t);
		for (int i = 0; i < t; i++) {
			int s1 = state[i].s1;
			int s2 = state[i].s2;
			map.put(s1 - s2, Math.max(map.getOrDefault(s1 - s2, 0), s1));
		}
```
最后是合并，完整代码如下：
```java
	int bigEyeBallHalf(int[] eyes) {
		int maxSize = 0;

		int n = eyes.length;
		Map<Integer, Integer> delta1 = cal(Arrays.copyOfRange(eyes, 0, n / 2));
		Map<Integer, Integer> delta2 = cal(Arrays.copyOfRange(eyes, n / 2, n));

		// 合并，差值为0的最大情况
		for (Integer d : delta1.keySet()) {
			if (delta2.containsKey(-d)) {
				maxSize = Math.max(maxSize, delta1.get(d) + delta2.get(-d));
			}
		}

		return maxSize;
	}

	private Map<Integer, Integer> cal(int[] sizes) {
		Ball[] state = new Ball[(int) Math.pow(3, sizes.length)];
		int t = 0;
		state[t++] = new Ball(0, 0);
		for (int size : sizes) {
			int end = t;
			for (int i = 0; i < end; i++) {
				Ball b = state[i];
				// 放入s1
				state[t++] = new Ball(b.s1 + size, b.s2);
				// 放入s2
				state[t++] = new Ball(b.s1, b.s2 + size);
				// 不放，舍去
			}
		}
		Map<Integer, Integer> map = new HashMap<>(t);
		for (int i = 0; i < t; i++) {
			int s1 = state[i].s1;
			int s2 = state[i].s2;
			map.put(s1 - s2, Math.max(map.getOrDefault(s1 - s2, 0), s1));
		}
		return map;
	}

	class Ball {
		int s1;
		int s2;

		Ball(int s1, int s2) {
			this.s1 = s1;
			this.s2 = s2;
		}

		@Override
		public String toString() {
			return "Ball{" +
					"s1=" + s1 +
					", s2=" + s2 +
					'}';
		}
	}
```

为什么可以拆分又合并？ 
为什么可以不需要考虑数组元素的顺序？

### 穿越虫洞
总会有更好、更快的方法。 应该一开始就看出来这道题满足动态规划的条件。

```java
	int bigEyeball(int[] eyes) {
		int n = eyes.length;
		int[][] dp = new int[n + 1][];

		int sum = sum(eyes);

		initArray(dp, sum);

		dp[0][0] = 0;

		for (int i = 1; i <= eyes.length; i++) {
			int s = eyes[i - 1];
			for (int j = 0; j <= sum - s; j++) {
				if (dp[i - 1][j] < 0) {
					continue;
				}
				// not choose
				dp[i][j] = max(dp[i][j], dp[i - 1][j]);
				// put in bigger
				dp[i][j + s] = max(dp[i][j + s], dp[i - 1][j]);
				// put in smaller, 2 situation
				dp[i][abs(j - s)] = max(dp[i][abs(j - s)], dp[i - 1][j] + min(j, s));
			}
		}
//		printArray(dp);
		return dp[n][0];
	}

	private void initArray(int[][] dp, int sum) {
		for (int i = 0; i < dp.length; i++) {
			dp[i] = new int[sum + 1];
			for (int j = 0; j < dp[i].length; j++) {
				dp[i][j] = -1;
			}
		}
	}

	private int sum(int[] eyes) {
		int sum = 0;
		for (int s : eyes) {
			sum += s;
		}
		return sum;
	}
```
其中的状态dp[i][j]代表： 已选择i个小球且增量（已经组成的2个球的大小差）为j时的最大大球size。
```java
// not choose
dp[i][j] = max(dp[i][j], dp[i - 1][j]);
// put in bigger
dp[i][j + s] = max(dp[i][j + s], dp[i - 1][j]);
// put in smaller, 2 situation
dp[i][abs(j - s)] = max(dp[i][abs(j - s)], dp[i - 1][j] + min(j, s));
```
这3个状态转移方程对应3种情况，需要说明的就是第3种情况，画个图解释把。

// todo

如果你觉得这就完了，那你就太天真了，其实这里的二维数组完全可以变为一维数组：
```java
	int bigEyeballDim1(int[] eyes) {
		int n = eyes.length;
		int sum = sum(eyes);
		int[] dp = new int[sum + 1];

		Arrays.fill(dp, -1);
		dp[0] = 0;
		for (int s : eyes) {
			int[] old = Arrays.copyOf(dp, dp.length);
			for (int i = 0; i <= sum - s; i++) {
				if (old[i] < 0) {
					continue;
				}
				dp[i + s] = max(dp[i + s], old[i]);
				dp[abs(i - s)] = max(dp[abs(i - s)], old[i] + min(s, i));
			}
		}
		return dp[0];
	}
```

# 参考

[java8实现排列算法](https://dzone.com/articles/java-8-master-permutations)