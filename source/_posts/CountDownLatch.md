---
title: CountDownLatch
date: 2022-12-15 13:59:31
categories: java
tags: lock
---
除了synchronized之外，并发包下还有其他很多锁工具来帮助我们完成理想的业务程序，CountDownLatch就是其中一个，这篇文章通过源码来记录它的原理。

<!-- more -->

## Demo
先来看一段使用CountDownLatch的实际应用：
```java
public static void main(String[] args) throws InterruptedException {
    CountDownLatch countDownLatch = new CountDownLatch(10);
    for (int i = 0; i < 10; i++) {
        new Thread(() -> {
            System.out.println(Thread.currentThread().getName() + "\tleave the room ....");
            countDownLatch.countDown();
        }, String.valueOf(i)).start();

    }
    countDownLatch.await();
    System.out.println("Ok, lock the door ...");
```
代码中通过`await()`方法来阻止程序运行，直到`countDown()`了全部线程。

## 内部类Sync
CountDownLatch内部的源码并不多，我们先看他的内部类`Sync`。
代码中发现这个内部类继承了**AQS**，可以理解为通过**AQS**自己实现了一把锁，内部类中加上有参构造一共有四个方法：

### 有参构造
```java
Sync(int count) {
    setState(count);
}
```
这里的`count`就是上面demo中创建对象时传入的数字。进一步地，通过调用**AQS**中`setState`方法来为state变量赋值，这个state变量是被声明为**volatile**的。

### getCount()
```java
int getCount() {
    return getState();
}
```
返回计数，在**AQS**也是直接返回了state变量。

### tryAcquiredShared()
```java
protected int tryAcquireShared(int acquires) {
    return (getState() == 0) ? 1 : -1;
}
```
这个方法返回获取的计数，并进行判断。

### tryReleaseShared()
```java
protected boolean tryReleaseShared(int releases) {
    // Decrement count; signal when transition to zero
    for (;;) {
        int c = getState();
        if (c == 0)
            return false;
        int nextc = c-1;
        if (compareAndSetState(c, nextc))
            return nextc == 0;
    }
}
```
这里是个无限循环，如果当前计数为0，返回false，否则计数减一，并尝试将减去后的值赋值到计数，成功后再判断是否为0。对整个方法做概述就是：判断当前计数是否为0，不为0就减一。
> 值得一提的是，这里尝试释放或获取锁的方法并不会在CountDownLatch中直接使用，而是对AQS内部方法的重写，使用了模版方法的设计模式。

## countDown()
这个方法最为直观，在demo中会直接使用。
```java
public void countDown() {
    sync.releaseShared(1);
}
```
我们看到他使用了内部类sync去调用了`releaseShared()`方法，传递了参数**1**，表示减一，显然内部类去调用了**AQS**中的方法。根据我们在上面的分析，这个方法会调用到我们重写的`tryReleaseShared`：
```java
public final boolean releaseShared(int arg) {
    if (tryReleaseShared(arg)) {
        doReleaseShared();
        return true;
    }
    return false;
}
```
如果`tryReleaseShared`返回为false（计数为0），就不进行释放了，返回false，否则会执行释放操作并返回true。

## await()
在demo中这个方法似乎可以阻挡线程继续前进，我们看看他是如何做到的。
```java
public void await() throws InterruptedException {
    sync.acquireSharedInterruptibly(1);
}
```
这里同样将参数**1**放入并调用到**AQS**中的方法：
```java
public final void acquireSharedInterruptibly(int arg)
        throws InterruptedException {
    if (Thread.interrupted())
        throw new InterruptedException();
    if (tryAcquireShared(arg) < 0)
        doAcquireSharedInterruptibly(arg);
}
```
如果线程被中断就抛出异常，否则尝试获取到计数，并判断是否小于0。里面尝试获取到方法就在内部类中被重写：`(getState() == 0) ? 1 : -1`，为0就返回1，概括下就是判断当前的计数是否为0，如果不为0就将线程置于“等待模式”。这里可以提前猜测下面的`doAcquireSharedInterruptibly()`方法会是一个无限循环，监听被赋予volatile的计数变量state，当他为0时就释放，否则一直循环，形成挂起等待的状态。

## 小结
通过对源码简单追溯我们可以大致了解到他的原理，自定义内部类作为锁，依赖**AQS**中的方法来完成加锁和解锁。我们会在其他篇章完成对**AQS**的分析。