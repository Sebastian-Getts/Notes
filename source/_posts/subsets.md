---
title: subsets
date: 2020-06-27 23:09:34
categories: Leetcode
tags: 
---

Return all possible subsets(the power set).

<!--more-->

# 5460. Number of Good Pairs

Given an array of integers `nums`.

A pair (i, j) is called _good_ if `nums[i] == nums[j]` and `i < j`.

Return the numbers of _good_ pairs.

Example 1:

```example
Input: nums = [1,2,3,1,1,3]
Output: 4
Explanation: There are 4 good pairs (0,3), (0,4), (3,4), (2,5) 0-indexed.
```

Example 2:

```example
Input: nums = [1,1,1,1]
Output: 6
Explanation: Each pair in the array are good.
```

Example 3:

```example
Input: nums = [1,2,3]
Output: 0
```

## Thinking 

- 蛮力法获取到所有重复的数字，如何解出符合要求的解？
- 用什么数据结构保存数组和对应的下标以保证遍历一次数组而不是两次？
- 利用递归求解应该是个不错的选择。

## Result

想多了。。。

```java
public int numIdenticalPairs(int[] nums) {
    int count = 0;
    // 这里i、j的命名与题目相反，思路结果是ok的
    for (int i = 0; i < nums.length; i++) {
        for (int j = 0; j < i; j++) {
            if (nums[i] == nums[j]) {
                count++;
            }
        }
    }
    return count;
}
```

# 78. Subsets

Given a set of distinct integers, *nums*, return all possible

**Note:** The solution set must not contain duplicate subsets.

**Example:**

```markdown
Input: nums = [1,2,3]
Output:
[
  [3],
  [1],
  [2],
  [1,2,3],
  [1,3],
  [2,3],
  [1,2],
  []
]
```

## Solution

```java
public List<List<Integer>> subsets(int[] nums) {
    if(nums == null){
        return null;
    }

    List<List<Integer>> result = new ArrayList<>();

    for(int value: nums){
        List<List<Integer>> temp = new ArrayList<>();

        for(List<Integer> a:result){
            temp.add(new ArrayList<>(a));
        }

        for(List<Integer> a:temp){
            a.add(value);
        }

        List<Integer> single = new ArrayList<>();
        single.add(value);
        temp.add(single);

        result.addAll(temp);
    }

    result.add(new ArrayList<>());

    return result;
}
```

所有的工作都在一个for循环中完成了，return前的一次add是加入空表，因为空也是原数组的一个子集。来看看for循环中做了什么，把result中的线性表赋给临时表、往临时表中的每个元素添加目前正在遍历的元素、往临时表中作为独立元素添加目前正在遍历的元素，最后是将临时表赋给result。

# 90. Subset II

