---
title: restful
date: 2019-11-28 22:17:48
categories: Java
tags:
- http
- swagger
---

restful风格的项目要前后端分离，前后端的http请求类型要清楚==。。。好像以用有8种。

<!-- more -->

# 序

rest: Representational State Transfer

所有东西都是资源，所有操作都通过对资源的增删改查（CRUD）来实现，与其对应的URL操作是POST, DELETE, PUT, GET，且所有操作都是无状态的。

## POST

新增

数据存放于**请求正文**，意味着可以放**大量数据**且**不限类型**，安全性高。

- 传输任意类型数据，包括声音、图片等
- 数据量大，，理论上无上限
- 安全性高
- 客户端浏览器不会对POST请求进行缓存。

```java
@PostMapping("/addr")
public String editAddr(@RequesetBody Map<String, String> map){
    System.out.println(map.get("addr"));
}
```



## GET

获取

他的特点和缺点都很明显（==特点就是缺点？）

- 参数值只能是字符串，而不能是其他类型
- 可以携带的数据量小（因为是在地址栏输入）
- 数据安全性低
- 会使用缓存，第一次打开的时候会下载相关信息（css，image…），提高用户体验

```java
@GetMapping("/homepage/storage/{id}")
public string getDetails(@PathVariable("id") String id){
    return id;
}
```



## PUT

修改

## DELETE

删除，同get请求。

## Q&A

登录/退出如何设计？

登录的过程无非就是向服务器 端索要授权，退出就是服务端注销授权。所以

```markdown
POST/authorization 登录
DELETE/authorizatio 退出
```

命名？

/资源名称/资源ID

对GET缓存而不对POST缓存？

同restful的含义，POST一般是上传（新增）资源，GET是获取资源，浏览器对POST缓存是没有意义的。

## 命令行工具

### CURL

方便用来测试非get请求的api，e.g.

```bash
curl -H "Content-Type:application/json" -X POST --data'{"name":"Qin"}' http:127.0.0.1:8888/getName/
```

其中`-H`是表示请求头的信息，指出参数类型，`-X`后添加请求类型，GET请求可以不用指明。

```bash
curl -X DELETE https://127.0.0.1:8080/apache/tomcat
```



