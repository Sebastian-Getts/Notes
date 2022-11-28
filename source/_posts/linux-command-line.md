---
title: linux-command-line
date: 2021-04-20 14:12:03
categories: linux
tags: utils
---

这篇总结一下linux常用命令，也就是bash命令。虽然一直用的Ubuntu，到现在也只熟悉几个常用的命令，对于生产环境来说是远远不够的，好在有条件熟悉，下面学习总结一下，遇到有意思的命令再补充。

<!-- more -->

这里将命令分为两大类，一类是系统相关的，例如磁盘存储、进程状态等，另一类是业务相关，例如查找、移动、复制文件等。

<!-- toc -->

# 系统

1. 根据端口查看程序
   
   有两种方式，可以用`netstat`或者`lsof`。
   
   ```shell
   lsof -i:8080 -- list openfiles
   netstat -nlt | grep 8080
   ```

2. 系统中磁盘使用情况
   
   ```shell
   df -h
   ```

# 业务

这部分大都与**查找**有关，可以分为文件外查找与文件内查找。 

## 文件外查找

1. 根据名称查找某个目录下的文件
   
   ```shell
   find / -name xxx.md
   ```

2. 递归查找某个文件
   
   ```shell
   find . -name *.java
   ```

## 文件内查找

1. 显示文件的后几行
   
   ```shell
   tail -n 10 xx.txt
   ```

2. 显示文件的前几行
   
   ```shell
   head -n 10 xx.txt
   ```

3. 在给定的文件中根据条件搜索字符串
   
   ```shell
   grep println Main.java
   ```