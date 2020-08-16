---
title: contest201
date: 2020-08-09 12:22:53
categories: Leetcode
tags: algorithm
---

Leetcode周赛201.

<!--more-->

# 1544 Make The String Great

Given a string `s` of lower and upper case English letters.

A good string is a string which doesn't have **two adjacent characters** `s[i]` and `s[i + 1]` where:

- `0 <= i <= s.length - 2`
- `s[i]` is a lower-case letter and `s[i + 1]` is the same letter but in upper-case or **vice-versa**.

To make the string good, you can choose **two adjacent** characters that make the string bad and remove them. You can keep doing this until the string becomes good.

Return *the string* after making it good. The answer is guaranteed to be unique under the given constraints.

**Notice** that an empty string is also good.

**Example 1:**

```
Input: s = "leEeetcode"
Output: "leetcode"
Explanation: In the first step, either you choose i = 1 or i = 2, both will result "leEeetcode" to be reduced to "leetcode".
```

**Example 2:**

```
Input: s = "abBAcC"
Output: ""
Explanation: We have many possible scenarios, and all lead to the same answer. For example:
"abBAcC" --> "aAcC" --> "cC" --> ""
"abBAcC" --> "abBA" --> "aA" --> ""
```

**Example 3:**

```
Input: s = "s"
Output: "s"
```

## Solution

- 首先要注意审题，明确界限的判断。尤其是`vice-versa`，反之亦然的意思，就是**相邻两个字母忽略大小写时相同，且一个大写一个小写**，需要将这两个字母剔除。
- 通过`example 2`可以看出算法应有*循环*的动作，剔除后还应该重新审视。

### mine

```java
public String makeGood(String s) {
    Stack<Character> stack = new Stack<>();
    for (int i = 0; i < s.length(); i++) {
        char c = s.charAt(i);
        if (!stack.empty() && (
                (Character.isUpperCase(c) && Character.isLowerCase(stack.peek()) && ((stack.peek() - 'a') == (c - 'A')))
                        ||
                        (Character.isLowerCase(c) && Character.isUpperCase(stack.peek()) && ((stack.peek() - 'A') == (c - 'a')))
        )) {
            stack.pop();
        } else {
            stack.push(c);
        }
    }
    Iterator<Character> iterator = stack.iterator();
    StringBuilder sb = new StringBuilder();
    while (iterator.hasNext()) {
        sb.append(iterator.next());
    }
	// 因为是iterator，不用reverse()
    return sb.toString();
}
```
### better

```java
boolean ch = true;
while (ch) {
    ch = false;
    String t = s;
    for (int i = 0; i < s.length() - 1; ++i) {
        if (s.charAt(i) + 32 == s.charAt(i + 1) || s.charAt(i + 1) + 32 == s.charAt(i)) {
            t = s.substring(0, i) + s.substring(i + 2);
            ch = true;
            break;
        }
    }
    s = t;
}
return s;
```

# 1545 Find Kth Bit in Nth Binary String

Given two positive integers `n` and `k`, the binary string `Sn` is formed as follows:

- `S1 = "0"`
- `Si = Si-1 + "1" + reverse(invert(Si-1))` for `i > 1`

Where `+` denotes the concatenation operation, `reverse(x)` returns the reversed string x, and `invert(x)` inverts all the bits in x (0 changes to 1 and 1 changes to 0).

For example, the first 4 strings in the above sequence are:

- S1 = "0"
- S2 = "0**1**1"
- S3 = "011**1**001"
- S4 = "0111001**1**0110001"

Return *the* `kth` *bit* *in* `Sn`. It is guaranteed that `k` is valid for the given `n`.

 

**Example 1:**

```
Input: n = 3, k = 1
Output: "0"
Explanation: S3 is "0111001". The first bit is "0".
```

**Example 2:**

```
Input: n = 4, k = 11
Output: "1"
Explanation: S4 is "011100110110001". The 11th bit is "1".
```

**Example 3:**

```
Input: n = 1, k = 1
Output: "0"
```

**Example 4:**

```
Input: n = 2, k = 3
Output: "1"
```

## Solution

题目中已经给了计算式，根据式子来计算结果。

```java
public char findKthBit(int n, int k) {
    StringBuilder sb = new StringBuilder("0");
    while (n > 1) {
        int integer = Integer.parseInt(sb.toString());
        StringBuilder stringBuilder = new StringBuilder(Integer.toBinaryString(integer));
        // 0-1 inverse
        for (int i = 0; i < stringBuilder.length(); i++) {
            if (stringBuilder.charAt(i) == '0') {
                stringBuilder.replace(i, i + 1, "1");
            } else {
                stringBuilder.replace(i, i + 1, "0");
            }
        }
        stringBuilder.reverse();
        sb.append("1").append(stringBuilder);
        n--;
        System.out.println(sb.toString());
    }

    char[] chars = sb.toString().toCharArray();
    return chars[k - 1];
}
```

上面的解题过程是错的，我觉得最好的方式应该是用递归，但是不太会，用来迭代，在n=4时的结果就错了。

### better

做`0-1`转换时，当时想用位运算，怎奈不熟练、没想起来`异或`。

- 异或 ^ ：相同为0，0异或任何数为任何数。在二进制的情况下，与`1`异或等同于`0-1`翻转。

#### method 1

一目了然，迭代

```java
public char findKthBit(int n, int k) {
    String s = "0";
    while (n>1) {
        --n;
        s = s+"1"+sinv(s);
    }
    // 从0开始，k-1
    return s.charAt(k-1);
}

public String sinv(String s) {
    StringBuilder a = new StringBuilder();
    // 从后遍历，reverse()
    for (int i = s.length()-1; i>=0; --i) {
        char c = s.charAt(i);
        // 0-1翻转
        c^=1;
        a.append(c);
    }
    return a.toString();
}
```

#### method 2

别具一格

```java
public char findKthBit(int n, int k){
    char findKthBit(int n, int k) 
    s[1]="0";
    t[1]="1";
    for(int i=2;i<=n;i++){
        s[i]=s[i-1];
        s[i]+='1';
        s[i]+=t[i-1];
        t[i]=s[i-1];
        t[i]+='0';
        t[i]+=t[i-1];
    }
    return s[n][k-1];
}
```

#### method 3

清清楚楚，深度优先

```java
char dfs(int n, int k) {
    if (n == 1) {
        return '0';
    } else {
        int len = (1 << n) - 1;
        int base = (1 << (n - 1)) - 1;
        if (k == base + 1) {
            return '1';
        } else if (k <= base) {
            return dfs(n - 1, k);
        } else {
            return dfs(n - 1, len - k + 1) ^ 1;
        }
    }
}

char findKthBit(int n, int k) {
    return dfs(n, k);
}
```

