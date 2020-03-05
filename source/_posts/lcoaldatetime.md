---
title: lcoaldatetime
date: 2020-01-11 16:28:37
categories: Java
tags: utils
---

Differences between **Date** and **LocalDateTime**, in fact, Date is deprecated.

<!-- more -->

# Date

```java
    public static void main(String[] args) {

        Date rightNow = new Date();
        System.out.println("now date: "+rightNow);
        System.out.println("now year: "+rightNow.getYear());
        System.out.println("now month: "+rightNow.getMonth());
    }
```

```markdown
now date: Sat Jan 11 16:36:03 CST 2020
now year: 120
now month: 0
```



so it's **deprecated**.

## SimpleDateFormat

**Date formats are not synchronized.**



# LocalDateTime

```java
    public static void main(String[] args) {

        LocalDateTime rightNow = LocalDateTime.now();
        System.out.println("now date: "+rightNow);
        System.out.println("now month: "+rightNow.getMonth());
        System.out.println("now year: "+rightNow.getYear());
    }
```

```markdown
now date: 2020-01-11T18:45:20.878750
now month: JANUARY
now year: 2020
```



## DateTimeFormatter

```java
    public static void main(String[] args) {

        LocalDateTime rightNow = LocalDateTime.now();

        System.out.println(rightNow.format(DateTimeFormatter.ISO_DATE));
        System.out.println(rightNow.format(DateTimeFormatter.BASIC_ISO_DATE));
        System.out.println(rightNow.format(DateTimeFormatter.ofPattern("yyyy/MM/dd")));
    }
```

```markdown
2020-01-11
20200111
2020/01/11
```



note: most important, **the class is immutable and thread-safe**.







