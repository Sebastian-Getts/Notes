---
title: contest202
date: 2020-08-16 14:36:31
categories: Leetcode
tags: algorithm
---

Leetocode周赛202

<!--more-->

# 1550. Three Consecutive Odds

Given an integer array `arr`, return `true` if there are three consecutive odd numbers in the array. Otherwise, return `false`.

**Example 1:**

```
Input: arr = [2,6,4,1]
Output: false
Explanation: There are no three consecutive odds.
```

**Example 2:**

```
Input: arr = [1,2,34,3,4,5,7,23,12]
Output: true
Explanation: [5,7,23] are three consecutive odds.
```

## solution

题目难度不高，因此重点关注代码技巧上。“连续三个基数”则返回true，否则false，一般情况下都会想到遍历数组的同时维护一个变量，变量达到三时返回。直到我看到了神级代码：

```java
public boolean threeConsecutiveOdds(int[] a) {
    for(int i = 0;i+2 < a.length;i++){
        if(a[i]%2 + a[i+1] % 2 + a[i+2] % 2 == 3){
            return true;
        }
    }
    return false;
}
```

rank榜单的前几名整齐化一地这样写。我们来看看这样写的原理：

同样是for循环，它的 判断条件是`i+2<a.length`，为何要`+2`,原因在for循环中，它每次在第i处下标都会同时获取到i的后两位，把和三个数与2相除取余，如果是奇数余数为1,那么这三个数相加即为3,好处是不用额外维护一个变量，代码也简单易懂。

**note:** 循环时同时做三个数的运算；取余判断奇偶



# 1551. Minimum Operations to Make Array Equal

You have an array `arr` of length `n` where `arr[i] = (2 * i) + 1` for all valid values of `i` (i.e. `0 <= i < n`).

In one operation, you can select two indices `x` and `y` where `0 <= x, y < n` and subtract `1` from `arr[x]` and add `1` to `arr[y]` (i.e. perform `arr[x] -=1 `and `arr[y] += 1`). The goal is to make all the elements of the array **equal**. It is **guaranteed** that all the elements of the array can be made equal using some operations.

Given an integer `n`, the length of the array. Return *the minimum number of operations* needed to make all the elements of arr equal.

**Example 1:**

```
Input: n = 3
Output: 2
Explanation: arr = [1, 3, 5]
First operation choose x = 2 and y = 0, this leads arr to be [2, 3, 4]
In the second operation choose x = 2 and y = 0 again, thus arr = [3, 3, 3].
```

**Example 2:**

```
Input: n = 6
Output: 9
```

## solution

这道题看着挺复杂，行数多，其实像是在`找规律`（我就是没找出来，n=6时output=9？），是一道数学题。

```java
public int minOperations(int n) {
    // Take care of overflow if n is too large.
    if(n%2==1){
        n/=2;
        return (n*(n+1));
    }        
    n/=2;
    return n*n;
}
```

上面的解法是将其分两种情况--奇数与偶数。考得不是算法， 是脑子吧。。。