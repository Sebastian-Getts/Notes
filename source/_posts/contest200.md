---
title: contest200
date: 2020-08-02 12:56:29
categories: Leetcode
tags: algorithm
---

Record Leetcode contest 200.

<!--more-->

# Q1

passed.

# Q2

Find the winner of an Array Game.

Given an integer array `arr` of **distinct** integers and an integer `k`.

A game will be played between the first two elements of the array (i.e. `arr[0]` and `arr[1]`). In each round of the game, we compare `arr[0]` with `arr[1]`, the larger integer wins and remains at position `0` and the smaller integer moves to the end of the array. The game ends when an integer wins `k` consecutive rounds.

Return *the integer which will win the game*.

It is **guaranteed** that there will be a winner of the game.

**Example 1:**

```markdown
Input: arr = [2,1,3,5,4,6,7], k = 2
Output: 5
Explanation: Let's see the rounds of the game:
Round |       arr       | winner | win_count
  1   | [2,1,3,5,4,6,7] | 2      | 1
  2   | [2,3,5,4,6,7,1] | 3      | 1
  3   | [3,5,4,6,7,1,2] | 5      | 1
  4   | [5,4,6,7,1,2,3] | 5      | 2
So we can see that 4 rounds will be played and 5 is the winner because it wins 2 consecutive games.
```

**Example 2:**

```markdown
Input: arr = [3,2,1], k = 10
Output: 3
Explanation: 3 will win the first 10 rounds consecutively.
```

**Example 3:**

```markdown
Input: arr = [1,9,8,2,3,7,6,4,5], k = 7
Output: 9
```

**Example 4:**

```markdown
Input: arr = [1,11,22,33,44,55,66,77,88,99], k = 1000000000
Output: 99
```

## My Solution

看到这题，首先我认为这题清晰明了，用__迭代__去完成全部流程，用**k**去做结束的标志，是一道从头到尾很明确的题。但是:joy:

贴上我稚嫩的代码：

```java
public int getWinner(int[] arr, int k) {
    int res = -1;
    int zero = k-1;
    int solution = 0;
    while(k>0){
        int currMax = Math.max(arr[0],arr[1]);
        int currMin = Math.min(arr[0], arr[1]);
        helper(currMax, currMin, arr);
        if(res == -1){
            // initial, no compare
            res = currMax;
        }else{
            if(currMax == res){
                k--;
                solution = currMax;
            }else{
                k = zero;
                res = currMax;
            }
        }
    }
    return solution;
}

private void helper(int max, int min, int[] arr){
    arr[0] = max;
    for (int i = 1; i < arr.length - 1; i++) {
        arr[i] = arr[i + 1];
    }
    arr[arr.length-1] = min;
}
```

没通过，因为`Time Limited`，跑得太慢了！

## Niubility Solution

```java
public int getWinner(int[] arr, int k) {
    // 数组长度
    int n = arr.length;
    // 数组长度与k之间取最小的。
    k = Math.min(k, n);
    int A = arr[0];
    // 标志位，记录相同次数
    int rep = 0;
    // 从第二个开始iterate，无终结条件
    for(int i = 1;;i++){
        // “i%n“ 取余数，逻辑变换数组。由于for循环无终结条件，所以i会无限增加超过n。
        int B = arr[i%n];
        if(A >= B){
            rep++;
        }else{
            A = B;
            rep = 1;
        }
        // 终结条件在这里，rep等于k时结束。
        if(rep == k){
            return A;
        }
    }
}
```

**通过对比可以发现，我耗时的原因在于：** 

1. 我是真的挪了数组！物理上的挪动，实际上，逻辑移动数组即可！我的程序算例4要6秒，这个只需要0秒。
2. `Math.min(k, n)`，如果题目给的k为`10000000`,数组长度为`8`,那么最后也是按`8` 来算，那么多循环无意义，一遍遍历即可获取最大（这样也行？）

况且，逻辑i上也没有去变换位置，题目的本质还是挨个遍历！

i.e. arr = [2,1,3,5,4,6,7], k = 2