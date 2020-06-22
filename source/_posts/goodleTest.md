---
title: goodleTest
date: 2020-06-22 14:38:50
categories: C++
tags: test
---

googletest，顾名思义，google公司研发的测试框架，适用于C++，协助完成包括单元测试在内的各种类型测试。

<!--more-->

谷歌测试团队的理念：

1. 测试应该是独立且可重复的。
2. 测试应该是被组织良好的，并且能反映出测试代码的架构。
3. 测试应该是可拔插、可重用的。
4. 当测试失败，应该有足够多的问题信息。
5. 测试框架应该帮助开发人员专注于测试内容，琐碎的事情由框架完成。
6. 测试的速度应该足够快。

googletest基于`xUnit架构`，用过JUnit或者PyUnit的再使用它应该不会陌生。

# 命名

注意区分Test, Test Case, Test Suite

| Meaning                    | googletest Term | ISTQB Term |
| -------------------------- | --------------- | ---------- |
| 涉及特定输入输出的测试代码 | TEST()          | Test Case  |

# 基本概念

- tests 使用**断言**来验证测试代码
- test suit 可以裂解为“测试套装”，包含一个或多个tests，多个tests来反映测试代码的结构，一个test suit中多个tests应该是有共享的对象。
- test program 包含多个“测试套装”。

# 断言

有`ASSERT_*`和`EXPECT_*`。前者会在遇到异常时抛弃当前的方法，后者在遇到非致命的故障时不会抛弃。通常，后者用的比较多，因为输出的异常信息会更多。

还可以自定义异常消息，使用**stream**特性，可以借助`<<`来实现，例如：

```c++
ASSERT_EQ(x.size(), y.size()) << "Vectors x and y are of unequal length";

for(int i=0; i<x.size(); ++i){
    EXPECT_EQ(x[i], y[i]) << "Vectors x and y differ at index " << i;
}
```

在断言后加上可能出现的异常，好比java中的`try-catch`块中，不打印异常信息而输出自定义的信息。

## true/false断言

| fatal assertion          | nonfatal assertion       | verifies           |
| ------------------------ | ------------------------ | ------------------ |
| ASSERT_TRUE(condition);  | EXPECT_TRUE(condition);  | condition is true  |
| ASSERT_FALSE(condition); | EXPECT_FALSE(condition); | condition is false |

出现异常时，`ASSERT_*`会在出现异常的部分返回，不继续进行（类比java中的throw，抛出异常），而`EXPECT_*`会继续执行后续的代码（类比java中的try-catch块捕捉异常）。但是无论哪种，断言失败都意味着测试失败。

## 数值比较

需要熟悉简写，如EQ、NE、LT……

| Fatal assertion        | Nonfatal assertion     | Verifies      |
| ---------------------- | ---------------------- | ------------- |
| ASSERT_EQ(val1, val2); | EXPECT_EQ(val1, val2); | val1 == val2  |
| ASSERT_NE(val1, val2); | EXPECT_EQ(val1, val2); | val1 !=  val2 |
| ASSERT_LT(val1, val2); | EXPECT_LT(val1, val2); | val1 < val2   |
| ASSERT_LE(val1, val2); | EXPECT_LE(val1, val2); | val1 <= val2  |
| ASSERT_GT(val1, val2); | EXPECT_GT(val1, val2); | val1 > val2   |
| ASSERT_GE(val1, val2); | EXPECT_GE(val1, val2); | val1 >= val2  |

## 字符串比较

注意区分C-strings和string对象的区别。比较两个string对象使用`EXPECT_EQ`，`EXPECT_NE`这些方式，参见上方。

| Fatal assertion               | Nonfatal assertion            | Verifies                                   |
| ----------------------------- | ----------------------------- | ------------------------------------------ |
| ASSERT_STREQ(str1, str2);     | EXPECT_STREQ(str1, str2);     | same content                               |
| ASSERT_STRNE(str1, str2);     | EXPECT_STRNE(str1, str2);     | different contents                         |
| ASSERT_STRCASEEQ(str1, str2); | EXPECT_STRCASEEQ(str1, str2); | same content, ignoring case(lower/capital) |
| ASSERT_STRCASENE(str1, str2); | EXPECT_STRCASENE(str1, str2); | different content, ignoring case           |

# 创建测试

```c++
TEST(TestSuiteName, TestName){
    ... test body ...
}
```

要注意两个入参都要满足c++的命名规范，且不能有下划线。

例如，有一个函数：

```c++
int Factorial(int n); // Return the factorial of n
```

那么它的测试函数可以这样写：

```c++
// Tests factorial of 0.
TEST(FactorialTest, HandlesZeroInput) {
  EXPECT_EQ(Factorial(0), 1);
}

// Tests factorial of positive numbers.
TEST(FactorialTest, HandlesPositiveInput) {
  EXPECT_EQ(Factorial(1), 1);
  EXPECT_EQ(Factorial(2), 2);
  EXPECT_EQ(Factorial(3), 6);
  EXPECT_EQ(Factorial(8), 40320);
}
```

googletest通过test suits把测试分组，上买能的函数中，虽然有两个（`HandlesZeroInput`, `handlesPositiveInput`），但是都属于`FacotrialTest`，跟Java的命名规范有区别。

