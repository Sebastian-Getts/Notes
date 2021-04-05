---
title: jvm
date: 2020-05-24 17:39:25
categories: JVM
tags: summary
---

associate with juc

<!--more-->

<!--toc-->

# 系统图

![Screenshot from 2020-06-04 20-11-48.png](https://i.loli.net/2020/06/04/UQfq2lrGu9mLc4C.png)

- 灰色代表线程私有，占用的内存非常少，几乎不存在垃圾回收
- 亮色代表存在垃圾回收

# 类加载器

经过javac编译后，形成的xxx.class文件存在电脑硬盘上，通过类加载器装进JVM并初始化为xxx.Class文件（装载进虚拟机）。只负责加载class文件，将之装载后成为Class文件，放进方法区。

> Car.class -> Class Loader -> Car Class -> car1/car2/car3

Car Class是后面car1、car2、car3的模板，后面的三个car也是实例化的产物。

![Screenshot from 2020-06-04 20-33-54.png](https://i.loli.net/2020/06/04/EYRbMN1fgIOuHBk.png)

## 种类

### 启动类加载器（Bootstrap）

由C++编写，默认加载一些编写程序比用的东西，比如Object, ArrayList, String等。

### 扩展类加载器（Extension）

Java编写，除了启动类加载器加载核心的东西外，还需要Extension加载入javax等java扩展类。

### 应用程序类加载器（AppClassLoader）

我们编写程序时定义的类所用的加载器

### 用户自定义加载器

定制化开发，不走默认的类加载顺序时，可以继承ClassLoader（抽象）。

## 双亲委派

比如如果需要使用A.java类，需要先去顶部Bootstrap寻找，找不到的话去Extension找，还没有的话去Application中找，还没有的话抛异常。

**Bootstrap** --> **Extension** --> **Application**

```java
public class String{
    public static void main(String[] args){
        System.out.println("hello world!");
    }
}
```

> 在类java.lang.String中找不到main方法。因为先从Bootstrap中寻找。

## 沙箱安全机制

**note**: 保证个人编写的代码不污染出厂的jdk代码，并且不同类中使用的Object都是相同的。

## 本地方法接口（Native Interface）

融合不同的编程语言为Java所用（即C/C++），在内存中专门开辟了一块区域处理标记为native的代码。目前该方法使用的越来越少了，除非是与硬件相关的应用，如通过java驱动打印机，企业级应用少见。

异构领域间通信发达，Socket通信或webService。

### Native

只是一个关键字。只有声明，没有实现，标记需要调用底层C语言函数库或系统。

### 本地方法栈

装native方法的栈。在内存中专门开辟了一块区域处理标记为native的代码，登记native方法，在Execution Engine执行时加载本地方法库。

# PC寄存器

实际是一个指针，线程私有，记录了方法之间的调用和执行情况，类似排班值日表。用来存储指向下一条指令的地址，即将要执行的指令代码。

是当前线程所执行的字节码的行号指示器。

# 栈

- 不存在垃圾回收问题
- ==线程私有==（想想加锁，不就在方法上/中加的么）

也叫栈内存，**主管Java程序的运行**，在线程创建时创建，线程结束时结束（释放栈内存）。基本类型的变量、对象的引用变量、实例方法都在栈空间中。

## 存储

在java中的方法装载在虚拟机的栈中叫栈帧。

- Local Variables: 输入参数、输出参数以及方法内的变量

  ```java
  // 入参为 x, y， 输出为result，方法内变量为result，均在栈中。
  public int add(int x, int y){
      int result = 0;
      result = x + y;
      return result;
  }
  ```

- Operand Stack: 记录出栈、入栈的操作

- Frame Data: 包括类文件、方法等等

## 运行

栈中的数据都是以栈帧（Stack Frame）的格式存在，栈帧是一个内存区块，是一个数据集，一个有关方法（Method）和运行期数据的数据集，当一个方法A被调用时就产生了一个栈帧，并被压入到栈中，执行完毕后弹出。

```java
// 方法深度调用，把栈撑爆了。 Exception: StackOverflowError 属于错误
public static void m1(){
    m1();
}
```



每个方法执行的同时都会创建一个栈帧，用于存储局部变量表、操作数栈、动态链接、方法出口等信息，每一个方法从调度直至执行完毕的过程，就对应着一个栈帧在虚拟机入栈到出栈的过程。栈的大小和具体JVM的实现有关，通常在256K～756K之间。

栈管运行，堆管存储。

# 方法区

class文件被ClassLoader装载进JVM称为Class文件，其实是装进了方法区。方法区是规范，在不同的虚拟机里的实现不一样，最典型的是`永久代(PermGen space)`和`元空间(Metaspace)`。

- 所有==线程共享==
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

例如运行时常量池、字段和方法数据、构造函数和普通方法的字节码内容。

元空间与永久代最大的区别在于：永久代使用的是jvm的堆内存，但是java8以后的元空间并不在虚拟机中而是**本机物理内存**。因此，元空间的大小仅受本地内存限制，类的元数据放入native memory，字符串池和类的静态变量放入java堆中，这样可以加载多少类的元数据就不再由MaxPermSize控制，而由系统的实际可用空间来控制。

实例变量存在堆内存中，与方法区无关。i.e.

```java
public class Demo{
    public void hello(){}
    public static void main(String[] args){
        Demo demo = new Demo();
        demo.hello();
    }
}
```

每次new之后都会产生一个hello方法以及变量demo，此时这个实例变量就存在堆（当然）。

# 方法区、栈、堆

```java
Person person1 = new Person();
Person person2 = new Person();
```

左边的引用变量放在栈中，右边new出来的实例存放在堆中。堆中的实例指向方法区（保证两个不同的实例对象有同样的行为）。

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

> -XX:MaxTenuringThreshold 设置对象在新生代中存活的次数（java8默认且最高15）

# GC

- minor GC
- major/full GC

major GC的速度比minor GC慢得多（考虑下young区和old区的大小比）。

## 垃圾回收算法

分代收集，根据各个代来使用

### 引用计数法

每次引用对象时会维护计数器，每次引用的时候会加1,如果是0的话会被回收，但是大量的计数器也会有消耗。最大的弊端还是循环引用。JVM一般不会用这种。

### 复制算法（Copying）

Minor GC使用的就是Copying。不会产生内存碎片，但是会耗费空间。

因为存活率都很低，复制也没啥。

### 标记清除法（Mark-Sweep）

Major GC使用的是Mark-Sweep，或者与下面的Mark-Compact混合实现。分为标记和清除两个阶段，先标记要回收的，然或再统一回收这些对象。对比上面的，没有复制-粘贴-清除，而是标记后清除，但是造成了内存碎片话（内存不连续），也没有Copying速度快（找出标记的需要进行扫描）。JVM为了空闲的内存还需要维持一个内存的空闲列表，又是一种开销。

### 标记压缩（Mark-Compact）

Mark-Sweep-Compact，标记清除压缩算法，比上面的多了一步整理的过程（不会产生内存碎片），显然时间上消耗更多了（慢工出细活），多了移动对象的时间。

也可以派生出另一种：多次GC后才进行压缩，减少移动对象的时间。

# JMM

Java的内存模型（Java Memory  Model)，本身是一种抽象的概念，并不真实存在，他描述的是一组规范，通过这组规范定义了程序中各个变量（**包括实例字段、静态字段以及构成数组对象的元素**）的访问方式。

在操作系统中我们有学习过，线程是资源调度的最小单位，进程是资源最小的分配单位，但是线程还是拥有部分必要的资源，其中，`工作内存`是每个线程的私有数据区域。java内存模型中规定所有变量都存储在主内存，它是共享的内存区域，所有线程都可以访问，但是线程对变量的操作（如读、取、赋值等）必须在工作内存中进行，首先要将变量从主内存拷贝到线程自己的工作内存空间，然后对变量进行操作，操作完成后再将变量写回主内存，换句话说，不能直接操作主内存中的变量，各个线程中的工作

内存存储着主内存中的变量副本拷贝。因此，不同的线程间无法访问对方的工作内存，线程间的通信（传值）必须通过主内存来完成。

## violatile

java虚拟机提供的轻量级的同步机制，乞丐版syncronized。

- 保证可见性
- 不保证原子性
- 禁止指令重排



# 总结

这一篇是对整个jvm的概览，接触java有一年多了，想深入了解java，在代码层面会止步于*native*以及便以后的*class*，所以，jvm是一个突破后，只有深入理解了jvm才能理解java的运行机制。当然我的初衷并不是无缘无故地想去了解它，而是源于多线程编程，所以我是从jmm入坑的，了解完jmm又迫不及待地从头阅读，有种豁然开朗的感觉。不出意外jvm会出一个系列。



