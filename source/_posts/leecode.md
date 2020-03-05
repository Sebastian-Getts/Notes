---
title: leecode
date: 2019-12-10 13:13:28
categories: Leecode
tags: leecode_easy
---

坚持刷题吧

<!-- mroe -->

# Two Sum

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

----

----

# Remove Element

Given an array *nums* and a value *val*, remove all instances of that value `in-place` and return the new length.

Do not allocate extra space for another array, you must do this by **modify the input array** `in-place` with O(1) extra memory

## Hints

1. Try two pointers
2. Did you use the fact that the order of elements can be changed?
3. What happens when the elements to remove are rare?

---

## Solution

#### Approach 1: Two pointers

#### Intuition:

Keep two pointers *i* and *j*, where *i* is the slow-runner while *j* is the fast-runner.

#### Algorithm

When *nums[j]* equals to the given value, skip this element by incrementing *j*. As long as *nums[j] != val*, we copy *nums[j]* to *nums[i]* and increment both indexes at the same time. Repeat the process until *j* reaches the end of the array and the new length is *i*.

```java
public int removeElement(int[] nums, int val){
    int i = 0;
    for(int j = 0; j < nums.length; j++){
        if(nums[j] != val){
            nums[i] = nums[j];
            i++;
        }
    }
    return i;
}
```



#### Complexity anaylysis

- Time complexity: O(n)
- Space complexity: O(1)



### Approach 2: Two Pointers-when elements to remove are rare

#### Intuition

Consider cases where the array contains few elements to remove. For example, *nums = [1,2,3,4]*, val = 4. The previous algorithm will do unnecessary copy operation of the first four elements. Another example is *nums=[4,1,2,3,5]*, val =4. It seems unnecessary to move elements [1,2,3,5] one step left as the problem description mentions that the order of elements could be changed.

#### Algorithm

When we encounter *nums[i]=val*, we can **swap the current element out** with the last element and dispose the last one. The essentially reduces the array's size by 1.

Note that the last element that was swapped in could be the value you want to remove itself. But don't worry, in the next iteration we will still check this element.

```java
public int removeElement(int[] nums, int val){
    int i = 0;
    int n = nums.length;
    while(i < n){
        if(nums[i] == val){
            nums[i] = nums[n - 1];
            n--; // reduce array size by one
        } else {
            i++;
        }
    }
    return n;
}
```

#### Complexity analysis

- Time complexity: O(n)
- Space complexity: O(1)

---

---



# Remove Duplicates from Sorted Array

Given a sorted array *nums*, remove the duplicates **in-place** such that each element appear only *once* and return the new length.

Do not allocate extra space for another array.

### Clarification:

Confused why the returned value is an integer but your answer is an array?

Note that the input array is passed in by **reference**, which means modification to the input array will be known to the caller as well.

Approach 1: Two Pointers

#### Algorithm

**Since the array is already sorted**, we can keep two pointers *i* and *j*, where *i* is the slow-runner while *j* is the fast-runner. As long as *nums[i] = nums[j]*, we increment *j* to skip the duplicate.

When we encounter *nums[i] != nums[i]*, the duplicate run has ended so we must copy its value to *nums[i+j]*. *i* is then incremented and we repeat the same process again until *j* reaches the end of array.

```java
public int removeDuplicates(int[] nums) {
    if (nums.length == 0) return 0;
    int i = 0;
    for (int j = 1; j < nums.length; j++) {
        if (nums[j] != nums[i]) {
            i++;
            nums[i] = nums[j];
        }
    }
    return i + 1;
}
```



# Longest Common Prefix

Write a function to find the longest common prefix string  amongst an array of strings. If there is no common prefix, return an empty string`""`.

## Solution

### Approach 1: Horizontal scanning

![image.png](https://i.loli.net/2020/02/01/zmUXiwkoG7Dgq8R.png)

```java
public String longestCommonPrefix(String[] strs) {
    if (strs.length == 0) {
        return "";
    }
    String prefix = strs[0];
    for (int i = 1; i < strs.length; i++) {
        while (strs[i].indexOf(prefix) != 0) {
            prefix = prefix.substring(0, prefix.length() - 1);
            if (prefix.isEmpty()) {
                return "";
            }
        }
    }
    return prefix;
}
```

#### Complexity Analysis

- Time Complexity: *O(S)*, where *S* is the sum of all characters in all strings.

  In the worst case  all *n* strings are the same. The algorithm compares the string **S1** with the other strings \[S2...Sn]. There are *S* character comparisons, where *S* is the sum of all characters in the input array.

- Space complexity: *O(1)*. We only used constant extra space.

### Approach 2: Vertical scanning

Imagine a very shot string is at the end of the array. The approach will still do *S* comparisons. One way to optimize this case is to do vertical scanning. We compare characters from top to bottom on the same column(same character index of the strings) before moving on to the next column.

```java
private String longestCommonPrefix2(String[] strs) {
    if (strs == null || strs.length == 0) {
        return "";
    }
    for (int i = 0; i < strs[0].length(); i++) {
        char c = strs[0].charAt(i);
        for (int j = 1; j < strs.length; j++) {
            if (i == strs[j].length() || strs[j].charAt(i) != c) {
                return strs[0].substring(0, i);
            }
        }
    }
    return strs[0];
}
```

#### Complexity Analysis

- Time complexity: *O(S)*, where *S* is the sum of all characters in all strings. In the worst case there will be *n* equal strings with length *m* and the algorithm perform *S* = *m x n* character comparisons. Even though the worst case is still the same as *Approach 1*, in the best case there are at most *n x minLen* comparisons where *minLen* is the length of the shortest string in the array.
- Space complexity: *O(1)*. We only used constant extra space.

### Approach 3: Divide and conquer

![image.png](https://i.loli.net/2020/02/01/MzcPpRCeEYbH8nx.png)

...

### Approach 4: Binary search

# Longest Substring Without Repeating Characters

## approach 1: brute force

```java
public class Solution {
    public int lengthOfLongestSubstring(String s) {
        int n = s.length();
        int ans = 0;
        for (int i = 0; i < n; i++)
            for (int j = i + 1; j <= n; j++)
                if (allUnique(s, i, j)) ans = Math.max(ans, j - i);
        return ans;
    }

    public boolean allUnique(String s, int start, int end) {
        Set<Character> set = new HashSet<>();
        for (int i = start; i < end; i++) {
            Character ch = s.charAt(i);
            if (set.contains(ch)) return false;
            set.add(ch);
        }
        return true;
    }
}
```

### time complexity: O(n^3)

## approach 2: Sliding Window

```java
public class Solution {
    public int lengthOfLongestSubstring(String s) {
        int n = s.length();
        Set<Character> set = new HashSet<>();
        int ans = 0, i = 0, j = 0;
        while (i < n && j < n) {
            // try to extend the range [i, j]
            if (!set.contains(s.charAt(j))){
                set.add(s.charAt(j++));
                ans = Math.max(ans, j - i);
            }
            else {
                set.remove(s.charAt(i++));
            }
        }
        return ans;
    }
}
```

time complexity: O(2n)

## approach 3: Sliding Window Optimized

### Using HashMap

```java
public class Solution {
    public int lengthOfLongestSubstring(String s) {
        int n = s.length(), ans = 0;
        Map<Character, Integer> map = new HashMap<>(); // current index of character
        // try to extend the range [i, j]
        for (int j = 0, i = 0; j < n; j++) {
            if (map.containsKey(s.charAt(j))) {
                i = Math.max(map.get(s.charAt(j)), i);
            }
            ans = Math.max(ans, j - i + 1);
            map.put(s.charAt(j), j + 1);
        }
        return ans;
    }
}
```

### Using ASCII 128

```java
public class Solution {
    public int lengthOfLongestSubstring(String s) {
        int n = s.length(), ans = 0;
        int[] index = new int[128]; // current index of character
        // try to extend the range [i, j]
        for (int j = 0, i = 0; j < n; j++) {
            i = Math.max(index[s.charAt(j)], i);
            ans = Math.max(ans, j - i + 1);
            index[s.charAt(j)] = j + 1;
        }
        return ans;
    }
}
```

time complexity: O(n)