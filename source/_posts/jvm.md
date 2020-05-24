---
title: jvm
date: 2020-05-24 17:39:25
categories: JVM
tags: jvm
---

associate with juc

<!--import-->

# 类加载器

经过javac编译后，形成的xxx.class文件存在电脑硬盘上，通过类加载器装进JVM并初始化为xxx.Class文件。

## 种类

## 双亲委派

## 沙箱安全机制

## Native

只是一个关键字。只有声明，没有实现，调用了底层C语言的实现。

# PC寄存器

记录了方法之间的调用和执行情况，类似排班值日表。用来存储指向下一条指令的地址，即将要执行的指令代码。

是当前线程所执行的字节码的行号指示器。

# 栈

- 不存在垃圾回收问题
- 线程私有

也叫栈内存，**主管Java程序的运行**，在线程创建时创建，线程结束时结束（释放栈内存）。基本类型的变量、对象的引用变量、实例方法都在栈空间中。

## 存储

在java中的方法装载在虚拟机的栈中叫栈帧。

Local Variables: 输入参数、输出参数以及方法内的变量

Operand Stack: 记录出栈、入栈的操作

Frame Data: 包括类文件、方法等等

## 运行

栈中的数据都是以栈帧（Stack Frame）的格式存在，栈帧是一个内存区块，是一个数据集，一个有关方法（Method）和运行期数据的数据集，当一个方法A被调用时就产生了一个栈帧，并被压入到栈中，执行完毕后弹出。

每个方法执行的同时都会创建一个栈帧，用于存储局部变量表、操作数栈、动态链接、方法出口等信息，每一个方法从调度直至执行完毕的过程，就对应着一个栈帧在虚拟机入栈到出栈的过程。栈的大小和具体JVM的实现有关，通常在256K～756K之间。

栈管运行，堆管存储。

# 方法区

- 所有线程共享
- 存在垃圾回收

存储每个类的**结构信息**（模板）

```java
public class Car{
    int price = 1233435;
    public park(){
        System.out.println("stop ...");
    }
}
```

例如运行时常量池、字段和方法数据、构造函数和普通方法的字节码内容。方法区是规范，在不同的虚拟机里的实现不一样，最典型的是`永久代(PermGen space)`和`元空间(Metaspace)`。

元空间与永久代最大的区别在于：永久代使用的是jvm的堆内存，但是java8以后的元空间并不在虚拟机中而是**本机物理内存**。因此，元空间的大小仅受本地内存限制，类的元数据放入native memory，字符串池和类的静态变量放入java堆中，这样可以加载多少类的元数据就不再由MaxPermSize控制，而由系统的实际可用空间来控制。

实例变量存在堆内存中，与方法区无关。

## 方法区、栈、堆

```java
Person person1 = new Person();
Person person2 = new Person();
```

要保证person1与person2来自同一个类实例化且保持各自的行为，依靠方法区的“模板”。

hotsopt是使用指针的方式访问对象：java堆中会存放类元数据的地址，类元数据即Class（类的结构信息）。栈中存放的则是对象的地址。即 栈-->堆-->方法区

# 堆

（Java7之前）	一个Jvm实例只存在一个堆内存，堆内存的大小可以调节。类加载器读取了类文件后需要把类、方法、常变量放到堆内存中，保存所有引用类型的真实信息，以便执行器执行。

(Java8)	永久区换成了元空间。

物理上为新生区+养老区。

## 堆内存

逻辑上分为三部分：新生+养老+永久

新生区： Youg Generation Space (Eden Sapce + Survivor 0 space + Survivor 1 space)

养老区：Tenure Generation Space

永久存储区：Permanent Space

- Eden: 0space: 1space  = 8 : 1 : 1
- Young : Old = 1 : 2

## 静态

实例化对象的整个生命周期都在新生区进行，最开始是在Eden Sapce,当满了之后会进行GC（垃圾回收），这时会清除大部分的垃圾，剩余的对象放入Survivior 0 space，当Eden Space和Survivor 0 space也满时，进行GC，幸存者放入Survivor 1 space，重复上一步，幸存者存入Tenure Genreration Space，重复上一步，也满时进行Full GC，重复上一步，再次满时，无处存储实例对象，会产生OutOfMemoryError(OOM)。

## 动态

Survivor 0 space: from区

Surrivor 1 space: to区

他们的位置不固定，每次GC之后位置会交换，空的为to区。

1. Eden, SurvivorFrom copy to SurviviorTo
2. clean up Eden, SurvivorFrom
3. Swap SurvivorTo and SurvivorFrom

## 永久代

是一个常驻内存区域，用于存放jdk自身所携带的Class、Interface的元数据，也就是说他存储的是运行环境必须的类信息，被装载进此区域的数据是不会被垃圾回收器回收的，关闭JVM才会释放此区域所占的内存。

## 调优

```java
public static void main(String[] args){
    // Returns the maximum amount of memory that the Java virtual machine will attempt to use.
    long l = Runtime.getRuntime().maxMemory();

    // Returns the total amount of memory in the Java virtual machine.
    long l1 = Runtime.getRuntime().totalMemory();

    // 1/4
    System.out.println("(-xmx) MAX_MEMORY: " + l + "bytes, " + (l / (double) 1024 / 1024 + "MB"));
    
    // 1/64
    System.out.println("(-xms) TOTAL_MEMORY: " + l1 + "bytes, " + (l1 / (double) 1024 / 1024 + "MB"));
}
```

**note:** 生产中会将最高值与最低值设置的一样大，避免应用程序争抢内存，产生峰谷。

# JMM

Java的内存模型（Java Memory  Model)，本身是一种抽象的概念，并不真实存在，他描述的是一组规范，通过这组规范定义了程序中各个变量（**包括实例字段、静态字段以及构成数组对象的元素**）的访问方式。

在操作系统中我们有学习过，线程是资源调度的最小单位，进程是资源最小的分配单位，但是线程还是拥有部分必要的资源，其中，`工作内存`是每个线程的私有数据区域。java内存模型中规定所有变量都存储在主内存，它是共享的内存区域，所有线程都可以访问，但是线程对变量的操作（如读、取、赋值等）必须在工作内存中进行，首先要将变量从主内存拷贝到线程自己的工作内存空间，然后对变量进行操作，操作完成后再将变量写回主内存，换句话说，不能直接操作主内存中的变量，各个线程中的工作内存存储着主内存中的变量副本拷贝。因此，不同的线程间无法访问对方的工作内存，线程间的通信（传值）必须通过主内存来完成。

## violatile

java虚拟机提供的轻量级的同步机制，乞丐版syncronized。

- 保证可见性
- 不保证原子性
- 禁止指令重排