---
title: junit5
date: 2022-12-20 16:33:48
categories: unit_test
tags: junit5
---

这篇总结梳理基于Junit5的单元测试，方便日后查阅，当然最全的文档还是来自[官方](https://junit.org/junit5/docs/current/user-guide/)的。笔者曾负责部门内单元测试的推广与培训，了解这个东西在使用起来会遇到哪些问题，使用体验如何等。

<!-- more -->

## 什么是单元测试
单元测试是开发人员将功能移交测试前的一项工作，用来自我测试，后期维护等。这里区分一下单元测试和集成测试：
- 单元测试：无需启动或依赖额外资源就能运行的测试用例
- 集成测试：与单元测试相对，需要依赖额外资源的（如Spring容器、DB等）测试用例
除了我们熟悉的后端之外，前端也是有单元测的，框架不同。同样是后端，都有不同的单元测试框架，笔者接触较多的有JUnit5和Spock。配合单元测试框架，在后端服务中涉及到其他不在此次核心代码编写内到资源，如外部接口、数据库等，我们可以结合Mock框架去模拟数据。最后，单元测试的覆盖率也是考察质量的标准之一，常用的有Jacoco等。

## 是否都有必要
单元测试不是景上添花，需要根据具体的业务来区分合适的场景，跟系统架构有很深的关系。如果前期架构工作不到位，单元测试实施起来会有点棘手，例如，功能拆分合理，分成了多个方法去完成一个功能，这种可以使用单元测试针对不同情况去做测试，否则单元测试写起来会繁琐不直观。

## 难以解决的痛点
目前看来不方便的地方还有不少，因工作的原因暂时无法有更深入的跟踪，这里暂列一些：
- 前端的单元测试
- 与数据库交互时的数据处理
- TDD实践
- ……
可以肯定的是单元测试比较适合新的业务发生时去完成，而不是后期再去补，如果那一块的代码经常改动或很核心，实施单元测试的意义还是很大的。而对于报表生成等固式代码较多且长的地方，写起来反而没有很大的参考性。
有人可能会提到静态类的mock，还没这个需求，但是Mockito官方有提供API去mock
## JUnit5
在使用JUnit5时还是比较顺利的，通俗易懂，简单上手，这里举几个笔者认为很好用的例子：

### @DisplayName
用于标注在测试方法上，这样在启动时下方会显示标注的名字。如果不写的话会选择显示方法名，开发人员，尤其是非英语国家的，使用这个会让使用者明白这个方法的用途。英语国家的开发可以忽略，可以直接修改方法名为易懂的就好了，比如：*at_5_floor_to_up_and_down_3_floor*

### @ParameterizedTest
这个注解完美解决了多个入参校验一个方法时的问题，他需要搭配其他注解去传递参数，比如：
```java
@ParameterizedTest
@ValueSource(ints = {1, 3, 10, 23})
@DisplayName("生成的数据量与输入是否一致")
void invoke(int count) {
    // given
    PickOneService pickOneService = new PickOneService();
    // when
    CommonResult<List<WordDetail>> invoke = pickOneService.invoke(count);
    // then
    List<WordDetail> data = invoke.getData();
    assertEquals(count, data.size());
}
```
如上所示，通过与`@ValueSource`注解的搭配使用，我们可以方便的测试多个入参，这里要注意的是，我们需要使用一个变量来做传递（如上面的`count`）。如果是其他类型的入参就搭配`@MethodSource`，如下：
```java
@ParameterizedTest
@MethodSource("stringProvider")
void testWithExplicitLocalMethodSource(String argument) {
    assertNotNull(argument);
}

static Stream<String> stringProvider() {
    return Stream.of("apple", "banana");
}
```

## 技术实现方式
目前浅显地认为是修改了底层的字节码。