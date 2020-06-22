---
title: observer
date: 2020-06-12 17:12:38
categories: Java
tags: design_patterns
---

观察者模式，融入一个场景的话就是观察者能够及时的知晓被观察者的动态。换句话说，改变常规的获取信息的方式，就是被观察者的每次动态推送到观察者。有咩有MQ的味道？

<!--more-->

一个好的设计模式能拯救一堆代码。

# 场景

设计一个应用：气象站检测到数据，显示装置应及时显示数据，气象站提供了一组API。

```java
public class WeatherData(){
    getTemperature(){};
    getHumidity(){};
    
    /**
    * 一旦气象更新，此方法会被调用。
    */
    measuremetnsChanged(){
        // our codes go here
    };
}
```

如果直接在`measuremetnsChanged`这个方法里写参数的更新，那么毫无疑问，违反了基本的编码常识：面向接口编程与松耦合。在后续更改显示装置代码的话，还得修改程序。

```java
public void measuremetnsChanged(){
    currentConditionsDisplay.update(getTemperature(), getHumiditiy(), getPressure());
    forecastDisplay.update(getTemperature(), getHumiditiy(), getPressure());
    ......
}
```

# 观察者模式

先看看我们平时是怎么浏览微信订阅号消息：

首先整个流程应该有两个参与者

- 订阅号运营者
- 订阅者

订阅号运营者需要关心的是如何高质量完成推文，订阅者关心的是能否收到推文（前提是订阅了）。在微信上，我们只需要订阅感兴趣的订阅号，微信方就会实现推送订阅号的推文，运营者和订阅者只需专注于自己的事情就好。

那么观察者模式也类似：

> 订阅号运营者+订阅者=观察者模式

不一样的是名称，订阅号运营者改为“subject"（主题），订阅者改为”observer"（观察者）。

由于一个主题可以被多个观察者订阅，所以，它实现了对象之间**一对多**；同时，这种对象设计也让主题和观察者之间**松耦合**.

对于主题，只知道观察者实现了某个接口（observer），不需要知道观察者的具体类型、做了什么，而且，任何时候都可以添加/删除观察者，因为主题唯一依赖的是一个实现observer接口的对象列表。

## 实现

![Screenshot from 2020-06-12 18-03-04.png](https://i.loli.net/2020/06/12/cwTWVXNpIQ5ebGo.png)

我们为subject定义一个接口，这样，无论有多少个主题，实现subject就可以了。对于观察者，除了要实现Observer接口外，有参构造函数必须要传入一个特定的主题，这样观察者才有意义。

```java
public CurrentConditionsDisplay(Subject weatherData) {
    this.weatherData = weatherData;
    weatherData.registerObserver(this);
}
```

以上是手动实现了观察者模式所需的api，事实上，java的util包中内置了观察者模式。只不过不是接口，而是类，使用时需要继承它，如果想同时实现它和另外一个父类就无法做到了，一定程度上限制了它的复用。所以还是根据业务手动创建观察者模式，并不难。

完整代码参考：[项目传送门](https://github.com/Sebastian-Getts/designPatternsPractice)

## 原理

虽然类似订阅，但是主观对象是不同的！！！比如微信订阅号，是否接收通知（是否订阅）是由订阅者来决定的，而在观察者模式当中，主观对象是主题，这就好比订阅的后半段。观察者模式的主动权不在观察者，而在于“想让谁观察”的主题：在一个具体的类实现了主题接口后，他能决定在自己有变化时通知谁，所以实现主题与观察者之间的耦合是在观察者接口中的注册方法。可以在主题中实现一个数组，用于保存观察者，在主题有变化时遍历数组中的观察者，实现通知。

# 应用

观察者模式在JavaBeans、Swing和RMI中都实现了观察者模式。