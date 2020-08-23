---
title: lock
date: 2020-07-20 21:46:41
categories: Java
tags: lock
---

锁跟多线程紧密相关，有复杂与简单之分。

<!--more-->

# 分类

![image.png](https://i.loli.net/2020/07/20/AwVJYTyQqzUpEPl.png)

# 乐观锁|悲观锁

所谓乐观锁、悲观锁可以类比地看作**JVM里的方法区**，他们只是规范、概念，具体落地的话有不同的实现，所以不仅仅是java中，数据库中也有类似的概念。那么，什么是乐观锁、悲观锁呢？

- 悲观锁：对于同一个数据的并发操作，悲观锁认为自己在使用数据的时候一定有别的线程来修改，因此在获取数据的时候会先加锁，确保数据不会被别的线程修改。在Java中，`synchronized`关键字和`Lock的实现类`都是悲观锁。
- 乐观锁：认为自己在使用数据时不会有别的线程修改数据，所以不会加锁，只是在更新数据的时候去判断之前有没有别的线程更新了这个数据。如果这个数据没有被更新，当前线程将自己修改的数据写入；如果数据已经被其他线程更新，则做进一步的操作（报错、重试或其他等等）。在Java中，通过**无锁编程**实现的乐观锁，最常用的就是`CAS算法`，Java原子类中的递增操作就是通过**CAS自旋实现**的。

根据他们的概念，可以发现**悲观锁适合写操作多的场景**，**乐观锁适合读操作多的场景**，这样利于性能的优化提升。

```java
// synchronized
public synchronized void testMehthod(){
    // do something...
}

// ReentrantLock
private ReentrantLock lock = new ReentrantLock();
public void modifyPublicResources()){
    try{
        lock.lock();
        // do something...
    }finally{
        lock.unlock();
    }
}

// 乐观锁
private AtomicInteger ai = new AtomicInteger();
atomicInteger.incrementAndGet(); // 执行自增1
```



# Compare And Swap

CAS，比较与交换，是一种无锁算法，在不使用锁的情况下实现多线程之间的变量同步，java并发包中的**原子类**就是通过这种算法实现了乐观锁。算法涉及到三个操作数：

- 需要读写的内存值V （已存在的值）
- 进行比较的值A
- 要写入的新值B

当`V=A`时，CAS通过原子方式用新值B来更新V的值（其中“比较”与“更新”两个操作是一个原子），否则不执行任何操作。一般情况下，“更新”是一个不断重试的操作。

## AtomicInteger

```java
public class AtomicInteger extends Number implements java.io.Serializable {
    private static final long serialVersionUID = 6214790243416807050L;

    // setup to use Unsafe.compareAndSwapInt for updates
    // 获取并操作内存的数据
    private static final Unsafe unsafe = Unsafe.getUnsafe();
    // 存储value在AtomicInteger中的偏移量
    private static final long valueOffset;

    static {
        try {
            valueOffset = unsafe.objectFieldOffset
                (AtomicInteger.class.getDeclaredField("value"));
        } catch (Exception ex) { throw new Error(ex); }
    }
	// 存储AtomicInteger的int值
    private volatile int value;
```

```java
public final int getAndIncrement() {
    return unsafe.getAndAddInt(this, valueOffset, 1);
}
```

```java
public final int getAndAddInt(Object var1, long var2, int var4) {
    int var5;
    do {
        var5 = this.getIntVolatile(var1, var2);
    } while(!this.compareAndSwapInt(var1, var2, var5, var5 + var4));

    return var5;
}
```

```java
public final native boolean compareAndSwapInt(Object var1, long var2, int var4, int var5);
```

一目了然了吧，最终的`compareAndSwapInt`是`native`，所以整个”比较+更新“操作属于原子操作，在JDK通过CPU的cmpxchg指令去比较寄存器中的A和内存中的V。CAS虽然避开了锁，但是也有自身的瑕疵：

- 看到`do-while`了吧，循环时间长会造成较大的CPU开销。

**note:** ABA问题，即原本是A，后来改成了B，然后又改成了A，这时用CAS去比较的话结果是什么呢？当然是false啦，每次更新时会加上版本号做标记，类似”1A-2B-3A"

# 自旋锁|适应性自旋锁

涉及到线程的两个状态转换：阻塞、唤醒。这个操作需要操作系统来完成，且状态转换要耗费一定的处理器时间，如果同步代码块中的内容过于简单，状态转换消耗的时间有可能比用户代码执行的时间还要长。

在许多场景中，同步资源的锁定时间很短，为了这一小段时间去切换线程，线程挂起和恢复现场的花费可能会让系统得不偿失。如果物理机器有多个处理器，能够让两个或以上的线程同时并行执行，我们就可以让后面那个请求锁的线程不放弃CPU的执行时间，看看持有锁的线程是否很快就会释放锁。

而为了让当前线程“稍等一下”，我们需让当前线程进行自旋，如果在自旋完成后前面锁定同步资源的线程已经释放了锁，那么当前线程就可以不必阻塞而是直接获取同步资源，从而避免切换线程的开销。这就是自旋锁。reference [here](https://mp.weixin.qq.com/s?__biz=MjM5NjQ5MTI5OA==&mid=2651749434&idx=3&sn=5ffa63ad47fe166f2f1a9f604ed10091&chksm=bd12a5778a652c61509d9e718ab086ff27ad8768586ea9b38c3dcf9e017a8e49bcae3df9bcc8&scene=38#wechat_redirect)

# 公平锁|非公平锁

简而言之，公平锁是好好排队的，非公平锁是插队来的。

在类`ReentrantLock`中，有一个内部类`Sync`，他是继承`AbstractQueuedSnchronizer`的，对锁的添加、释放等操作大部分都是在`Sync`实现的，他又有`FairSync`和`NonfairSync`两个子类。`ReentrantLock`默认使用非公平锁。

# 独享锁|共享锁

别被名字搞晕了！独享=排他=互斥锁，同《操作系统》中的相关概念。如果数据身上有了一把排他锁，那么其他线程就不能再对他施加任何锁，例如JDK中的`synchronized`和并发包中的`Lock`。

共享锁是指数据身上有了共享锁，其他线程也可以在他身上加锁，只能加共享锁。获得共享锁的线程只能读数据，不能修改数据。

独享锁和共享锁也是通过AQS来实现的。具体参考类`ReentrantReadWriteLock`。类中有`ReadLock`和`WriteLock`两把锁，