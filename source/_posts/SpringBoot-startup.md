---
title: SpringBoot startup
date: 2021-02-15 13:18:14
categories: springboot
tags: source
---

出个系列总结一下SpringBoot，会偏底层一些。这篇主要介绍SpringBoot的大致启动过程，细节会在稍后文章中讲解。

<!--more-->

​		使用SpringBoot会让人感到清爽，没有那么多的配置文件。笔者曾参与过Spring和Struts2的项目，虽然时间不长，但仍感受到了配置文件的复杂，难以维护。后来使用SpringBoot做web应用，只需一个程序入口main方法，启动后便能使用，无形中它帮助我们配置了一切，如果想修改，这一切也可以在properties/yml中修改。从软件工程学的角度来看，Spring是非常成功的产品，SpringBoot则更贴近用户，“约定大于配置。并不是很神奇的不用配置，而是在启动时帮助我们配置好了，除了自动配置，我们还会看看他的IOC、AOP的实现，包括常用的web服务器也内嵌在里面，所以接下来几篇我们会一探究竟。

<!--toc-->

# 启动

```java
@SpringBootApplication
public class MyApplication {
    public static void main(String[] args) {
        SpringApplication.run(MyApplication.class, args);
    }
}
```

这是SpringBoot的启动类入口，在resources目录下还会有配置文件，在启动类中我们要做的事情就两个：

- @SpringBootApplication
- 调用类SpringApplication的静态方法run，传入启动类的class以及main的args

所以，通过这个静态方法run，肯定会对启动类上的注解以及配置文件进行解析。跟进静态方法run，我们会发现他做了两件事

- 实例化SpringApplication
- 调用实例方法run

接下来我们先从实例化看起。

# 实例化

```java
public SpringApplication(ResourceLoader resourceLoader, Class<?>... primarySources) {
    // 初始化资源加载器，这里是null
    this.resourceLoader = resourceLoader;
    Assert.notNull(primarySources, "PrimarySources must not be null");
    // 启动类的class
    this.primarySources = new LinkedHashSet<>(Arrays.asList(primarySources));
    // 判断应用程序的类型
    this.webApplicationType = WebApplicationType.deduceFromClasspath();
    // 设置初始化器
    setInitializers((Collection) getSpringFactoriesInstances(ApplicationContextInitializer.class));
    // 设置监听器
    setListeners((Collection) getSpringFactoriesInstances(ApplicationListener.class));
    // 判断启动类
    this.mainApplicationClass = deduceMainApplicationClass();
}
```

以上就是实例化，实例化并不复杂，也只是做些简单的工作，着重说一下应用程序类型、初始化器和监听器，后面会再次用到。

## 应用程序类型

虽然平时用SpringBoot最多的是作web程序开发，但是他支持的类型不止web，Spring中有上下文，后续会根据应用的类型去创建对应的上下文，所以会在这里做判断。

如果是web类型的，SpringBoot会启动内嵌的web服务器，否则不会，而web服务器也分为响应的和非响应两种。如何判断呢？编译后会根据全类名判断是否有相应的class，如果要应用是web相关的，自然会引入相关的class。

```java
private static final String WEBMVC_INDICATOR_CLASS = "org.springframework.web.servlet.DispatcherServlet";

	private static final String WEBFLUX_INDICATOR_CLASS = "org.springframework.web.reactive.DispatcherHandler";

	private static final String JERSEY_INDICATOR_CLASS = "org.glassfish.jersey.servlet.ServletContainer";

static WebApplicationType deduceFromClasspath() {
    if (ClassUtils.isPresent(WEBFLUX_INDICATOR_CLASS, null) && !ClassUtils.isPresent(WEBMVC_INDICATOR_CLASS, null)
        && !ClassUtils.isPresent(JERSEY_INDICATOR_CLASS, null)) {
        return WebApplicationType.REACTIVE;
    }
    for (String className : SERVLET_INDICATOR_CLASSES) {
        if (!ClassUtils.isPresent(className, null)) {
            return WebApplicationType.NONE;
        }
    }
    return WebApplicationType.SERVLET;
}
```

## SPI

在说监听器和初始化器之前，我们先来说说SPI。跟进前两者的代码发现，他们的初始化逻辑是相同的。

```java
public static final String FACTORIES_RESOURCE_LOCATION = "META-INF/spring.factories";
```

SpringBoot会通过类加载器遍历上面的文件，文件属于配置文件，里面以key-value的形式放入了数据，例如监听器的入参是`ApplicaitonListener`的class，根据这个会找出对应的其他全类名，取出后再通过反射去初始化这些类。然后装入对应的容器。

## 监听器

```properties
org.springframework.context.ApplicationListener=\
org.springframework.boot.ClearCachesApplicationListener,\
org.springframework.boot.builder.ParentContextCloserApplicationListener,\
org.springframework.boot.cloud.CloudFoundryVcapEnvironmentPostProcessor,\
org.springframework.boot.context.FileEncodingApplicationListener,\
org.springframework.boot.context.config.AnsiOutputApplicationListener,\
org.springframework.boot.context.config.ConfigFileApplicationListener,\
org.springframework.boot.context.config.DelegatingApplicationListener,\
org.springframework.boot.context.logging.ClasspathLoggingApplicationListener,\
org.springframework.boot.context.logging.LoggingApplicationListener,\
org.springframework.boot.liquibase.LiquibaseServiceLocatorApplicationListener
```

这里列出一部分的*spring.facories*中的listener，可以发现每个listener都有其对应的功能，与之相对应的是event，对于每个事件也有他对应的类。由于类数量多，且职责明确，他类中的内容是很少的，只是对传入的对象进行处理，比如`ClearCachesApplicationListener`，清除缓存。

这些类只是监听，换句话说是需要被动触发，目前只是初始化阶段，等后续run的时候会初始化事件广播等其他对象，会与这些监听器一起配合使用。这些监听器被初始化完成后会存放在List容器中。

## 初始化器

初始化器听起来是初始化用的，初始化什么呢？我们先看文件下对应的初始化器（与监听器同理，他是凭借`ApplicationContextInitializer`）找对应的全类名

```properties
org.springframework.context.ApplicationContextInitializer=\
org.springframework.boot.context.ConfigurationWarningsApplicationContextInitializer,\
org.springframework.boot.context.ContextIdApplicationContextInitializer,\
org.springframework.boot.context.config.DelegatingApplicationContextInitializer,\
org.springframework.boot.rsocket.context.RSocketPortInfoApplicationContextInitializer,\
org.springframework.boot.web.context.ServerPortInfoApplicationContextInitializ
```

我们知道context是Spring的核心，不同类型的应用程序上下文都不一样，上下文 这个对象也会有中众多属性，这些初始化器就起到了初始化上下文的功能。例如地一个就是设置warnings的。只是目前是将这些类初始化，并将对象放入List容器。他们实现了相同的接口，后续也会向监听器一般被触发，然后遍历这些初始化器将传入的上下文初始化（对属性赋值）。

# Run

实例化完成后就是调用实例方法run了。总共就实例化和run两件事，实例化不复杂，那么是事情都落在了run上了。

```java
public ConfigurableApplicationContext run(String... args) {
    StopWatch stopWatch = new StopWatch();
    stopWatch.start();
    ConfigurableApplicationContext context = null;
    Collection<SpringBootExceptionReporter> exceptionReporters = new ArrayList<>();
    configureHeadlessProperty();
    // 获取listeners，是listener的持有者
    SpringApplicationRunListeners listeners = getRunListeners(args);
    listeners.starting();
    try {
        ApplicationArguments applicationArguments = new DefaultApplicationArguments(args);
        // 准备环境
        ConfigurableEnvironment environment = prepareEnvironment(listeners, applicationArguments);
        configureIgnoreBeanInfo(environment);
        Banner printedBanner = printBanner(environment);
        // 创建上下文
        context = createApplicationContext();
        exceptionReporters = getSpringFactoriesInstances(SpringBootExceptionReporter.class,
                                                         new Class[] { ConfigurableApplicationContext.class }, context);
        // 准备上下文，初始化
        prepareContext(context, environment, listeners, applicationArguments, printedBanner);
        // 刷新上下文
        refreshContext(context);
        afterRefresh(context, applicationArguments);
        stopWatch.stop();
        if (this.logStartupInfo) {
            new StartupInfoLogger(this.mainApplicationClass).logStarted(getApplicationLog(), stopWatch);
        }
        listeners.started(context);
        callRunners(context, applicationArguments);
    }
    catch (Throwable ex) {
        handleRunFailure(context, ex, exceptionReporters, listeners);
        throw new IllegalStateException(ex);
    }

    try {
        listeners.running(context);
    }
    catch (Throwable ex) {
        handleRunFailure(context, ex, exceptionReporters, null);
        throw new IllegalStateException(ex);
    }
    return context;
}
```

这部分内容较多，我们先承接初始化将上下文的准备工作说一说，其余的在后面的文章说再提。

## RunListeners

通过名字可以看出，`SpringApplicaitonRunListeners`掌握着各种listener，但是不是那么的直接。

```java
private SpringApplicationRunListeners getRunListeners(String[] args) {
    Class<?>[] types = new Class<?>[] { SpringApplication.class, String[].class };
    return new SpringApplicationRunListeners(logger,
                                             getSpringFactoriesInstances(SpringApplicationRunListener.class, types, this, args));
}
```

可以看到，与获取监听器、初始化器的方式如出一辙。这里获取到的类只有一个，`EventPublishingRunListener`。也就是说`SpringApplicationRunListeners`持有类`EventPublishingRunListener`，run方法中的所有listeners的方法内部都是调用`EventPublishingRunListenr`的，相当于他的代理类。后者的内部又是如何实现的，如何关联之前实例化的listeners呢？

在`EventPublishingRunListener`的内部持有两个重要的对象，一个广播器`SimpleApplicationEventMulticaster`，例如：

```java
@Override
public void starting() {
    this.initialMulticaster.multicastEvent(new ApplicationStartingEvent(this.application, this.args));
}
```

开始监听，会创建一个相应的事件，并将其广播出去。注意到一个参数`this.application`，这是持有的另一个重要的对象：`SpringApplication`。前面提到，有对他进行实例化，实例化的时候会设置两个属性：初始化器和监听器。这里将`SpringApplication`传进去，后续自然会通过get方法去获取到listeners，再触发对应event的listener。

## createApplicationContext

```java
	public static final String DEFAULT_CONTEXT_CLASS = "org.springframework.context."
			+ "annotation.AnnotationConfigApplicationContext";

	public static final String DEFAULT_SERVLET_WEB_CONTEXT_CLASS = "org.springframework.boot."
			+ "web.servlet.context.AnnotationConfigServletWebServerApplicationContext";

	public static final String DEFAULT_REACTIVE_WEB_CONTEXT_CLASS = "org.springframework."
			+ "boot.web.reactive.context.AnnotationConfigReactiveWebServerApplicationContext";

protected ConfigurableApplicationContext createApplicationContext() {
    Class<?> contextClass = this.applicationContextClass;
    if (contextClass == null) {
        try {
            switch (this.webApplicationType) {
                case SERVLET:
                    contextClass = Class.forName(DEFAULT_SERVLET_WEB_CONTEXT_CLASS);
                    break;
                case REACTIVE:
                    contextClass = Class.forName(DEFAULT_REACTIVE_WEB_CONTEXT_CLASS);
                    break;
                default:
                    contextClass = Class.forName(DEFAULT_CONTEXT_CLASS);
            }
        }
        catch (ClassNotFoundException ex) {
            throw new IllegalStateException(
                "Unable create a default ApplicationContext, please specify an ApplicationContextClass", ex);
        }
    }
    return (ConfigurableApplicationContext) BeanUtils.instantiateClass(contextClass);
}
```

之前有提到，初始化的时候设置了应用程序类型，在这里会根据这个类型去创建对应的上下文，同样是通过反射进行的。

## prepareContext

创建完上下文，我们再来看刷新前的准备工作。

```java
private void prepareContext(ConfigurableApplicationContext context, ConfigurableEnvironment environment,
                            SpringApplicationRunListeners listeners, ApplicationArguments applicationArguments, Banner printedBanner) {
    context.setEnvironment(environment);
    // 后置处理上下文
    postProcessApplicationContext(context);
    // 初始化上下文
    applyInitializers(context);
    listeners.contextPrepared(context);
    if (this.logStartupInfo) {
        logStartupInfo(context.getParent() == null);
        logStartupProfileInfo(context);
    }
    // Add boot specific singleton beans
    ConfigurableListableBeanFactory beanFactory = context.getBeanFactory();
    beanFactory.registerSingleton("springApplicationArguments", applicationArguments);
    if (printedBanner != null) {
        beanFactory.registerSingleton("springBootBanner", printedBanner);
    }
    if (beanFactory instanceof DefaultListableBeanFactory) {
        ((DefaultListableBeanFactory) beanFactory)
        .setAllowBeanDefinitionOverriding(this.allowBeanDefinitionOverriding);
    }
    if (this.lazyInitialization) {
        context.addBeanFactoryPostProcessor(new LazyInitializationBeanFactoryPostProcessor());
    }
    // Load the sources
    Set<Object> sources = getAllSources();
    Assert.notEmpty(sources, "Sources must not be empty");
    // 创建BeanDefinitionLoader
    load(context, sources.toArray(new Object[0]));
    listeners.contextLoaded(context);
}
```

准备工作也不少，listeners的响应一个比较好的阶段划分标志。可以看到分为了*contextPrepared*和*contextLoaded*。前者主要是对上下文的处理，后者是对上下文中的工厂属性进行处理，后续得用工厂去生产bean。

### contextPrepared

这个阶段主要做两件事：后置处理，初始化。我们一件一件看。

#### postProcess

```java
protected void postProcessApplicationContext(ConfigurableApplicationContext context) {
    if (this.beanNameGenerator != null) {
        // 为bean命名
        context.getBeanFactory().registerSingleton(AnnotationConfigUtils.CONFIGURATION_BEAN_NAME_GENERATOR,
                                                   this.beanNameGenerator);
    }
    if (this.resourceLoader != null) {
        if (context instanceof GenericApplicationContext) {
            ((GenericApplicationContext) context).setResourceLoader(this.resourceLoader);
        }
        if (context instanceof DefaultResourceLoader) {
            ((DefaultResourceLoader) context).setClassLoader(this.resourceLoader.getClassLoader());
        }
    }
    if (this.addConversionService) {
        context.getBeanFactory().setConversionService(ApplicationConversionService.getSharedInstance());
    }
}
```

这里主要为上下文装配工厂的`beanNameGenerator`、资源加载器和类加载器。

#### applyInitializers

```java
protected void applyInitializers(ConfigurableApplicationContext context) {
    for (ApplicationContextInitializer initializer : getInitializers()) {
        Class<?> requiredType = GenericTypeResolver.resolveTypeArgument(initializer.getClass(),
                                                                        ApplicationContextInitializer.class);
        Assert.isInstanceOf(requiredType, context, "Unable to call initializer.");
        initializer.initialize(context);
    }
}
```

之前提到的初始化器，在这里会对刚生成的上下文进行初始化，配置相关属性。

### contextLoaded

这里主要是创建`BeanDefinitionLoader`，用来后续从xml、javaConfig中加载bean。

```java
protected void load(ApplicationContext context, Object[] sources) {
    if (logger.isDebugEnabled()) {
        logger.debug("Loading source " + StringUtils.arrayToCommaDelimitedString(sources));
    }
    BeanDefinitionLoader loader = createBeanDefinitionLoader(getBeanDefinitionRegistry(context), sources);
    if (this.beanNameGenerator != null) {
        loader.setBeanNameGenerator(this.beanNameGenerator);
    }
    if (this.resourceLoader != null) {
        loader.setResourceLoader(this.resourceLoader);
    }
    if (this.environment != null) {
        loader.setEnvironment(this.environment);
    }
    loader.load();
}
```



# 总结

我们启动SpringBoot很简单，实际上内部做了非常多的事情，正是这些“约定”简化了我们的使用。核心是围绕着上下文来做的：

- 根据应用程序的类型创建对应的上下文
- 初始化器配置上下文
- 监听机制响应对应的事件