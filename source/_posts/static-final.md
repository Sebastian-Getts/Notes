---
title: static_final
date: 2020-04-12 16:19:56
categories: Java
tags:[static][final]
---

Java的关键字static, final，以及部分jvm的内容。

<!-- more -->

# final

先说说final的位置，它可以标注在__类__上、__方法__上以及__变量__上，且变量部分实例和局部。

简单来说，final的作用就是令其唯一。

| final | influence    |
| ----- | ------------ |
| 类    | 不能被继承   |
| 方法  | 不能被重写   |
| 变量  | 不能再被更改 |

# static

同上，他的位置也是多样的。可以标注在__方法__上和__变量__上。

静态，不受实例的影响：例如 Math.max(a, b)，输出的结果只跟调用方传入的a、b的值有关，与Math的实例无关。

```java
public class MyBook{
    double price;
    
    public static void main(String[] args){
        //会报告异常，静态方法中不能使用实例变量，对他来说是未知的。
        System.out.println(price);
    }
    
    public void setPrice(double price){
        this.price = price;
    }
    
    public float getPrice(){
        return pricce;
    }
    
    public float sellingPrice(){
        int bookPrice = 2/3 * price;
        return bookPrice;
    }
}
```

如上例所示，由于静态方法是直接用类名来引用的，所以**实例变量**对于它来说是未知的。那么，实例变量是谁可知、又如何可知的呢？



## 变量

变量按照不同的分类可以用不同的分法。

按照位置分类，可以有局部变量和实例变量；按照类型又可以有原始变量和引用变量。

局部变量：声明在方法内部的变量，如例子中方法sellingPrice()内的变量`bookPrice`。

实例变量：声明在类内、方法之外的变量，如例子中的`price`。关于实例变量，在上例中每创建一个MyBook的对象，都会伴随对象产生一个变量price，且互不影响。

原始变量：即primitive变量，使用java的基本数据类型声明的变量，如`int a = 0`。

引用变量：在创建对象的过程中，将对象赋予的变量。如`MyBook firstBook = new MyBook();`中，`new MyBook()`的作用是利用构造函数创建对象，`MyBook firstBook`声明引用变量，最后是赋值对象给引用。

### static

如果在实例变量上添加了static修饰符，那么这个变量会被所有的实例共享。

## 栈和堆

声明之后的变量存到哪里去了？栈和堆。

- 局部变量会跟随方法一起保存在栈中，除此之外还有方法的调用状态，他们一起被称为**堆栈块**。
- 实例变量会跟随类的对象一起保存在堆中。

所以，在静态方法中，对于实例变量是不可知的，或者说不知道该调用哪一个实例变量。

{% note info%}

非primitive的变量只是保存对象的引用。对象都存在堆中，而引用的变量本身会放在栈上。

{% endnote %}