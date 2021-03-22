---
title: Spring Security AutoConfiguration
date: 2021-03-22 22:18:10
categories: framework
tags: spring security
---

​		最近有设计权限模块，用到了*Spring Security*，在SpringBoot项目中导入了相关的jar包后几乎不用做任何配置（当然，除了启用的*@EnableWebSecurity*）就会拦截请求，达到了“安全“的目的，配置的方式也是多种多样，我们先从”方便使用“这个角度，看看他如何做到的”拆箱即用“。

<!-- more -->

# 入口

​		在SpringBoot中使用注解来解放xml配置文件后，一直都是*@Configuration*的天下，开启一个模块的功能同样需要它。开头提到的那个注解*@EnableWebSecurity*就是探究的入口：

```java
@Retention(value = java.lang.annotation.RetentionPolicy.RUNTIME)
@Target(value = { java.lang.annotation.ElementType.TYPE })
@Documented
@Import({ WebSecurityConfiguration.class,
		SpringWebMvcImportSelector.class,
		OAuth2ImportSelector.class })
@EnableGlobalAuthentication
@Configuration
public @interface EnableWebSecurity {

	/**
	 * Controls debugging support for Spring Security. Default is false.
	 * @return if true, enables debug support with Spring Security
	 */
	boolean debug() default false;
}
```

我们看到通过*@Import(...)*导入了三个class，后两个都是以*Selector*结尾，在命名规范的Spring源码中大概是可以猜出内容的：根据某个条件选择性地加载类，也就是动态地*@Import(...)*，这里我们不去关注Selector，从”方便使用“的角度，我们是来探究开箱即用的，所以着重看下第一个*WebSecurityConfiguration*配置类。

在进入第一个配置类之前有必要看一下这个注解的注释信息：

>Add this annotation to an @Configuration class to have the Spring Security configuration defined in any WebSecurityConfigurer or more likely by extending the WebSecurityConfigurerAdapter base class and overriding individual methods

告诉了我们如何使用以及自定义安全规则，那么使用起来应该是这样：

```java
@EnableWebSecurity
@Configuration
public class MyWebSecurityConfiguration extends WebSecurityConfigurerAdapter {
    
    @Override
    public void confugre(HttpSecurity httpSecurity){
        // ....
    }
}
```

下面我们进入配置类。

# 配置类

Spring Security从来不是单独存在的，正如他的名字一般，前面是有Spring的，Spring的核心就是IoC，所以，配置也是一样，一定会从把各个bean交代给容器。我们来看看他都做了啥。一进入类中，注释就讲得明明白白：

> Uses a WebSecurity to create the FilterChainProxy that performs the web based security for Spring Security. It then exports the necessary beans. Customizations can be made to WebSecurity by extending WebSecurityConfigurerAdapter and exposing it as a Configuration or implementing WebSecurityConfigurer and exposing it as a Configuration. This configuration is imported when using EnableWebSecurity.

我们都知道web请求是典型的责任链，或者说是过滤器链，在这个配置类中就注册了过滤器的持有类和相关配置，先看看他的准备工作：

## setFilterChainProxySecurityConfigurer

```java
@Autowired(required = false)
public void setFilterChainProxySecurityConfigurer(
    // 入参一
    ObjectPostProcessor<Object> objectPostProcessor,
    // 入参二
    @Value("#{@autowiredWebSecurityConfigurersIgnoreParents.getWebSecurityConfigurers()}") List<SecurityConfigurer<Filter, WebSecurity>> webSecurityConfigurers)
    throws Exception {
    webSecurity = objectPostProcessor
        .postProcess(new WebSecurity(objectPostProcessor));
    if (debugEnabled != null) {
        webSecurity.debug(debugEnabled);
    }
    
    webSecurityConfigurers.sort(AnnotationAwareOrderComparator.INSTANCE);

    Integer previousOrder = null;
    Object previousConfig = null;
    for (SecurityConfigurer<Filter, WebSecurity> config : webSecurityConfigurers) {
        Integer order = AnnotationAwareOrderComparator.lookupOrder(config);
        if (previousOrder != null && previousOrder.equals(order)) {
            throw new IllegalStateException(
                "@Order on WebSecurityConfigurers must be unique. Order of "
                + order + " was already used on " + previousConfig + ", so it cannot be used on "
                + config + " too.");
        }
        previousOrder = order;
        previousConfig = config;
    }
    for (SecurityConfigurer<Filter, WebSecurity> webSecurityConfigurer : webSecurityConfigurers) {
        // 遍历webSecurityConfigures，执行webSecurity的apply
        webSecurity.apply(webSecurityConfigurer);
    }
    // 将confugures赋给势力变量
    this.webSecurityConfigurers = webSecurityConfigurers;
}
```



### getWebSecurityConfigurers

入参二是有些奇怪的，实际上是执行了类`AutowiredWebSecurityConfigurersIgnoreParents`中的静态方法*getWebSecurityConfigurers*，目的是从上下文中获取到configures：

```java
public List<SecurityConfigurer<Filter, WebSecurity>> getWebSecurityConfigurers() {
   List<SecurityConfigurer<Filter, WebSecurity>> webSecurityConfigurers = new ArrayList<>();
   Map<String, WebSecurityConfigurer> beansOfType = beanFactory
         .getBeansOfType(WebSecurityConfigurer.class);
   for (Entry<String, WebSecurityConfigurer> entry : beansOfType.entrySet()) {
      webSecurityConfigurers.add(entry.getValue());
   }
   return webSecurityConfigurers;
}
```



### apply

这里的apply是配置类中的属性webSecurity执行的，方法内实际的操作是”添加“，即把configures添加到容器中做保存，相当与是为webSecurity的属性赋值了。

```java
private <C extends SecurityConfigurer<O, B>> void add(C configurer) {
    // ...
    synchronized (configurers) {
        // ...
        List<SecurityConfigurer<O, B>> configs = allowConfigurersOfSameType ? this.configurers
            .get(clazz) : null;
        if (configs == null) {
            configs = new ArrayList<>(1);
        }
        configs.add(configurer);
        // private final LinkedHashMap<Class<? extends SecurityConfigurer<O, B>>, List<SecurityConfigurer<O, B>>> configurers = new LinkedHashMap<>();
        this.configurers.put(clazz, configs);
        // ...
    }
}
```

要知道，我们在*入口*处提到的用法，是在一个继承了抽象类的类上使用注解，并可以自定义安全规则，那个抽象类就是一个*WebSecurityConfigurer*，他实现了接口：

```java
public abstract class WebSecurityConfigurerAdapter implements WebSecurityConfigurer<WebSecurity> {
    // ...
}
```

所以可以总结一下这个方法：在这个配置类的这一方法中，我们实现的configurer会被方法*getWebSecurityConfigurers*从上下文中取出，经过排序等操作后填充至webSecurity的属性中保存。



## springSecurityFilterChain

准备工作之后是过滤器链。

```java
// 	public static final String DEFAULT_FILTER_NAME = "springSecurityFilterChain";
@Bean(name = AbstractSecurityWebApplicationInitializer.DEFAULT_FILTER_NAME)
public Filter springSecurityFilterChain() throws Exception {
    // 在上个方法中有给属性赋值，我们有继承的话 这里不为空，即true
    boolean hasConfigurers = webSecurityConfigurers != null
        && !webSecurityConfigurers.isEmpty();
    if (!hasConfigurers) {
        // 为空的话新建一个
        WebSecurityConfigurerAdapter adapter = objectObjectPostProcessor
            .postProcess(new WebSecurityConfigurerAdapter() {
            });
        // 再次执行apply
        webSecurity.apply(adapter);
    }
    // 不为空的话 会直接执行这里的build方法
    return webSecurity.build();
}
```

到这里我们可以大致猜测他后续的步骤，最上面的demo中方法是configure，入参是httpSecurity，所以过滤器链也会与这些对象和方法有关，build也应该是构建过滤器链的。

```java
private AtomicBoolean building = new AtomicBoolean();

public final O build() throws Exception {
    // 这里对build方法用了自旋CAS防止重复构建
    if (this.building.compareAndSet(false, true)) {
        this.object = doBuild();
        return this.object;
    }
    throw new AlreadyBuiltException("This object has already been built");
}
```

在*doBuild()*方法里用到了模板方法模式，同SpringBoot启动时做的refresh一样，给开发者留了余地，在构建前后都能实现一些方法，我们这里着重看看他内部实现了的。

### init

初始化，方法中会遍历configurer，其中包括我们自己实现的（假设我们继承了WebSecurityAdapter），那我们来看看init做了啥：

```java
public void init(final WebSecurity web) throws Exception {
    // 获取httpSecurity
    final HttpSecurity http = getHttp();
    // web是webSecurity的一个实例变量，通过获取的httpSecurity为其属性赋值
    web.addSecurityFilterChainBuilder(http).postBuildAction(() -> {
        FilterSecurityInterceptor securityInterceptor = http
            .getSharedObject(FilterSecurityInterceptor.class);
        web.securityInterceptor(securityInterceptor);
    });
}
```

#### getHttp

```java
protected final HttpSecurity getHttp() throws Exception {
   if (http != null) {
      return http;
   }

   AuthenticationEventPublisher eventPublisher = getAuthenticationEventPublisher();
   localConfigureAuthenticationBldr.authenticationEventPublisher(eventPublisher);

   AuthenticationManager authenticationManager = authenticationManager();
   authenticationBuilder.parentAuthenticationManager(authenticationManager);
   Map<Class<?>, Object> sharedObjects = createSharedObjects();

    // 生成对象
   http = new HttpSecurity(objectPostProcessor, authenticationBuilder,
         sharedObjects);
    // 默认的话 会生产默认的安全策略。就相当与我们什么都没有配置
   if (!disableDefaults) {
      // @formatter:off
      http
         .csrf().and()
         .addFilter(new WebAsyncManagerIntegrationFilter())
         .exceptionHandling().and()
         .headers().and()
         .sessionManagement().and()
         .securityContext().and()
         .requestCache().and()
         .anonymous().and()
         .servletApi().and()
         .apply(new DefaultLoginPageConfigurer<>()).and()
         .logout();
      // @formatter:on
      ClassLoader classLoader = this.context.getClassLoader();
      List<AbstractHttpConfigurer> defaultHttpConfigurers =
            SpringFactoriesLoader.loadFactories(AbstractHttpConfigurer.class, classLoader);

      for (AbstractHttpConfigurer configurer : defaultHttpConfigurers) {
         http.apply(configurer);
      }
   }
    // 配置httpSecurity
   configure(http);
   return http;
}
```

上面的方法中在返回httpSecurity对象之前会执行*configure*方法，是否记得demo以及开篇时讲的关于如何使用注解*@EnableSpringSecurity*？注释给的方法是在一个实现了抽象类的配置类中用该注解，并且重写*configure*方法，于是，在这里就用到了，方法会以httpSecurity作为配置对象并实现安全机制。



# 小结

以上梳理了SpringSecurity为何能做到开箱即用，主要是自定义的配置在何处生效的。然而还有相当多的地方没有讲解到，以后逐一梳理。