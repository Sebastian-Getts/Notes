---
title: springAOP
date: 2020-03-28 14:43:58
categories: Spring
tags: aop
---

AOP, 切面。聊聊几个通知。

<!--more-->

# 用途

如果是吃个蛋糕，会怎么吃？有的人会一层一层吃，当然最上面是奶油或者水果，最下方是面包，但是大部分人都不会这么吃，会用刀将蛋糕切开，将糅合了多层的可口蛋糕一起送入口中，而非第一种吃法那样有先后顺序。Spring框架中的AOP的用途就好比那把刀，将容器中的bean有个安排。

# 通知

AOP中的刀不像是切蛋糕那样最终把蛋糕送入口中，它的实际工序会更多。比如送入口中可能是最后一步，在这之前也许会统一撒点肉松、统一加热之类的。虽然有点奇怪。

Spring的命名是让人通俗易懂的，也可以理解为你的英语水平够用。诸如*@Before*, *@After*...之类的一眼扫过去就能知道它的作用。目前用到的有5个：@Before, @After, @AfterReturning, @AfterThrowing和@Around。他们都不是直接标注就可以使用，而是**需要指要作用的方法**。

由于作用的目标方法大多相同，因此还可以提取公共的路径。

与之相关的要先介绍`JointPoint`，根据词意不难理解：切点。切面中的切点可以说是很细节的了，能用他来获取切面相关的信息，可以理解为“帮手”。

## @PointCut

公用切入点。括号后加入作用路径。

```java
@Pointcut("execution(public int org.example.aop.MathCalculate.*(..)) ")
public void pointCut() {
}
```

MathCalculate为类名，`MathCalculate.*`表示作用于类下的所有方法。`(..)`表示任意参数。



## @Before

这个是前置通知。表示在方法执行前执行标识了这个注解的方法。

```java
@Before("pointCut()")
public void logStart(JoinPoint joinPoint) {
    System.out.println(joinPoint.getSignature().getName() + "，logStart()..方法名：" + "....参数：" + Arrays.asList(joinPoint.getArgs()));
}
```



## @After

后置通知。方法结束后会被调用，**无论方法成功还是失败**，类似于`finally`。

```java
@After("pointCut()")
public void logEnd(JoinPoint joinPoint) {
    System.out.println(joinPoint.getSignature().getName() + "，@After.方法名：" + ". 一定会返回的。.参数：" + Arrays.asList(joinPoint.getArgs()));
}
```



## @AfterReturning

返回通知。在方法正常结束时用。因为是正常结束，一般都需要知道返回的结果，所以入参相比之前的就多了一个。

```java
@AfterReturning(value = "pointCut()", returning = "object")
public void logReturn(JoinPoint joinPoint, Object object) {
    System.out.println(joinPoint.getSignature().getName() + "，@AfterReturning..正常返回。.运行结果：" + object);
}
```



## @AfterThrowing

异常通知。抛出异常的时候用。抛出的异常也是对象，需要告诉Spring，所以这也算一个入参。

```java
@AfterThrowing(value = "pointCut()", throwing = "exception")
public void logException(JoinPoint joinPoint, Exception exception) {
    System.out.println(" 方法名：" + joinPoint.getSignature().getName() + ".....异常信息：" + exception);
}
```



## @Around

环绕通知。听这个名字有没有觉得很仙气，很厉害的样子。的确厉害，一个顶四个。。

他的“帮手”也不再是JointPoint了，而是升级版的：`ProceedingJoinPoint`。

```java
@Around(value = "pointCut()")
public Object logAround(ProceedingJoinPoint proceedingJoinPoint) {
    Object result;
    try {
        result = proceedingJoinPoint.proceed();
        System.out.println(proceedingJoinPoint.getSignature().getName() + "，Around ..方法名：" + "....参数：" + Arrays.asList(proceedingJoinPoint.getArgs()));

        System.out.println(proceedingJoinPoint.getSignature().getName() + "，Around..正常返回。.运行结果：" + result);
    } catch (Throwable throwable) {
        System.out.println(" 方法名：" + proceedingJoinPoint.getSignature().getName() + "....Around  .异常信息：" + throwable);
        throw new RuntimeException(throwable);
    }
    System.out.println(proceedingJoinPoint.getSignature().getName() + "，Around.方法名：" + ". 一定会返回的。.参数：" + Arrays.asList(proceedingJoinPoint.getArgs()));
    return result;
}
```

## 注意事项

如果认为标注注解就能生效就  *too young to navie* 了。

- 将业务逻辑代码以及切面类（例如日志打印服务）都加入到容器中，并且告诉Spring哪个是切面类（在类上加**@Aspect**）
- 在切面类上的要用的通知方法上加入相应注解（如@Before）。
- 在配置类上开启注解的aop模式（ **@EnableAspectJAutoProxy**）。

# 源码