---
title: ArrangementAndCombination
date: 2022-09-30 16:59:04
categories: java
tags: Leetcode
---

本文整理排列组合相关的算法，包含各类可能存在的附加条件。相关列题参考Leetcode的`combination sum`以及`subset`系列。

<!-- more -->

## combination

给定的数据不含重复，但每个数字可以重复使用。

```java
    public List<List<Integer>> combinationSum(int[] candidates, int target) {
        List<List<Integer>> list = new ArrayList<>();
        helper(list, new ArrayList<>(), candidates, target, 0);

        return list;
    }

    public void helper(List<List<Integer>> list, List<Integer> tempList, int[] candidates, int target, int start) {
        if(target <= 0) {
            // target为0时符合要求，小于0的舍弃。
            if(target == 0) list.add(new ArrayList<>(tempList));
        } else {
            // i = start，从start开始
            for(int i=start; i<candidates.length; i++) {
                tempList.add(candidates[i]);
                // start位置仍传递当前值，表示值可以复用
                helper(list, tempList, candidates, target - candidates[i], i);
                tempList.remove(tempList.size() - 1);
            }
        }
    }
```

```properties
Input: candidates = [2,3,5], target = 8
Output: [[2,2,2,2],[2,3,3],[3,5]]
```

### combination II

给定的数据含有重复的，且每个数字只能使用一次。

```java
    public List<List<Integer>> combinationSum2(int[] candidates, int target) {
        List<List<Integer>> list = new ArrayList<>();
        // 先对数据排序，用于后续判断nusm[i]、nums[i-1]时使用
        Arrays.sort(candidates);
        helper(list, new ArrayList<>(), candidates, target, 0);

        return list;
    }

    public void helper(List<List<Integer>> list, List<Integer> templist, int[] nums, int target, int start) {
        if(target <= 0) {
            if(target == 0) list.add(new ArrayList<>(templist));
        } else {
            for(int i=start; i<nums.length; i++) {
                // 用于保证重复数据时，只使用一次，如[2,2,3]只出现一次。
                if(i > start && nums[i] == nums[i-1]) {
                    continue;
                }
                templist.add(nums[i]);
                helper(list, templist, nums, target - nums[i], i+1);
                templist.remove(templist.size() - 1);
            }
        }
    }
```

### combination III

只使用1～9的数字，每个数字用一次，给定变量`k`（表示组合中数字的个数）和变量`n`（表示组合中数字的和），求符合要求的组合。

```java
    public List<List<Integer>> combinationSum3(int k, int n) {
        List<List<Integer>> list = new ArrayList<>();
        int[] nums = {1,2,3,4,5,6,7,8,9};
        helper(list, new ArrayList<>(), nums, 0, n, k);

        return list;
    }

    public void helper(List<List<Integer>> list, List<Integer> templist, int[] nums, int start, int target, int k) {
        // 与其他的情况相比，这里多了长度限制和对目标值的判断
        if(target <= 0 && templist.size() == k) {
            if(target == 0) list.add(new ArrayList<>(templist));
        } else {
            for(int i=start; i<nums.length; i++) {
                templist.add(nums[i]);
                helper(list, templist, nums, i+1, target - nums[i], k);
                templist.remove(templist.size() - 1);
            }
        }
    }
```

## subset

```java
public List<List<Integer>> arrangement(int[] nums) {
    List<List<Integer>> list = new ArrayList<>();
    helper(list, new ArrayList<>(), nums);

    return list;
}


public static void helper(List<List<Integer>> list, List<Integer> tempList, int[] nums) {
    // 当临时表中的数据的量等于给定数组的量时，装入list
    if(tempList.size() == nums.length) {
        list.add(new ArrayList<>(tempList));
    } else {
        for(int i=0; i<nums.length; i++) {
            if(tempList.contains(nums[i])) continue;
            tempList.add(nums[i]);
            helper(list, tempList, nums);
            tempList.remove(tempList.size() - 1);
        }
    }
}
```
