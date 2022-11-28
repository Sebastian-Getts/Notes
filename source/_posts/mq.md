---
title: mq
date: 2020-07-20 21:04:40
categories: middleware
tags: activemq
---

mq的出现是大势所趋，也一定是为了解决某方面的问题，从这里入手，可以综合的了解所有mq的异同。

<!--more-->

# MQ的引入

模拟几个场景：

1. `学生模块`和`老师模块`。功能：学生向老师抛出问题，老师反馈给学生答案。老师一次只能给一个学生解答问题，这样一来学生数量很多的话就会给后续等待的学生到成堵塞、浪费资源。同时，众多的学生与老师之间形成了耦合。
   
   解决方式：引入`班长模块`，学生将问题都抛给班长（需要定义格式），班长不做解答，只做问题的记录，这样学生将问题抛出后不用等待。班长收集问题后，将问题给老师模块，老师依次解答。这样解决了学生与老师之间的耦合，也避免了众多学生的等待浪费。

2. `系统A`需要发送数据给其他系统，已经完成了给B、C发送的功能，发送给每个系统的数据可能有差异，因此发送前会对数据进行组装。
   
   上线后又新增了一个需求，`D`也要接收`A`的数据，__此时就需要修改A系统，让他感知到D的存在__，这时就暴露出一个问题：每接入一个下游系统，都需要对`A`进行改造，开发、联调效率低，耦合严重，增加`A`的负担。

## 好处

- 解决耦合  当新的模块接进来时，可以做到代码改动最小

- 异步模型  “早上下单，下午收货“，提升整体系统的吞吐能力

- 削峰  相当于流量缓冲池，可以让后端系统按照自身吞吐能力进行消费，不被冲跨

# 订阅模式

| 比较项目  | Topic模式队列                                                   | Queue模式队列                                                              |
| ----- | ----------------------------------------------------------- | ---------------------------------------------------------------------- |
| 工作模式  | ”订阅-发布“模式，如果当前没有订阅者，消息将会被丢弃，如果有多个订阅者，都会被分发。                 | ”负载均衡“模式。如果当前没有消费者，消息也不会被丢弃。如果有多个消费者，那么消息也只会发送给其中一个消费者（轮寻着发）。一对一（端对端）。 |
| 有无状态  | 无状态                                                         | Queue数据默认会在mq服务器上以文件形式保存                                               |
| 传递完整性 | 如果没有订阅者，消息会被丢弃。不完整。                                         | 消息不会丢弃                                                                 |
| 处理效率  | 由于消息要按照订阅者的数量进行复制，所以处理性能会随着订阅者的增加而明显降低，并且还要结合不同消息协议、自身的性能差异 | 由于一条信息只发送给一个消费者，所以性能与消费者数量无关。但是不同消息协议的具体性能也是有差异的                       |

# JMS

Java消息服务，Java Message Service，JavaEE中的一套规范，指的是两个应用程序之间进行异步通信的API，它为标准消息协议i和消息服务提供了一组通用接口，包括创建、发送、读取消息等，用于支持Java应用程序开发。

实现JMS接口和规范的消息中间件，即我们的MQ服务器。

## MESSAGE

JMS message的组成：消息头 + 消息体 + 消息属性

### 消息头

记录常用的

- JMSDestination 消息发送的目的地，Queue或Topic

- JMSDeliveryMode 持久或非持久（消息的持久化）。持久话能让数据更可靠，即JMS出现故障的话数据也不会丢失，会在服务器恢复之后再次传递。

- JMSExpiration 过期时间，过期时间之后消息还没被发出去，就清除

- JMSPriority 优先级，0-4普通，5-9加急，不严格按照顺序，但加急一定高于普通

- JMSMessgeID 唯一ID，判断是否重复消费，幂等性

### 消息体

封装具体消息数据，5种格式。（使用频率高）

- TextMessage 普通字符串消息 （使用频率高）

- MapMessage map类型消息，key为String类型，值为Java基本数据类型

- BytesMessage 二进制数组消息

- StreamMessage 流

- ObjectMessage 可序列化的Java对象

发送和接受的消息类型必须一致。

### 消息属性

如果需要除消息头字段以外的值，那么可以使用消息属性。

```java
TextMessage tm = session.createTextMessage("wa wa");
tm.setStringProperty("c01","vip"); // 增加属性


TextMessage tms = (TextMessage) messge;
System.out.println(tms.getStringProperty("c01")); // 接收
```

# 可靠性

MQ挂了，消息的持久话和丢失的情况如何？一般有**三个特征**来保障：持久化、事务、签收，其中**事务偏生产者，签收偏消费者**。此外对于对于宕机，还有**多节点集群**。

## 持久化 PERSISTENT

参考redis的持久化（有rdb和aof），消息也有类似的辅助。

### QUEUE

#### 参数设置

1. 非持久 服务器宕机，消息不存在
   
   > messaegeProducer.setDeliveryMode(DeliveryMode.*NON_PRESISTENT*);

2. 持久化 服务器宕机后消息依然存在
   
   > messageProducer.setDelieveryMode(DeliveryMode._PRESISTENT_);

#### 模拟场景

非持久化时，当发布者在队列发布了消息，之后将activeMQ服务器重启，MQ服务器中的消息会丢失。

持久化时，上述操作后，数据依然存在。

在队列中，如果**不显示标注持久**，**默认持久化**，因为可靠性是优先考虑的因素。

持久、事物、签收

### TOPIC

对于topic，先启动订阅再启动生产，否则没有意义（没人订阅，发送的消息都是废消息）。持久化topic类似于订阅号：

1. 先运行一次消费者，等于向MQ注册

2. 然后再运行生产者发送信息

3. 消费者一定会收到订阅消息。不在线的话下次连接时会接收。

## 事务 TRANSACTION

数据库的事务、ACID、隔离级别

```java
// 创建session的第一个参数即 事务是否开启
Session session = connection.createSession(false, Session.AUTO_ACKNOWLEDGE);
```

### 生产者

- false 关闭事务，只要执行`send`就进入到队列中

- true 开启事物，先执行`send`再执行`commit`，消息才被真正提交到队列中。

对于事物的true，为何多此一举？保证事务的高可用、容错性，可以回滚。

```java
try{
    // ok session.commit;
}catch (Exception e){
    // error
    session.rollback();
}finally{
    if(null != session){
        session.close();
    }
}
```

### 消费者

创建session时将事务改为`true`，同样需要`commit`，否则事务会被重复消费。

## 签收 ACKNOWLEDGE

分为事务和非事务两种情况

#### 非事务

```java
// 创建session的第个参数即 签收类型
Session session = connection.createSession(false, Session.AUTO_ACKNOWLEDGE);
```

- 自动签收（默认）   **AUTO_ACKNOWLEDGE**  （使用频率高）

- 手动签收 **CLIENT_ACKNOWLEDGE** （使用频率高）

- 允许重复消息 **DUPS_OK_ACKNOWLEDGE**

手动签收时需要手动标记，否则会造成重复消费：

```java
TextMessage tm = (TextMessage)messageConsumer.receive(4000L);
if(null != tm){
    tm.acknowledge();
}else{
    break;
}
// ...
```

### 事务

```java
// 创建session的第个参数即 签收类型
Session session = connection.createSession(true, Session.AUTO_ACKNOWLEDGE);
```

有事务就需要`commit`。

## 点对点

基于队列，生产者发消息到队列，消费者从队列接收消息，队列的存在使得消息的**异步传输**成为可能。类比平时的即时通讯工具。

- 如果在**Session**关闭时有部分消息已被收到但还没有签收（**acknowledge**)，那当消费者下次连接到同样的队列时，消息会被再次接收。（不会丢失）

- 队列可以长久地保存消息直到消费者收到消息。**消费者不需要因为再次担心消息丢失而时刻和队列保持激活的连接状态**，充分体现了异步传输模式的优势。

## 发布订阅

JMS Pub/Sub模型。定义了如何向一个内容节点发布和订阅消息，这些节点被称作**topic**，主题可以被认为是消息的传输中介，publisher发布消息到主题，subscribe从主题订阅消息。主题使得publisher和subscribe保持互相独立，不需要接触即可保证消息的传送。

### 非持久

对于非持久订阅，只有当客户端处于激活状态，也就是和MQ保持连接状态才能收到发送到某个主题的消息。如果消费者处于离线状态，生产者发生发送的主题消息将会丢失作废，消费者永远不会收到。所以消费者要先注册才能接受到发布。

### 持久化

客户端先向MQ注册一个自己的身份ID识别号，当这个客户端处于离线时，生产者会为这个ID保存所有发送到主题的消息，当客户再次连接到MQ时，MQ会根据消费者的ID得到所有当自己处于离线时发送到主题的消息（即 可以恢复、派送未签收的消息）。

# BROKER

集群、配置时会用到。

相当于一个ActiveMQ服务器**实例**，实现了用代码的形式启动ActiveMQ将MQ嵌入到Java代码中，以便随时用随时启动（用的时候再启动，这样节省资源、保证可靠性）。

之前会在linux服务器上启动，而在这里，是将MQ装在了代码里，MQ是一个实例。  类比springboot内嵌tomcat.

## 消息发送模式

ActiveMQ支持同步、异步两种发送的模式将消息发送到broker，模式的选择对发送延时有巨大影响，使用异步发送可以显著的提高发送的性能。

`ActiveMQ默认使用异步发送的模式`，**同步发送有两种情况**：1. 是明确指定使用同步发送。2. 在未使用事务的情况下发送持久化的消息。第二种情况是特别要注意的，每次发送都会阻塞producer直到broker返回一个确认，表示消息已经被安全地持久化到磁盘，确认机制提供了消息安全的保障，同时阻塞客户端带来了很大的延时。

异步发送可以最大化producer端的发送效率，适合发送消息比较密集的情况下使用，提升producer性能的情况下，也有一定的弊端，就是消耗较多client端内存同时，也会导致broker端性能消耗增加（不停地发消息，能不累么）；此外，它也不能保证消息100%地发送成功，需要容忍消息丢失的可能。很多高性能的应用，`允许在失败的情况下有少量的数据丢失`。

# ACTIVEMQ的传输协议

Q: 默认的61616端口如何更改？生产上的链接协议如何配置的，使用tcp么？

调优：使用NIO传输协议

支持的通讯协议：TCP, NIO, UDP, SSL, VM……（对于java，主要使用前两个）

| 协议     | 描述                  |
| ------ | ------------------- |
| TCP    | 默认的协议，性能相对可以        |
| NIO    | 基于TCP协议之上的，进行了扩展和优化 |
| HTP(s) | 基于HTTP(s)           |

## NIO

要换为NIO，需要修改`activemq.xml`配置文件。

```xml
<broker>
    ...
        <transportConnectors>
            <transportConnector name="nio" uri="nio://192.168.111.136"/>
        </transportConnectors>
    ...
</broker>
```

在消费者、生产者修改代码，指定传输协议：

```java
public stati final String ACTIVEMQ_URL = "nio://192.168.111.136";


public static void main(String[] args){
    ActiveMQConnectionFactory af = new ActiveMQConnectionFactory(ACTIVEMQ_URL);
    ......
}
```

### 增强

Q: uri以”nio“开头，表示这个端口使用以TCP协议为基础的NIO网络IO模型，但是这样的设置方式，只能使这个端口支持`openwire（TCP）`，如何让这个端口支持NIO，又支持多个协议呢？

默认是`BIO+TCP`，目前是`NIO+TCP`，那么如何做到`NIO+TCP/Mqtt/stomp`。

A: 开启多协议支持，用`auto`关键字，[reference](https://activemq.apache.org/auto)。

```xml
<transportConnector name="auto" uri="auto://localhost:5761"/>
```

**note:** 在activeMQ后台配置面板的`Network`可以查看开启的网络协议。

# ACTIVEMQ的存储和可持久化

对于上面的提到的节点（事务、持久、签收），他们都是MQ自带的，不能保证自身故障时的持久，这里提到的可持久化的目的是将数据保存在另外一台机器做备份，达到物理隔离，完成高可用。所以为了避免意外宕机后丢失信息，需要做到重启后可以恢复消息队列，消息系统一般都会`采用持久化机制`（所有MQ都会这样）：在发送者将消息发送出去后，消息中心首先将消息存储到本地数据文件、内存数据库或者远程数据库等，再试图将消息发送给接收者，成功则将消息从存储中删除，失败i则继续尝试发送；如果是重启，消息中心启动后首先检查指定的存储位置，如果有未发送成功的消息，则需要把消息发送出去。

主要介绍两个DB：`KahaDB`, `LevelDB`, `JDBC`

Q: AMQ持久化机制

## KahaDB

基于日志文件，从ActiveMQ5.4开始作为默认的持久化插件（相当于Redis的aof），记录做了哪些操作。

在配置文件中，有：

```xml
<persistenceAdapter>
    <kahaDB directory="${activemq.data}/kahadb"/>
</persistenceAdpter>
```

### 存储原理

reference [here](https:/activemq.apache.org/kahadb)

可用于任何场合，提高了性能和恢复能力。消息存储使用一个**事务日志**和一个**索引文件**（存储所有地址）。

Kahadb在消息保存目录中只有4类文件和一个lock：db-1.log, db.data, db.free, db.redo, lock. （4个文件1把锁）

#### db\<Number\>.log

存储消息到预定义大小的数据记录文件中，Number初始为1，。当数据文件已满时，一个新的文件会随之创建。当不再有引用到数据文件中的任何消息时，文件会被删除或归档（自我空间清理）。

#### db.data

包含了持久化的`BTree索引`，索引了消息数据记录中的消息，它是消息的索引文件，本质上是B-Tree，使用B-Tree作为索引指向`db-\<Number>.log`里面存储的消息。

#### db.free

当前`db.data`文件里哪些页面是空闲的，文件具体内容是所有空闲页的**ID**. 类比linux的bash命令`free`。

#### db.redo

用来进行消息恢复，如果KahaDB消息存储在强制退出后启动，用于恢复BTree索引。

#### lock

相当于mysql中的悲观锁。表示当前获得kahadb读写权限的broker。

## JDBC

主要。将数据放入mysql/oracle中，这是对于长时间持久化存储，推荐用jdbc，特别是带了Journal的。缺点是有点慢。kahaDB是将服务器做本地数据库，JDBC是将他放入另外一个磁盘（类似云盘），相对来说更安全。

## LevelDB

## JDBC Message store with ActiveMQ Journal

主要。

# Q&A

1. 引入消息队列后该如何保证其高可用性

2. 异步投递Async Sends

3. 延迟投递和定时投递

4. 分发策略

5. ActiveMQ消费重试机制

6. 死信队列

7. 如何保证消息不被重复消费呢？谈谈幂等性问题

## 高可用

zookeeper + (replicated-leveldb-store)的主从集群，起码非单机版，是集群的。

## 异步投递

如何确认发送成功？ 

在消息发送完后接收回调。

```java
ActiveMQConnectionFacotry acf = new ActiveMQConnectionFactory(URL);
// 设置为异步发送消息
acf.setUseAsyncSend(true);
ActiveMQMessageProducer amp = (ActiveMQMessageProducer)session.createProducer(queue);
...
TextMessage message = session.createTextMessage();
// 未message设置属性
message.setJMSMessageID(UUID.randomUUID().toString());

// 使用带有回调的send方法来发送
amp.send(message, new AsyncCallback(){
    @Override
    public void onSucces(){

        System.out.println(message.getJMSmessageID+" succeed")
    }
    @Override
    public void onException(JMSException exception){
        // 拿到属性来确认发送失败的消息
        System.out.println(message.getJMSmessageID+" fail")
    }
})
```

## 延迟投递和定时投递

参考[官网说明](http://activemq.apache.org/delay-and-schedule-message-delivery.html)

| Property name          | type   | description |
| ---------------------- | ------ | ----------- |
| AMQ\_SCHEDULED\_DELAY  | long   | 延迟投递的时间     |
| AMQ\_SCHEDULED\_PERIOD | long   | 重复投递的时间间隔   |
| AMQ\_SCHEDULED\_REPEAT | int    | 重复投递次数      |
| AMQ\_SCHEDULED\_CRON   | String | Cron表达式     |

在`activemq.xml`中配置*schedulerSupport*属性为*true*且Java代码中封装的辅助消息类型为*ScheduledMessage*即可。

```java
long delay = 3 * 1000; //延迟投递的时间，每3秒
long period = 4 * 1000;
int repeat = 5;

TextMessage message = session.createTextMessage();
message.setLongProperty(ScheduledMessage.AMQ_SCHEDULED_DELAY, delay);
message.setLongProperty(ScheduledMessage.AMQ_SCHEDULED_PERIOD, delay);
message.setIntProperty(ScheduledMessage.AMQ_SCHEDULED_REPEAT, delay);

messageProducer.send(mesage);
...
```

## ActiveMQ消费重试机制

- 哪些情况会引起消息重发？

- 消息重发时间间隔和重发次数

- 有毒消息Posion ACK

reference [here](activemq.apache.org/redelivery-policy)

重发：在设置事务后没有进行提交（commit），消息就会被重复消费，这时会触发重发机制，默认被重复消费6次后MQ会把这个消息放入DLQ（Dead Letter Queue）死信队列供开发查看，不会再被消费。

## 如何保证消息不被重复消费（幂等性）

**note**: 何时会重复消费？网络延迟造成MQ重试，进而重复消费。

- 如果是做数据库的插入操作，可以给消息做一个唯一主键，重复消费时会导致主键冲突

- 使用第三方服务来做消费记录。以redis为例，给消息分配一个**全局id**，只要消费过该消息，将\<id, message\>以K-V形式写入redis，消费者消费前先去redis中查询有没有消费记录即可。