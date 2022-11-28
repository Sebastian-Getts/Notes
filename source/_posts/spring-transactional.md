---
title: spring_transactional
date: 2022-09-01 11:13:45
categories: springboot
tags: 'transaction'
---

在Spring中事务是如何处理的，事务的传播机制又是怎样的。

<!-- more -->

```java
@Transactional(rollbackFor = Exception.class, propagation = Propagation.REQUIRED)
public void testMyTransaction(String s) {
    // ...
}
```

我们看到有两个关键的参数，一个是接受就滚时的异常类型，另一个是传播机制。

## 传播机制

稍微复杂些的代码中会出现事务嵌套事务的情况，这就会涉及到事务传播。

```java
public enum Propagation {
    REQUIRED(0),
    SUPPORTS(1),
    MANDATORY(2),
    REQUIRES_NEW(3),
    NOT_SUPPORTED(4),
    NEVER(5),
    NESTED(6);

    private final int value;

    private Propagation(int value) {
        this.value = value;
    }

    public int value() {
        return this.value;
    }
}
```

看到如上所示，对应的传播机制有**7种**，其中默认的是`REQUIRED`。

| 传播类型          | 含义                                                                                                   |
| ------------- | ---------------------------------------------------------------------------------------------------- |
| REQUIRED      | Support a current transaction, create a new one if none exists                                       |
| SUPPORTS      | Support a current transaction, execute non-transactionally if none exists                            |
| MANDATORY     | Support a current transaction, throw an exception if none exists                                     |
| REQUIRES_NEW  | Create** a new transaction, and suspend the current transaction if one exists                        |
| NOT_SUPPORTED | Execute non-transactionally, suspend the current transaction if one exists                           |
| NEVER         | Execute non-transactionally, throw an exception if a transaction exists                              |
| NESTED        | Executed within a nested transaction if a current transaction exists, behave like REQUIRED otherwise |
