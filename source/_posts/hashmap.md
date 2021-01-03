---
title: hashmap
date: 2020-08-20 23:04:30
categories: Java
tags: hashmap, data structure
---

Java Hashmap，经典数据结构。主要理解他的组成结构和哈希原理，哈希冲突如何处理。基于jdk8。

<!--more-->

# Example

```java
Map<String, Object> map = new HashMap<>();
map.put("name", "Gloria");
map.put("age", 3);
map.put("wage", 539.8);
System.out.println(map);
```

通过一个简单的`put`操作，来看看究竟发生了什么。

## 构造

初始化时，构造一个HashMap对象，这里有有参和无参（当然，阿里开发规约建议知道容量的情况下要指定大小）的构造方法，有参中你可以指定装载因子、容量、甚至是把map放进去：

```java
Map<String, Object> map1 = new HashMap<>(map); // map为上方那个
```

来看看初始化容量时的装载因子：

```java
    /**
     * The load factor for the hash table.
     *
     * @serial
     */
    final float loadFactor;
```

HashMap的容量是我们存入的数值乘以`0.75`,例如：

```java
Map<String, Object> map = new HashMap<>(16);
```

那么，这个map的**实际容量**就是12，超过这个数量的话就会进行扩容操作。一般我们都使用默认的`0.75`,自定义**初始容量**。

## put初识

```java
/**
 * Implements Map.put and related methods.
 *
 * @param hash hash for key
 * @param key the key
 * @param value the value to put
 * @param onlyIfAbsent if true, don't change existing value
 * @param evict if false, the table is in creation mode.
 * @return previous value, or null if none
 */
final V putVal(int hash, K key, V value, boolean onlyIfAbsent,
               boolean evict) {
    return putVal(hash(key), key, value, false, true);
}key
```

put有几个参数，其中之一是hash值，所以我们先来看看他的hash，上面是他的入参，可以看到，只对传入的key进行hash处理了。那么hash是如何做的呢？

```java
static final int hash(Object key) {
    int h;
    return (key == null) ? 0 : (h = key.hashCode()) ^ (h >>> 16);
}
```

惊不惊喜，意不意外？（好吧，很easy了）首先，他是一个三目元算，判断key是否为null，如果是返回0（说明hashmap允许存入key为null）,否则“一顿操作”。再来细看key不为null的情况，用到了两个**位运算**:

- ^ 异或(两个相同的数做异或运算结果为0)
- \>\>\> 无符号右移，左边空出来的补0

首先是给h赋值为key的hashCode，key的hashcode是通过Object的`native方法`，所以跟不下去了！所以重点放在位运算上，将h进行右移16位再与之自身进行异或。

关于异或先放在这里，我们来看看后续是如何存储的，往下一跟便能发现一个变量`table`，他的类型是`Noe<K,V> []`，即Node类型数组，接下来我们来看看他的结构，包括存储时防止冲突的解决方法。



# Node

它是HahsMap的静态内部类，存储的核心，构造也不复杂，可以看看。

```java
 /**
  * Basic hash bin node, used for most entries.  (See below for
  * TreeNode subclass, and in LinkedHashMap for its Entry subclass.)
  */
static class Node<K,V> implements Map.Entry<K,V> {
    final int hash; // 用来定位数组索引位置
    final K key;
    V value;
    Node<K,V> next; // 链接下一个Node

    Node(int hash, K key, V value, Node<K,V> next) {
        this.hash = hash;
        this.key = key;
        this.value = value;
        this.next = next;
    }
    
    // get, set equals ...
}
```

- 脱脱的链表有么有！！！ `Node<K, V> next`！！！
- 上面提到的`table`就是一个链表类型的数组，里面用来装Node链表。所以他的基本储存就明了了：数组+链表。
- 实现了`Map.Entry<K, V>`接口，所以，他的本质（或者说表现）就是一个k-v键值对。
- 与算法题通常定义的简易链表不同，除了`next`外这里存储了三个值：`hash`, `key`, `value`



# 冲突解决

首先想想：什么是哈希表。

哈希表=数组+链表。通过`Node<K, V>`以及`Node<K, V> []`我们知道hashmap是使用哈希表存储的。通过课本我们也了解到对需哈希冲突，解决的方式通常有两种：开放寻址、链地址。毫无疑问，既然用了链表，那就连地址呗，实现方式同样是`数组+链表`。

哈希冲突是有条件的，或者说是限制。在hashmap中，冲突取决于**桶**（即之前提到的`table`数组）和**哈希算法**，前者代表了空间成本，后者则是时间成本，空间与时间的权衡是要自己考虑的了（一般默认）。它默认的做法是初始化一个大小，容不下时会进行扩容，如此一来，数组占的空间又小还能使得发生碰撞的概率减小。我们来看看初始化涉及到的一些参数：

```java
/**
  * The number of key-value mappings contained in this map.
  */
transient int size;

/**
  * The number of times this HashMap has been structurally modified
  * Structural modifications are those that change the number of mappings in
  * the HashMap or otherwise modify its internal structure (e.g.,
  * rehash).  This field is used to make iterators on Collection-views of
  * the HashMap fail-fast.  (See ConcurrentModificationException).
  */
transient int modCount;

/**
  * The next size value at which to resize (capacity * load factor).
  *
  * @serial
  */
// (The javadoc description is true upon serialization.
// Additionally, if the table array has not been allocated, this
// field holds the initial array capacity, or zero signifying
// DEFAULT_INITIAL_CAPACITY.)
int threshold;

/**
  * The load factor for the hash table.
  *
  * @serial
  */
final float loadFactor;
```

`threshold`临界值，所能容纳k-v的极限。如果不指定任何值，初始化时Node<K,V>[] table的length是16, loadFactor是0.75,，那么

> threshold = loadFactor * length

也就是说，table数组中所能容纳的Node个数由`threshold`指定，初始为12.往里面装的Node个数超过12，会进行扩容， 扩容为之前的两倍。这里的负载因子可以看作是对空间的限制，毕竟长度16,由于负载因子变成了12,所以如果内存紧张，对时间要求也不高，可以加大因子，允许超过1.

size就是表示目前存储的Node的数量。

在HashMap中，哈希桶数组的table长度必须为2的n次方，这是一种**非常规**设计，为什么呢？一个冷知识：

- 2的n次方的数为`合数`，实际上`质数`导致哈希冲突的概率要小于合数。

参考HashTable的初始化，`initialCapacity`就是11. 进行这种非常规的设计必然是有道理的，这道理猜都能猜的到吧，当然是为了减少冲突，直接哈希是肯定不可能，不如素数来得快，所以必然是做了一些操作。什么操作呢？后续且看代码。另外，即时哈希算法和桶做得再合理也免不了出现链表过长的情况（数组中一个坑里好长的链表）。链表过长会影响性能，数组形同虚设，所以，在jdk8中引入了**红黑树**，当链表长度过长（默认为8）时会将链表转换为红黑数，利用它快速增删改查的特点提高hashmap的性能。



# 确定索引

我们知道，数组的查询效率很高而链表很慢，hahsmap的查询效率与数组无异，我们存储的个k-v都以Node链表的形式放入table数组中，并且尽可能地使每个它分布均匀，每个位置上的元素只有一个，对于平时操作的增删改查都是以key的hash来进行查找，可以理解为table的index 了，当找到后最好是不用再遍历链表（最好是这样），所以非常的u迅速，那么，如何确定索引？根据上方的hash代码，总结起来三步：

> 取值（key的hashCode），高位运算，取模运算

我们知道，对于存入的任意key，只要它返回的hashCode相同，那么生成的hash码也一定相同。想让Node在数组中能均匀分布，我们首先想到的应该是对数组取模，这样一来一定是均匀分散在数组中 了，但是对于底层运算来说，取模的操作消耗还是比较大的，我们来看看hashmap是如何找到高效的替代方法的：

```java
if ((p = tab[i = (n - 1) & hash]) == null)
            tab[i] = newNode(hash, key, value, null);
```

在代码中有这么一行，n为数组长度，hash为key的哈希码，由于n总是2的n次方，所以`(n-1)&hash`等价于对length取模，比使用`%`具有更高的效率。

 

# put详解

```java
/**
 * Implements Map.put and related methods.
 *
 * @param hash hash for key
 * @param key the key
 * @param value the value to put
 * @param onlyIfAbsent if true, don't change existing value
 * @param evict if false, the table is in creation mode.
 * @return previous value, or null if none
 */
final V putVal(int hash, K key, V value, boolean onlyIfAbsent,
               boolean evict) {
    Node<K,V>[] tab; Node<K,V> p; int n, i;
    // 判断table的是否为空，是则执行扩容操作
    if ((tab = table) == null || (n = tab.length) == 0)
        n = (tab = resize()).length;
    // 计算插入数组的索引，如果为null，新建节点
    if ((p = tab[i = (n - 1) & hash]) == null)
        tab[i] = newNode(hash, key, value, null);
    else {
        Node<K,V> e; K k;
        // 判断key是否存在，如ugo存在直接覆盖掉value
        if (p.hash == hash &&
            ((k = p.key) == key || (key != null && key.equals(k))))
            e = p;
        // 判断是否是红黑树，如果是的话就在树中操作，
        else if (p instanceof TreeNode)
            e = ((TreeNode<K,V>)p).putTreeVal(this, tab, hash, key, value);
        else {
            // 遍历table
            for (int binCount = 0; ; ++binCount) {
                if ((e = p.next) == null) {
                    // 链表的插入操作
                    p.next = newNode(hash, key, value, null);
                    // 长度大于8时转红黑树
                    if (binCount >= TREEIFY_THRESHOLD - 1) // -1 for 1st
                        treeifyBin(tab, hash);
                    break;
                }
                if (e.hash == hash &&
                    ((k = e.key) == key || (key != null && key.equals(k))))
                    break;
                p = e;
            }
        }
        if (e != null) { // existing mapping for key
            V oldValue = e.value;
            if (!onlyIfAbsent || oldValue == null)
                e.value = value;
            afterNodeAccess(e);
            return oldValue;
        }
    }
    ++modCount;
    // 超过最大容量就扩容
    if (++size > threshold)
        resize();
    afterNodeInsertion(evict);
    return null;
}
```



# 扩容

我们知道HashMap的存储基础是桶，也就是数组，一般涉及数组的扩容，都是重新定一个大的数组，然后将小的数组拷贝过去（参考ArrayList），那么这里的HashMap是如何做的呢？怎么处理内部的Node以及红黑数呢？

> note: 要注意上方提到的一些实例变量，都是与HashMap相关的属性。

```java
/**
 * Initializes or doubles table size.  If null, allocates in
 * accord with initial capacity target held in field threshold.
 * Otherwise, because we are using power-of-two expansion, the
 * elements from each bin must either stay at same index, or move
 * with a power of two offset in the new table.
 *
 * @return the table
 */
final Node<K,V>[] resize() {
    Node<K,V>[] oldTab = table;
    int oldCap = (oldTab == null) ? 0 : oldTab.length;
    int oldThr = threshold;
    int newCap, newThr = 0;
    if (oldCap > 0) {
        // 太大就不管了，let it go
        if (oldCap >= MAXIMUM_CAPACITY) {
            threshold = Integer.MAX_VALUE;
            return oldTab;
        }
        // 没超过最大值，左移一位（X2）
        else if ((newCap = oldCap << 1) < MAXIMUM_CAPACITY &&
                 oldCap >= DEFAULT_INITIAL_CAPACITY)
            newThr = oldThr << 1; // double threshold
    }
    else if (oldThr > 0) // initial capacity was placed in threshold
        newCap = oldThr;
    else {               // zero initial threshold signifies using defaults
        newCap = DEFAULT_INITIAL_CAPACITY;
        newThr = (int)(DEFAULT_LOAD_FACTOR * DEFAULT_INITIAL_CAPACITY);
    }
    // 计算resize的上限
    if (newThr == 0) {
        float ft = (float)newCap * loadFactor;
        newThr = (newCap < MAXIMUM_CAPACITY && ft < (float)MAXIMUM_CAPACITY ?
                  (int)ft : Integer.MAX_VALUE);
    }
    threshold = newThr;
    @SuppressWarnings({"rawtypes","unchecked"})
    Node<K,V>[] newTab = (Node<K,V>[])new Node[newCap];
    table = newTab;
    if (oldTab != null) {
        // 遍历数组，把每个桶都移动到新的中去
        for (int j = 0; j < oldCap; ++j) {
            Node<K,V> e;
            if ((e = oldTab[j]) != null) {
                oldTab[j] = null;
                if (e.next == null)
                    newTab[e.hash & (newCap - 1)] = e;
                else if (e instanceof TreeNode)
                    ((TreeNode<K,V>)e).split(this, newTab, j, oldCap);
                else { // preserve order
                    Node<K,V> loHead = null, loTail = null;
                    Node<K,V> hiHead = null, hiTail = null;
                    Node<K,V> next;
                    do {
                        next = e.next;
                        if ((e.hash & oldCap) == 0) {
                            if (loTail == null)
                                loHead = e;
                            else
                                loTail.next = e;
                            loTail = e;
                        }
                        else {
                            if (hiTail == null)
                                hiHead = e;
                            else
                                hiTail.next = e;
                            hiTail = e;
                        }
                    } while ((e = next) != null);
                    if (loTail != null) {
                        loTail.next = null;
                        newTab[j] = loHead;
                    }
                    if (hiTail != null) {
                        hiTail.next = null;
                        newTab[j + oldCap] = hiHead;
                    }
                }
            }
        }
    }
    return newTab;
}
```

