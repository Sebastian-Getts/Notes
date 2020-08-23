---
title: reflect
date: 2020-05-27 00:31:17
categories: Java
tags: annatation, reflect
---

java反射，lang包下的relect包中存放了关于反射相关的实现，通过反射java可以在运行时完成一些动作（如获取值）。反射是框架的基础，平时用的原生注解、自定义注解、以及代理，都离不开反射。

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

以上是自定义注解的基本格式，内部的参数如`name`则是在使用注解时填写的，`default`表明了他的默认值，同时也说明这个参数是选填的。例如使用时如下：

```java
@MyAnnotation(name = "Gloria")
public class TestAnnotation(){
    
    @MyAnnotation(name = "Manny")
	public void beLucky(){
        // do something
    }    
}
```

此外，在框架中使用了注解，一般都是会去处理（当然，谁也不会定义一个毫无用处的注解），我们自定义注解也是一样，通常会与**切面**结合使用。为什么呢？因为注解的出现是为了方便开发，减少代码量（尤其是配置），所以我们会去集中处理标记了某个注解的方法，通过切面我们可以定义标注了某个注解的方法/类来处理他们。

## 原理

用途三三两两就讲完了，其实很多，可以参考源码。下面说说他的实现原理。

我们都知道，反射离不开`Class`，那么他是怎么出现的呢？JVM！这得从类加载开始说起，当java代码编译完后成了字节码文件（xx.class）时jvm就可以加载它啦，通过类加载器，他就成为了Class对象，他的相关结构信息会被保存在方法区。被创建出来的对象存在于堆中，通过反射，可以从对象获取到他的结构信息，有点像通过儿子爸爸很像，通过儿子推理出爸爸的样子。具体什么结构信息呢？加载在方法上、类上的注解。当然更详细的等我看完JVM的书！