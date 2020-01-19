---
title: vue04
date: 2020-01-19 15:07:46
categories: vue
tags: vue
---

vue的与后端交互。

<!-- more -->

# 序

- 前后端交互模式
- promise用法
- 接口调用-fech用法
- 接口调用-axios用法
- 接口与调用-async/await用法

# 接口调用方式

原生：

- ajax
- 基于jQuery的ajax

new：

- fetch
- axios

## resful形式的url

http请求方式

- GET 查询
- POST 添加
- PUT 修改
- DELETE 删除

符合规则的url

- http://www.hello.com/books GET, POST
- http://www.hello.com/books/1284 PUT, DELTE

note: 传统的url传送数据依赖JSON，与请求方式无关。

## Promise

异步编程的一种解决方案，语法上来讲，，promise是一个对象，可以获取异步操作的消息。[official site](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_objects/Promise)

优点：

- 避免多层异步调用嵌套问题（**回调地狱**）
- promise对象提供了简洁的api

### 基本用法

- 实例化Promise对象，构造函数中传递函数，用于处理异步任务
- `resolve`和`reject`两个参数用于处理成功和失败两种情况，并通过p.then获取处理结果

```js
var p = new Promise(function(resolve, reject){
    //invoke resovle() when success
    //inovke reject() when fail
});
p.then(function(ret){
    //get info from resolve
}, function(ret){
    //get info from reject
});
```

### 常用api

#### api方法

- p.then() 得到异步任务的正确结果
- p.catch() 获取异常信息
- p.finally() 成功与否都会执行

```js
queryData()
.then(function(data){
    console.log(data);;
})
.catch(function(data){
    console.logg(data);
})
.finally(function(){
    cosnole.log('finished');
})
```

#### 对象方法

- promise.all() 并发处理多个异步任务，所有任务都完成才能得到结果
- promise.race() 并发处理多个任务，只要有一个任务完成救就能得到结果

```js
Promise.all([p1,p2,p3]).then((result)=>{
    console.log(result)
})

Promise.race([p1, p2, p3]).then((result) => {
    console.log(result)
})
```

## fetch

传统ajax的升级版，基于promise来实现。

###  语法

```js
fetch(url).then(fn2)
		  .then(fn3)
		  ...
          .cathc(fn)
```

```js
fetch('/abc').then(data=>{
    return data.text();
}).then(ret=>{
    //final data
    console.log(ret);
})
```

**note**: text()方法属于fetch API的一部分，它返回一个promise实例对象，用于获取后台返回的数据。

### 常用配置选项

- method(String): Http request, defautl *GET*
- body(String): Http reqeust parameters
- header(Object): Http request header, defualt {}

```js
fetch('/abc', {
    method: 'get'
}).then(data=>{
    return data.text();
}).then(ret=>{
    console.log(ret);
})
```

#### GET/DELTE

- tranditional:

```js
fetch('/abc?id=123').then(data=>{
    return data.text();
}).then(ret=>{
    console.log(ret);
})
```

- restful:

```js
fetch('/abc/123',{
    method: 'get'
}).then(data=>{
    return data.text();
}).then(ret=>{
    console.log(ret);
})
```



#### POST/PUT

```js
fetch('/books/,{
      method: 'post',
      //body: 'uname=list&pwd=123',
      body: JOSN.stringify({
      	uname: 'lisa',
      	pwd: '123'
      })
      headers:{
      	//'Content-Type': 'application/x-www-form-urlencoded',
          'Content-Type':'application/json'
      }
      }).then(data=>{
          return data.text();
      }).then(ret=>{
          console.log(ret);
      })
```



### 响应数据格式

- text(): 将返回体处理成字符串类型
- json(): 返回结果和JSON.parse(responseText)一样



## axios

referece [official site](https://github.com/axios/axios)

特点：

- 支持浏览器和node.js
- 支持promise
- 能拦截请求和响应
- 自动转换JSON数据

### 基本用法

```js
axios.get('/data')
	.then(ret=>{
    console.log(ret.data)
})
```

使用前需要引入

```js
<script type="text/ajvascript" src="js/axios.js"></script>
```

### 常用API

#### GET/DELETE

- 通过url传参
- 通过params传参

```js
axios.get('/data?id=123')
	.then(ret=>{
    coonsole.log(ret.data)
})
```

```js
axios.get('/data/24')
	.then(ret=>{
    console.log(ret.data)
})
```

```js
axios.get('/data',{
    params:{
        id:123
    }
})
.then(ret=>{
    console.log(ret.data)
})
```



#### POST/PUT

- 通过选项传递参数（默认传递的是json格式的数据）

```js
axios.post('/data',{
    uname: 'tom',
    pwd: 123
}).then(ret=>{
    console.log(ret.data)
})
```

- 通过URLSearchParams传递参数

```js
const params = new URLSearchParams();
params.append('param1','value1');
params.append('param2', 'value2');
axios.post('/api/test', params).then(ret=>{
    console.log(ret.data)
})
```

### 响应结果

- data(json形式)
- headers
- status
- statusText

### 全局配置

- axios.default.timeout = 3000;//ms, 超时时间
- axios.default.baseURL = "http://localhost:3000/app";//默认地址的前部分
- axios.default.headers[ 'mytoken' ] = "adf1844934nadfnaodn02"; //设置请求头

```html
<body>
    axios.default.baseURL = 'http://localhost:3000/';
    ...
</body>
```



### 拦截器

#### 请求拦截器

在请求发出去之前设置一些信息

```js
axios.interceptors.request.use(function(config){
    return config;
}. function(err){
                               
})
```

#### 响应拦截器

在获取数据之前对数据做一些加工处理

```js
axios.interceptors.response.use(function(res){
    return res;
}, function(err){
    
})
```

## async/await

ES7引入的新语法，可以更加方便的进行异步操作。

async关键字用于函数上，await关键字用于async函数中。

```js
async function queryData(id){
    const ret = await axios.get('/data');
    return ret;
}

queryData.then(ret=>{
    console.log(ret)
})
```

#### 处理多个异步

```js
async function queryData(){
    var ino = await axios.get('async1');
    var ret = await axios.get('async2' + info.data);
    return ret.data;
}

queryData().then(function(data){
    console.log(data)
})
```

