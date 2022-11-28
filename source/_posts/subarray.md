---
title: subarray
date: 2021-02-27 13:45:38
categories: Leetcode
tags: 
- double poiters
- map+preSum
---

这篇聊聊双指针以及他的替代方法。title是subarray，这是因为相关的题使用双指针解起来是十分方便的，但是也有不适用的情况，所以更建议使用一步到位的`map` + `preSum`，双指针的思路是很容易理解的，后者需要绕个弯。

<!-- more -->

<!--toc-->

# [Subarray Sum Equals K](https://leetcode.com/problems/subarray-sum-equals-k/)

Given an array of integers `nums` and an integer `k`, return *the total number of continuous subarrays whose sum equals to `k`*.

以上是题干，我们从这道题来入手这篇的主题。由于是求连续的子数组，所以我们首先想到的应该是双指针：

```java
public int subarraySum(int[] nums, int k){
    int res = 0;
    for(int lo = 0, hi = 0, sum = 0; hi < nums.length; hi++){
        sum += nums[i];
        whlie(lo < nums.length && sum > k){
            sum -= nums[lo++];
        }
        if(sum == k) res++;
    }

    return res;
}
```

如果提交以上代码，肯定不会AC，为什么呢，我们再来看题目的**Constraints**：

- `1 <= nums.length <= 2 * 104`
- `-1000 <= nums[i] <= 1000`
- `-107 <= k <= 107`

注意到了么，给的入参中数字是可以为负数的，在代码中`sum-= nums[lo++]`是无效的，如果入参都是正数，双指针就是OK的。

## map + preSum

​        与双指针不同的是，这种解法用到了额外的数据结构`map`，在这里关于映射表的用法也有多种。另外一个`preSum`很好理解，就是前缀和。用这两个能做什么呢？我们从前缀和来试着理解下：

有一串数字：1,2,3,4,5,6，6个数字，前5个的和记为P5，是15；前2个的和记为P2，是3，那么`P5 - P2`是12，正是子串\[2, 3\]。就是利用这个方式来找子串。那么子串找到了如何利用map呢？别忘了，入参不仅仅只有数组，在这道题中我们还要找到和为target的子串的数量，换句话说，要找到符合条件的子串。如果符合条件，那么应该满足：`Px - Py = target (x > y)`，但是这样做我们岂不是要找出所有子串然后相减？显然违背了初衷（简单），我们换个思路，长的前缀和是已知的，目标值也是已知的，所以可以这样写：`Px - target = Py`，然后统计有多少个符合的子数组即可，这样我们的map可以定义为*Map\<Integer, Integer\>*，用来保存*当前的数组和*和*数组和的个数*。

```java
public int subarraySum(int[] nums, int k){
    if(nums.length == 0) return 0;
    Map<Integer, Integer> map new HashMap<>();
    int sum = 0, result = 0;
    for(int cur : nums){
        sum += cur; // preSum
        if(sum == k) result++; //也可以提前在map中放入 map.put(0, 1)
        result += map.getOrDefault(sum - k, 0);
        map.put(sum, map.getOrDefault(sum, 0) + 1);
    }

    return result;
}
```

通过这道题可以衍生出很多种题目，尤其是这种解法，非常巧妙。特别是，改下题目，如果不是返回符合条件的个数，而是返回子数组呢？那么我们map记录的就不是子数组和的个数了，而应该是下标：`sum(i, j) = sum(0, j) - sum(0, i)`。

# [Minimum Operations to Reduce X to Zero](https://leetcode.com/problems/minimum-operations-to-reduce-x-to-zero)

You are given an integer array `nums` and an integer `x`. In one operation, you can either remove the leftmost or the rightmost element from the array `nums` and subtract its value from `x`. Note that this **modifies** the array for future operations.

Return *the **minimum number** of operations to reduce* `x` *to **exactly*** `0` *if it's possible**, otherwise, return* `-1`.

**Constraints:**

- `1 <= nums.length <= 105`
- `1 <= nums[i] <= 104`
- `1 <= x <= 109`

​        以上是题干，题目规定了取数的方式：只能从最左或最右侧取数。之所以把这道题放在这里，是因为换个角度看，其实也是求子数组！最小操作数意味着取最少的数字，那么子数组要在满足给定值的情况下保证最多。例如，有数组：1,2,3,4,5，目标值是6，我们需要从数组中找出满足（数组和为15，15-6=9）和为9的情况下个数最多的情况，这样一来，其余的值和为6且个数最少。

由于题目给了限制条件：数组成员均大于或等于1，不存在负数，可以使用双指针遍历：

```java
public int minOperations(int[] nums, int x){
    int target = Arrays.stream(nums).sum() - x;
    int size = -1, n = nums.length;
    for(int lo = 0, hi = 0, sum = 0; hi < n; hi++){
        sum += nums[hi];
        while(lo < n && sum > target){
            sum -= nums[lo++];
        }
        if(sum == target) size = Math.max(size, hi - lo + 1);
    }
    return size < 0 ? -1 : n - size;
}
```

也能使用前缀和：

```java
public int minOperations(int[] nums, int x) {
    int target = Arrays.stream(nums).sum() - x;
    if(target == 0) return nums.length;
    Map<Integer, Integer> map = new HashMap<>();
    map.put(0, -1);// 长度，下面是 i - map.value
    int sum = 0, res = 0;
    for(int i=0; i<nums.length; i++){
        int num = nums[i];
        sum += num;
        if(map.containsKey(sum - target)){
            res = Math.max(res, i - map.get(sum - target));
        }
        map.put(sum, i);
    }

    return res == 0 ? -1 : nums.length - res;
}
```
