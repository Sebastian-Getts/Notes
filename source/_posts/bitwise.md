---
title: bitwise
date: 2020-06-01 21:11:25
categories: Java
tags: bitwise
---

Introduction of Java bitwise and operation.

<!-- more -->

# 简介

| 操作符 | 名称         | 描述              |
| ------ | ------------ | ----------------- |
| &      | 与           | 1 & 1 = 1 (only)  |
| \|     | 或           | 0 \| 0 = 0 (only) |
| ^      | 异或         | 1 ^ 0 = 1         |
| ~      | 非           | ~ 1 = 0           |
| <<     | 左移         | 右边空出来的补0   |
| >>     | 带符号位右移 | 最高位补符号位    |
| >>>    | 无符号位右移 | 左边空出来的补0   |

位操作符仅适用于整数类型（byte, short, int, long）。位操作涉及的字符将转换为整数。所有的位操作符可以构成位赋值操作符，例如=，|=，<<=以及>>>=。

位运算都是补码运算的，其中，负数做补码时，符号位不变，其余取反后加一；运算完成后，再做一遍之前的操作，得到源码。

## 举例

```java
int a = -1;
// 11111111111111111111111111111111111(32个1)
System.out.println(Integer.toBinaryString(a));
// -1
System.out.printlnl(a>>1);
// 1111111111111111111111111111111111(32个1)
System.out.println(Integer.toBinaryString(a>>1));
// 2147483647
System.out.println(a>>>1);
// 0111111111111111111111111111111111(31个1)
System.out.prinlnt(Integer.toBinaryString(a>>>1));
```

### 分析：

#### a>>1

原码：10000000000000000000000000000001

反码：1111111111111111111111111111111111110

补码：1111111111111111111111111111111111111

补码做运算：11111111111111111111111111111111111111（右移一位，左侧空位用符号位（1）来补）

取反：10000000000000000000000000000000

原码：10000000000000000000000000000001 即 -1.

#### a>>>1

同样是补码运算，只是在后续操作中，将符号位看作是数字，那么该补码就如同正数补码一样。

补码做运算：011111111111111111111111111111111111（右移一位，左侧空位用（0）来补）

正数原码即补码。

# 应用

## HashMap

```java
static final int hash(Object key) {
        int h;
        return (key == null) ? 0 : (h = key.hashCode()) ^ (h >>> 16);
    }
```

上例代码基于jdk1.8，hashmap获取hash值的示例代码。在该类中使用了大量的`^`, `|`, `<<`, `<<<`等位运算符。

## 奇偶性

```java
2 & 1; // 0
8 & 1; // 0
7 & 1; // 1
```

1的原码：0001

8的原码：1000

7的原码：0111

奇数的最低位永远是1,偶数的为0.

## etc

……
