---
title: vue03
date: 2020-01-18 21:18:36
categories: Vue
tags: vue
---

vue组件化开发

<!-- more -->

# 序

- 组件化开发思想
- 组件的注册方式
- 组件的数据交互方式
- 组件插槽的用法
- Vue调试工具的用法
- 组件的方式实现业务功能

# 组件化开发思想

- 标准
- 分治
- 重用
- 组合

写的代码要尽可能多的重用。

## 组件化规范

Web Components: 通过创建封装好功能的定制元素解决重用问题。但是目前还没有被浏览器广泛支持。vue实现了它的部分规范。

## 组件注册

#### 全局组件注册语法

```js
Vue.component(component_name,{
    data: component_data,
    template: template_content
})
```

e.g.

```ls
//定义一个名为button-counter的新组件
Vue.component('button-counter',{
data: function(){
	reuturn{
		count; 0
	}
},
template: '<button v-on:click="count++">clicked{{count}}times.</button>'
})
```

使用

```js
<div id="app">
    <button-counter></button-counter>
</div>
```

- 组件可以重复用，且数据是独立的。
- data是函数
- 组件模板内容必须是单个根元素，可以是`模板字符串`。
  - 模板字符串：增强可读性(反引号内，可以换行)
- 如果使用驼峰式命名组件，在使用时只能在`字符串模板`中使用，在普通的标签模板中，必须使用`短横线`的方式。

#### 局部组件注册

```js
new Vue({
    el: '#app'
    components:{
    'component-a': componentA,
    'component-b': componentB,
}
})
```

e.g.

```js
<hello-tom></hello-tom>

var HelloTom = {
    data:function(){
        retrun {
            msg: 'HelloTom'
        }
    },
    template:'<div>{{msg}}</div>'
}

var vm = new Vue({
    el: '#app',
    data:{
        
    },
    components: {
        'hello-tom': HelloTom
    }
})
```

- 局部定义的组件只能在它的父组件中使用。（如果定义了全组组件，不能在其中使用）

### DEVTOOLS

[Vue插件](https://github.com/vuejs/vue-devtools)，帮助查看复杂组件之间的关系。

## 组件间数据交互

组件间的关系：父子，兄弟。

组件内部通过props接收传递过来的值

```js
Vue.component("menu-item",{
    props: ['title'],
    template: '<div>{{title}}</div>'
})
```

### 父组件通过属性将值传递给子组件

```js
<menu-item title='data from father'></menu-item>
<menu-item :title="title"></menu-item>
```



props传递数据原则：单向数据流。

### 子组件向福组件传值

通过自定义事件向父组件传递信息

```js
<button v-on:click='$emit("enlarge-text")'>enlarge text</button>
```

```js
<button v-on:click='$emit("enlarge-text",0.1)'>enlarge text</button>
```



父组件监听子组件的事件

```js
<menu-item v-on:enlarge-text='fontsize += 0.1'></menu-item>
```

```js
<menu-item v-on:enlarge-text='fontsize += $event'></menu-item>
```

### 兄弟组件间传值

单独的事件中心管理组件间的通信

```js
var eventHub = new Vue()
```

监听事件与销毁

```js
eventHub.$on('add-todo',addTodo)
eventHub.$off('add-todo')
```

触发事件

```js
eventHub.$emit('add-todo',id)
```

## 组件插槽

### 基本用法

```js
Vue.component('alert-box',{
    template:`
		<div class="demo-alert-box">
			<strong>Error!</strong>
			<slot></slot>
		</div>`
})
```

### 插槽内容

```js
<alert-box>Something bad happened.</alert-box>
```

```js
<body>
    <div id="app">
        <alert-box>it's a bug</alert-box>
        <alert-box>sythntax mistakes</alert-box>
        <alert-box></alert-box>
    </div>
    <script type="text/javascript" src="js/vue.js"></script>
    <script type="text/javascript">

        Vue.component('alert-box',{
            template:`
                <div>
                    <strong>ERROR: </strong>
                    <slot>defautl mistakes</slot>
                </div>
            `
        })
        var vm = new Vue({
            el: '#app',
            data:{

            }
        });
    </script>
    
</body>
```

### 具名插槽

#### 插槽定义

```js
<div class="container">
    <header>
    	<slot name="header"></slot>
	</header>
	<main>
            <slot></slot>
	</main>
	<footer>
            <slot name="footer"></slot>
	</footer>
</div>
```

#### 插槽内容

```js
<base-layout>
    <h1 slot="header">title content</h1>
	<p>main content 1</p>
	<p>main content 2</p>
	<p slot="footer">bottom content</p>
</base-layout>
```

### 作用域插槽

应用场景：父组件对子组件的内容进行加工处理

#### 插槽定义

```js
<ul>
    <li v-for="item in list" v-bind:key="item.id">
        <slot v-bind:item="item">
            {{item.name}}
         </slot>
	</li>
</ul>
```

#### 加工处理

 ```js
<fruit-list :list='list'>
            <template slot-scope='slotProps'>
                <strong class='current' v-if='slotProps.item.id == 2'>{{slotProps.item.name}}</strong>
            </template>
        </fruit-list>
 ```



# 购物车

组件化方式实现业务需求

根据业务功能进行组件化划分

- 标题（展示文本）
- 列表（展示、数量变更、删除）
- 结算（计算商品总额）



















