---
title: springmvc-dispatcherservlet
date: 2021-04-06 13:59:49
categories: springmvc
tags: dispatcherservlet
---

这是剖析springmvc的第一篇，剖析前他的原理已经猜的差不多了， 看源码是为了做一个验证，因为他也是依托于spring的，离不开ioc，所以一部分的原理已经清楚了， 剩下的是核心类`DispatcherServlet`以及为springboot适配而做的工作。

<!-- more -->

<!-- toc -->

# HttpServletBean

```properties
-- HttpServlet
    -- HttpServletBean
        -- FrameworkServlet
            -- DispatcherServlet
```

`HttpServlet`我们都知道，是javax提供的类，对所有的http请求做了封装，也是对每个servlet类的具体实现，在springmvc中为了将这个类融入到框架中，首先将他视作bean，添加了一些属性、实现了两个接口：`EnvironmentCapable`和`EnvironmentAware`，这两个接口的作用可通过名称或方法名来看（正符合spring的规范的设计）：

```java
public interface EnvironmentCapable{
    Environment getEnvironment();
}

public interface EnvironmentAware extends Aware{
    void setEnvironment(Environment environment);
```

除此之外，`HttpServletBean`重写了*init()*方法：

```java
public final void init() throws ServletException {

   // Set bean properties from init parameters.
   PropertyValues pvs = new ServletConfigPropertyValues(getServletConfig(), this.requiredProperties);
   if (!pvs.isEmpty()) {
      try {
          // 使用beanWrapper构造servletBean
         BeanWrapper bw = PropertyAccessorFactory.forBeanPropertyAccess(this);
         ResourceLoader resourceLoader = new ServletContextResourceLoader(getServletContext());
         bw.registerCustomEditor(Resource.class, new ResourceEditor(resourceLoader, getEnvironment()));
         initBeanWrapper(bw);
         bw.setPropertyValues(pvs, true);
      }
      catch (BeansException ex) {
         if (logger.isErrorEnabled()) {
            logger.error("Failed to set bean properties on servlet '" + getServletName() + "'", ex);
         }
         throw ex;
      }
   }

    // 子类方法重写，也就是初始化时可以做更多的事情
   // Let subclasses do whatever initialization they like.
   initServletBean();
}
```

# FrameworkServlet

这是一个抽象类，但他把控了大方向，正如他的名字一样，充分适配了spring上下文，具体体现在两个方面：

- 每个servlet都管理着web上下文实例
- 事件推送机制

了解上面之前我们还是先顺着`HttpServletBean`中提到的扩展初始化的机制——留给子类复写的方法*initServletBean()*，看看在这里他是如何实现的：

```java
protected final void initServletBean() throws ServletException {
    // log...
   try {
       // 初始化WebApplicationContext，如果不存在的话会先创建
      this.webApplicationContext = initWebApplicationContext();
       // 留给子类重写
      initFrameworkServlet();
   }
   catch (ServletException | RuntimeException ex) {
      logger.error("Context initialization failed", ex);
      throw ex;
   }
   // log...
}
```

```java
protected WebApplicationContext initWebApplicationContext() {
   WebApplicationContext rootContext =
         WebApplicationContextUtils.getWebApplicationContext(getServletContext());
   WebApplicationContext wac = null;

   if (this.webApplicationContext != null) {
      // A context instance was injected at construction time -> use it
      wac = this.webApplicationContext;
      if (wac instanceof ConfigurableWebApplicationContext) {
         ConfigurableWebApplicationContext cwac = (ConfigurableWebApplicationContext) wac;
         if (!cwac.isActive()) {
            // The context has not yet been refreshed -> provide services such as
            // setting the parent context, setting the application context id, etc
            if (cwac.getParent() == null) {
               // The context instance was injected without an explicit parent -> set
               // the root application context (if any; may be null) as the parent
               cwac.setParent(rootContext);
            }
            configureAndRefreshWebApplicationContext(cwac);
         }
      }
   }
   if (wac == null) {
      // No context instance was injected at construction time -> see if one
      // has been registered in the servlet context. If one exists, it is assumed
      // that the parent context (if any) has already been set and that the
      // user has performed any initialization such as setting the context id
      wac = findWebApplicationContext();
   }
   if (wac == null) {
      // No context instance is defined for this servlet -> create a local one
      wac = createWebApplicationContext(rootContext);
   }

   if (!this.refreshEventReceived) {
      // Either the context is not a ConfigurableApplicationContext with refresh
      // support or the context injected at construction time had already been
      // refreshed -> trigger initial onRefresh manually here.
      synchronized (this.onRefreshMonitor) {
         // 留给子类实现
         onRefresh(wac);
      }
   }

   if (this.publishContext) {
      // Publish the context as a servlet context attribute.
      String attrName = getServletContextAttributeName();
      getServletContext().setAttribute(attrName, wac);
   }

   return wac;
}
```

初始化webApplicationContext时主要做两件事：

- 关联servlet与容器，做法是设置父上下文
- 推送事件

# DispatcherServlet

我们顺着上面留给子类重写的方法看起，这个类中并没有重写`initFrameworkdServlet()`，但是重写了`onRefresh()`方法：

```java
    @Override
    protected void onRefresh(ApplicationContext context) {
        initStrategies(context);
    }

    /**
     * Initialize the strategy objects that this servlet uses.
     * <p>May be overridden in subclasses in order to initialize further strategy objects.
     */
    protected void initStrategies(ApplicationContext context) {
        initMultipartResolver(context);
        initLocaleResolver(context);
        initThemeResolver(context);
        initHandlerMappings(context);
        initHandlerAdapters(context);
        initHandlerExceptionResolvers(context);
        initRequestToViewNameTranslator(context);
        initViewResolvers(context);
        initFlashMapManager(context);
    }
```

也就是说，在初始化阶段会做这么多事情，主要是集中在了这里，包括我们熟悉的*HandlerMapping*请求映射处理和异常处理*HandlerExceptionResolvers*等，做的是更具体的功能的实现。

所以说，`HttpServletBean`也是继承了`HttpServlet`的，他做的是完成Bean所需要的工作，如配置环境属性；`FrameworkServlet`扩展了父类初始化时能做的事情，并且更加适配了spring上下文：有了上下文属性和事件推送；在这个类中，他做的事情更加具体了。

## 分发请求

上面提到`HttpSrevlet`对每个请求做了分装，细分了不同种类的请求，如POST、GET等，他的子类`HttpServletBean`是对bean的一种适配，业务规则没有做什么改变，而`FrameworkServlet`重写了*service()*方法：

```java
protected void service(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {

   HttpMethod httpMethod = HttpMethod.resolve(request.getMethod());
    // 判断方法是否是PATHCH或null
   if (httpMethod == HttpMethod.PATCH || httpMethod == null) {
      processRequest(request, response);
   }
   else {
      super.service(request, response);
   }
}
```

```java
protected final void processRequest(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {

    long startTime = System.currentTimeMillis();
    Throwable failureCause = null;

    // 这部分是国际化的处理
    LocaleContext previousLocaleContext = LocaleContextHolder.getLocaleContext();
    LocaleContext localeContext = buildLocaleContext(request);

    RequestAttributes previousAttributes = RequestContextHolder.getRequestAttributes();
    ServletRequestAttributes requestAttributes = buildRequestAttributes(request, response, previousAttributes);

    WebAsyncManager asyncManager = WebAsyncUtils.getAsyncManager(request);
    asyncManager.registerCallableInterceptor(FrameworkServlet.class.getName(), new RequestBindingInterceptor());

    initContextHolders(request, localeContext, requestAttributes);

    try {
        // 留给子类实现，即Dispatcherservlet
        doService(request, response);
    }
    catch (ServletException | IOException ex) {
        failureCause = ex;
        throw ex;
    }
    catch (Throwable ex) {
        failureCause = ex;
        throw new NestedServletException("Request processing failed", ex);
    }

    finally {
        resetContextHolders(request, previousLocaleContext, previousAttributes);
        if (requestAttributes != null) {
            requestAttributes.requestCompleted();
        }
        logResult(request, response, failureCause, asyncManager);
        publishRequestHandledEvent(request, response, startTime, failureCause);
    }
}
```

```java
protected void doService(HttpServletRequest request, HttpServletResponse response) throws Exception {
    logRequest(request);

    // Keep a snapshot of the request attributes in case of an include,
    // to be able to restore the original attributes after the include.
    Map<String, Object> attributesSnapshot = null;
    // 如果是include请求，特殊处理
    if (WebUtils.isIncludeRequest(request)) {
        attributesSnapshot = new HashMap<>();
        Enumeration<?> attrNames = request.getAttributeNames();
        while (attrNames.hasMoreElements()) {
            String attrName = (String) attrNames.nextElement();
            if (this.cleanupAfterInclude || attrName.startsWith(DEFAULT_STRATEGIES_PREFIX)) {
                attributesSnapshot.put(attrName, request.getAttribute(attrName));
            }
        }
    }

    // Make framework objects available to handlers and view objects.
    request.setAttribute(WEB_APPLICATION_CONTEXT_ATTRIBUTE, getWebApplicationContext());
    request.setAttribute(LOCALE_RESOLVER_ATTRIBUTE, this.localeResolver);
    request.setAttribute(THEME_RESOLVER_ATTRIBUTE, this.themeResolver);
    request.setAttribute(THEME_SOURCE_ATTRIBUTE, getThemeSource());

    if (this.flashMapManager != null) {
        FlashMap inputFlashMap = this.flashMapManager.retrieveAndUpdate(request, response);
        if (inputFlashMap != null) {
            request.setAttribute(INPUT_FLASH_MAP_ATTRIBUTE, Collections.unmodifiableMap(inputFlashMap));
        }
        request.setAttribute(OUTPUT_FLASH_MAP_ATTRIBUTE, new FlashMap());
        request.setAttribute(FLASH_MAP_MANAGER_ATTRIBUTE, this.flashMapManager);
    }

    try {
        // 其他请求在这里处理
        doDispatch(request, response);
    }
    finally {
        if (!WebAsyncUtils.getAsyncManager(request).isConcurrentHandlingStarted()) {
            // Restore the original attribute snapshot, in case of an include.
            if (attributesSnapshot != null) {
                restoreAttributesAfterInclude(request, attributesSnapshot);
            }
        }
    }
}
```

我们可以看到，在最初的`FrameworkServlet`中进入到`DispatcherServlet`中是有条件的，如果不是PATCH或null的方法就进入不了了吗？并不是，看到上面的流程，他会先去执行父类的方法，然后同样会回到`DispatcherServlet`中的*doDispatcherf()*中，更准确的说是*processRequest()*中，在process之后会紧接着发布事件，`FrameworkServlet`是针对父类有了较大的业务修改的，重写了很多方法，其中就包括各种*doPost()*、*doGet()*……这些，按照上面的流程，执行父类的请求，就会回到`FrameworkServlet`类中，而不是`HttpServlet`：

```java
protected final void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {

    processRequest(request, response);
}

/**
 * Delegate POST requests to {@link #processRequest}.
 * @see #doService
 */
@Override
protected final void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {

    processRequest(request, response);
```

# 小结

以上是这篇的内容，主要介绍要了DispatcherServlet及其父类之间的关系，在融合进spring框架时各自的侧重点。关于请求时如何准确找到对应的controller（也就是没有展开将的*doDispatch(request, response)*方法）将在后面继续分析。