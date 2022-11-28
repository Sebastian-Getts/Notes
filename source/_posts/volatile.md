---
title: volatile
date: 2020-07-20 21:23:51
categories: JVM
tags: lock
---

这个关键字用于将Java变量标记为`being stored in main memory`，意味着每次对volatile变量的读取都将从计算机内存中读取，而不是从CPU缓存中读取，并且对volatile变量的写入都将被写入主存而不是CPU缓存。

<!--more-->

# Visibility problems

主要是多线程中的问题。线程在操作`非volatile`的变量时，出于性能原因，都会将变量从主存复制到CPU缓存中，如果计算机上有多个CPU，那么每个线程可能在不同的CPU上运行，每个线程可以将变量复制到不同的CPU缓存中。

那么问题来了，对于`非volatile`的变量，无法保证Java虚拟机何时将数据从主存储器读取到CPU缓存中，或者何时将数据从CPU缓存写入到主存储器中，设想一种情况：多个线程访问一个共享对象，该对象包含一个计数器

```java
public class ShareObject{
    public int counter = 0;
}
```

假设只有线程1会将计数器递增，同时线程1和线程2都会不时地访问它。

如果counter不声明为`volatile`，就无法保证计数器的值从CPU缓存重写回主存，这就意味着主存的counter与CPU缓存的值可能不同！（JVM内存模型有没有）。这种因为没有被另一个线程回写到主存导致无法同步值的问题就叫做“Visibility problem”，**一个线程的更新对其他线程是不可见的**。

# Visibility Guarantee

关键字`volatile`的设定就是解决上面提到的可见性问题。通过声明counter变量为`volatile`的，所有对该变量更改都将立即回写到主存，同时所有对该变量的读操作也都会从主存中读取。下面是加了关键字`volatile`的例子：

```java
public class ShareObject{
    // 由于声明为volatile，因此更改变量对于其他线程的是可见的
    public volatile int counter = 0 ;
}
```

但是，目前仅是线程1更改，对线程2可见，要想线程1、2都更改，那么仅仅声明为`volatile`是不够的。

## Full Visibility Guarantee

实际上，关键字`volatile`的可见保证性超越了`volatile`变量本身。有点绕吧，可见保证性如下：

- 如果线程A更改了`volatile`变量，并且线程B随后读取了它，则在写入`volatile`变量之前线程A可见的所有变量在线程B读取`volatile`变量后也将可见。

- 如果线程A读取了一个`volatile`变量，则在读取那个变量时线程A可见的所有变量也将从主存中重新读取。

看个代码例子：

```java
public class MyClass{
    private int years;
    private int months;
    private volatile int days;

    // 更改了三个变量，只有days是volatile的
    public void update(int years, int months, int days){
        this.years = year;
        this.months = months;
        this.days = days;    
    }
}
```

”Full Visibility Guarantee“意味着，当一个值被写入days，那么线程所有的可见的变量都会被写入主存，对于上面的例子来说，months和years也会被写入主存。读取他们的值时，可以这样：

```java
public class MyClass{
    private int years;
    private int months;
    private volatile int days;

    public int totalDays(){
        int total = this.days;
        total += months * 30;
        total += years * 365;
        return total;   
    }

    public void update(int years, int months, int days){
        this.years = years;
        this.months = months;
        this.days = days;
    }
}
```

着重观察*totalDays()*，他一开始会将`days`的值赋给变量`total` ,由于`days`的类型是`volatile`，所以，读取`days`的同时，其他变量（months、years）也都会从主存中读取，因此，这就是为什么可见保证性超过了`volatile`他本身，所以，对于本例甚至其他用到这个关键字的，都可以按照上面的顺序来保证读取到最新值（只给一个变量声明为`volatile`，读取时必须**最后**读取带有`volatile`属性的值）。

# Instruction Reordering

指令重排！！！出于性能原因，JVM和CPU是允许对程序中的指令进行重新排序，只要指令的语义含义保持不变即可。例如：

```java
int a = 1;
int b = 2;
a++;
b++;
```

这些指令可以重新排序为下列的顺序，且不会丢失原有程序的语义：

```java
int a  = 1;
a++;
int b = 2;
b++
```

然而，当变量属于`volatile`时，指令排序就需要小心了，看看下面的例子：

```java
public class MyClass{
    private int years;
    private int months;
    private volatile int days;

    public void update(int years, int months, int days){
        this.years = years;
        this.months = months;
        this.days = days;
    }
}
```

如果JVM重排指令，像下面这样：

```java
    public void update(int years, int months, int days){
        // 这里将days赋值动作放到了第一位
        this.days = days;
        this.years = years;
        this.months = months;
    }
```

当days的顺序变了，months和years的值就无法正确地展现给其他线程。接下来是如何解决这个问题。

## Volatile Happens-Before Guarantee

`volatile`关键字提供了一些“保证”，即不会去做的一些操作，以免出现意外。

- 如果读/写其他变量出现在写`volatile变量`之前，那么就不能重排为出现在它之后。当然返回过是允许的。
- 如果读/写其他变量出现在读`volatile变量`之后，那么就不能重排为出现在它之前。

# Volatile is Not Always Enough

很明显，在一开始counter的例子中存在这种情况，读取counter并赋值期间，存在多个线程的竞争状态，都赋值的话会覆盖彼此（往主存中），这时就得采用能保证`原子性`的操作了，如**syncronized**或者比并发包下的`lock`了。
