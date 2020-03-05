---
title: vue01
date: 2020-01-17 12:55:47
categories: Vue
tags: vue
---

vue learning... 渐进式JavaScript框架, [reference](https://cn.vuejs.org/v2/guide)

<!-- more -->

# 序

渐进：声明式渲染->组件系统->客户端路由->集中式状态管理->项目构建

# 使用

### 原生JS：

```js
<div id="msg"></div>
<script type="text/javacript">
    var msg = 'Hello World';
	var div = document.getElementById('msg');
	div.innerHTML = msg;
</script>
```

---

### jQuery：

```javascript
<div id="msg"></div>
<script type="text"/javascript" src="js/jquery.js"></srcipt>
<script type="text/javascript">
    var msg = 'Hello World';
	$('#msg').html(msg);
</script>
```

jQuery对原生进行封装。

---

### Vue.js:

```javascript
<div id="app">
    <div>{{msg}}</div>
</div>
<script type="text/javascript" src="js/vue.js"></script>
<script type="text/javascript">
    new Vue({
    	el: '#app',
    	data:{
            msg: 'Hello world'
        }
})
```

#### 步骤：

1. 需要提供标签用于填充数据
2. 引入vue.js库文件
3. 可以使用vue的语法做功能了
4. 把vue提供的数据填充到标签里面

不再涉及底层的DOM操作。

#### 实例参数：

- el：元素的挂载位置（一般是css选择器）
- data：模型数据（值是一个对象）

#### 差值表达式：

- 将数据填充到html标签中
- 差值表达式支持基本的计算操作（花括号中可是js运算）

#### 编译：

vue代码->vue框架->原生js代码

---

## 模板语法

前端渲染：

把数据填充到HTML标签中。

- 原生js拼接字符串
- 使用前段模板引擎
- 使用vue特有的模板引擎

语法概览：

- 差值表达式
- 指令
- 事件绑定
- 属性绑定
- 样式绑定
- 分支循环结构

### 指令

本质就是自定义属性，格式：以v-开始（比如：v-cloak）

#### v-cloak

- 差值表达式存在的问题：闪动
- 使用该指令可以解决
- 原理：先隐藏，替换好值之后再显示最终的值

[reference](https://cn.vuejs.org/v2/api/#v-cloak)

1. 提供样式
2. 在差值表达式所在标签中添加v-cloak指令

```javascript
<style type="text/css">
    [v-cloak]{
        display: none;
    }
</style>
...
<body>
    <div id="app">
        <div v-cloak>{{msg}}</div>
	</div>
</body>
```

#### v-text

```javascript
<div v-texxt='msg'><div>
```

效果跟差值表达式一样，但是没有差值表达式的闪动问题，用户体验更好。

#### v-html

填充HTML的片段。会解析。但是会有一定的危险性，容易导致`XSS`（跨站脚本攻击）。本网站内部数据可以使用，第三方的数据不可以用。

```javascript
<div v-html='msg1'></div>

data:{
    msg1:'<h1>HTML</h1>'
}
```

#### v-pre

填充原始信息。例如：不解析花括号。跳过编译。

```javascript
<div v-pre>{{msgg}}</div>
```

#### 数据响应式

- 如何理解
  - html5中的响应式（屏幕尺寸变化导致样式的变化）
  - 数据的响应式（数据的变化导致页面内容的变化）
- 数据绑定：将数据填充到标签中
- v-once：只编译一次，显示内容之后不再具有响应式功能

响应式：f12后在控制台也可以修改数据，，例如：`vm.msg`，`vm.msg=123`。数据变化后页面也会跟着变化，数据驱动。

v-once就是为了防止在控制台修改数据，这样可以提高性能。

### 双向数据绑定

双向：数据->页面，用户修改内容->影响模型数据

#### v-model

```js
<div>
    <input type="text" v-model='msg'>
</div>
```

#### MVVM

M(model) : data中的数据，本质是plain javascript objects

V(view) ： 视图，模板，本质是dom元素

VM(View-Model)： 是两者的结合，控制能力。两者本不能直接交互，所以有了vue进封装（底层是DOM Listen, Data Bindings）。

### 事件绑定

#### v-on

```js
<input type='button' v-on:click='num++'/>

<input type='button' @click='nunm++'/>
```

```js
<div>{{num}}</div>
<div>
    <button v-on:click='num++'>click</button>
</div>

data:{
    num:0
}
```

####  方法

**methods**用来写方法，抽取“num++”放在方法中，增加可读性。

```js
methods:{
    handle: function(){
        this.num++; //this means vue object vm.
    }
}
```



调用方式有两种

- 直接绑定函数名称

  ```js
  <button v-on:click='say'>Hello</button>
  ```

  

- 调用函数

  ```js
  <button v-on:click='say()'>Say hi</button>
  ```

  

#### 事件函数传参

普通参数和事件对象（event）

```js
<button v-on:click='say("hi", $event)'>Say hi</button>
```

`$event`为固定写法。

1. 如果事件直接绑定函数名称，那么会默认船体事件对象作为事件函数的第一个参数
2. 如果事件绑定函数调用（没加括号），那么事件对象必须作为最后一个参数显示传递，并且事件对象的名称必须是`$event`。

#### 事件修饰符

- stop 阻止冒泡

  ```js
   <a v-on:click.stop="handle">jump</a>
  ```

  

- prevent 阻止默认行为

  ```js
  <a v-on:click.prevent="handle">jump</a>
  ```

冒泡

```js
<div v-on:click='handle0'>
    <button v-on:click='handle1'>click</button>
</div>
<div>
    <a href="http://www.google.com" v-on:click='handle2'>google</a>
</div>

methods:{
    handle0: function(){
        this.num++;
    },
    handle1:function(event){
        event.stopPropagation(); //traditional
    },
    handle2:function(event){
        event.preventDefault();
    }
}
```

点击button后会冒泡，触发父元素的div中的`handle0`.

传统的形式是`event.stopPropagation()`，在vue中可以使用`v-on:click.stop`。

#### 按键修饰符

用在键盘事件中进行过滤（指定），按键触发函数。

- .enter

  ```js
  <input v-on:keyup.enter='submit'>
  ```

  

- .delete

  ```js
  <input v-on:keyup.delete='handle'>
  ```

...

#### 自定义按键修饰符

```js
Vue.config.keyCodes.f1 = 112
```

```js
<input type='text' v-on:keyup='handle'>

methods:{
    handle:function(event){
        console.log(event.keyCode)//利用keyCode自定义
    }
}

<input type='text' v-on.keyup.65='handle'>
    
```



### 计算器

- 通过`v-model`指令实现数值之间的绑定
- 给计算按钮绑定事件，实现计算逻辑
- 将计算结果绑定对应位置

```js
 <!DOCTYPE html>
 <html lang="en">
     <head>
         <meta charset="UTF-8">
         <title>Document</title>
     </head>
     <body>
         <div id="app">
             <h1>Simple Calculator</h1>
             <div>
                 <span>NUM A: </span>
                 <span>
                     <input type="text" v-model='a'>
                 </span>
             </div>
             <div>
                 <span>NUM B: </span>
                 <span>
                     <input type="text" v-model='b'>
                 </span>
             </div>
             <div>
                 <button v-on:click='handle'>CALCULATE</button>
             </div>
             <div>
                 <span>SOLUTION:</span>
                 <span v-text='result'></span>
             </div>
         </div>
         <script type="text/javascript" src="js/vue.js"></script>
         <script type="text/javascript">
             var vm = new Vue({
                 el: '#app',
                 data: {
                     a: '',
                     b: '',
                     result: ''
                 },
                 methods: {
                     handle: function(){
 
                         this.result = parseInt(this.a) + parseInt(this.b);
                     }
                 }
             });
         </script>
     </body>
 </html>
```

### 属性绑定

#### v-bind

```js
<a v-bind:hreff='url'>jump</a>
<a :href='url'>jump</a>
```

对比一下使用前后，

使用前：

```js
<a href="www.google.com">Google</a>
```

使用后：

```js
<a v-bind:href="url">Google</a>

data:{
    url: 'www.google.com'
}
```

#### 双向绑定原理

v-model的底层用到了`v-bind`.

```js
<input v-bind:value="msg" v-on:input="msg=$event.target.value">
```

```js
<input type="text" v-bind:value="msg" v-on:input='handle'>
    
data:{
    msg: 'hello'
},
methods: {
    handle: function(event){
        this.msg = event.target.value;
    }
}
```



### 样式绑定

#### class样式处理

对象语法：

```js
<div v-bind:class="{active: isActive}"></div>
```

数组语法：

```js
<div v-bidn:class="[activeClass, errorClass]"></div>
```

简化class绑定的值：

```js
<div v-bind:class='arrClasses'></div>

data:{
    arrClasses:['active','error']
}
```

```js
<div v-bind:class='obejctClasses'></div>

data:{
    objectClasses:{
        active: true,
        error: true
    }
}
methods: {
    handle: function(){
        this.objectClasses.error = false;
    }
}
```

全局定义的默认class会被保留，新绑定会和默认的结合在一起。

#### style样式处理

对象语法：

```js
<div v-bind:style="{color:activeColor, fontSize:fontsize}"></div>
```

数组语法：

```js
<div v-bind:style="[basestyles, overridignstyles]"></div>
```

### 分支结构

- v-if 控制元素是否渲染到页面
- v-else-if 同上
- v-else 同上
- v-show：控制元素样式是否显示 display:none。已经渲染到页面

频繁的显示或隐藏：`v-show`

### 循环结构

v-for遍历数组

```js
<li v-for='item in list'>{{item}}</li>
```

```js
<li v-for='(item, index) in list'>{{item}} + '---'+{{index}}</li>
```

key来帮助Vue区分不同元素，从而提高性能。

```js
<li :key='item.id' v-for='(item, index) in list'>{{item}}+'--'+{{index}}</li>
```

e.g.

```js
<li v-for='item in frutits'>{{item}}</li>
<li v-for='(item,index) in fruits'>{{item+'---'+index}}</li>

data:{
    fruits:['apple','orange','banana']
}
```

```js
<li v-for='item in my fruits'>
    <span>{{item.ename}}</span>
	<span>{{item.cname}}</span>
</li>

data:{
    myfrutis:[{
        ename:'apple',
        cname:'苹果'
    }]
}
```

v-for遍历对象：

```js
<div v-for='(value, key, index) in object'></div>
```

与`v-if`结合使用：

```js
<div v-if='value==12' v-for='(value, key, index) in object'></div>
```













