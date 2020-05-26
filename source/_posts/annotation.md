---
title: reflect
date: 2020-05-27 00:31:17
categories: Java
tags: annatation, reflect
---

Introduction of Java annotation

<!-- more -->

# Reflection

在程序执行期间可以通过Reflection API取得任何类的内部信息，并能直接操作任意对象的内部属性及方法。

Normal: class -> new -> object

Reflect: object -> getClass() -> class

## 动态语言

在运行时代码可以根据某些条件改变自身结构。

i.e. Object-C, C#, JavaScrit, PHP, Pthon and etc.

### 静态语言

i.e. Java, C, C++

- Java也有一定的动态性，利用反射机制获得相关特性。

## Class

Java反射的源头，通过对象反射求出类的名字。

在Object类中定义了一个方法，自然而然会被所有子类继承：

> public final Class getClass()

## META_ANNOTATION

- **@Target** 用于描述注解的使用范围
- **@Retention** 表示需要在什么级别保存该注解信息，描述注解的生命周期（Source<CLASS<**RUNTIME**)，一般默认RUNTIME。
- @Document 说明注解将被包含在JAVADOC中
- @Inherited 说明子类可以继承父类的该注解

```java
@Target({ElementTYpe.TYPE,ELementType.METHOD})
@Retention(RetentionPolicy.RUNTIME)
public @interface MyAnnotation(){
    String name() default "";
}
```

