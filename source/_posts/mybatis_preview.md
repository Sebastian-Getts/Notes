---
title: mybatis_preview
date: 2020-08-05 22:21:19
categories: framework
tags: mybatis
---

Mybatis帮助我们提升与数据库交互的效率，简化了JDBC的样板代码。

<!--more-->

# 流程

```flow
start=>start: start
config=>operation: mybatis-config.xml
build=>operation: SqlSessionFactoryBuilder
factory=>operation: SqlSessionFactory
session=>parallel: SqlSession
mapper=>operation: Sql Mapper
end=>end: end

start->config->build->factory->session
session(path1,)->end
session(path2,right)->mapper->end
```

对于`SqlSessionFactoryBuilder`来说，作用是创建`SqlSessionFactory`，一旦创建完工厂就没用了，所以是作为**局部变量**；而对于`SqlSessionFactory`，可以把它看作*连接池*，应该一直运行，不应重复创建、销毁或另建实例（单例模式登场），否则浪费资源，他可以创建`SqlSession` 。创建`SqlSession`后用来链接数据库，每个session被看作是请求数据库，他是**线程不安全**的，每个线程都应有自己的session，不共享，所以最佳作用域是**方法域**，即每次与数据库交互都创建一个`SqlSession`，用完关闭（关闭是为了释放资源给别的线程使用，否则并发大了容易宕机）。

## 属性名与数据库表字段名

当pojo中的实例变量与数据库字段中不一致时，可以使用`resultMap`来解决，即**结果集映射**。

也常用`resultType`，但是他是简单地将所有列映射到HashMap中的key上，很单一，不适合处理复杂情况，而map可以更加灵活地处理情况。用来`resultMap`时可以去掉`resultType`属性。

## 日志工厂

mybatis会默认去寻找日志框架，配置后会有sql信息输出，十分有用！

```xml
<settings>
	<setting name="logImpl" value="log4j"/>
</settings>
```

## 分页

mybatis支持分页，有`limit`和`rowBounts`两个方法。区别是前者在sql中实现，后者面向对象。

```sql
select * from USER limit #{index},#{size}
```

# 缓存

默认定义了两级缓存：一级缓存、二级缓存

## 一级缓存

默认开启，在session的`close`之前都有效，如果是查询相同的数据，直接在缓存中拿。

## 二级缓存

需要手动开启和配置，基于`namespace`级别，有`Cache`接口来自定义实现。
