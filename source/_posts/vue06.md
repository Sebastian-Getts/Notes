---
title: vue06
date: 2020-01-19 18:20:17
categories: Vue
tags: vue
---

vue工程化

<!-- more -->

# 序

- 模块化规范
- webpack
- vue单文件组件
- vue脚手架
- element-ui

# 模块化

- 传统模式

  多个js文件存在**命名冲突**，**文件依赖**等问题

- 模块化

  把单独的一个功能封装到一个模块（文件）中，模块之间互相隔离，但是可以通过特定的接口公开内部成员，也可以依赖别的模块。方便代码重用，提升开发效率，便于后期维护。

## 浏览器模块化规范

AMD， CMD

## 服务器端模块化规范

CommonJS

## ES6模块化规范

大一统。浏览器与服务器端通用。

- 每个js文件都是一个独立的模块
- 导入模块成员使用import关键字
- 暴露模块成员使用export关键字

### babel

node.js对es6的支持不是很好，需要第三方插件来转化。

babel：语法转化工具，可以把高级的有兼容性的转化为低级的没有兼容器的代码。

# webpack

前端项目构建工具（打包工具）。

# vue单文件组件

后缀，`.vue`，构成：

- template 组件的模板区域

- script 业务逻辑区域

- style 样式区域

  ```html
  <style scoped></style>
  <!--防止与其他组件起冲突-->
  ```

```html
<template>
	<div>
        <h1>
            这是app根组件
        </h1>
    </div>
</template>
<script>
export default{
    data(){
        return {};
    },
    methods:{}
}
</script>
<style scoped>
    h1{
        color: red;
    }
</style>
```





