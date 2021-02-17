---
title: SpringBoot environment
date: 2021-02-15 16:19:17
categories: springboot
tags: source
---

​		SpringBoot配置文件的相关分析。我们都知道目前SpringBoot的配置文件可以配置文件很简单，支持多环境，有yml和properties，那么他的加载机制是怎样的呢？又是如何读取的？

<!--more-->

<!--toc-->

前面提到，启动SpringBoot项目分为实例化类SpringApplication和run，在run阶段会准备环境。我们先通过代码看看环境是如何被准备的

```java
private ConfigurableEnvironment prepareEnvironment(SpringApplicationRunListeners listeners, ApplicationArguments applicationArguments) {
    // 根据应用类型创建对应的环境
    ConfigurableEnvironment environment = getOrCreateEnvironment();
    configureEnvironment(environment, applicationArguments.getSourceArgs());
    ConfigurationPropertySources.attach(environment);
    listeners.environmentPrepared(environment);
    bindToSpringApplication(environment);
    if (!this.isCustomEnvironment) {
        environment = new EnvironmentConverter(getClassLoader()).convertEnvironmentIfNecessary(environment, deduceEnvironmentClass());
    }
    ConfigurationPropertySources.attach(environment);
    return environment;
}
```

一个从产生的对象，要将它生产出来一般都离不开创建与初始化，所以也可以将上面的分为这两部分。

# 创建环境

首先我们先看创建环境。`getOrCreateEnvironment`会根据应用类型初始化相应的环境，条件与之前分析的创建应用上下文的相同，分为：*默认*，*Servlet*， *REACTIVE*。这三个环境的都会继承一个接口`ConfigurableEnvironment`，我们看看接口都做了什么

```java
void setActiveProfiles(String... profiles);

void addActiveProfile(String profile);

void setDefaultProfiles(String... profiles);

MutablePropertySources getPropertySources();

Map<String, Object> getSystemProperties();

Map<String, Object> getSystemEnvironment();

void merge(ConfigurableEnvironment parent);
```

可以看到他们后续的抽象类及继承类都是围绕着profile和property来工作的，前者分为默认和激活两个状态，后者用map来存储配置文件中的键值对。

# 配置环境

配置环境的方法是模板方法，详细分为了`property`和`profile`。前者是添加默认配置和命令行配置，后者是选择激活的profile。

接下来是ConfigurationPropertySources的attach。这个方法会检查特殊字段是否为空 ，然后去做对应的处理

```java
private static final String ATTACHED_PROPERTY_SOURCE_NAME = "configurationProperties";
```

除了这个，我们还需要了解environment中的propertySource的类型：MutablePropertySource。他的属性是一个*CopyOnWriteArrayList*实现的线性表，仅此而已，返型是PropertySource对象。

下面是一个非常重要的处理，监听器的执行。之前提到，执行时会创建相应的event，然后再通过广播去找对应的listener，我们来看看listener `ConfigFileApplicationListener`被触发后的执行：

```java
private void onApplicationEnvironmentPreparedEvent(ApplicationEnvironmentPreparedEvent event) {
    List<EnvironmentPostProcessor> postProcessors = loadPostProcessors();
    // 把自己也加入到了后置处理器中，因为这个listener也继承了EnvironmentPostProcessor
    postProcessors.add(this);
    AnnotationAwareOrderComparator.sort(postProcessors);
    for (EnvironmentPostProcessor postProcessor : postProcessors) {
        postProcessor.postProcessEnvironment(event.getEnvironment(), event.getSpringApplication());
    }
}
```

响应的事件也如之前所说，都很简洁，这里环境准备的响应首先获取到后置处理器，随后将类本身也加入进去，排序后依次执行后置处理器的方法对环境做处理。

```java
List<EnvironmentPostProcessor> loadPostProcessors() {
    // 获取环境后置处理器的方式与之前的监听器初始化器相同
    return SpringFactoriesLoader.loadFactories(EnvironmentPostProcessor.class, getClass().getClassLoader());
}
```

```properties
# Environment Post Processors
org.springframework.boot.env.EnvironmentPostProcessor=\
org.springframework.boot.cloud.CloudFoundryVcapEnvironmentPostProcessor,\
org.springframework.boot.env.SpringApplicationJsonEnvironmentPostProcessor,\
org.springframework.boot.env.SystemEnvironmentPropertySourceEnvironmentPostProcessor,\
org.springframework.boot.reactor.DebugAgentEnvironmentPostProcessor
```

由于listener本身也是processor（单独把它加入到processor里了），所以我们重点关注这里的后置处理。这部分也是加载配置文件的关键。

## Load

后置处理也是层层委托

```java
protected void addPropertySources(ConfigurableEnvironment environment, ResourceLoader resourceLoader) {
    RandomValuePropertySource.addToEnvironment(environment);
    // 创建loader后调用load方法
    new Loader(environment, resourceLoader).load();
}
```

```java
private static final Set<String> LOAD_FILTERED_PROPERTY;

static {
    Set<String> filteredProperties = new HashSet<>();
    filteredProperties.add("spring.profiles.active");
    filteredProperties.add("spring.profiles.include");
    LOAD_FILTERED_PROPERTY = Collections.unmodifiableSet(filteredProperties);
}
void load() {
    // defaultProperties
    FilteredPropertySource.apply(this.environment, DEFAULT_PROPERTIES, LOAD_FILTERED_PROPERTY,
                                 (defaultProperties) -> {
                                     this.profiles = new LinkedList<>();
                                     this.processedProfiles = new LinkedList<>();
                                     this.activatedProfiles = false;
                                     this.loaded = new LinkedHashMap<>();
                                     initializeProfiles();
                                     while (!this.profiles.isEmpty()) {
                                         Profile profile = this.profiles.poll();
                                         if (isDefaultProfile(profile)) {
                                             addProfileToEnvironment(profile.getName());
                                         }
                                         // 重载load
                                         load(profile, this::getPositiveProfileFilter,
                                              addToLoaded(MutablePropertySources::addLast, false));
                                         this.processedProfiles.add(profile);
                                     }
                                     // 重载load
                                     load(null, this::getNegativeProfileFilter, addToLoaded(MutablePropertySources::addFirst, true));
                                     addLoadedPropertySources();
                                     applyActiveProfiles(defaultProperties);
                                 });

```

上面的方法看着长，别被lambda吓到了，实际上是调用了apply方法，后面那个只是一个consumer参数。也就是在这个listener里解析了properties以及yml，定义了解析顺序和规则。里面有多个重载的load方法，在load方法内还会遍历地用*propertySourceLoaders*中的loader去调用load方法，propertySourceLoader是一个接口，有两个实现类：`PropertiesPropertySourceLoader`和`YamlPropertySourceLoader`。

## 自定义

我们知道，加载了postprocessor后会触发processor，如果要自定义配置文件或者指定路径呢？利用他的SPI机制，我们可以在在META-INF下创建spring.factories，在里面按照给定的key加上我们实现了`EnvironmentPostProcessor`的类。可以参考给出的类来写，将配置文件加入列表即可。