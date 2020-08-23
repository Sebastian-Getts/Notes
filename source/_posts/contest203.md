---
title: contest203
date: 2020-08-23 12:22:22
tags: LeetCode
---

Leetcode周赛203

<!--more-->

# 1560. Most Visited Sector in a Circular Track

Given an integer `n` and an integer array `rounds`. We have a circular track which consists of `n` sectors labeled from `1` to `n`. A marathon will be held on this track, the marathon consists of `m` rounds. The `ith` round starts at sector `rounds[i - 1]` and ends at sector `rounds[i]`. For example, round 1 starts at sector `rounds[0]` and ends at sector `rounds[1]`

Return *an array of the most visited sectors* sorted in **ascending** order.

Notice that you circulate the track in ascending order of sector numbers in the counter-clockwise direction (See the first example).

**Example 1:**

![img](https://assets.leetcode.com/uploads/2020/08/14/tmp.jpg)

```
Input: n = 4, rounds = [1,3,1,2]
Output: [1,2]
Explanation: The marathon starts at sector 1. The order of the visited sectors is as follows:
1 --> 2 --> 3 (end of round 1) --> 4 --> 1 (end of round 2) --> 2 (end of round 3 and the marathon)
We can see that both sectors 1 and 2 are visited twice and they are the most visited sectors. Sectors 3 and 4 are visited only once.
```

**Example 2:**

```
Input: n = 2, rounds = [2,1,2,1,2,1,2,1,2]
Output: [2]
```

**Example 3:**

```
Input: n = 7, rounds = [1,3,5,7]
Output: [1,2,3,4,5,6,7]
```

## solution

这道题虽然看起来长，但是难度是`easy`的，所以一定不会复杂，仔细看来只是求重复次数最多的sectors，我觉得难点是在头一个数比后一个数大的情况下（相当与跑步比赛中的套圈），如何去从头开始循环。

```java
public List<Integer> mostVisited(int n, int[] rounds) {
    // 取数组第一个和最后一个数字
    int f = rounds[0], t = rounds[rounds.length-1];
    List<Integer> ret = new ArrayList<>();
    for(int i = f;;){
        ret.add(i);
        if(i == t)break;
        i++;
        if(i == n+1)i = 1;
    }
    Collections.sort(ret);
    return ret;
}
```

emmmm上面这个有些取巧，不明白的先看看下面这个：

```java
public List<Integer> mostVisited(int n, int[] A) {
    List<Integer> res = new ArrayList<>();
    for (int i = A[0]; i <= A[A.length - 1]; ++i)
        res.add(i);
    if (res.size() > 0) return res;
    // 下面计算的是start>end的情况，[1, end] + [start, n]
    for (int i = 1; i <= A[A.length - 1]; ++i)
        res.add(i);
    for (int i = A[0]; i <= n; ++i)
        res.add(i);
    return res;
}
```

实际上，我们只需要关注首节点和末节点就行了，因为要求的是重复次数最多的sector，那么，必然会涉及到首尾，完全不必考虑中间节点。

- 如果start<=end，返回\[start, end\]
- 如果start>end，返回\[start, n\]+\[1, end\]

另外一个版本，更好理解：

```java
public List<Integer> mostVisited(int n, int[] rounds) {
    int len = rounds.length, fr = rounds[0], to = rounds[len - 1];
    List<Integer> res = new ArrayList<>();
    if (to >= fr) {     // no circle, such as [1,3,1,2]
        for (int i = fr; i <= to; i++) res.add(i);
    } else {            // cross a circle, such as [2,3,2,1]
        // 这里遍历每个sector
        for (int i = 1; i <= n; i++) {
            // 如果到最后一个sector的下一个，就从数组中第一个开始，相当于从“后端”开始了，省去了中间部分。
            if (i == to + 1) i = fr;
            res.add(i);
        }
    }
    return res;
}
```

涉及`环`的问题，要找到问题本质。这里说的首尾，一是指给定n个sector中的首尾，二是指给定round中的首尾。



# 1561. Maximum Number of Coins You Can Get

There are 3n piles of coins of varying size, you and your friends will take piles of coins as follows:

- In each step, you will choose **any** 3 piles of coins (not necessarily consecutive).
- Of your choice, Alice will pick the pile with the maximum number of coins.
- You will pick the next pile with maximum number of coins.
- Your friend Bob will pick the last pile.
- Repeat until there are no more piles of coins.

Given an array of integers `piles` where `piles[i]` is the number of coins in the `ith` pile.

Return the maximum number of coins which you can have.

 

**Example 1:**

```
Input: piles = [2,4,1,2,7,8]
Output: 9
Explanation: Choose the triplet (2, 7, 8), Alice Pick the pile with 8 coins, you the pile with 7 coins and Bob the last one.
Choose the triplet (1, 2, 4), Alice Pick the pile with 4 coins, you the pile with 2 coins and Bob the last one.
The maximum number of coins which you can have are: 7 + 2 = 9.
On the other hand if we choose this arrangement (1, 2, 8), (2, 4, 7) you only get 2 + 4 = 6 coins which is not optimal.
```

**Example 2:**

```
Input: piles = [2,4,5]
Output: 4
```

**Example 3:**

```
Input: piles = [9,8,7,6,5,1,2,3,4]
Output: 18
```



## solution

我觉得这道题本质是个排序的题，但是要按一定的规则排序，最初设想的是每三个数排序，取中间那个。

然而好的算法都是讲究技巧的，不是靠蛮力。完全可以放心地对数组进行排序，可以理解为逆向思维，例如example1中的数组排好序后：*[1,2,2,4,7,8]*，无论我们怎么分，最优解必然是Bob拿到前两个数，剩下的四个是我们与Alice分，由于是我拿第二大的，所以先分我，在分给Alice，依照这样的一个思路，问题就解决了。

```java
public int maxCoins(int[] A) {
    Arrays.sort(A);
    int res = 0, n = A.length;
    for (int i = n / 3; i < n; i += 2)
        res += A[i];
    return res;
}
```

