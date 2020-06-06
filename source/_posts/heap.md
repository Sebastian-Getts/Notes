---
title: heap
date: 2020-06-06 22:54:27
categories: Java
tags: datastructure
---

这里的堆是数据结构中的堆，不是JVM中的堆。

关键词：堆，二叉树，优先级队列，排序，topN

<!-- more -->

# 结构

堆的结构是完全二叉树，而且是有序的，分大顶堆和小顶堆。	

## 完全二叉树

- 路径长度是指路径上的边数
- 结点深度是指从根结点到该结点的路径的长度
- 每一层都是满的或者最后一层不满但最后一层的叶子都是靠左放置

## 二叉堆

- 完全二叉树
- 每个结点大于或等于它的任意一个孩子

# 存储

可以将二叉堆用数组来存储。

例如如下一个二叉堆：

![Screenshot from 2020-06-06 15-24-34.png](https://i.loli.net/2020/06/06/JbDlczXVh35sEF1.png)

在数组中保存：{62,42,59,32,39,44,13,22,29,14,33,30,17,9}

可以看到相当是以广度优先遍历了这个二叉树，并将遍历的结点按顺序存入数组。可以从中发现一些存储的规律，对于任意一个位置_i_，他的左子结点在_2i+1_处，右子结点在_2i+2_处，父结点在_(i-1)/2_处。例如：39在数组中的下标是4，那么他的左子结点就在（2×4+1）=9处。

# 应用

## 优先级队列

优先级队列的底层就是用堆来实现的。同时一道比较经典的算法题用优先级队列可以轻松实现：top n 问题

## TOP N

给一组数据，求其中最大/小的几个数。

```java
// 求最小的n个数
public static int[] topN(int[] array, int n) {
    if (n == 0) {
        return new int[0];
    }
    // default big heap, lambda make it small heap
    Queue<Integer> heap = new PriorityQueue<>(n, ((o1, o2) -> Integer.compare(o2, o1)));

    for (int e : array) {
        // put the integer in when it smaller than the top of integer
        if (heap.isEmpty() || heap.size() < n || e < heap.peek()) {
            heap.offer(e);
        }
        if (heap.size() > n) {
            // delete the top of heap integer
            heap.poll();
        }
    }

    int[] res = new int[heap.size()];
    int j = 0;
    for (int e : heap) {
        res[j++] = e;
    }
    return res;
}
```

上面用到了小顶堆，for循环中的两个判断，符合条件的放进堆中，第二个判断中，当堆中的元素个数大于要求的个数时，删除堆中的顶部元素（优先级队列的本质还是队列，进出满读FIFO）。

稍作修改，可以让上面的代码输出最大的n个数，显而易见的是，我们只需修改入队列的条件以及优先级队列的堆排序方式：

```java
// 默认大顶堆
Queue<Integer> heap = new PriorityQueue<>(n);
for(int e: array){
    // 大于堆顶的放入优先级队列
    if(heap.isEmpty() || heap.size() < n || e > heap.peak()){
        heap.offer(e);
    }
    // 超过要求的个数，清除堆顶元素
    if(heap.size() > n){
        heap.pool();
    }
}
```





