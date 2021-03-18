---
title: mybatis sql resolution
date: 2021-03-07 19:03:54
categories: framework
tags: mybatis
---

承接去年记录的mybatis，从架构和源码的角度剖析mybatis。从整个项目工程来看他比spring小得多，因此代码更易读。使用他时，通常我们要做的就是编写sql和接口，这篇首先从sql解析开始。

<!-- import -->

<!-- toc -->

```java
public class Test {

    // 模拟的pojo
    static class User {
        int age;
        int name;
    }

    public static void main(String[] args) {
        // 核心就在这
        UserMapper userMapper = (UserMapper) Proxy.newProxyInstance(Test.class.getClassLoader(), new Class<?>[]{UserMapper.class}, new InvocationHandler() {
            @Override
            public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
                // 获取到注解
                Select annotation = method.getAnnotation(Select.class);
                // 构建入参的映射
                Map<String, Object> map = buildMethodArgNameMap(method, args);

                System.out.println(map.toString());
                if (annotation != null) {
                    String[] value = annotation.value();
                    String s = parseSql(value[0], map);
                    System.out.println(s);
                }
                return null;
            }
        });
        userMapper.selectUesList(2);
    }

    // 解析sql
    public static String parseSql(String sql, Map<String, Object> map) {
        StringBuilder sb = new StringBuilder();
        int length = sql.length();
        for (int i = 0; i < length; i++) {
            char c = sql.charAt(i);
            if (c == '#') {
                int nextIndex = i + 1;
                char nextChar = sql.charAt(nextIndex);
                if (nextChar != '{') {
                    throw new RuntimeException("sql写法错误，应该是 { ");
                }
                StringBuilder argSb = new StringBuilder();
                i = parseSqlArg(argSb, sql, nextIndex);
                String argName = argSb.toString();
                Object argValue = map.get(argName);
                sb.append(argValue.toString());
                continue;
            }
            sb.append(c);
        }

        // 返回解析后拼接过的sql
        return sb.toString();
    }

    /**
     * 这里应该是解析出{}中的的东西
     */
    private static int parseSqlArg(StringBuilder argSb, String sql, int nextIndex) {
        for (int i = nextIndex + 1; i < sql.length(); i++) {
            char c = sql.charAt(i);
            if (c != '}') {
                argSb.append(c);
            } else {
                return i;
            }
        }
        throw new RuntimeException("sql写法错误，应该是 } ");
    }

    /**
     * 解析传入的参数
     *
     * @param method method
     * @param args   参数
     * @return 解析后的参数
     */
    public static Map<String, Object> buildMethodArgNameMap(Method method, Object[] args) {
        Map<String, Object> map = new HashMap<>(6);
        // 方法的入参，例如：Integer id, args是实际的入参值，如 6
        Parameter[] parameters = method.getParameters();
        for (int i = 0; i < parameters.length; i++) {
            map.put(parameters[i].getName(), args[i]);
        }
        return map;
    }
}


interface UserMapper {

    @Select("select * from User where id = #{id}")
    List<Test.User> selectUesList(Integer id);
}	
```

以上只是模拟mybatis架构中的解析sql的部分，真正的解析还是比较复杂的，要考虑很多种情况，但是原理是一样，都离不开动态代理。下面我们看看他的架构设计图（非官方）：![mybatis_structure.jpg](https://i.loli.net/2021/03/07/cPamMLRFU4xHXu8.jpg)

我们从这个角度去想：如何用sql去跟数据库交互？如何动态地去用sql与数据库交互？站在现在看过去，mybatis实现了这一点，如何做的？利用接口来实现，有两种方式：在接口上用注释来写或者写在xml文件里需要替换的地方用`#{}`括起来，在需要的地方调用接口的方法并把值传进去，我们要做的就只有这些，其他的mybatis帮我们做了。我们来看看他都做了什么，首先就是映射关系，把传入的值替换到sql语句并拼接起来、查询的结果映射到想要的对象上；管理sql与数据库的交互。这两个是最基本的，其次，还可以做些优化，比如缓存，频繁地查询某个sql可以将结果存起来；扩展性，对结果统一处理等。