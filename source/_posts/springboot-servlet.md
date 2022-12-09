---
title: Springboot-servlet
date: 2021-02-28 22:01:17
categories: springboot
tags: servlet
---

这篇探究SpringBoot的内置servlet容器。

<!-- more -->

<!-- toc -->

自打接触java web项目以来，使用的绝大多数情况都是内置的tomcat，还没好好整tomcat，他就被内置了。这篇看看他是如何被放入springboot并启动的。

# 入口

之前有分析过springBoot的refresh方法，里面又有十几个方法，其中有一个名叫`onRefresh()`的方法，用到了**模板方法**，让子类复写来完成特定工作的，之前也提到过，在类`SpringApplication`初始化时就会根据class文件判断程序的类型，现在我们假设引入了web环境，那么这个方法就会被`ServletWebServerApplicationContext`重写：

```java
@Override
protected void onRefresh() {
    super.onRefresh();
    try {
        // 创建web服务器！
        createWebServer();
    }
    catch (Throwable ex) {
        throw new ApplicationContextException("Unable to start web server", ex);
    }
}
```

# 创建服务

入口找到后，接下来我们分析他是如何创建的：

```java
private void createWebServer() {
    // volatile标志的引用
    WebServer webServer = this.webServer;
    // 从抽象类（父类）中获取servlet容器
    ServletContext servletContext = getServletContext();
    // 判断获取到的容器是否为null
    if (webServer == null && servletContext == null) {
        // 为null就从web服务器工厂建一个
        ServletWebServerFactory factory = getWebServerFactory();
        // 从这里获取到web服务器！入参还有初始化器！
        this.webServer = factory.getWebServer(getSelfInitializer());
        getBeanFactory().registerSingleton("webServerGracefulShutdown",
                                           new WebServerGracefulShutdownLifecycle(this.webServer));
        getBeanFactory().registerSingleton("webServerStartStop",
                                           new WebServerStartStopLifecycle(this, this.webServer));
    }
    // 不为null就启动它
    else if (servletContext != null) {
        try {
            getSelfInitializer().onStartup(servletContext);
        }
        catch (ServletException ex) {
            throw new ApplicationContextException("Cannot initialize servlet context", ex);
        }
    }
    initPropertySources();
}
```

## getWebServerFactory

工厂哪里来？回顾之前的就可以猜到，SPI！

```java
protected ServletWebServerFactory getWebServerFactory() {
    // Use bean names so that we don't consider the hierarchy
    String[] beanNames = getBeanFactory().getBeanNamesForType(ServletWebServerFactory.class);
    if (beanNames.length == 0) {
        throw new ApplicationContextException("Unable to start ServletWebServerApplicationContext due to missing "
                                              + "ServletWebServerFactory bean.");
    }
    if (beanNames.length > 1) {
        throw new ApplicationContextException("Unable to start ServletWebServerApplicationContext due to multiple "
                                              + "ServletWebServerFactory beans : " + StringUtils.arrayToCommaDelimitedString(beanNames));
    }
    return getBeanFactory().getBean(beanNames[0], ServletWebServerFactory.class);
}
```

## getSelfInitializer

看看如何获取到初始化器：

```java
private org.springframework.boot.web.servlet.ServletContextInitializer getSelfInitializer() {
    return this::selfInitialize;
}
```

这里会获取到初始化器，这些初始化器就相当与一个个的配置，只是目前没有去配置那个容器对象，在等一个触发的时机。

# getWebServer

```java
public WebServer getWebServer(ServletContextInitializer... initializers) {
    if (this.disableMBeanRegistry) {
        Registry.disableRegistry();
    }
    // 创建tomcat实例
    Tomcat tomcat = new Tomcat();
    File baseDir = (this.baseDirectory != null) ? this.baseDirectory : createTempDir("tomcat");
    // 设置属性
    tomcat.setBaseDir(baseDir.getAbsolutePath());
    Connector connector = new Connector(this.protocol);
    connector.setThrowOnFailure(true);
    tomcat.getService().addConnector(connector);
    customizeConnector(connector);
    tomcat.setConnector(connector);
    tomcat.getHost().setAutoDeploy(false);
    configureEngine(tomcat.getEngine());
    for (Connector additionalConnector : this.additionalTomcatConnectors) {
        tomcat.getService().addConnector(additionalConnector);
    }
    // 准备
    prepareContext(tomcat.getHost(), initializers);
    // 获取
    return getTomcatWebServer(tomcat);
}
```

我们主要来看如何获取tomcat的，这里入参传入了tomcat的一个引用:

```java
protected TomcatWebServer getTomcatWebServer(Tomcat tomcat) {
    // 继续调用有有参方法
    return new TomcatWebServer(tomcat, getPort() >= 0, getShutdown());
}
```

```java
public TomcatWebServer(Tomcat tomcat, boolean autoStart, Shutdown shutdown) {
    Assert.notNull(tomcat, "Tomcat Server must not be null");
    this.tomcat = tomcat;
    this.autoStart = autoStart;
    this.gracefulShutdown = (shutdown == Shutdown.GRACEFUL) ? new GracefulShutdown(tomcat) : null;
    // 初始化
    initialize();
}

private void initialize() throws WebServerException {
    logger.info("Tomcat initialized with port(s): " + getPortsDescription(false));
    synchronized (this.monitor) {
        try {
            addInstanceIdToEngineName();

            Context context = findContext();
            context.addLifecycleListener((event) -> {
                if (context.equals(event.getSource()) && Lifecycle.START_EVENT.equals(event.getType())) {
                    // Remove service connectors so that protocol binding doesn't
                    // happen when the service is started.
                    removeServiceConnectors();
                }
            });

            // Start the server to trigger initialization listeners
            this.tomcat.start();

            // We can re-throw failure exception directly in the main thread
            rethrowDeferredStartupExceptions();

            try {
                ContextBindings.bindClassLoader(context, context.getNamingToken(), getClass().getClassLoader());
            }
            catch (NamingException ex) {
                // Naming is not enabled. Continue
            }

            // Unlike Jetty, all Tomcat threads are daemon threads. We create a
            // blocking non-daemon to stop immediate shutdown
            startDaemonAwaitThread();
        }
        catch (Exception ex) {
            stopSilently();
            destroySilently();
            throw new WebServerException("Unable to start embedded Tomcat", ex);
        }
    }
}
```

在上面的初始化的方法中，我们找到了启动的地方。