---
title: springmvc-argument
date: 2021-04-07 12:20:01
categories: springmvc
tags: source
---

这一篇承接上面的handlerMapping，在通过request获取到handlerExecutionChain和handler之后的处理操作，实际上不同的handlerMapping映射出来的东西是不一样的，adapter在这里的作用是用handler得到对应的视图方法。

<!-- more -->

<!-- toc -->

# HandlerAdapter

```java
public interface HandlerAdapter {

    // 判断是否支持该handler
    boolean supports(Object handler);

    // 通过handler返回modelAndView
    @Nullable
    ModelAndView handle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception;

    long getLastModified(HttpServletRequest request, Object handler);

}
```

我们可以看到该接口的一个方法*handle*就是通过handler返回对应的modelAndView。那么这个接口及实现类是何时加载的呢？记得在第一篇有分析过实例化时的准备工作吗，那里有一些模板方法，其中就有关于初始化这个handlerAdapter的：

```java
protected void initStrategies(ApplicationContext context) {
    initMultipartResolver(context);
    initLocaleResolver(context);
    initThemeResolver(context);
    initHandlerMappings(context);
    // 初始化handlerAdapter
    initHandlerAdapters(context);
    initHandlerExceptionResolvers(context);
    initRequestToViewNameTranslator(context);
    initViewResolvers(context);
    initFlashMapManager(context);
}
```

```java
private void initHandlerAdapters(ApplicationContext context) {
    this.handlerAdapters = null;

    if (this.detectAllHandlerAdapters) {
        // Find all HandlerAdapters in the ApplicationContext, including ancestor contexts.
        Map<String, HandlerAdapter> matchingBeans =
            BeanFactoryUtils.beansOfTypeIncludingAncestors(context, HandlerAdapter.class, true, false);
        if (!matchingBeans.isEmpty()) {
            this.handlerAdapters = new ArrayList<>(matchingBeans.values());
            // We keep HandlerAdapters in sorted order.
            AnnotationAwareOrderComparator.sort(this.handlerAdapters);
        }
    }
    else {
        try {
            HandlerAdapter ha = context.getBean(HANDLER_ADAPTER_BEAN_NAME, HandlerAdapter.class);
            this.handlerAdapters = Collections.singletonList(ha);
        }
        catch (NoSuchBeanDefinitionException ex) {
            // Ignore, we'll add a default HandlerAdapter later.
        }
    }

    // Ensure we have at least some HandlerAdapters, by registering
    // default HandlerAdapters if no other adapters are found.
    if (this.handlerAdapters == null) {
        this.handlerAdapters = getDefaultStrategies(context, HandlerAdapter.class);
        if (logger.isTraceEnabled()) {
            logger.trace("No HandlerAdapters declared for servlet '" + getServletName() +
                         "': using default strategies from DispatcherServlet.properties");
        }
    }
}
```

## 实现类

handlerAdapter有几个简单的实现类可以看下：

```java
// 这是默认的实现方式
public class SimpleControllerHandlerAdapter implements HandlerAdapter {

    @Override
    public boolean supports(Object handler) {
        return (handler instanceof Controller);
    }

    @Override
    @Nullable
    public ModelAndView handle(HttpServletRequest request, HttpServletResponse response, Object handler)
        throws Exception {

        // 会调用controller的handlerRequest
        return ((Controller) handler).handleRequest(request, response);
    }
}
```

```java
public class SimpleServletHandlerAdapter implements HandlerAdapter {

    @Override
    public boolean supports(Object handler) {
        return (handler instanceof Servlet);
    }

    @Override
    @Nullable
    public ModelAndView handle(HttpServletRequest request, HttpServletResponse response, Object handler)
        throws Exception {

        ((Servlet) handler).service(request, response);
        return null;
    }
}
```

他的实现类大都像上面的一样支持某种类型的handler，但我们最常用的是`RequestMappingHandlerAdapter`，他是专门用来处理标记了*@RequestMapping*注解的HandlerMethod。

# 参数处理

之前有提到dispatcherServlet中，通过*doDispatch*来处理请求，里面通过reqeust获取到对应的adapter并且调用adapter里面的方法来处理：

```java
// Determine handler adapter for the current request.
HandlerAdapter ha = getHandlerAdapter(mappedHandler.getHandler());
// Actually invoke the handler.
mv = ha.handle(processedRequest, response, mappedHandler.getHandler());
```

*handle*方法是接口HandlerAdapter的抽象实现类中的**final**方法:

```java
public final ModelAndView handle(HttpServletRequest request, HttpServletResponse response, Object handler)
    throws Exception {
    // 交由子类实现，也就是RequestMappingHandlerAdapter
    return handleInternal(request, response, (HandlerMethod) handler);
}
```

最终处理的是invokeHandlerMethod，在这里会为equest创建一个`ServletInvocableHandlerMethod`，也就是说，对于向后端请求服务的request，实际处理的是用`ServletInvocableHandlerMethod`将request包裹之后的，在配置过一些属性后会将它作为入参，继续执行*invokeAndHandle*方法。

## invokeAndHandle

```java
// 处理请求与返回
public void invokeAndHandle(ServletWebRequest webRequest, ModelAndViewContainer mavContainer,
                            Object... providedArgs) throws Exception {

    // 请求
    Object returnValue = invokeForRequest(webRequest, mavContainer, providedArgs);
    setResponseStatus(webRequest);

    if (returnValue == null) {
        if (isRequestNotModified(webRequest) || getResponseStatus() != null || mavContainer.isRequestHandled()) {
            disableContentCachingIfNecessary(webRequest);
            mavContainer.setRequestHandled(true);
            return;
        }
    }
    else if (StringUtils.hasText(getResponseStatusReason())) {
        mavContainer.setRequestHandled(true);
        return;
    }

    mavContainer.setRequestHandled(false);
    Assert.state(this.returnValueHandlers != null, "No return value handlers");
    try {
        // 返回
        this.returnValueHandlers.handleReturnValue(
            returnValue, getReturnValueType(returnValue), mavContainer, webRequest);
    }
    catch (Exception ex) {
        if (logger.isTraceEnabled()) {
            logger.trace(formatErrorForReturnValue(returnValue), ex);
        }
        throw ex;
    }
}
```

# 小结

简而言之，请求（handlerMethod）由特定的adapter处理，比如*RequestMappingHandlerAdapter*，他会继续被封装成*ServletInvocableHandlerMethod*，Adapter的作用就是