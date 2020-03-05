---
title: bat
date: 2019-10-31 12:17:08
categories: Shell
tags: Windows
---

# BATCH

扩展名为**bat**或**cmd**。

在用机是Windows系统，想写一个脚本来代替每次写完后重复输入的命令，大致是：

```bash
hexo clean
hexo g
hex d
git add . 
git commit -m "update"
git push -f
```



## 符号

@：  不显示它后边的命令语句，只显示命令执行的结果 

 & ： 命令连接符，将两个命令连续执行不用分行 

 && ： 当前一个命令成功时，才执行后一个命令，否则不执行 

||：上一个命令执行失败才执行下一个命令

|：管道符号。将上一个命令输出的内容作为下一个命令的输入内容。

\>：重定向符号。将命令的输出结果重定向到后面的设备文件中，原文件的内容被覆盖。

## idea

可以使用`&&`来完成连续执行命令的过程，并且上一个执行成功时才执行下一个命令。

e.g.:

```bash
hexo clean && hexo g && hexo d && git add . && git commit -m "update" && git push -f
```
----
# BASH
今天（2019/12/3）打算在Ubuntu上写个同样功能的脚本。。

