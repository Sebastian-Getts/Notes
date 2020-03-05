---
title: tagOfHexo
date: 2019-11-07 23:41:44
categories: Hexo
tags: hexo
---

为了能够更好的书写文档，更方便地使用markdown以及hexo，特写此篇总结较为常用的以及探索不常用的语法。。。

<!--more-->

# 居中

```markdown
{% cq %} blah blah blah {% endcq %}
{% centerquote %}blah blah blah{% endcenterquote %}
```

{% cq %}i think it will be center{% endcq %}

{% note info %}
if there is somthing wrong with the grammer,, it will not generate files successfully...

{% endnote %}

# note标签

通过note标签可以为段落添加背景色。

```markdown
{% note [class] %}
content
{% endnote %}
```

其中 class 可以为：`default`, `primary`, `success`, `info`, `warning`, `danger`。

{% note primary %}

this is primary note tag

{% endnote %}

{% note success%}

this is success note tag

{% endnote %}

{% note info%}

this is info tag

{% endnote %}

{% note warning %}

this is warning tag

{% endnote %}

{% note danger%}

this is danger tag

{% endnote %}

{% note %}

this is undefined note tag

{% endnote %}

# label标签

> 语法： {% label [class]@text %}

```markdown
I heard the echo, {% label default@from the valleys and the heart %}
Open to the lonely soul of {% label info@sickle harvesting %}
Repeat outrightly, but also repeat the well-being of
Eventually {% label warning@swaying in the desert oasis %}
{% label success@I believe %} I am
{% label primary@Born as the bright summer flowers %}
Do not withered undefeated fiery demon rule
Heart rate and breathing to bear {% label danger@the load of the cumbersome %}
Bored
```

I heard the echo, {% label default@from the valleys and the heart %}
Open to the lonely soul of {% label info@sickle harvesting %}
Repeat outrightly, but also repeat the well-being of
Eventually {% label warning@swaying in the desert oasis %}
{% label success@I believe %} I am
{% label primary@Born as the bright summer flowers %}
Do not withered undefeated fiery demon rule
Heart rate and breathing to bear {% label danger@the load of the cumbersome %}
Bored

# button按钮

可以添加带有主题样式的按钮。

> {% button /path/to/url/, text, icon [class], title %}

也可以写为：

> {% btn /path/to/url, text, icon [class], title %}

e.g.:

```markdown
{% btn #, content %}
{% btn #, content & title, title %}
{% btn #, content & image, home %}
{% btn #, content $ big-imgage, home fa-fw fa-lg %}
```

{% btn #, content %}
{% btn #, content & title, title %}
{% btn #, content & image, home %}
{% btn #, content $ big-imgage, home fa-fw fa-lg %}

# tab标签

用于创建tab选项卡。

```markdown
{% tabs [unique name], [index] %}
	<!--tab1-->
	content
	<!--tab2-->
	content
{% endtabs %}
```

{% tabs Tab标签列表 %}  

<!-- tab 标签页1 -->    

标签页1文本内容  

<!-- endtab --> 

 <!-- tab 标签页2 -->   

 标签页2文本内容 

 <!-- endtab --> 

 <!-- tab 标签页3 -->   

 标签页3文本内容  

<!-- endtab -->

{% endtabs %}   

<% note warning %>

这个貌似不起作用。。。

<% endnote %>

# 引用站内链接

```markdown
{% post_link slug [title] %}
```

slug：表示`_post`下的文件名。

就像这样：这是一篇介绍比特币的{% post_link bt01 博客 %} =.=

# 插入swig代码

想插入swig代码（包括原生html、js等），可以通过raw标签**禁止markdown引擎**u安然标签内的内容。

```markdown
{% raw %}
content
{% endraw %}
```

用途：常用于在页面内引入第三方脚本实现特殊功能，尤其是该第三方脚本尚无i相关hexo插件支持的时候，可以通过**写原生Web页面**的形式引入脚本并实现逻辑。

{% note warning %}

What is swig?

{% endnote %}

# 插入Gist

{% note danger %}

What is gist...

{% endnote %}



 {% cq %} [reference]( https://theme-next.iissnan.com/tag-plugins.html ){% endcq %} 





