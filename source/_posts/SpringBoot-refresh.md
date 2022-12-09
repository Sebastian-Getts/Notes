---
title: SpringBoot refresh
date: 2021-02-15 16:19:30
categories: springboot
tags: refresh
---

这篇主要分析SpringBoot在run阶段的*refresh*过程。

<!--more-->

之前提到，SpringBoot会根据应用的类型去创建对应的容器，在做refresh时也是用对应的容器对执行刷新方法的，但是无论是哪个容器都会调用抽象父类的refresh方法，换句话说，接口定义了容器规范，抽象类实现了部分功能（例如refresh），再由具体的容器类型去继承抽象类实现个性化。先来看看refresh：

```java
synchronized (this.startupShutdownMonitor) {
    // Prepare this context for refreshing.
    prepareRefresh();

    // Tell the subclass to refresh the internal bean factory.
    ConfigurableListableBeanFactory beanFactory = obtainFreshBeanFactory();

    // Prepare the bean factory for use in this context.
    prepareBeanFactory(beanFactory);

    try {
        // Allows post-processing of the bean factory in context subclasses.
        postProcessBeanFactory(beanFactory);

        // Invoke factory processors registered as beans in the context.
        invokeBeanFactoryPostProcessors(beanFactory);

        // Register bean processors that intercept bean creation.
        registerBeanPostProcessors(beanFactory);

        // Initialize message source for this context.
        initMessageSource();

        // Initialize event multicaster for this context.
        initApplicationEventMulticaster();

        // Initialize other special beans in specific context subclasses.
        onRefresh();

        // Check for listener beans and register them.
        registerListeners();

        // Instantiate all remaining (non-lazy-init) singletons.
        finishBeanFactoryInitialization(beanFactory);

        // Last step: publish corresponding event.
        finishRefresh();
    }
```

<!--toc-->

# prepareRefresh

刷新前的准备工作，设置一些开关；初始化property。

# prepareBeanFactory

准备beanFactory，可以分为以下几个部分：

1. 设置类加载器和bean解析器

2. 添加beanPostProcessor：`ApplicationContextAwarePostProcessor`，并忽略五个依赖，因为查看前者，会发现他已经实现了要忽略的五个依赖。
   
   ```java
   // Configure the bean factory with context callbacks.
   beanFactory.addBeanPostProcessor(new ApplicationContextAwareProcessor(this));
   beanFactory.ignoreDependencyInterface(EnvironmentAware.class);
   beanFactory.ignoreDependencyInterface(EmbeddedValueResolverAware.class);
   beanFactory.ignoreDependencyInterface(ResourceLoaderAware.class);
   beanFactory.ignoreDependencyInterface(ApplicationEventPublisherAware.class);
   beanFactory.ignoreDependencyInterface(MessageSourceAware.class);
   beanFactory.ignoreDependencyInterface(ApplicationContextAware.class);
   ```

3. 手动设置注入的bean，相当与初始化。*registerResolvableDependency*方法是将对应的入参以key-value的形式放入map中。
   
   ```java
   // BeanFactory interface not registered as resolvable type in a plain factory.
   // MessageSource registered (and found for autowiring) as a bean.
   beanFactory.registerResolvableDependency(BeanFactory.class, beanFactory);
   // this是上下文容器
   beanFactory.registerResolvableDependency(ResourceLoader.class, this);
   beanFactory.registerResolvableDependency(ApplicationEventPublisher.class, this);
   beanFactory.registerResolvableDependency(ApplicationContext.class, this);
   ```

# postProcessBeanFactory

添加postProcessor；在beanFacotry中手动注册web容器相关的bean，如servletContext等。

```java
protected void postProcessBeanFactory(ConfigurableListableBeanFactory beanFactory) {
    // add之后紧接着ignore，说明加入的processor实现了后者的功能
    beanFactory.addBeanPostProcessor(new ServletContextAwareProcessor(this.servletContext, this.servletConfig));
    beanFactory.ignoreDependencyInterface(ServletContextAware.class);
    beanFactory.ignoreDependencyInterface(ServletConfigAware.class);

    WebApplicationContextUtils.registerWebApplicationScopes(beanFactory, this.servletContext);
    WebApplicationContextUtils.registerEnvironmentBeans(beanFactory, this.servletContext, this.servletConfig);
}
```

# invokeBeanFactoryPostProcessors

参照之前的postProcessContext一样，会调用一些postProcessor再去配置BeanFactory。内部会将实现委托给`PostProcessorRegistrationDelegate`，实现的细节代码较长，这里就不贴了。

​        首先是排序，它会按照postProcessor的顺序来使用，顺序为：priorityOrdered, ordered, regular。但是有没有想过这些processor是哪里来的呢？之前都是在往context加入后置处理。实际上，在创建对应容器时，相应的context会会初始化，这个时候会往*BeanDefinitionRegistry*加入postProcessor。

```java
String[] postProcessorNames =
    beanFactory.getBeanNamesForType(BeanDefinitionRegistryPostProcessor.class, true, false);
for (String ppName : postProcessorNames) {
    if (beanFactory.isTypeMatch(ppName, PriorityOrdered.class)) {
        // configurationClassPostProcessor，用来解析@Config注解
        currentRegistryProcessors.add(beanFactory.getBean(ppName, BeanDefinitionRegistryPostProcessor.class));
        processedBeans.add(ppName);
    }
}
sortPostProcessors(currentRegistryProcessors, beanFactory);
registryProcessors.addAll(currentRegistryProcessors);
invokeBeanDefinitionRegistryPostProcessors(currentRegistryProcessors, registry);
currentRegistryProcessors.clear();
```

​        随后主要是解析Configertaion注解，在刚启动时也只有启动类上标注有注解（@SpringApplication中带有），在后置处理类中，更多的工作是负责处理解析与否，详细的解析工作是交给了类`ConfigurationClassParser`，每个bean都由BeanDefinitionHolder持有，有属性beanDefinition来定义bean，根据这个来做后续判断，在*doProcessConfigurationClass*方法中，可以看到过程如下：解析@PropertySource，@ComponentScan，@Import，@ImportResource等等。其中跟进import，会发现他还会解析其中的`selector`并再次递归，如此往复。

​        以上涉及到了注解的解析，这时回到我们的启动类查看启动类上的注解@SpringApplication，跟进：

```java
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
@Documented
@Inherited
@SpringBootConfiguration
@EnableAutoConfiguration // 启动自动装配
@ComponentScan(excludeFilters = { @Filter(type = FilterType.CUSTOM, classes = TypeExcludeFilter.class),
        @Filter(type = FilterType.CUSTOM, classes = AutoConfigurationExcludeFilter.class) })
public @interface SpringBootApplication {
    // ...
}
```

我们主要查看他自动装配的原理：

```java
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
@Documented
@Inherited
@AutoConfigurationPackage
@Import(AutoConfigurationImportSelector.class) // 这里的代码会被解析
public @interface EnableAutoConfiguration {
    // ...
}
```

在AutoConfigurationImportSelector中，selectImport方法会被调用，在里面会有`getCandidateConfigurations`，顾名思义，根据*EnableAutoConfiguration.class*这个key从*spring.factories*中获取对应的values：

```properties
org.springframework.boot.autoconfigure.EnableAutoConfiguration=\
org.springframework.boot.autoconfigure.admin.SpringApplicationAdminJmxAutoConfiguration,\
org.springframework.boot.autoconfigure.aop.AopAutoConfiguration,\
org.springframework.boot.autoconfigure.amqp.RabbitAutoConfiguration,\
# ...
```

共一百多个，这些会被解析后放入beanFactory中。

# registerBeanPostProcessors

这个方法内的步骤与上一个一样。委托给`PostProcessorRegistrationDelegate`来做事。

# InitMessageSource

国际化处理

# initApplicationEventMulticaster

初始化广播器，其实之前是有初始化过的，直接拿来用。如果没有的话会在这里重新初始化一个。

# onRefresh

抽象方法中这里空出来了，留给不同的实现类去实现，对于Servlet来说是创建web服务器。

# registerListeners

添加监听器到持有者中。

# finishBeanFactoryInitialization

这一步是实例化所有的bean了。

# finishRefresh

最后一步除了发布相应的时间外还会清楚上下文缓存、初始化它的生命周期。

# 总结

refresh的内容还是很多的。重点关注这几个方面：

- 实现了与注解的联动
- 完成了自动化配置
- 解析bean之间的依赖并实例化