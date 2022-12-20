---
title: primeNumber
date: 2022-12-18 17:07:24
categories: leetcode
tags: prime
---

这篇归纳**质数**和**质因数**的算法和实现。今天周赛遇到了关于质因数的题。

<!-- more -->

## 质数
2、3、5、7、9、11……，想通过程序设计来求解质数，看到有个算法非常巧妙，做法是使用一个临时表记下那些不是质数的，最后那些未被做标记的就是质数了。如何判断数字是否非质数呢？在一定范围内，如果他有其他的因数则是非质数。如下，求n以内的所有质数：
```java
private List<Integer> helper(int n) {
	List<Integer> list = new ArrayList<>();
	boolean[] primeRec = new boolean[n+1];
	for(int i=2; i<=n; i++) {
		for(int j=2; i*j<=n; j++) {
			primeRec[i*j] = true;
		}
	}
	for(int i=2; i<primeRec.length; i++) {
		if(!primeRec[i]) list.add(i);
	}

	return list;
}
```
就这样，通过遍历给定范围内的数字就能将他们标记完，最后就能得到质数了。

## 质因数
了解了质数后，如何得到一个数字的质因数？比如：90的质因数为`2, 3, 3, 5`。除了短除法之外，援引网上的资料，*Pollard Rho*在几十年前提出了因数分解的方法：
1. 目标数字为n，先找一个最小质数k
2. 如果k恰好等于n，k即为所求，过程结束
3. n能整除k，k为所求，并用n整除k后的商作为新的n，重复2
4. 如果n不能整除k，则用新的k值，重复2
```java
private List<Integer> helper(int n) {
	List<Integer> list = new ArrayList<>();
	List<Integer> primeList = getPrime(n);
	int i = 0;
	int k = primeList.get(i++);
	while(true) {
		if(k == n) {
			list.add(k);
			break;
		}
		if(n % k == 0) {
			list.add(k);
			n /= k;
		} else {
			k = primeList.get(i++);
		}
	}

	return list;
}
```