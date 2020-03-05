---
title: resolveXML
date: 2019-11-13 23:41:20
categories: Java
tags: xml
---

最近解析xml，有点碰壁，源于粗心。。要注意变量的声明位置

<!--more-->

# Dom4j

一般用来解析，其实也可以用来构造xml。还会用到Document和DocumentHelper。

## 构造

待开发。。。

## 解析

对象：

1. SAXReader：读取xml文件到Document树结构文件对象
2. Document：xml文档对象树，类比html文档对象
3. Element：元素节点

步骤：

1. 创建解析器

   ```java
   SAXReader reader = new SAXReader();
   ```

2. 通过解析器read方法获取Document对象

   ```java
   Document doc = reader.read("abc.xml");
   ```

3. 获取xml根节点

   ```java
   Element root = doc.getRootElement();
   ```

4. 遍历解析子节点

{% note warning %}

实际中多采用 *doc = DocumentHelper.parseText(response)* 来解析字符串中的xml

{% endnote %}

