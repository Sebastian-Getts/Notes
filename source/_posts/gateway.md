---
title: gateway
date: 2022-11-25 17:50:49
categories: springcloud
tags: gateway
---

这篇整理sringcloud家族中的gateway，梳理一下它的功能是使用方法，主要参照[官方手册](https://docs.spring.io/spring-cloud-gateway/docs/current/reference/html/#gateway-starter)。原理和源码放在其他篇章。

<!-- more -->

## 核心概念
- Route
- Predicate
- Filter

路由由predicate和filter组合定义而成，之前做过spring security的集成，在Gateway这里与之原理类似，通过一系列过滤器来实现具体需求，predicate与java8中的断言是一样的，换句话说，predicate就是用java8中的断言来实现的。另外，之所以说与spring security类似，是因为在Gateway中摈弃了经典的servlet容器，内部使用了Netty。

### 内置实现
在我们自定义功能之前，Gateway有Spring中一如既往的风格，约定大于配置，有了一些开箱即用的功能。需要注意的是，这些都是需要在配置文件中配置的。
#### predicate
允许我们实用已有的规则匹配，如时间前后、时间区间、请求头、请求参数、请求类型、远程地址等。
```yaml
spring:
  cloud:
    gateway:
      routes:
      - id: xforwarded_remoteaddr_route # destination
        uri: https://example.org
        predicates:
        - After=2017-01-20T17:42:47.789-07:00[America/Denver]
        # - Before=2017-01-20T17:42:47.789-07:00[America/Denver]
        # - Between=2017-01-20T17:42:47.789-07:00[America/Denver], 2017-01-21T17:42:47.789-07:00[America/Denver]
        # - Cookie=chocolate, ch.p
        # - Header=X-Request-Id, \d+
        # - Host=**.somehost.org,**.anotherhost.org
        # - Method=GET,POST
        # - Path=/red/{segment},/blue/{segment}
        # - Query=green
        # - RemoteAddr=192.168.1.1/24

```
#### Filter
内置的过滤器可以让我们**通过配置来对请求和响应做出一些修改**。超多内置的过滤器可以看[这里](https://github.com/spring-cloud/spring-cloud-gateway/tree/main/spring-cloud-gateway-server/src/test/java/org/springframework/cloud/gateway/filter/factory)。常用内置过滤器如添加请求头、添加响应头、跨域处理、头部替换、流量控制、重定向等等。

## 实用方案
利用网关能做出来的实用有效的东西。
### 流量控制
默认会结合redis用**令牌桶**的方式，内置的过滤器为`RequestRateLimiter`，在使用时需要引入`spring-boot-starter-data-redis-reactive`依赖。配置例如：
```yml
spring:
  cloud:
    gateway:
      routes:
        - id: requestRateLimiter
          uri: http://localhost:8080
          predicates:
            - Path=/book/**
          filters:
            -name: RequestRateLimiter
            args:
              redis-rate-limiter.replenishRate: 1 # 生成令牌的速率
              redis-rate-limiter.burstCapacity: 2 # 桶容量大小
              key-resolver: "#{@pathKeyResolver}" # 这里可以在代码中配置bean，选择使用ip或者uri来进行限流
```
```java
    @Bean
    public KeyResolver pathKeyResolver() {

        return exchange -> Mono.just(exchange.getRequest().getURI().getPath());
    }
```

## 高可用部署方案
网关多启动几个来做集群，为分担负载，网关的前面用Nginx做代理。

### 网关与注册中心
在作为destination的URI中，我们实用域名而非IP，并且在配置中支持与注册中心联动。

## 其他网关
