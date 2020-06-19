---
title: string
date: 2020-06-18 22:46:12
categories: Java
tags: String
---

老生常谈，三兄弟：String, StringBuffer, StringBuilder.众所周知，字符串底层是用char数组来实现的，为什么String的是final，另外两个不是呢？首先从他们的诞生日期上就可以看出来一些端倪：String、StringBuffer出生于Java1.0, StringBuilder在Java1.5才出来……

<!--more-->

# 序

先看看String，平时用的最多的。它是不可变的字符序列，附上String的Java doc：

`The String class represents character strings. All string literals in Java programs, such as "abc", are implemented as instances of this class. Strings are constant; their values cannot be changed after they are created. String buffers support mutable strings. Because String objects are immutable they can be shared.`

```java
String str = "abc";
```

```java
char data[] = {'a', 'b', 'c'};
String str = new String(data);
```

上面的两个是相同的（对于_equals()_来说），通过equals方法，我们可以看到，入参是一个对象，这也能理解idea工具在校验时提示我们“翻转equals”，规范方法的调用。它的内部实现，是判断对象是否属于String，如果是的话强转String，然后将之转为char数组，依次比较数组中的字符，每个都相同的话返回true。

以上，告诉我们，好好看Java doc多重要，里面也是干货满满。

对于StringBuffer和StringBuilder，前者线程安全，后者线程不安全。

# String

final的类，final的char数组。所以对已声明的字符串的任何更改都会重新创建一个新的String。

看看常用的方法，equals()：

```java
public boolean equals(Object anObject) {
    if (this == anObject) {
        return true;
    }
    if (anObject instanceof String) {
        String anotherString = (String)anObject;
        int n = value.length;
        if (n == anotherString.value.length) {
            char v1[] = value;
            char v2[] = anotherString.value;
            int i = 0;
            while (n-- != 0) {
                if (v1[i] != v2[i])
                    return false;
                i++;
            }
            return true;
        }
    }
    return false;
}
```



## 构造

无参构造时，默认初始化char数组为空串

```java
public String(String original) {
    this.value = original.value;
    this.hash = original.hash;
}
```

有参构造，常用的是将一个字符串作为构造的入参中

```java
public String(char value[]) {
    this.value = Arrays.copyOf(value, value.length);
}
```

# StringBuffer

```java
public StringBuffer() {
    super(16);
}
```

```java
public StringBuffer(int capacity) {
    super(capacity);
}
```

它的两个构造方法都是调用父类（AbstractStringBuilder）的，跟String不同的是对于数组先初始化它的容量，要注意的是，它的数组前没有`final`，验证了他的可变性。

粗略来说，去掉StringBuffer中的`syncronizrd`就是StringBuilder。

# trap

```java
public static void main(String[] args) {
    String a = "456";
    String b = "789";
    String c = "456789";
    String d = new String("456789");
    System.out.println(c == (a + b));  // false
    System.out.println(c.equals(a + b));  // true
    System.out.println(c == d);   // false
    System.out.println(c.equals(d));   // true
}
```

可以理解为String有一个常量池，每次String出来一个字符串，放进去；如果有重复的String字符串，但是变量名不同，那么他们的值是相同的（用`==`可以判断为true）。对于字符串相加，可以理解为以一个有参构造的方式创建了一个新的字符串，即`a+b`如同上面的`d`。所以对于new出来的对象，当然是不等于值为字符串的`c`了；为什么equals相同，可以参看equals的方法内部实现。

如果要问StringBuilder有没有类似的对比，答案是没有。为什么？因为他没有重写equals方法，对比的话，除非是同一个对象，都则都会返回`false`。

