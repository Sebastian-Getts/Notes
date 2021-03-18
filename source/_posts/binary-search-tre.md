---
title: binary search tree
date: 2021-02-27 15:58:06
categories: Leetcode
tags: bst
---

这篇看看二分查找树，提到二分，有我们已知的二分搜索，它用在已排序的线性表，跟这个二分查找树又有什么关系呢？我想答案应该是方便维护。对于线性表，如果除了查询外还会往里面存入数据，那么我们需要频繁地去排序来让数组变得有序；对于树来讲，新增加节点，我们只需修改部分分支，且尽量让他保持平衡。

<!-- more -->

<!-- toc -->

# 遍历

二叉树有前中后序遍历，其中，中序遍历能使我们得到二叉树从小到大的节点值。如何能按照中序遍历二叉树呢？根据我们的习惯，从左侧最下方开始找，按照这个思路，必然是一个深度优先的算法，可以从递归和迭代两个思路入手。

```java
public List<Integer> getValuesFromBST(TreeNode root){
    TreeNode p = root;
    List<Integer> list = new ArrayList<>();
    Deque<TreeNode> deque = new ArrayDeque<>();
    whlie(p != null || deque.isEmpty()){
        while(p != null){
            deque.offerLast(p);
            p = p.left;
        }
        p = deque.pollLast();
        list.add(p.val); // u can do anything here
        p = p.right;
    }
    
    return list;
}
```

按照上面遍历的代码，其实我们还可以做更多的事情，毕竟都能便利出来了，其他的诸如取前N个数、验证BST是否合法等等其他的都可以参照这个来做。

# 有效

根据二叉树“左小右大”的特点，在进行中序遍历时就可以来验证他的有效性：

```java
public boolean isBSTValid(TreeNode root){
    TreeNode p = root;
    TreeNode pre = null; // 记录前一个节点
    Deque<TreeNode> deque = new ArrayDeque<>();
    whlie(p != null || deque.isEmpty()){
        while(p.left != null){
            deque.offerLast(p);
            p = p.left;
        }
        p = deque.pollLast();
        if(pre != null && p.val <= pre.val){ // 判断是否合法
            return false;
        }
        pre = p;
        p = p.right;
    }

    return true;
}
```



# 其他

其实BST的可玩性挺高的，想对于其他数据结构，BST是活灵活现地展示出来的，而且还有具有二分查找的效率、左小右大的规律，所以题目大多来源于他的展示，例如打印前序遍历、中序遍历、层序遍历等等。还有一种是比较隐晦的，例如这道题：*[Score of Parentheses](https://leetcode.com/problems/score-of-parentheses/)*。