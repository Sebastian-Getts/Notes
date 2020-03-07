---
title: leecode2
date: 2020-03-07 11:46:01
categories: Leecode
tags: ['lcs','recursion']
---

像那种结果要返回所有符合要求解的题十有八九都是要利用递归。根本思想是DFS，常用手段是递归。

<!-- more -->

#  LCS

先回顾下`最长公共子串`问题。连着两天做到了相关的算法题，换汤不换药的。

题目描述：

给定两个字符串，求两个字符串的最大公共子串，例如："abcd", "acefd"的最大公共子串是"acd"。

## 思路

要找到最大公子串，要直面的问题是对比，对比如果出现相同的字母该如何处理，不同的又要如何处理。

可以思考这样一个方案，逐个比较，如果发现了不同的字母，可以两个子串其中一个的不同字母去掉，在比较余下的谁的值更大，这里的值是最大子串的长度。如果相同，将相同的字母划去后加一，再比较划去后的子串，又回到一开始字母相同或不同的问题了。

```flowchart
st=>start: two strings
op=>operation: compare two strings
cond=>condition: if the letter equals
op1=>operation: 划去在比较的相同的字母，形成一组新的字符串，值加一
op2=>operation: 划去不同的字母，形成两组新的字符串,分别比较取最大
cond2=>condition: 是否有空串
end=>end: end
st->op->cond
cond(yes)->op1->cond2
cond(no)->op2->cond2
cond2(yes)->end
cond2(no)->op
```

如上图所示。如果用表格记录的话，在划去不同的字母后形成的两组子串中最大值以及划去相同字母后余下的字符串比较的值都是被保留在表格中的，于是整体算法思路就很清楚了。

|      | " "  |  a   |  b   |  c   |  e   |  f   |
| :--: | :--: | :--: | :--: | :--: | :--: | :--: |
| " "  |  0   |  0   |  0   |  0   |  0   |  0   |
|  a   |  0   |  1   |  1   |  1   |  1   |  1   |
|  c   |  0   |  1   |  1   |  2   |  2   |  2   |
|  e   |  0   |  1   |  1   |  2   |  3   |  3   |
|  f   |  0   |  1   |  1   |  2   |  3   |  4   |
|  d   |  0   |  1   |  1   |  1   |  3   |  4   |

我们可以用dp表示一个二维数组，相当于上图中的表格，做出新的流程图：

```flow
st=>start: two strings
end=>end: end
op=>operation: compare two strings
cond=>condition: if two string equal?
op2=>operation: 1+dp[i][j]
op3=>operation: Math.max(dp[i][j+1],dp[i+1][j])
st->op->cond
cond(yes)->op2->end
cond(no)->op3->end
```

# DFS

题目描述：给定一个数组和一个目标值，要求返回由数组中数字组合成目标值的所有组合。

例如：【2,3,6,7】目标值7. 返回【【2,2,3】【7】】

```java
public List<List<Integer>> combinationSum(int[] candidates, int target) {
    List<List<Integer>> result = new ArrayList<>();
    List<Integer> temp = new ArrayList<>();
    helper(candidates, 0, target, 0, temp, result);
    return result;
}
 
private void helper(int[] candidates, int start, int target, int sum,
                    List<Integer> list, List<List<Integer>> result){
    if(sum>target){
        return;
    }
 
    if(sum==target){
        result.add(new ArrayList<>(list));
        return;
    }
 
    for(int i=start; i<candidates.length; i++){
        list.add(candidates[i]);
        helper(candidates, i, target, sum+candidates[i], list, result);
        list.remove(list.size()-1);
    }
}
```

