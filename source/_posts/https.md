---
title: https
date: 2020-03-14 10:43:29
categories: Network
tags: ['http','https']
---

**Hypertext Transfer Protocol Secure**, an extension of the Hypertext Transfer Protocol. 

How to encrypt communication? Through referred to as **HTTP over TLS**, or **HTTP over SSL**

- Transport Layer Security
- Secure Sockets Layer

<!-- more -->

# HTTP与HTTPS



## Difference

HTTPS的URL地址开头是`https://`，默认使用的的端口是`443`，在http与TCP之间加入了SSL或者TSL，它的设计就是为了防止信息被窃取，会对包括header在内的整个信息加密。

---

HTTP的URL地址开头是`http://`，默认使用的端口是`80`，他没有使用加密，直接通过TCP来进行传输，因此传输过程中的敏感信息有被窃听、攻击的风险。



## Limitation

SSL/TSL没有禁止网络搜索器（website crawler）搜索它的索引，所以在这种情况下，请求和响应的报文的大小是会被知晓的（内容仍然加密无法破解）。



# URI、URL与URN

url是uri的子集。

## URI

统一资源标识符。*A string of characters that unambiguously identifies a particular resource*.  它规定了一些特定的语法规则，并且在规则下还可以自有扩展，例如`http://`。

## URN

统一资源名称。*A Uniform Resource Name(URN) is a URI that identifies a resource by name in a particular namespace.* 它能标识一个唯一的名称，但不清楚它的位置。

## URL

统一资源定位符。*A Uniform Resource Locator(URL) is a URI that specifies the means of acting upon or obtaining the representation of a resource.* 就是我们常见的http请求地址。

[reference](https://en.wikipedia.org/wiki/Uniform_Resource_Identifier)