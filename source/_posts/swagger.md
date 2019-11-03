---
title: swagger
date: 2019-11-02 22:51:41
categories: 
- 技术
- explore
tags:
- swagger
- SpringBoot
---
# SWAGGER

## 前后端分离

Vue + SpringBoot



后端时代：前端只有管理静态页面；模板引擎jsp



前后端分离时代：

- 后端：后端控制层、服务层、数据访问层
- 前端：前端控制层，视图层
  - 伪造后端数据，json。不需要后端，前端一九能够跑起来
- 前后端交互：api
- 前后端相对独立，松耦合
- 前后端甚至可以部署在不同的服务器上

产生一个问题：

- 前后端集成联调，前后端人员无法做到及时协商

解决方案：

- 首先指定schema（计划的提纲），实时更新api
- 早些年，指定word文档计划
- 前后端分离
  - 前端测试后端接口：postman
  - 后端提供接口，需要实时更新最新的消息及改动

## swagger

restful api 文档在线自动生成工具

在项目使用swagger需要springfox

- swagger2
- ui

#### springboot集成swagger

导入相关依赖：

```xml
<!-- https://mvnrepository.com/artifact/io.springfox/springfox-swagger2 -->
<dependency>
    <groupId>io.springfox</groupId>
    <artifactId>springfox-swagger2</artifactId>
    <version>2.9.2</version>
</dependency>

<!-- https://mvnrepository.com/artifact/io.springfox/springfox-swagger-ui -->
<dependency>
    <groupId>io.springfox</groupId>
    <artifactId>springfox-swagger-ui</artifactId>
    <version>2.9.2</version>
</dependency>

```

#### 配置swagger

swagger的实例**docket**

##### 配置swagger信息

新建一个关于swagger的配置类

```java
@Configuration
@EnableSwagger2
public class SwaggerConfig {

    @Bean
    public Docket docket() {
        return new Docket(DocumentationType.SWAGGER_2)
                .apiInfo(apiInfo());
    }

    private ApiInfo apiInfo() {
        Contact contact = new Contact("Sebastian", "https://www.raspberrypi.org/", "2573992956@qq.com");
        return new ApiInfo("Sebastian's api document", "FUN SWAGGER", "1.1",
                "http://www.baidu.com", contact, "Apache 2.0",
                "http://www.bing.com", new ArrayList());
    }
}
```

##### 配置扫描接口及开关

Docket.select()

>  RequestHandlerSelectors //配置要扫描接口的方式

源码涉及[链式调用](https://www.jb51.net/article/49405.htm)

```java
@Bean
public Docket docket() {
    return new Docket(DocumentationType.SWAGGER_2)
        .apiInfo(apiInfo())
        .enable(false)
        .select()
        .apis(RequestHandlerSelectors.basePackage("com.sunday.personal.tuesday.controller"))
        //                .paths(PathSelectors.ant("/com/sunday/personal/tuesday/config/*"))
        .build(); //build
}
//basePackage, 扫描路径中的
//any，扫描全部
//withClassAnnotation(RestController.class)，扫描类上有…的类
//withMethodAnnotation(...)，扫描方法上有…的类
```



<u>只在测试环境使用swagger：</u>

```java
@Bean
public Docket docket(Environment environment) {


    //TODO:设置要显示的swagger环境
    //Profiles profiles = Profiles.of("dev");

    //获取项目的环境
    boolean flag = environment.acceptsProfiles(); //acceptsProfiles(profiles)

    return new Docket(DocumentationType.SWAGGER_2)
        .apiInfo(apiInfo())
        .enable(false)
        .select()
        .apis(RequestHandlerSelectors.basePackage("com.sunday.personal.tuesday.controller"))
        //                .paths(PathSelectors.ant("/com/sunday/personal/tuesday/config/*"))
        .build(); //build
}
```

#### 配置api分组

```java
@Bean
public Docket docket2(){
    return new Docket(DocumentationType.SWAGGER_2).groupName("crm");
}

@Bean
public Docket docket1(){
    return new Docket(DocumentationType.SWAGGER_2).groupName("pay");
}

@Bean
public Docket docket() {


    //TODO:设置要显示的swagger环境
    //        Profiles profiles = Profiles.of("dev");

    //获取项目的环境
    //        boolean flag = environment.acceptsProfiles(); //acceptsProfiles(profiles)

    return new Docket(DocumentationType.SWAGGER_2)
        .apiInfo(apiInfo())
        .groupName("interface")
        .enable(true)
        .select()
        .apis(RequestHandlerSelectors.basePackage("com.sunday.personal.tuesday.controller"))
        .build(); //build
}
```

#### 实体类配置

@Api...注释