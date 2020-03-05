---
title: tensorflow01
date: 2019-12-07 11:36:19
categories: Tensorflow
tags:
- tensorflow
- python
---

一些python基础语法。。。
<!-- more -->

# pyton
1. 循环语句
```markdown
for variable in range(startValue, endValue):
    do somthing

---
for variable in listName:
    do something
---
while condition:
    do something
---
stop the circle
break
```

2. 函数、模块、包
函数：执行某些操作的一段代码
定义函数：
```markdown
def functionName (parameter list):
    function body
```
使用函数：
```markdown
functionName (parameter list)
```
e.g.:
```python
input("please input your class number:")
```

模块：函数的集合，先导入，再使用，用`模块.函数名`调用。
包：包 含有多个模块。
```python
from PIL import Image
```
from 包 import 模块


3. 类、对象、面向对象
类：是函数的集合，可实例化出对象的模具
实例化：对象=类（）
对象：是实例化出的实体，对象实实在在存在，完成具体工作
面向对象：优化修改类，类实例化出对象，对象调用类里的函数执行具体的操作
----
类的定义：
```markdown
class className (fatherClassName):
    pass
```
- 先用pass占位，起架构；再用具体的函数替换pass完善类。
- 类里定义函数时，语法规定第一个参数必须是self。
- \__init\__函数，在新对象实例化时会自动运行，用于给新对象赋初值。

e.g.
```python
class Animals():
    def breathe(self):
        print "breathing"
    def move(self):
        print "moving"
    def eat(self):
        print "eating food"

class Mammals(Animals):
    def breastfeed(self):
        print "feeding young"

class Cats(Mammals):
    def __init__(self, spots):
        self.spots = spots
    def catch_mouse(self):
        print "catch mosue"
    def lef_foot_forward(self):
        print "left foot forward"
    def left_foot_backward(self):
        print "left foot backward"
    def dance(self):
        self.left_foot_backward()
        self.left_foot_backward()
        self.left_foot_backward()

kitty=Cats(10)
print kitty.spots
kitty.dance()
kitty.breastfeed()
kitty.move()
```

4. 文件操作
- 文件写操作 import pickle
```markdown
开：文件变量=open（“文件路径文件名”，“wb”）
存：pickle.dump（待写入的变量，文件变量）
关：文件变量.close()
```
- 文件读操作 import pickle
```markdown
开：文件变量=open（“文件路径文件名”，“rb”）
取：放内容的变量=pickle.load（文件变量）
关：文件变量.close()
```

