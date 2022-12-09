---
title: mybatis autoconfiguration
date: 2021-03-09 20:48:57
categories: springbot
tags: mybatis
---

这一篇我们来看mybatis在springboot环境下的自动装配。之前分析过SpringBoot对于Spring的自动装配，mybatis引入时作为一个starter，开箱即用的产品，自然也少不了，同时在springboot的大环境下，为了方便开发肯定也会遵循他的装配法则。

<!-- more -->

<!-- toc -->

# 来源

如果还记得之前的分析就会知道，SpringBoot会从`META-INF`目录下找`spring.factories`文件，并从中找`EnableAutoConfiguration`对应的值，这个值是一个以逗号分割开的全类名字符串，你配多少他加载多少。换句话说，如果没有导入mybatis，就不会有相关的配置。加载后会通过反射来获取类相关信息并进行配置。mybatis的自动装配内容非常少，我们来看下：

```properties
# Auto Configure
org.springframework.boot.autoconfigure.EnableAutoConfiguration=\
org.mybatis.spring.boot.autoconfigure.MybatisLanguageDriverAutoConfiguration,\
org.mybatis.spring.boot.autoconfigure.MybatisAutoConfiguration
```

一共就两个类，第一个是语言相关的，会检测是否有*thymeleaf*、*framemarker*等web框架，如果有的话会配置相关的语法，目前项目大多前后分离，在此就不分析这部分啦，我们重点看看下面那个`MybatisAutoConfiguration`配置类。

# 自动装配

通过这个类我们要弄清楚他自动装配了啥。

```java
@Configuration
@ConditionalOnClass({SqlSessionFactory.class, SqlSessionFactoryBean.class}) // 路径下存在这两个类的class时生效
@ConditionalOnSingleCandidate(DataSource.class) // 单个数据源生效
@EnableConfigurationProperties({MybatisProperties.class}) // 启用mybatis配置文件的属性
@AutoConfigureAfter({DataSourceAutoConfiguration.class, MybatisLanguageDriverAutoConfiguration.class}) // 这两个类后自动配置
public class MybatisAutoConfiguration implements InitializingBean {
    // ...
}
```

## sqlSessionFactory

```java
@Bean
@ConditionalOnMissingBean // 缺少这个bean时创建他
public SqlSessionFactory sqlSessionFactory(DataSource dataSource) throws Exception {
    // ...
}
```

sqlSessionFactory是用来创建sqlSession的，我们知道，每次执行sql时都是以sqlSession为执行对象的，里面封装了增删改查等操作，要创建这个factory需要数据源，并且里面还用到了配置文件，就是上面注解中的`MapperProperties`，会根据用户配置的信息来修改facotry的相关属性。

## sqlSessionTemplate

```java
@Bean
@ConditionalOnMissingBean // 同sqlSessionFactory
public SqlSessionTemplate sqlSessionTemplate(SqlSessionFactory sqlSessionFactory) {
    ExecutorType executorType = this.properties.getExecutorType();
    return executorType != null ? new SqlSessionTemplate(sqlSessionFactory, executorType) : new SqlSessionTemplate(sqlSessionFactory);
}
```

这个sqlSessionFactory的创建需要用到sqlSessionFactory，同时会根据用户有没有指定`executorType`来创建对应的sqlSessionTemplate。通过这个bean的名称可以知道他是一直种sqlSession的模板，而且还用到了配置文件中`executorType`这个属性，他通常有三个选择：

- SIMPLE：为每个语句的执行创建一个预处理语句，基操
- REUSE：复用预处理语句
- BATCH：批量执行所有更新语句

## MapperScannerRegistrarNotFoundConfiguration

```java
@Configuration
@Import({MybatisAutoConfiguration.AutoConfiguredMapperScannerRegistrar.class}) // 导入
@ConditionalOnMissingBean({MapperFactoryBean.class, MapperScannerConfigurer.class}) // 缺少这两个类时生效
public static class MapperScannerRegistrarNotFoundConfiguration implements InitializingBean {
    public MapperScannerRegistrarNotFoundConfiguration() {
    }

    public void afterPropertiesSet() {
        MybatisAutoConfiguration.logger.debug("Not found configuration for registering mapper bean using @MapperScan, MapperFactoryBean and MapperScannerConfigurer.");
    }
}
```

这个类导入了一个内部类，并且会在`MapperFactoryBean`和`MapperScannerConfigure.class`缺少时生效，这个大家就很熟悉了，**通常没有写_@MapperScan_时的异常就是在这里产生的**：

```java
public class MapperFactoryBean<T> extends SqlSessionDaoSupport implements FactoryBean<T> {
    private Class<T> mapperInterface;
    private boolean addToConfig = true;

    public MapperFactoryBean() {
    }

    public MapperFactoryBean(Class<T> mapperInterface) {
        this.mapperInterface = mapperInterface;
    }

    protected void checkDaoConfig() {
        super.checkDaoConfig();
        Assert.notNull(this.mapperInterface, "Property 'mapperInterface' is required");
        Configuration configuration = this.getSqlSession().getConfiguration();
        // 如果开启了“添加配置”并且接口没有被添加过的话
        if (this.addToConfig && !configuration.hasMapper(this.mapperInterface)) {
            try {
                // 往mybatis的配置类中添加接口
                configuration.addMapper(this.mapperInterface);
            } catch (Exception var6) {
                this.logger.error("Error while adding the mapper '" + this.mapperInterface + "' to configuration.", var6);
                throw new IllegalArgumentException(var6);
            } finally {
                ErrorContext.instance().reset();
            }
        }

    }
    // ...
}
```

总结一下，这个自动配置类主要做了以下工作：

1. 启用配置文件
2. 缺少sqlSessionFactory时创建该bean，依赖数据源dataSource
3. 缺少sqlSessionTemplate时创建该bean，依赖sqlSessionFactory
4. 没有配置mapper文件扫描时注册异常bean，否则扫描并加载mapper

以上是我们使用mybatis的基础，启用了配置文件，我们会加入mapper文件路径等配置信息，有了sqlSessionFactory就会创建sqlSessionTemplate，进而根据他获到mybatis的关键类Configuration，最后将获取到的mapper接口加入到配置类中，配置类是持有`mapperRegister`的，这个就好比一个mapper池，装载着所有的mapper接口，使用HashMap实现。