---
title: arraylist-grow
date: 2021-05-12 23:35:52
categories: Java
tags: summary
---

以前一直想当然的以为arrayList是双倍扩容（跟HashMap不一样！）……吸取教训，今天总结一下。

<!-- more -->

<!-- toc -->

以下基于*jdk8*分析

```java
public boolean add(E e) {
    ensureCapacityInternal(size + 1);  // Increments modCount!!
    elementData[size++] = e;
    return true;
}
```

可以看到，在*ensureCapacityInternal*之后就可以进行数组的插入了，而且插入后将size加1了。后一个*size++*容易理解，size记录数组的长度，赋值完元素后加1操作，这里有几个实例变量，`modCount`、`size`、`elementData`。

- `modCount`，继承于AbstractList，用于记录着集合的修改次数，也就是每次add或remove都加1. 是**fail-fast**机制。在初始化迭代器时，**modCount的值会赋给expectedModCount，在迭代的过程中，只要modCount改变了，造成两者不一致，就会抛出currentModificationExpections**。
- `size`，数组中包含元素的个数
- `elementData`，数组，也就是ArrayList底层实际存储数据的地方

# 确认容量

```java
private void ensureCapacityInternal(int minCapacity) {
    ensureExplicitCapacity(calculateCapacity(elementData, minCapacity));
}
```

这个方法内将他分为两步



## 计算capacity

```java
private static int calculateCapacity(Object[] elementData, int minCapacity) {
    if (elementData == DEFAULTCAPACITY_EMPTY_ELEMENTDATA) {
        return Math.max(DEFAULT_CAPACITY, minCapacity);
    }
    return minCapacity;
}
```

怎么计算呢？判断是否是空的，如果是的话就赋予默认的容量，否则就返回入参minCapacity，所以，这一步就是为初始化（未指定大小）来做的。

## 明确capacity

```java
private void ensureExplicitCapacity(int minCapacity) {
    modCount++;

    // overflow-conscious code
    if (minCapacity - elementData.length > 0)
        grow(minCapacity);
}
```

add操作，增加modCount来记录。由于传入的minCapacity是size+1，size是元素的个数（不是数组长度，初始10个坑位，可以只存2个元素），size+1表示期望的元素数量。紧接着判断期望的数量是否大于数组长度，如果大于的话执行执行*grow*方法。

## 扩容

```java
private void grow(int minCapacity) {
    // overflow-conscious code
    int oldCapacity = elementData.length;
    int newCapacity = oldCapacity + (oldCapacity >> 1);
    if (newCapacity - minCapacity < 0)
        newCapacity = minCapacity;
    if (newCapacity - MAX_ARRAY_SIZE > 0)
        newCapacity = hugeCapacity(minCapacity);
    // minCapacity is usually close to size, so this is a win:
    elementData = Arrays.copyOf(elementData, newCapacity);
}
```

不是想象中简单的两倍，但是最终是一样的，拿到一个新的数组，将旧数组的元素复制过去，那么， 新的数组长度如何确认呢？关键就在这个方法中了。

- `oldCapacity`：原始数组长度
- `newCapacity`：原始数组长度 + 原始数组长度/2 （也就是1.5倍的原始数组长度）

上面两个是初始定义的参数，除了这两个，还会传入一个参数`minCapacity`，这里会有个问题，按照定义的参数，新数组能满足期望的长度么？按理说每次都只是加一个元素，是可以满足的吧？代码中有后续的判断：

- 如果新的容量小于期望容量，那么就将期望容量作为新的容量
- 如果新的容量大于最大的数组容量，调用*hugeCapacity*来生成新的容量。新的容量有两种来源，一种是1.5倍的原始长度，另一种是被期望长度赋予，无论哪种，这里都要判断是否大于最大值。如果大于的话拿期望值作为参数去计算新的容量。这里也有两种可能：
  - 1.5倍的原始长度符合期望，但是大于了最大长度，所以不能1.5倍的计算，要拿期望长度重新计算
  - 1.5倍的原始长度不符合期望，直接拿期望长度作为新的长度，但是新的长度大于了最大长度，所以拿期望长度重新计算

```java
private static int hugeCapacity(int minCapacity) {
    if (minCapacity < 0) // overflow
        throw new OutOfMemoryError();
    return (minCapacity > MAX_ARRAY_SIZE) ?
        Integer.MAX_VALUE :
        MAX_ARRAY_SIZE;
}
```

大于最大值如何解决？小于0 的话溢出（size+1），抛出内存溢出，大于的话直接拿整型的最大值作为返回值，等于就返回最大值。

# 执行加操作

经过上一步，应该有位置放元素了，正常添加，然后size计数。