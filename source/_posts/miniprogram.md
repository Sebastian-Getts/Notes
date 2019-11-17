---
title: miniprogram
date: 2019-11-16 15:43:32
categories:
- 技术
- 微信小程序
tags: miniprogram
---

微信小程序，以前做过，后来搁置到一边了，现在有机会终于要好好捣鼓他了。reference: [official website]( https://developers.weixin.qq.com/miniprogram/dev/reference/ )

emmm，还有个微信小程序大赛，是没机会参加了。

<!-- mroe -->

# 序

1. 小程序没有DOM对象，一切基于组件化
2. 小程序的四个重要**文件**：
   - *.js
   - *.wml view结构-->html
   - *.wxss view样式-->css
   - *.json view数据-->json文件

<% note info %>

学了vue再来学小程序，爽到飞起。。。然而我vue还没学完

<% endnote %>



## 获取用户信息

相关配置信息都在pages下的配置文件中，不是在全局。用到的配置文件：index.js, index.wxml, index.wxss。

```html
<!--pages/index/index.wxml-->
<view class='viewContainer'>
  <image class='avatar'src="{{userInfo.avatarUrl}}"></image>
  <button bindgetuserinfo='handleUserInfo' open-type="getUserInfo" style='display:{{isShow?"block":"none"}}' >get user info</button>
  <text class='sayHi'>Hi,{{userInfo.nickName}}</text>
  <view class='try' catchtap="handParent">
    <text catchtap="handChild">have a try</text>
  </view>
</view>
```

在button组件中，`bindgetuserinfo`可以处理用户信息（通过回调获得）。`open-type`作为button的一个属性，是**微信开放能力**获取的标签。



```js
 /**
   * 生命周期函数--监听页面加载
   */
onLoad: function (options) {
    this.dealWithUserInfo();
  },

  /**
    * 校验用户信息获取
    */
  dealWithUserInfo(){
    wx.getSetting({
      success: (data) => { //ES6
        if (data.authSetting['scope.userInfo']) {
          this.setData({
            isShow: false
          })
        } else {
          this.setData({
            isShow: true
          })

        }
      }
    }),

    // console.log(this);
    wx.getUserInfo({
      success: (data) => { //作用域。。for 'this'
        console.log(data);
        this.setData({
          userInfo: data.userInfo
        })
      },
      fail: (res) => {
        console.log(res);
      }
    })
  },

  handleUserInfo(data){
    if(data.detail.rawData){
      this.dealWithUserInfo();
    }
  },
```

```js
  /**
   * 页面的初始数据
   */
  data: {
    msg:'nice',
    userInfo:{},
    isShow:true
  },
```

在js中，定义相关行为。在onLoad中调用`dealWithUserInfo`相当于触发了button按钮。在初始化数据中给定`userInfo`空值，然后在回调函数中获取到用户信息后对它更新。



## swiper

轮播图

```css
/* pages/list/list.wxss */
swiper {
  width: 100%;
  height: 400rpx;
}

swiper image {
  width: 100%;
  height: 100%;
}
```

```html
<!--pages/list/list.wxml-->
<view>
  <swiper indicator-dots indicator-color='gray' indicator-active-color='green'>
    <swiper-item>
      <image src="/images/detail/carousel/01.jpg"></image>
    </swiper-item>
    <swiper-item>
      <image src="/images/detail/carousel/02.jpg"></image>
    </swiper-item>
  </swiper>
</view>
```

## 模板

只需要样式和结构即可，wxml和wxcss。



## Flex布局

Flex是Flexible Box的缩写，意为**弹性布局**，用来为盒装模型提供最大的灵活性。任何一个容器都可以指定为Flex布局。

#### 属性

flex-direction:

- row(default): 主轴为水平方向，起点在左端
- row-reverse: ~，起点在右端
- column: ~，主轴为垂直方向，起点在上沿
- column-reverse: ~，起点在下沿



## 移动端适配

physic pixel：屏幕的分辨率

设备独立像素（css像素）：虚拟像素

dpr：设备像素比，一般以iPhone6的dpr为准（dpr=2），物理像素/设备独立像素。

PPI：一英寸显示屏上的像素点个数。

#### 方案

底层做了viewport适配的处理，实现了理想视口。

iPhone6： 1rpx=1物理像素=0.5px

- 以iPhone6的物理像素个数为标准：750
- 1rpx=目标设备宽度/750*px



视网膜屏幕：分辨类超过人眼识别极限的高分辨率屏幕。

iPhone的dpr=2为人类肉眼分辨的极限。



## 小程序开发

目录结构

```
pages
utils
 app.js
 app.json
 app.wxss
 project.config.json
 sitemap.json
```



### 框架

配置性文件

### 组件

pages.index中wxml的标签即是组件。

### API





### 自定义事件

1. 冒泡事件：当一个组件上的事件被触发后，该事件会向父节点传递
2. 非冒泡事件：~，不会像父节点传递。
3. bindtap-->冒泡，catchtap-->不冒泡