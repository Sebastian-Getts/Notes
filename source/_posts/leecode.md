---
title: leecode
date: 2019-12-10 13:13:28
categories: algorithm
tags: leecode
---

坚持刷题吧

<!-- mroe -->

## Two Sum

Given an array of integers, return **indices** of the two numbers such that they add up to a specific target. You may assume that each input would have **exactly** one solution, and you may not use the *same* element twice.

**Example:**

```markdown
Given nums = [2,7,11,15], target = 9,

Because nums[0] + nums[1] = 2 + 7 = 9,
return [0,1].
```

----

## Solution

### Approach 1: Brute Force

Loop through each element *x* and find if there is another value that equals to *target - x*.

```java
public int[] twoSum(int[] nums, int target) {
    for (int i = 0; i < nums.length; i++) {
        for (int j = i + 1; j < nums.length; j++) {
            if (nums[j] == target - nums[i]) {
                return new int[] { i, j };
            }
        }
    }
    throw new IllegalArgumentException("No two sum solution");
}
```

#### Complexity Analysis

- Time complexity: O(n^2)

- Space complexity: O(1)

  {% note info %}

  复杂度其实是2n，n前的常数相比幂来说可以忽略不记。。。

  {% endnote %}

### Approach 2:  Two-pass Hash Table

We reduce the look up time from *O(n)* to *O(1)* by trading space for speed. A hash table is built exactly for this purpose, it supports tast look up in *near* constant time.("near": if a collision occurred, a look up could degenerate to *O(n)* time.).

A simple implementation uses two iterations. In the first iteration, we add each element's value and tis index to the table. Then, in the second iteration we check if each element's complement(*target - nums[i]*) exists in the table. Beware that the complement must not be *nums[i]* itself!

```java
public int[] twoSum(int[] nums, int target) {
    Map<Integer, Integer> map = new HashMap<>();
    for (int i = 0; i < nums.length; i++) {
        map.put(nums[i], i);
    }
    for (int i = 0; i < nums.length; i++) {
        int complement = target - nums[i];
        if (map.containsKey(complement) && map.get(complement) != i) {
            return new int[] { i, map.get(complement) };
        }
    }
    throw new IllegalArgumentException("No two sum solution");
}
```

#### Complexity Analysis:

- Time complexity: *O(n)*. Traverse the list containing *n* elements exactly twice. Since the hash table refuces the look up time to *O(1)*, the time complexity is *O(n)*.
- Space complexity: *O(n)*. The extra space required depends on the number of items stored in the hash table, which stores exactly *n* elements.

### Approach 3: One-pass Hash Table

While we iterate and inserting elements into the table, we also look back to check if current element's complement already exists in the table. If it exists, we have found a solution and return immediately.

```java
public int[] twoSum(int[] nums, int target) {
    Map<Integer, Integer> map = new HashMap<>();
    for (int i = 0; i < nums.length; i++) {
        int complement = target - nums[i];
        if (map.containsKey(complement)) {
            return new int[] { map.get(complement), i };
        }
        map.put(nums[i], i);
    }
    throw new IllegalArgumentException("No two sum solution");
}
```

#### Complexity Analysis:

- Time Complexity: *O(n)*.
- Space complexity: *O(n)*.



