---
title: vue02
date: 2020-01-17 23:21:24
categories: vue
tags: vue
---

vue常用特性

<!-- more -->

# 序

- 表单操作
- 自定义指令
- 计算属性
- 过滤器
- 侦听器
- 生命周期 

# 表单操作

用户交互的时候用到表单操作。

### 基于vue的表单操作

- input单行文本
- textarea多行文本
- select下拉多选
- radio单选框
- checkbox多选框

### 表单域修饰符

- number: 转化为数值
- trim: 去掉开始和结尾的空格
- lazy: 将input事件切换为change事件

```js
<input v-model.number="age" type="number">
```

lazy使用场景：注册时校验用户名是否被注册过，当失去焦点时开始检测。

### 自定义指令

```js
<input type="text" v-focus>

Vue.directive('focus',{
    inserted: funciton(el){
    el.focus();
}
})
```

### 计算属性

表达式的计算逻辑可能会比较复杂，使用计算属性可以使模板内容更加简洁。

```js
<div>{{reverseString}}
data:{
    msg:'hello'
},
computed:{
    reverseString: function(){
        return this.msg.split('').reverse().join('');
    }
}
```

与方法的区别：缓存上的差异，方法不存在缓存。对于**同样的数据**，多次访问只用到一次的结果，而方法会执行两次。

### 侦听器

和计算属性类似，数据变化会通知侦听器绑定的方法。

应用场景：异步或开交较大的操作。

```js
watch:{
    fisrName:function(val){
        this.fullName = val + this.lastName;
    },
     lastName:function(vla){
         this.fullName = this.firstName + val;
     }
}
```

#### 应用场景：验证用户名是否可用。

- 通过`v-model`实现数据绑定
- 需要提供提示信息
- 需要侦听器监输入信息的变化
- 需要修改触发的事件

```js
<body>
    <div id="app">
        <div>
            <span>username: </span>
            <span>
                <input type="text" v-model.lazy='username'>
            </span>
            <span>{{tip}}</span>
        </div>
    </div>
    <script type="text/javascript" src="js/vue.js"></script>
    <script type="text/javascript">

        var vm = new Vue({
            el: '#app',
            data: {
                username:'',
                tip:''
            },
            methods:{
                checkName:function(username){
                    //接口调用，用定时任务的方式模拟接口调用
                    var that = this;
                    setTimeout(function(){
                        if(username == 'admin'){
                            that.tip = 'change it';
                        }else{
                            that.tip = 'ok';
                        }
                    },2000);
                }
            },
            watch:{
                username:function(val){//当数据变化时会触发
                    //调用后台验证
                    this.checkName(val);
                    this.tip = 'checking...';
                }
            }
        })
    </script>
</body>
```

### 过滤器

#### 自定义过滤器（全局）

```js
Vue.filter('filterName'function(value){
    //logic...
})
```

局部过滤器

```js
filters:{
    capitalize:function(){
        ...
    }
}
```

使用

```html
<div>{{msg|upper}}</div>
<div>{{msg|upper|lower}}</div> <!-- 级联 -->
<div v-bind:id="id|formatId"></div>
```



#### 带参数过滤器

```js
Vue.filter('format',function(value, arg1){
    
})
```

使用

```html
<div>
    {{date | format('yyyy-MM-dd')}}
</div>
```

### 声明周期

- 挂载
- 更新
- 销毁

### 修改响应式数据

```js
Vue.set(vm.items, indexOfItem, newValue)
```

```js
vm.$set(vm.items, indexOfItem, newValue)
```

参数一表示要处理的数组名称，参数二表示要处理的数组索引，参数三表示要处理的数组的值。

### library

#### 变异方法

push(), pop(), shift(), unshift(), splice(), sort(), reverse()

#### 替换数组（生成新的数组）

filter(), concat(), slice()

```js
this.list = this.list.slice(0,2)
```

#### 图书列表

- 静态列效果
- 基于数据实现模板效果
- 处理每行的操作按钮

#### 添加图书

- 实现表单的静态效果
- 添加图书表单域数据绑定
- 添加按钮事件绑定
- 实现添加业务逻辑

#### 修改图书

- 修改信息填充到表单
- 修改后重新提交表单
- 重用添加和修改的方法

#### 常用特性应用

- 过滤器（格式化日期）
- 自定义指令（获取表单焦点）
- 计算属性（统计图书数量）
- 侦听器（验证图书存在性）
- 生命周期（图书数据处理）  



# library.html

```js
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <title>Document</title>
    <style type="text/css">
        .grid {
            margin: auto;
            width: 500px;
            text-align: center;
        }

        .grid table {
            width: 100%;
            border-collapse: collapse;
        }

        .grid th,td {
            padding: 10;
            border: 1px dashed rgb(224, 182, 105);
            height: 35px;
            line-height: 35px;
        }

        .grid th {
            background-color: rgb(255, 207, 117);
        }

        .grid .book {
            padding-bottom: 10px;
            padding-top: 5px;
            background-color: rgb(236, 192, 111);
        }
        .grid .total{
            height: 30px;
            line-height: 30px;
            border-top: 1px solid rgb(173, 139, 69);
            background-color: rgb(196, 153, 75);
        }
    </style>
</head>

<body>
    <div id="app">
        <div class="grid">
            <div>
                <h1>图书管理</h1>
                <div class="book">
                    <div>
                        <label for="id">
                            编号:
                        </label>
                        <input type="text" id="id" v-model='id' :disabled='flag' v-focus>
                        <label for="name">
                            名称:
                        </label>
                        <input type="text" id="name" v-model='name'>
                        <button @click='handle' :disabled='isSubmit'>提交</button>
                    </div>
                </div>
            </div>
            <div class="total">
                <span>图书数量：</span>
                <span>{{total}}</span>
            </div>
            <table>
                <thead>
                    <tr>
                        <th>编号</th>
                        <th>名称</th>
                        <th>时间</th>
                        <th>操作</th>
                    </tr>
                </thead>
                <tbody>
                    <tr :key='item.id' v-for='item in books'>
                        <td>{{item.id}}</td>
                        <td>{{item.name}}</td>
                        <td>{{item.date}}</td>
                        <td>
                            <a href="" @click.prevent='modify(item)'>修改</a>
                            <span>|</span>
                            <a href="" @click.prevent='del(item)'>删除</a>
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>
    <script type="text/javascript" src="js/vue.js"></script>
    <script type="text/javascript">

        Vue.directive('focus',{
            inserted: function(el){
                el.focus();
            }
        })
        var vm = new Vue({
            el: '#app',
            data: {
                isSubmit: false,
                flag: false,
                id: '',
                name: '',
                books: []
            },
            methods: {
                handle: function () {
                    var book = {};
                    if (!this.flag) {
                        book.id = this.id;
                        book.name = this.name;

                        book.date = '',
                        this.books.push(book);
                    } else {
                        this.books.some((item) => {
                            if (item.id == this.id) {
                                item.name = this.name;
                                return true;
                            }
                        }),
                        this.flag = true;
                    }
                    this.id = '',
                    this.name = ''

                },
                modify: function (itemin) {
                    // this.id = books.id;
                    // this.name = books.name
                    this.flag = true;
                    var book = this.books.filter(function (item) {
                        return item.id == itemin.id
                    })
                    this.id = book[0].id;
                    this.name = book[0].name;
                },
                del:function(itemin){
                    // //查找索引
                    // var index = this.books.findIndex(function(item){
                    //     return item.id == itemin.id;
                    // });
                    // //删除
                    // this.books.splice(index, 1);
                    //method2 也可已通过filter来实现
                    this.books = this.books.filter(function(item){
                        return item.id != itemin.id;
                    })

                    this.id = '',
                    this.name = '',
                    this.flag = false;
                }
            },
            computed:{
                total:function(){
                    return this.books.length;
                }
            },
            watch:{
                name: function(val){
                    var flag = this.books.some(function(item){
                        return item.name == val;
                    });
                    
                    if(flag){
                        this.isSubmit = true;
                    }else{
                        this.isSubmit = false;
                    }
                }
            },
            mounted: function(){
                //一般用于获取后台数据，然后把数据填充到模板
                var data = [{
                    id: 1,
                    name: '三国演义',
                    date: ''
                }, {
                    id: 2,
                    name: '水浒传',
                    date: ''
                }, {
                    id: 3,
                    name: '红楼梦',
                    date: ''
                }, {
                    id: 4,
                    name: '西游记',
                    date: ''
                }];
                this.books = data;
            }
        })
    </script>
</body>

</html>
```











