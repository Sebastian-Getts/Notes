---
title: tensorflow02
date: 2019-12-08 13:05:17
categories: tensorflow
tags: tensorflow
mathjax: true
---

试着搭建一个神经网络，总结搭建八股

<!-- more -->

# 序

基于tensorflow的NN：用`张量`表示数据，用`计算图`搭建神经网络，用`会话`执行计算图，优化线上的`权重`（参数），得到模型。

- 张量（tensor）：多维数组（列表）

- 阶：张量的维数

  | 维数 | 阶   | 名字        | 列子                                   |
  | ---- | ---- | ----------- | -------------------------------------- |
  | 0-D  | 0    | 标量 scalar | s=1 2 3                                |
  | 1-D  | 1    | 向量 vector | v=[1,2,3] 数组                         |
  | 2-D  | 2    | 矩阵 matrix | m=[[1,2,3],[4,5,6],[7,8,9]] 二维数组   |
  | n-D  | n    | 张量 tensor | t=[[[...]]] n个 方括号有n个就是n阶张量 |

  张量可以表示0阶到n阶数组

- 数据类型：tf.float32 t.int32 ...

e.g.

```python
import tensorflow as tf

a = tf.constant([1.0,2.0])
b = tf.constant([3.0,4.0])

result = a + b
print result
```

```python
Tensor("add:0", shape=(2,),dtype=float32)
节点名：第0个输出 维度=一维数组长度2  数据类型 
```



## 计算图

搭建神经网络的计算过程，只搭建，不运算。如序中所示。

```python
import tensorflow as tf

x=tf.constant([[1.0,2.0]])
w=tf.constant([[3.0],[4.0]])

y=tf.matmul(x,w)
print y

Tensor("matmul:0",shape(1,1),dtype=float32)
```



## 会话

执行计算图中的节点运算

>with.tf.Session() as sess: print sess.run(y)

```python
import tensorflow as tf

x=tf.constant([[1.0,2.0]])
w=tf.constant([[3.0],[4.0]])

y=tf.matmul(x,w)
print y

with tf.Session() as sess:
print sess.run(y)


Tensor("matmul:0",shape(1,1),dtype=float32)
[[11.]]
```



## 参数

即`权重W`，用变量表示，随机给初值。

> w = tf.Variable(tf.random_normal([2,3], stddev=2, mean=0, seed=1))
>
> ​								正态分布	产生2x3矩阵	标准差为2 均值为0  随机种子

>tf.truncated_normal()        tf.random_uniform()
>
>去掉过大偏离点的正态分布      平均分布

tf.zeros 全0数组  tf.zeros([3,2],int32) 生产[[0,0],[0,0],[0,0]]

tf.ones 全1数组  tf.ones([3,2],int32) 生成[[1,1],[1,1],[1,1]]

tf.fill 全定值数组  tf.fill([3,2],6) 生成[[6,6],[6,6],[6,6]]

tf.constant 直接给值  tf.constant([3,2,1]) 生成[3,2,1]



## 实现过程

1. 准备数据集，提取特征，作为输入喂给神经网络（Neural Network, NN)
2. 搭建NN结构，从输入到输出（先搭建计算图，再用会话执行）`NN向前传播算法：计算输出`
3. 大量特征数据喂给NN，迭代优化NN参数 `NN反向传播算法：优化参数训练模型`
4. 使用训练好的模型预测和分类

1～3为循环的训练过程，4为使用过程

e.g.; 生产一批零件，将体积x1和重量x2为特征输入NN，通过NN后输出一个数值。

{% note info%}

发现用线性代数的思想去理解传播过程、权重这些东西会好理解一些

{% endnote %}

e.g.1

```python
#coding:utf-8
#两层简单神经网络（全连接）
import tensorflow as tf

#定义输入和输出
x = tf.constant([[0.7,0.5]])
w1 = tf.Variable(tf.random_normal([2,3],stddev=1, seed=1))
w2 = tf.Variable(tf.random_normal([3,1],stddev=1,seed=1))

#定义前向传播过程
a = tf.matmul(x, w1)
y = tf.matmul(a, w2)

#用会话计算结果
width tf.Session() as sess:
    init_op = tf.global_variables_initializer()
    sess.run(init_op)
    print"y in tf3_3.py is:\n", sess.run(y)
    
```



```markdown
y is:
[[3.0904665]]
```

e.g.2

```python
#coding:utf-8
#两层简单神经网络（全连接）
import tensorflow as tf

#定义输入和输出
x = tf.constant([[0.7,0.5]])
w1 = tf.Variable(tf.random_normal([2, 3], stddev=1, seed=1))
w2 = tf.Variable(tf.random_normal([3, 1], stddev=1, seed=1))
 
#定义前向传播过程
a = tf.matmul(x, w1)
y = tf.matmul(a, w2)

#用会话计算结果
with tf.Session() as sess:
    init_op = tf.global_variables_initializer()
    sess.run(init_op)
    print"y in tf3_3.py is:\n", sess.run(y)

```

e.g.3

```python
import tensorflow as tf

x = tf.placeholder(tf.float32, shape=(None, 2))
w1= tf.Variable(tf.random_normal([2,3], stddev=1, seed=1))
w2= tf.Variable(tf.random_normal([3,1], stddev=1, seed=1))

a = tf.matmul(x, w1)
y = tf.matmul(a, w2)

with tf.Session() as sess:
    init_op = tf.global_variables_initializer()
    sess.run(init_op)
    print "the result of tf3_5.py is:\n", sess.run(y, feed_dict={x: [[0.7,0.5],[0.2,0.3],[0.3, 0.4],[0.4,0.5]]})
    print "w1:\n", sess.run(w1)
    print "w2:\n", sess.run(w2)
```

# 反向传播

训练模型参数，在所有参数上用梯度下降，使NN模型在训练数据上的损失函数最小。

- 损失函数（loss）：`预测值（y）`与`已知答案（y_）`的差距

- 均方误差MSE：
  $$
  MSE(y\_,y)=\frac{\sum ^n _{i=1} (y-y\_)^2}{n}
  $$

  $$
  loss = tf.refuce\_mean(tf.square(y\_-y))
  $$

  

- 反向传播训练方法：以减小loss值为优化目标

- 学习率：决定参数每次更新的幅度。（recommand: 0.001)

e.g.:

```python
#coding:utf-8

import tensorflow as tf
import  numpy as np #python的科学计算模块
BATCH_SIZE = 8 #一次喂入神经网络多少组数据
seed = 23455 

#基于seed产生随机数
rng = np.random.RandomState(seed)

#随机数返回32行2列的矩阵 表示32组 体积和中路 作为输入数据集
X = rng.rand(32,2)

#从X的32行2列的矩阵中 取出一行 判断如果和小于1 给Y赋值1，否则0.
Y = [[int(x0+x1 < 1)] for (x0, x1) in X] #是否为真

print "X:\n",X
print "Y:\n",Y

#定义神经网路的输入、参数和输出，，定义前向传播过程
x = tf.placeholder(tf.float32, shape=(None, 2))
y_= tf.placeholder(tf.float32, shape=(None, 1))

w1= tf.Variable(tf.random_normal([2,3], stddev=1, seed=1))
w2= tf.Variable(tf.random_normal([3,1], stddev=1, seed=1))

a=tf.matmul(x, w1) #矩阵乘法
y=tf.matmul(a, w2)

#定义损失函数及反向传播方法
loss = tf.reduce_mean(tf.square(y-y_)) #均方误差
train_step = tf.train.GradientDescentOptimizer(0.001).minimize(loss) #梯度下降
#train_step = tf.train.MomentumOptimizer(0.001,0.9).minimize(loss)
#train_step = tf.train.AdamOptimizer(0.001).minimize(loss)

#生成会话，训练STEPS轮
with tf.Session() as sess:
    init_op = tf.global_variables_initializer()
    sess.run(init_op)

    print "w1:\n", sess.run(w1)
    print "w2:\n", sess.run(w2)
    print "\n"

    #训练模型
    STEPS = 3000 #训练3000轮
    for i in range(STEPS):
        start = (i*BATCH_SIZE) % 32
        end = start + BATCH_SIZE
        sess.run(train_step, feed_dict={x: X[start: end], y_:Y[start:end]})
        if i%500 == 0: #每500轮后打印loss
            total_loss = sess.run(loss, feed_dict={x: X, y_: Y})
            print("After %d training step(s), loss on all data is %g" % (i, total_loss))

    #输出训练后的参数取值
    print "\n"
    print "w1:\n", sess.run(w1)
    print "w2:\n", sess.run(w2)
```

## 搭建神经网络的八股：

准备、前传、反传、迭代

- 准备 import
- 前向传播：定义输入、参数和输出. e.g.: x, y_, w1, w2, a, y
- 反向传播：定义损失函数、反向传播方法. e.g.: loss, tran_step
- 生成会话，训练STEPS轮

