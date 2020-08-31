---
title: decorating
date: 2020-06-12 18:30:28
categories: DesignPatterns
tags: design_patterns
---

继承滥用：一个父类下有成百上千个子类，还无法高效解决问题，怎么优化？装饰者模式。

<!-- more -->

# 场景

一家咖啡厅售卖咖啡，在这里讨论的当然是网上售卖。父类是`Beverage`抽象类，包含一个抽象方法_cost()_，根据不同口味实现不同的价格，诸如HouseBlend, DarkRoast Decaf, Espresso... 购买咖啡时，也可以加入各种调料，如豆浆、摩卡等等，这些也是要收费的，最终下单时会将这些所有整合。

如何高效设计呢？如果某个调料价格上涨该从何处修改？新增原料怎么办？

> 类应该堆扩展开放，对修改关闭。



# 装饰者模式

以上个场景为例，以父类为主体，在运行时以调味料来“装饰”父类，最终得到顾客想要的口味。

1. DarkRoast对象
2. 用摩卡装饰
3. 用奶泡装饰
4. 调用cost方法，依赖delegate添加价钱



# 实现

![Screenshot from 2020-06-12 20-50-33.png](https://i.loli.net/2020/06/12/jQwAkbz7V6n8dGK.png)



其中`Condiment`是调料类，重写了`Beverage`的`getDescription`方法。以Whip为例：

```java
public class Whip extends Condiment {
    Beverage beverage;

    public Whip(Beverage beverage) {
        this.beverage = beverage;
    }

    @Override
    public String getDescription() {
        return beverage.getDescription() + ", Whip";
    }

    @Override
    public double cost() {
        return .30 + beverage.cost();
    }
}
```

它的_cost_方法入获取description的方法如出一辙，这样的好处在于：

```java
Beverage beverage1 = new DarRoast();
beverage1 = new Mocha(beverage1);
beverage1 = new Mocha(beverage1);
beverage1 = new Whip(beverage1);
System.out.println(beverage1.getDescription() + " $" + beverage1.cost());
```

```console
Brazil Dark Roast Coffee, Mocha, Mocha, Whip $2.75
```

制作一杯咖啡时，添加不同的调料只需要创建调料的实例，里面装上饮料父类，最后打印出描述和价格的时候，会自动加上父类的。这样的方式不妨称之为**委托**.

# 应用

## Java I/O

大量的`Decorator Pattern`在java的io包中运用。输入输出在计算机中的底层实现都是0101……来实现的，所以，例如，最底层的实现类是_FileInputStream_（好比是_Beverage_），往上”装饰“一层可以是字节_BufferedInputStream_（好比是_Espresso_），接着往上是_LineNumberInutStream_（好比是加调料_Mocha_）。

```flow
para1=>parallel: FileInputStream
para2=>parallel: BufferedInputStream
para3=>parallel: LineNumberInputStream
op1=>operation: Beferage
op2=>operation: Espresso
op3=>operation: Mocha
para1(path1, bottom)->para2
para2(path1,bottom)->para3
para1(path2, right)->op1
para2(path2, right)->op2
para3(path2, right)->op3
```

