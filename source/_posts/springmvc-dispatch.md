---
title: springmvc-dispatch
date: 2021-04-06 16:35:27
categories: springmvc
tags: dispatch
---

​        如何匹配controller，根据我们的使用以及对spring容器的理解，我可以猜测是通过反射获取注解，进而分类的，那springmvc是对他如何封装的呢？在springboot中又是如何融入springmvc，何时做的那些工作呢？

<!-- more -->

<!-- toc -->

# AbstractHandlerMappingMethod

​        这个类继承了`AbstractHandlerMapping`并且实现了接口`InitializingBean`（任何bean在初始化时都会执行他的方法，接口中只有一个方法*afterPropertiesSet()*）。那这个类是做什么的呢？首先他是一个抽象类，一定会有更具体的类来实现它，其次，又是因为他是抽象类，所以内部一定定义了不用子类重复实现的公公流程，指明了大方向，结合web环境来说，**他定义了每个请求与`HandlerMethod`之间的映射关系**。

下面我们从他实现的接口开始看，因为那时这个类刚刚实例化，我们看看他作为bean都做了哪些工作：

```java
@Override
public void afterPropertiesSet() {
    initHandlerMethods();
}

/**
 * Scan beans in the ApplicationContext, detect and register handler methods.
 * @see #getCandidateBeanNames()
 * @see #processCandidateBean
 * @see #handlerMethodsInitialized
 */
protected void initHandlerMethods() {
    for (String beanName : getCandidateBeanNames()) {
        if (!beanName.startsWith(SCOPED_TARGET_NAME_PREFIX)) {
            processCandidateBean(beanName);
        }
    }
    handlerMethodsInitialized(getHandlerMethods());
}
```

从上面的注解可以看出，他会从上下文中扫描所有的bean并检测他是否是*handler method*。

```java
protected void processCandidateBean(String beanName) {
   Class<?> beanType = null;
   try {
      beanType = obtainApplicationContext().getType(beanName);
   }
   catch (Throwable ex) {
      // An unresolvable bean type, probably from a lazy bean - let's ignore it.
      if (logger.isTraceEnabled()) {
         logger.trace("Could not resolve type for bean '" + beanName + "'", ex);
      }
   }
    // 判断是否是handler的bean
   if (beanType != null && isHandler(beanType)) {
       // 检测他的hadnler方法
      detectHandlerMethods(beanName);
   }
}

/**
 * Look for handler methods in the specified handler bean.
 * @param handler either a bean name or an actual handler instance
 * @see #getMappingForMethod
 */
protected void detectHandlerMethods(Object handler) {
   Class<?> handlerType = (handler instanceof String ?
         obtainApplicationContext().getType((String) handler) : handler.getClass());

   if (handlerType != null) {
      Class<?> userType = ClassUtils.getUserClass(handlerType);
       // Method:ReqeustMappingInfo, 方法的第二个参数通过lambda传入
      Map<Method, T> methods = MethodIntrospector.selectMethods(userType,
            (MethodIntrospector.MetadataLookup<T>) method -> {
               try {
                   // 这里返回的类型是RequestMappingInfo，为方法创建mapping对象
                  return getMappingForMethod(method, userType);
               }
               catch (Throwable ex) {
                  throw new IllegalStateException("Invalid mapping on handler class [" +
                        userType.getName() + "]: " + method, ex);
               }
            });
      if (logger.isTraceEnabled()) {
         logger.trace(formatMappings(userType, methods));
      }
      methods.forEach((method, mapping) -> {
         Method invocableMethod = AopUtils.selectInvocableMethod(method, userType);
          // 注册methods
         registerHandlerMethod(handler, invocableMethod, mapping);
      });
   }
}
```

```java
@Override
protected boolean isHandler(Class<?> beanType) {
    // 判断是否是handler的条件：是否有@Controller的注解或者@RequestMapping的注解
   return (AnnotatedElementUtils.hasAnnotation(beanType, Controller.class) ||
         AnnotatedElementUtils.hasAnnotation(beanType, RequestMapping.class));
}
```

> 这里也验证了一开始的猜测，通过注解来过滤我们需要的bean

# HandlerMapping

这是一个接口，为每个请求与处理做映射关系，里面有很多属性，有一个方法*getHandler(HttpServletRequest request)*，返回的是`HandlerExecutionChain`，所以说这也体现了拿servlet处理web的设计理念：如何做到通过reqeust找到我们要处理的方法，通过url中的参数来找我们写的controller，具体id细节就放在这个接口中来实现，返回的是一个处理链，然后怎么做呢，将这个处理链加到总的链中。

```java
public final HandlerExecutionChain getHandler(HttpServletRequest request) throws Exception {
    // 这是一个抽象方法，由子类实现，通过request返回handler
    Object handler = getHandlerInternal(request);
    if (handler == null) {
        handler = getDefaultHandler();
    }
    if (handler == null) {
        return null;
    }
    // Bean name or resolved handler?
    if (handler instanceof String) {
        String handlerName = (String) handler;
        handler = obtainApplicationContext().getBean(handlerName);
    }

    // 再通过handler与request新建chain
    HandlerExecutionChain executionChain = getHandlerExecutionChain(handler, request);

    if (logger.isTraceEnabled()) {
        logger.trace("Mapped to " + handler);
    }
    else if (logger.isDebugEnabled() && !request.getDispatcherType().equals(DispatcherType.ASYNC)) {
        logger.debug("Mapped to " + executionChain.getHandler());
    }

    if (hasCorsConfigurationSource(handler) || CorsUtils.isPreFlightRequest(request)) {
        CorsConfiguration config = (this.corsConfigurationSource != null ? this.corsConfigurationSource.getCorsConfiguration(request) : null);
        CorsConfiguration handlerConfig = getCorsConfiguration(handler, request);
        config = (config != null ? config.combine(handlerConfig) : handlerConfig);
        executionChain = getCorsHandlerExecutionChain(request, executionChain, config);
    }

    return executionChain;
}
```

```java
protected HandlerExecutionChain getHandlerExecutionChain(Object handler, HttpServletRequest request) {
    HandlerExecutionChain chain = (handler instanceof HandlerExecutionChain ?
                                   (HandlerExecutionChain) handler : new HandlerExecutionChain(handler));

    String lookupPath = this.urlPathHelper.getLookupPathForRequest(request, LOOKUP_PATH);
    for (HandlerInterceptor interceptor : this.adaptedInterceptors) {
        if (interceptor instanceof MappedInterceptor) {
            MappedInterceptor mappedInterceptor = (MappedInterceptor) interceptor;
            if (mappedInterceptor.matches(lookupPath, this.pathMatcher)) {
                // 加拦截器
                chain.addInterceptor(mappedInterceptor.getInterceptor());
            }
        }
        else {
            chain.addInterceptor(interceptor);
        }
    }
    return chain;
}
```

# 小结

​        这里再提一下springmvc的处理流程，首先到DispatcherServlet，他通过handlerMapping获得HandlerExecutionChain，然后获得HandlerAdapter，HandlerAdapter在内部对于每个请求都会实例化一个ServletInvocableHandlerMethod进行处理，ServletInvocableHandlerMethod在进行处理的时候会对请求和响应分别处理。下一篇我们分析他的参数处理，关于adapter和handlerMethod。