---
title: PlainTasks
date: 2019-11-04 00:02:24
categories: utils
tags: sublime
---

自从换掉了Ubuntu用回Windows，todoList一直是个问题，用了sublime之后发现有款相关的插件，打算学着用下。

<!--more-->

## PlainTastks

**新增任务**：ctrl+enter/i

**完成任务**：ctrl+D

**取消任务**：alt+C

完成的任务不能直接标记为取消，需要先改为未完成。

**标签**：用@可以定义一个标签

 用圆点加斜杠(或者反斜杠)加文件名的形式创建一个文件链接 

**归档**：ctrl+shift+A归档状态为“完成”的任务

**新的任务文档**：ctrl+shift+P，输入task，选择“Tasks: New document”；输入--，再按tab可以生成任务列表的分割线。

**优先级**：输入c，再按tab，会变成@critical（红色背景），除此，还有high，low，today等。

**时间跟踪**：

- 输入s，按两次tab键，将生成任务开始时间，当任务完成或取消时，会自动计算任务所花时间并显示到归档任务里。
- 输入tg，按两次tab，将生成一个任务开关时间，可以暂停或恢复。
- 输入cr，按两次tab，将生成一个任务创建时间，用ctrl+shift+enter创建一个新任务自动附加创建时间标签。
- 输入d，按一次tab，将生成一个任务的超期时间@due()，如果再按一下，就插入当前时间。

[more information]( https://github.com/aziz/PlainTasks/blob/master/Readme.md )

