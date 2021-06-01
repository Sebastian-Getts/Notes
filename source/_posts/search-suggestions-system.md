---
title: search suggestions system
date: 2021-05-31 22:54:11
categories: LeetCode
tags: treeMap trie
---

来源于5月”每日一题“板块中最后一天的一道题，乍一看应该是用`Trie`，但是实现起来有些复杂，没有其他更好的思路，然后评论区一看，又被Lee神的代码震撼到了。

<!-- more -->

# TreeMap

Q: 根据输入的目标词，每输入一个字符，就从提供的词组中找出最符合规则的三个词（最多三个）。详情[戳这]([Explore - LeetCode](https://leetcode.com/explore/challenge/card/may-leetcoding-challenge-2021/602/week-5-may-29th-may-31st/3762/))。

A: 最大的功臣就是treemap了。首先来了解一下他的常用的、易混淆的API，如`higherKey`与`ceilingKey`的区别，前者是寻找大于当前key的key，后者是寻找大于等于当前key的key。`lowerKey`和`floorKey`同理。

```java
public List<List<String>> suggestedProducts(String[] products, String searchWord) {
    List<List<String>> res = new ArrayList<>();
    TreeMap<String, Integer> map = new TreeMap<>();
    Arrays.sort(products);
    List<String> productList = Arrays.asList(products);
    for(int i= 0; i<products.length; i++){
        map.put(products[i], i);
    }
    String key = "";
    for(char c : searchWord.toCharArray()){
        key += c;
        String ceiling = map.ceilingKey(key);
        // 只要大于'z'的任意字符都可以
        String floor = map.floorKey(key + "~");
        // 当前字符都匹配不到，后续更不可能了
        if(ceiling == null || floor == null) break;
        // Math防止越界，map.get(floor)+1就是囊括了最后一个元素的极限
        res.add(productList.subList(map.get(ceiling), Math.min(map.get(ceiling) + 3, map.get(floor) + 1)));
    }
    while(res.size() < searchWord.length()) res.add(new ArrayList<>());

    return res;
}
```

