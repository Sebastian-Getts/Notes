---
title: thymeleaf01
date: 2019-11-13 22:25:42
categories: frontend
tags:
- springboot
- thymeleaf
---

thymeleaf，一种新型模板引擎。参考资料：usingthymeleaf。

reference: [project web site](https://www.thymeleaf.org)

<!-- more -->

# Standard Expression Syntax

```java
public class ThymeleafProperties {
    private static final Charset DEFAULT_ENCODING = Charset.forName("UTF-8");
    private static final MimeType DEFAULT_CONTENT_TYPE = MimeType.valueOf("text/html");
    public static final String DEFAULT_PREFIX = "classpath:/templates/";
    public static final String DEFAULT_SUFFIX = ".html";
```

只要把html页面放在指定类路径下，thymeleaf就会自动渲染。

note：加了@Response注解的返回的是字符串，而不是页面。同理，如果使用@RestController会导致显示文字。

名称空间：

```xml
<html xmlns:th="http://www.thymeleaf.org">
```

## 使用

```html
<!DOCTYPE html>
<html lang="en" xmlns:th="http://www.thymeleaf.org">
<head>
    <meta charset="UTF-8"/>
    <title>templates</title>
</head>
<body>
<h2>hi, thymeleaf~</h2>
<div th:text="${who}">nice to meet u~</div>
<div th:utext="${who}"></div>
<hr/>

<h4 th:text="${consumer}" th:each="consumer:${consumer}"></h4>
<hr/>
<h4>
    <span th:text="${consumer}" th:each="consumer:${consumer}"></span>
</h4>
</body>
</html>
```

1. th:text 改变当前元素里面的文本内容
2. th:insert 片段包含
3. th:each 遍历
4. th:if 条件判断
5. th:object 声明变量
6. th:attr 任意属性修改，支持prepend、append
7. th:value 修改指定属性默认值
8. th:text 修改标签体内容（utext，不转义特殊字符）
9. th:fragment 声明片段

## 表达式

 ```properties
Simple expressions:
    Variable Expressions: ${...} 获取变量值：OGNL
    Selection Variable Expressions: *{...} 选择表达式，在功能上与dollar符号相同
    Message Expressions: #{...}
    Link URL Expressions: @{...}
    Fragment Expressions: ~{...}
Literals: 字面量
    Text literals: 'one text' , 'Another one!' ,…
    Number literals: 0 , 34 , 3.0 , 12.3 ,…
    Boolean literals: true , false
    Null literal: null
    Literal tokens: one , sometext , main ,…
Text operations: 文本操作
    String concatenation: +
    Literal substitutions: |The name is ${name}|
Arithmetic operations: 数学运算
    Binary operators: + , - , * , / , %
    Minus sign (unary operator): -
Boolean operations: 布尔运算
    Binary operators: and , or
    Boolean negation (unary operator): ! , not
Comparisons and equality: 比较运算
    Comparators: > , < , >= , <= ( gt , lt , ge , le )
    Equality operators: == , != ( eq , ne )
Conditional operators: 条件运算			
    If-then: (if) ? (then)
    If-then-else: (if) ? (then) : (else)
    Default: (value) ?: (defaultvalue)
Special tokens:
Page 17 of 106
No-Operation: _
 ```



### Variable Expressions

${...} belongs to OGNL (Object-Graph Navigation Language)，more about OGNL, reference [it]( http://commons.apache.org/proper/commons-ognl/ ).

### Selection Variable Expressions

```html
<div th:object="${session.user}">
	<p>Name: <span th:text="*{firstName}">Sebastian</span>.</p>
	<p>Surname: <span th:text="*{lastName}">Pepper</span>.</p>
	<p>Nationality: <span th:text="*{nationality}">Saturn</span>.</p>
</div>
```

### Message Expressions

主要用来取国际化信息。