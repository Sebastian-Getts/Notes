---
title: http
date: 2019-11-06 00:11:40
categories: CS
tags:
- request
- session
---

## HTTP

虽然在校学习过计算机网络相关的知识，但是，纸上谈兵终觉浅，关于http的请求，会在代码中见到request、response、session，甚至还有cookie，今天好好把它撸顺 =。=

<!--more-->

## Request, Response

只是一个请求，请求完毕后，request里面的内容也将被释放。

重点是`HttpServletRequest`：它的对象代表客户端的请求，当客户端通过HTTP协议访问时，HTTP请求头中的信息都封装在这个对象中，我们可以通过这个对象的方法，获取请求信息。所以，要想得到浏览器信息，就要找到对象。[reference]( https://mp.weixin.qq.com/s/CnZeDQCi0x4Wq3N_JeGbEw ).

`HttpServletResponse`：它的对象代表http的响应，向浏览器输出数据，找response对象。由状态行、实体内容、消息头、一个空行组成（好像回到了课堂？）。



## Session

