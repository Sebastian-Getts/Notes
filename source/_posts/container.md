---
title: container
date: 2019-11-09 11:40:10
categories: 
- 技术
- java
tags: container
---



聊聊Java的合集框架，线性表、栈、队列和优先队列。为一个特定的任务选择最好的数据结构和算法是开发高性能软件的一个关键。

地基不牢，地动山摇。。脑子里突然蹦出这句

<!--more-->

# 引

“在面向对象思想里，一种数据结构也被认为是一个容器或容器对象，他是一个能存储其他对象的对象，这里的其他对象常称为数据或元素。定义一种数据结构从本质上讲就是定义一个类。数据结构类应该使用数据域存储数据，并提供方法支持查找、插入和删除等操作。因此，创建一个数据结构就是创建这个类的一个实例。然后，就可以使用这个实例上的发方法来操作这个数据结构。”

Java提供了很多的能有效组织和操作数据的数据结构，它们被成为Java Collections Framework。主要包括线性表、向量、栈、队列、优先队列、集合和映射表。



# 合集

Java合集框架支持两种类型的容器：

- 存储一个元素合集，称为collection（合集）
- 存储键值对，称为map（映射表）

首先介绍合集。

- *set* 用于存储一组**不重复**的元素
- *list* 用于存储一个**有序元素**合集
- *stack* 用于存储采用**后进先出**方式处理的对象
- *queue*用于存储采用**按照优先级顺序**处理的对象
- *priority queue* 用于存储**按照优先级顺序**处理的对象

{% note info%}

Java 合集框架的设计时使用接口、抽象类和具体类的一个很好的例子。

1. 用接口定义框架
2. 抽象类提供这个接口的部分实现
3. 具体类用具体的数据结构实现这个接口
4. 提供一个部分实现接口的抽象类对用户编写代码提供了方便

用户可以简单地定义一个具体类继承自抽象类，而无需实现接口中的所有方法。

{% endnote %}

# 迭代器

每种合集都是可迭代的（Iterable），可以获得集合的Iterator对象来遍历合集中的所有元素。

Iterator是一种经典的设计模式，**用于在不需要暴露数据是如何保存到数据结构的细节的情况下，来遍历一个数据结构**。

Collection接口继承自Iterable接口，接口定义了iterator方法，该方法会返回一个迭代器。Iterator接口为遍历各种类型的合集中代元素**提供了统一的方法**。接口中的iterator()方法返回一个Iterator的实例。

```java
import java.util.*;

public class TestIteraor{
    public static void main(String[] args){
        Collection<String> collection = new ArrayList<>();
        collection.add("New York");
        collection.add("Atlanta");
        
        Iterator<String> iterator = collection.iterator();
        while(iterator.hasNext()){
            System.out.print(iterator.next().toUpperCase() +" ");
        }
        System.out.println();
    }
}
```

在第五行创建了一个具体的合集对象，在第九行获得合集的一个迭代器。



# 线性表

list接口继承自collection接口，定义了一个用户顺序存储元素的合集，可以使用他的两个具体类ArrayList或者LinkedList来创建一个线性表（list）。

ArrayList：数组线性表，用于数组存储元素，这个数组是动态创建的。如果元素个数超过了数组的容量，就创建一个更大的新数组，并将当前数组中的所有元素都复制到新数组中。

LinkedList：链表类。在一个链表（linked list）中存储元素。

## 选择

- 如果需要**通过下表随机访问元素**，而不会在线性表起始位置插入或删除元素，那么ArrayList提供了最高效率的合集。

- 如果应用程序**需要在线性表的起始位置插入或删除元素**，就应该选择LinkedList类。

- 线性表的大小是可以动态增大或减小的。然而数组一旦被创建，大小就是固定的，如果应用程序**不需要在线性表中插入或删除元素**，那么数组是效率最高的数据结构。



## 向量类和栈类

{% note primary %}

在Java API中，Vector是AbstractList的子类，Stack是Vector的子类

{% endnote %}

在Vector中，除了包含用于**访问**和**修改向量的同步**的方法之外，他跟ArrayList是一样的。同步方法用于**防止两个或多个线程同时访问和修改某个向量时引起数据损坏**。对于许多不需要同步的应用程序来说，使用ArrayList比使用Vector效率更高。

是不是可以用向量处理缴费，防止重复嘞？



# 集合和映射表

是不是有点晕了，起的中文名让人云里雾里，所以，，，最好还是直接记英文名。

集合（set）是一个用于存储和处理**无重复元素**的高效数据结构。

映射表（map）就不多说了。

## 集合

<% note primary %>

可以使用集合的三个具体类HashSet, LinkedHashSet, TreeSet 来创建集合。

<% endnote %>

Set接口扩展了Collection接口，不过他没有引入新的东西，只是**规定Set的实例不包含重复的元素**。

