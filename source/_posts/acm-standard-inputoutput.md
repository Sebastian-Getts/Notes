---
title: acm standard inputoutput
date: 2021-04-19 21:56:55
categories: Leetcode
tags: standard
---

​		算法题中通常有两种方式提交代码，一种是核心代码模式，就像LeetCode平台中的那样，还有的就是ACM模式，后者不仅要完成题目中的算法逻辑，还需要定义输入输出，尤其是输入输出，需要符合规范才可以（如果核心代码完成，因为输入输出而丢分就太可惜了）。这篇就是对输入输出的总结，题型来自牛客。

<!-- more -->

# 多组输入

根据是否给定组数有两种循环，没有明确组数就用while，给定了的就用for循环一定的次数。**虽然给的示例是多行输入多行输出，但是多组输入实际上是多个测试，每输入一行数据，在回车输入下一行数据前就要有一个输出**。

## 无限循环

#### 题目A

输入描述:

```
输入包括两个正整数a,b(1 <= a, b <= 10^9),输入数据包括多组。
```

输出描述:

```markdown
输出a+b的结果
```

示例1

输入

```
1 5
10 20
```

输出

```markdown
6
30
```

THINKING：每次输入两个整数，可输入多组，每组都会产生一个结果。

```java
import java.util.*;

public class Main {
    public static void main(String[] args){
        Scanner sc = new Scanner(System.in);
        while(sc.hasNext()){ // next() or nextInt() is ok
            int a = sc.nextInt();
            int b = sc.nextInt();
            // your business
            System.out.println(a+b);
        }
    }
}
```

#### 题目B

输入描述:

```
输入数据有多组, 每行表示一组输入数据。
每行的第一个整数为整数的个数n(1 <= n <= 100)。
接下来n个正整数, 即需要求和的每个正整数。
```

输出描述:

```
每组数据输出求和的结果
```

示例1

输入

```
4 1 2 3 4
5 1 2 3 4 5
```

输出

```
10
15
```

```java
import java.util.*;

public class Main {
    public static void main(String[] args){
        Scanner sc = new Scanner(System.in);
        
    }
}
```

THINKING：这道题的输入跟下面的带结提示的相比就少了一个结束的判断条件。需要着重注意第一个数字与后面数字的关系处理，应该是**到一定个数后就进入业务逻辑处理，通过输出来进行换行**。

```java
import java.util.*;

public class Main {
    public static void main(String[] args){
        Scanner sc = new Scanner(System.in);
        while(sc.hasNext()){
            int n = sc.nextInt();
            int[] arr = new int[n];
            for(int i=0; i<n; i++){
                arr[i] = sc.nextInt();
            }
            // your business
            int sum = 0;
            for(int num : arr){
                sum += num;
            }
            System.out.println(sum);
        }
    }
}
```

#### 题目 C

输入描述:

```
多个测试用例，每个测试用例一行。

每行通过空格隔开，有n个字符，n＜100
```

输出描述:

```
对于每组测试用例，输出一行排序过的字符串，每个字符串通过空格隔开
```

示例1

输入

```
a c bb
f dddd
nowcoder
```

输出

```
a bb c
dddd f
nowcoder
```

THINKING：多组输入，只不过每个元素都是字符串。

```java
import java.util.*;

public class Main {
    public static void main(String[] args){
        Scanner sc = new Scanner(System.in);
        while(sc.hasNext()){
            String[] str = sc.nextLine().split(" ");
            //  your business
            Arrays.sort(str);
            StringBuilder sb = new StringBuilder(str[0]);
            for(int i=1; i<str.length; i++){
                sb.append(" ").append(str[i]);
            }
            System.out.println(sb.toString());
        }
    }
}
```



### 结束提示

虽然是不限定输入组数，但是给了结束标志，这时在while中添加一个判断条件，符合的话跳出循环。

#### 题目 A

输入描述:

```
输入包括两个正整数a,b(1 <= a, b <= 10^9),输入数据有多组, 如果输入为0 0则结束输入
```

输出描述:

```
输出a+b的结果
```

示例1

输入

```
1 5
10 20
0 0
```

输出

```
6
30
```

```java
import java.util.*;

public class Main {
    public static void main(String[] args){
        Scanner sc = new Scanner(System.in);
        while(sc.hasNext()){
            int a = sc.nextInt();
            int b = sc.nextInt();
            if(a == 0 && b == 0) return;
            // your business
            System.out.println(a+b);
        }
    }
}
```

#### 题目B

比上面的稍微复杂一点，不过也是根据输入标志退出输入，需要额外处理的就是第一个数字和后面数字的关系

输入描述:

```
输入数据包括多组。
每组数据一行,每行的第一个整数为整数的个数n(1 <= n <= 100), n为0的时候结束输入。
接下来n个正整数,即需要求和的每个正整数。
```

输出描述:

```
每组数据输出求和的结果
```

示例1

输入

```
4 1 2 3 4
5 1 2 3 4 5
0
```

输出

```
10
15
```

```java
import java.util.*;

public class Main {
    public static void main(String[] args){
        Scanner sc = new Scanner(System.in);
        while(sc.hasNext()){
            // 注意这里是如何处理第一个数字和后续输入数字的关系的
            int n = sc.nextInt();
            if(n == 0) return;
            int[] arr = new int[n];
            for(int i=0; i<n; i++){
                arr[i] = sc.nextInt();
            }
            // your business
            int sum = 0;
            for(int num : arr){
                sum += num;
            }
            System.out.println(sum);
        }
    }
}
```

#### 题目C

输入描述:

```
输入数据有多组, 每行表示一组输入数据。

每行不定有n个整数，空格隔开。(1 <= n <= 100)。
```

输出描述:

```
每组数据输出求和的结果
```

示例1

输入

```
1 2 3
4 5
0 0 0 0 0
```

输出

```
6
9
0
```

THINKING：这道题与前面的题有所不同了，首先他还是多组输入，每一行算作一组，但是每一组没有给定输入的个数，按照日常的操作来看我们是用回车来判断是否是一组的，在java中如何做呢？答案是方法`nextLine()`；其次是输入的元素，如果是两个的话，我们读取两次`nextInt()`就好，但这是不定个数的，再用这个方法会有些麻烦，再看题目，各个输入之间是用空格隔开的，**我们何不按行读取，然后用空格分开**，那么**每一行就被视作一个字符串，用函数`nextLine()`获取输入的一行就可以了**。

```java
import java.util.*;

public class Main {
    public static void main(String[] args){
        Scanner sc = new Scanner(System.in);
        while(sc.hasNext()){
            String[] str = sc.nextLine().split(" ");
            // your business
            int sum = 0;
            for(String s : str){
                sum += Integer.parseInt(s);
            }
            System.out.println(sum);
        }
    }
}
```



## 有限个数

#### 题目A

输入描述:

```
输入第一行包括一个数据组数t(1 <= t <= 100)
接下来每行包括两个正整数a,b(1 <= a, b <= 10^9)
```

输出描述:

```
输出a+b的结果
```

示例1

输入

```
2
1 5
10 20
```

输出

```
6
30
```

THINKING：相比较没有明确输入组数的，这个提到了输入的个数，那我们就不用while无限循环了， 只需要循环给定的个数就好了。

```java
import java.util.*;

public class Main {
    public static void main(String[] args){
        Scanner sc = new Scanner(System.in);
        int t = sc.nextInt();
        for(int i=0; i<t; i++){
            int a = sc.nextInt();
            int b = sc.nextInt();
            // your business
            System.out.println(a+b);
        }
    }
}
```

#### 题目B

输入描述:

```
输入的第一行包括一个正整数t(1 <= t <= 100), 表示数据组数。
接下来t行, 每行一组数据。
每行的第一个整数为整数的个数n(1 <= n <= 100)。
接下来n个正整数, 即需要求和的每个正整数。
```

输出描述:

```
每组数据输出求和的结果
```

示例1

输入

```
2
4 1 2 3 4
5 1 2 3 4 5
```

输出

```
10
15
```

```java
import java.util.*;

public class Main {
    public static void main(String[] args){
        Scanner sc = new Scanner(System.in);
        int t = sc.nextInt();
        for(int i=0; i<t; i++){
            int n= sc.nextInt();
            int[] arr = new int[n];
            for(int j=0; j<n; j++){
                arr[j] = sc.nextInt();
            }
            // your business
            int sum = 0;
            for(int num : arr){
                sum += num;
            }
            System.out.println(sum);
        }
    }
}
```

# 单组输入

通过上面可以看出，多组输入是依靠**for循环**或者**while**用`hasNext()`不停地监控键盘来实现的，与之相比，单组输入就省去了循环。

#### 题目A

输入描述:

```
输入有两行，第一行n

第二行是n个空格隔开的字符串
```

输出描述:

```
输出一行排序后的字符串，空格隔开，无结尾空格
```

示例1

输入

```
5
c d a bb e
```

输出

```
a bb c d e
```

THINKING：在第一行输入一个长度，在第二行输入给定长度的空格隔开的字符串。既然是字符串，我们能否直接拿取到整个字符串，然后空格隔开，按给定的长度来取前部分呢，事实上这么做就没问题的。**如果没有输入长度，而是题目中有要求长度，那么直接用整行再split后取一个长度也ok的**。

```java
import java.util.*;

public class Main {
    public static void main(String[] args){
        Scanner sc = new Scanner(System.in);
        // 第一行輸入的是一個數字，而且要換行來做下一行的輸入，要用nextLine
        int n = Integer.parseInt(sc.nextLine());
        String[] str = sc.nextLine().split(" ");
        // your business
        Arrays.sort(str);
        StringBuilder sb = new StringBuilder(str[0]);
        for(int i=1; i<n; i++){
            sb.append(" ").append(str[i]);
        }
        System.out.println(sb.toString());
    }
}
```

# 总结

​		对于做习惯了Leetcode的“傻瓜式”算法题的人来说，ACM模式有些难以理解，尤其是算法部分都完成了，最后挂在了输入上导致提交不通过的人。但是不管怎么样，毕竟算法都能AC，这个花时间看看也不是很难，而且ACM模式也是主流，不仅仅是牛客，PAT、CodeForces这些也都采用的ACM模式。

​		提交时后台数据都不止一个用例，所以要着重掌握多组输入的情况，对于未告知数量的，用`hasNext()`来循环，单行数据较多或不确定的，使用`nextLine()`直接获取整行数据，再用`split()`分隔开后处理。**虽然是多组数据，但是每喂一组数据，就要调用编写的算法模块去处理一组并且输出**，而不是接受完统一处理。