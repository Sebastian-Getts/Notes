---
title: predict the winner
date: 2021-05-14 15:59:32
categories: leetcode
tags: dp
---

这是一道关于选择的问题，来源于[LeetCode]([Predict the Winner - LeetCode](https://leetcode.com/problems/predict-the-winner/))，一道很有意思的题目，这篇blog记录了从暴力逐步优化到dp的过程。

<!-- more -->

# 题目

简单说下题目，详细的数量限制等条件可以参照题目网站。

两个选手，从一个池中选取数字，选的时候只能从两端拿，并且每个人都是按照最优的方式。数字的大小代表得分，问最后一号选手的得分是否可以大于二号选手。

例1. 有数组{1，5，2}，无论一号选手选择1还是2，最后二号选手都将选择5并且获胜。

例2，有数组{1, 5, 233, 7}，一号选手可以通过一定的策略获取到233，所以一号选手可以获胜。

# 分析

如何下手呢？首先啊，涉及到策略，一味地贪心法是不可取的，我们可以枚举出所有的可能性，并且自下而上地选择最优。对于一号选手来说，可选的数字下标为i，j，那么有两种情况：

1. 选择i，此时二号选手也有两种情况可选：i+1，j。如果选择i+1，一号就剩下i+2或j；如果选择j，一号就剩下i+1或j-1，对于一号选手来说，可以获取的分数有两种情况（取min是因为二号选手获取最优解，那对 一号选手来说获取的就是最小值）
   - score.i + min(score.i+1, score.j-1)。二号选手选取了j
   - score.i + min(score.i+2, score.j)。二号选手选取了i
2. 选择j，此时二号选手的可选情况为：i，j-1。如果选择i，一号剩下i+1或j-1；如果选择j-1，一号剩下i+1，j-2，对一号选手来说，同上：
   - score.j + min(score.i+1, j-1)。二号选手选取了i
   - score.j + min(score.i, score.j-2)。二号选手选取了j

对于一号选手来说，也是择优，所以最终的结果是Math.max(两种情况)，最后与二号选手的的得分相比较。

## 法一

```java
public boolean predictWinner(int[] nums){
    int total = 0;
    for(int num : nums) total += num;
    int firstPlayer = helper(nums, 0, nums.length-1);

    return firstPlayer >= total - firstPlayer;
}

private int helper(int[] nums, int i, int j){
    if(i > j) return 0;
    if(i == j) return nums[i];

    return Math.max(
        nums[i] + Math.min(helper(nums, i+1, j-1), helper(nums, i+2, j)),
        nums[j] + Math.min(helper(nums, i+1, j-1), helper(nums, i, j-2))
    );
}
```

对于如何一组数字来说，都是可以拆解成更小的问题，例如上面的{1,5,2}，可以看作是{1,5}的扩展版本，所以，有了上面的方程，可以引入备忘录来代替重复的计算，减少递归深度。

## 法二

```java
public boolean predictWinner(int[] nums){
    int total = 0;
    for(int num : nums) total += num;
    int len = nums.length;
    int[][] memo = new int[len][len];
    Arrays.fill(memo, -1);
    int firstPlayer = helper(nums, 0, len-1, memo);

    return firstPlayer >= total - firstPlayer;
}

private int helper(int[] nums, int i, int j){
    if(i > j) return 0;
    if(i == j) return nums[i];
    if(memo[i][j] != -1) return memo[i][j];
    int score = Math.max(
        nums[i] + Math.min(helper(nums, i+1, j-1, memo), helper(nums, i+2, j, memo)),
        nums[j] + Math.min(helper(nums, i+1, j-1, memo), helper(nums, i, j-2, memo))
    );
    memo[i][j] = score;

    return score;
}
```
