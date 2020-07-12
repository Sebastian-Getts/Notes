---
title: sort
date: 2020-06-23 15:47:49
categories: Java
tags: sort
---

基于Java的排序讨论，涉及插入、选择、冒泡、归并、快速、堆、外部、桶排序等。

<!--more-->



# 序

通过排序可以了解算法相关的知识和技能，是个很好的开始。目前已知基于比较的排序算法，最好的时间复杂度不会好于O(nlogn)，但是有非基于比较的算法可以做到O(n)。关于多种不同的排序算法，还有诸多可深究的，比如时间复杂度与空间复杂度之间的取舍、稳定性等。知道彼此之间的优劣后，需要知道各个算法的如何实现。



# 插入排序

{% note primary %}

重复地将新的元素插入到一个排好序的子线性表中，直到整个线性表排好序。

{% endnote %}

插入排序默认数组中初始化只存在一个元素，然后第二个元素“插入“进去（默认插入末尾），如果比旁边的小，则互换位置，然后”插入“第三个…… 注意我这里的”插入“带了引号，是因为元素本身就存在于数组，并没有开辟新的内存空间给一个新的数组。

## 实现

```java
public void insertionSort(int[] list) {
    for (int i = 1; i < list.length; i++) {
        int curr = list[i];	// 当前的要插入的元素
        int k;	// 当前元素的左侧元素的指针
        for (k = i - 1; k >= 0 && list[k] > curr; k--) {
            list[k + 1] = list[k];
        }
        list[k + 1] = curr;	// 不满足for循环中的判断条件，退出后把当前元素插入指定位置。
    }
}
```

- 算法复杂度为O(n2)，空间复杂度为O(1)
- 只有大于左侧元素才会换位置，所以是**稳定的**



# 冒泡排序

{% note primary %}

多次遍历数组，在每次遍历中连续比较相邻的元素，如果元素没有按照顺序排列，则互换他们的值。

{% endnote %}

bubble sort，又叫sinking sort。冒泡排序/下沉排序，每遍历一次数组，都会有一个较小的值浮向顶部（左侧），较大的值沉向底部（右侧），换句话说，就是每次遍历都会进行到底，所以我觉得从算法实现的角度来说**下沉排序**会更贴切。

## 实现

```java
public void bubbleSort(int[] list) {
    boolean needNextPass = true;

    for (int k = 1; k < list.length && needNextPass; k++) {
        needNextPass = false;
        for (int i = 0; i < list.length - k; i++) {
            if (list[i] > list[i + 1]) {
                int temp = list[i];
                list[i] = list[i + 1];
                list[i + 1] = temp;

                needNextPass = true;
            }
        }
    }
}
```

- 算法复杂度为O(n2)，空间复杂度为O(1)
- 稳定的



# 归并排序

{% note primary %}

归并排序算法将数组分为两半，对每部分递归地应用归并排序。在两部分排好序后，对他们进行归并。

{% endnote %}



# 选择排序

{% note primary %}

先找到数列中最小的数，然后将它和第一个元素交换，然后在剩下的数列中找到最小的数，将它和第二个元素交换，依此类推，直到只剩最后一个数为止。

{% endnote %}



# 快速排序

{% note primary %}

在数组中选一个称为主元的元素，将数组分为两部分，使得第一部分中的所有元素都小于或等于主元，第二部分中的所有元素都大于主元。对第一部分第二部分分别地应用快速排序。

{% endnote %}