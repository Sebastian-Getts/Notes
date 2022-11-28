---
title: jump games
date: 2021-05-24 12:13:39
categories: LeetCode
tags: greedy, dp, stratey
---

*Jump Games*在LeetCode中是一个系列的问题，涉及动态规划、贪心等策略，非常有意思，尤其是昨天周赛再次遇到了这个系列的新题，在此复盘、总结。

<!-- more -->

<!-- toc -->

# Jump Game

> 输入一个数组，从下标0开始，数组中每个数字表示你能跳跃的最大距离，问能否到达终点。

这道题是能否到达终点，返回的是一个布尔值，所以不用关心到达终点的方式以及相关数量。假设有i，它可以跳跃的距离是d，那么在距离(i+1, i+d)之间都是可行进的范围，我们需要从这里面选出一步来往下走，对于下一步也重复上一步的操作，直到终点。但是这样做的话时间复杂度会到O(n^2)，提交肯定会TLE。

### dp

动态规划，用数组维护一个跳力值，只要到终点还有跳力（不为负）就说明是可行的。如何去写状态转移方程呢？对于一个位置i，只能从前n步中过来，但是这是不确定的，所以我们可以一步一步地往前走，同时维护最大跳力即可，所以回到刚才的位置i，他是从i-1过来的，那么他所剩的跳力可以从上一步中获取，到目前的i时减去一（i-1到i要耗费一个跳力）。对于i-1，有两种选择，一种是维护的跳力dp，另一种是i-1位置时获取的跳力nums，取一个最大值就行。dp中存储的就是跳力值了。

```java
public boolean canReach(int[] nums){
    int len = nums.length, res = 0;
    int[] dp = new int[len];
    for(int i=1; i<nums.length; i++){
        res = Math.max(dp[i-1], nums[i-1]) - 1;
        if(res < 0) return false;
    }

    return true;
}
```

### greedy

可以对上面的dp做化简，我们只关心能否到达终点，一个简单的布尔值，不关心最终能跳多远，也就是跳力，所以可以只保留一个最远的值，判断他是否到比终点大就可，用到了贪心的思想。

```java
public boolean canReach(int[] nums){
    int len = nums.length, reach = 0;
    for(int i=0; i<len; i++){
        if(i > reach || reach >= len - 1) break;
        reach = Math.max(reach, i + nums[i]);
    }

    return reach >= len - 1;
}
```

# Jump Game II

> 同样是给一个数组，从下标0开始，每个数字表示你能跳跃的最大距离，区别是，在保证总能到达终点的情况下，返回耗费最少的跳跃次数。

既然题目都保证了是终点可达的，那么是不是可以每次都选择跳的最远的那个？具体怎么选？其实不然，题目要求返回最少的次数，没有让详细返回跳的方案，所以，在一个能跳跃的区间内，总有一个符合条件的点，循环往复总会到达终点，我们只需要记录“循环”多少次不就行了。有三个变量：jump、curEnd、curFarthest，对于每一步都有一个区间范围，范围的末端就是curEnd，每个范围都会产生一个能到达的最远距离，我们以curEnd和curFarthest的最大值作为末尾标志，一旦区间跑完，就加一次jump，这样就做到了不关心具体在哪个点jump，而只关心次数了。

```java
public boolean minJumpTimes(int[] nums){
    int jumps = 0, curEnd = 0, curFarthest = 0;
    for(int i=0; i<nums.length-1; i++){
        curFarthest = Math.max(curFarthest, i + nums[i]);
        if(i == curEnd){
            jumps++;
            curEnd = curFarthest;
        }
    }

    return jumps;
}
```

# Jump Game III

> 给定一个数组和一个起始位置start，对于每个点，只能走i-start或i+start两个位置，问能否访问到数组中任意0的位置。

这种题实际上也是属于模拟，根据题目中的要求来做就好了，目前至少有两种方式，一种是递归地遍历（或者说深度优先），同时带上备忘录来标记访问过的点，另一种是广度优先，因为一个点可以带出来两个访问的方向，而且是顺序进行的。

### dfs

回溯，总是可以穷举出来的，每个点上都有两种方式可选，同一个点可能会被访问多次，我们也需要做一个标记来表示他被访问过，不能到达的话不必重复访问。

```java
public boolean canReach(int][] nums, int start){
    if(start >= 0 && start < nums.length && nums[start] < nums.length){
        int jump = nums[start];
        nums[start] += nums.length; // 做标记，这样nums[start]总是不合法的，不会再访问了
        return jump == 0 || canReach(nums, start + jump) || canReach(nums, start - jump);
    }

    return false;
}
```

### bfs

……

# JumpGame VII

> 给一个数组和一个minJump以及一个maxJump，其中只包含0或1，下标0处为0，从下标0处出发，每次跳跃的范围是(i+minJump, i+maxJump)且只能跳落到其中的0处，问能否跳跃到终点。

可以怎么做？如果按照题目中的要求，在一个范围内找寻0来作为下一个起跳点，那么对于长度为n的数组，即便是使用dp来保存状态，时间复杂度也将会是O(n^2)。参考上面类似的思想， 他只询问能到到达终点，并不关心具体的路径，所以可以在范围的地方着手优化。