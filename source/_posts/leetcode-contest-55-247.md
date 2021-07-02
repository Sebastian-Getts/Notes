---
title: leetcode_contest_55&247
date: 2021-06-27 12:55:29
categories: LeetCode
tags: summary
---

这周是双周，打了两场周赛，总结一下这两场

<!-- more -->

# 247

## 删除一个元素使数组严格

一堆无序的数组，从里面删除一个元素保证整个数组是严格递增。题目中的限制是数组的长度小于1000（从这里考虑是否暴力）。当时做法有顾虑暴力法，而且考虑的是**是否挨个将每一个元素剔除掉然后再遍历一遍都是是递增**（考虑到复杂度，时间成本大，空间上可能还要创建多个数组，我直接pass了）；考虑的方法二是**多指针**，试了一个三指针的，WA了，又试了一个四指针，也WA==。

其实想复杂了，遍历一遍，删除掉不符合的元素，然后再遍历一遍，看看是否符合。（枚举+暴力）

```java
public boolean canBeIncreasing(int[] nums) {
    // 模拟每个数组被删除的场景
    if(check(nums)) return true;
    int len = nums.length;
    for(int i=0; i<len; i++){
        int[] t = new int[len - 1];
        int k = 0;
        for(int j=0; j<len; j++){
            if(j == i) continue;
            t[k++] = nums[j];
        }
        if(check(t)) return true;
    }
    
    return false;
}

private boolean check(int[] nums) {
    for(int i=1; i<nums.length; i++){
        if(nums[i] <= nums[i-1]) return false;
    }
    
    return true;
}

```



## 删除一个字符串中所有出现的给定子字符串

额外要求是从左开始删除，字符串和子字符串的长度都不超过1000.

这道题体现了**会python的重要性**.

```python
def removeOccurences(self, s: str, part: str) -> str:
    while part in s:
        s = s.replace(part, '')
       
    return s
```



## 最大序列的交替和

