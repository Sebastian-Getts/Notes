---
title: Pascal's Triangle
date: 2019-11-04 13:02:35
categories: Math
tags: PermutationAndCombination
mathjax: true
---

读了华罗庚的著作《杨辉三角》有感：杨辉三角引申出的杨辉恒等式，利用了排列组合的原理，可以作用在二项式、开方等等的方面，简直amazing。。。。。。。。Btw，练习了Latex语法。

<!--more-->

类似下方的三角形，被称为杨辉三角，外国称其为帕斯卡三角。

```markdown
   1
  1 1
 1 2 1
1 3 3 1
.....
```



可以推出一般规律：

第n+1行：
$$
1, C_n^1, Cn^2, ..., 1
$$


其中，用到了熟悉的组合：
$$
C_n^r=\frac{n(n-1)...(n-r+1)}{r!}=\frac{n!}{r!(n-r)!}
$$
他表示**从n件东西中取出r件东西的组合数**。

从杨辉三角中可以看出：两条斜边都是1，而其余的数都是由其肩上的两个数之和。

于是有了**杨辉恒等式**：
$$
C_{n-1}^{r}+C_{n-1}^{r-1}=C_{n}^{r}(r=1,2,3...n)
$$
这里是将本没有意义的记号赋予了值：
$$
C_{n}^{0}=1, C_{n-1}{n}=0
$$
杨辉恒等式的具体证明结果如下：
$$
C_{n-1}^{r}+C_{n-1}^{r-1}=\frac{(n-1)!}{r!(n-1-r)!}+\frac{(n-1)!}{(r-1)!(n-r)!}
=\frac{(n-1)!}{r!(n-r)!}(n-r)+\frac{(n-1)!}{r!(n-r)!}r=\frac{n!}{r!(n-r)!}
=C_{n}^{r}
$$

### 应用

- 二项式定理
- 开方
- 高阶等差级数
- ……

### Latex

组合：

```latex
C_{n-1}^{r}, \tbinom{n}{m}
```

$$
C_{n-1}^{r},\tbinom{n}{m}
$$

分数：

```latex
\frac{(n-1)!}{r!(n-1-r)!}
```

$$
\frac{(n-1)!}{r!(n-1-r)!}
$$

- note: 如果想使用mathjax，开启latex，需要在头部添加：

  ```properties
  mathjax: true
  ```

  



