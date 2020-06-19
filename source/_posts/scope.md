---
title: scope
date: 2020-06-18 22:42:58
categories: Java
tags: scope
---

Java的作用域，关于变量的作用范围、内部类等的防混淆。

<!--more-->

# 内部类

为什么会有内部类？静态内部类又是什么？他们可以用到什么范围的变量？

当一个类中，普通的变量无法满足需求，单独在外面放一个类又不合适，就可以把它设置为内部类。

```java
public class Person{
    int eyes;
    int ears;
    class brain{
        ...
    }
}
```

所以，适用实例变量的（诸如静态）都应该适用于内部类，内部类是一个“长长的”变量声明。



