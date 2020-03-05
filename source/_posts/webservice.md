---
title: webservice
date: 2020-01-04 10:46:18
categories: CS
tags: 
- network
- principles
---

it's said that webService is Simple... In fact, webService = http + xml

<!-- more -->



# 序

- 使用webService的原因：调用其他服务提供商提供的服务，例如天气查询、汽车违章记录等等。
- webService使用xml来进行传输，使用自己的协议`SOAP（简单对象访问协议）`。
- 可以使用http的get请求来访问，也可以借助封装的http-client来访问。还可以使用java自带的`wsImport`来实现本地代理，将webService翻译成java类。
- 可以自己写webService，`对服务类加上注解`。通过`endPoint（端点服务）`能够把我们的webService服务类发布出去。

## 



## WSDL

WebService Description Language. Web服务描述语言。是基于XML的用于描述webService以及如何访问webService的语言。通过xml形式说明：

- 服务在什么地方 - 地址
- 提供什么样的方法 - 如何调用

主要元素：

| 元素        | 定义                       |
| ----------- | -------------------------- |
| \<portType> | web service 执行的操作     |
| \<message>  | web service 使用的消息     |
| \<types>    | web service 使用的数据类型 |
| \<binding>  | web service 使用的通信协议 |

其中，`porType`元素是最重要的元素，它可以描述一个webService、可被执行的操作，以及相关的信息。可以把这个元素比作高级编程语言的一个函数库。

e.g.

```xml
<message name="getTermRequest">
   <part name="term" type="xs:string"/>
</message>

<message name="getTermResponse">
   <part name="value" type="xs:string"/>
</message>

<portType name="glossaryTerms">
  <operation name="getTerm">
        <input message="getTermRequest"/>
        <output message="getTermResponse"/>
  </operation>
</portType>
```



portType元素把 "glossaryTerms" 定义为某个端口的名称，把 "getTerm" 定义为某个操作的名称。

操作 "getTerm" 拥有一个名为 "getTermRequest" 的*输入消息*，以及一个名为 "getTermResponse" 的输出消息。

message元素可定义每个消息的部件，以及相关联的数据类型。

### portType

请求-响应是最普通的操作，其实，，WSDL定义了四中类型

| 类型             | 定义                                       |
| ---------------- | ------------------------------------------ |
| one-way          | got request, not response                  |
| request-response | got request and give back a response       |
| solicit-response | give a request and wait for a response     |
| notification     | give a request and not wait for a response |



#### one-way

e.g.

```xml
<message name="newTermValues">
   <part name="term" type="xs:string"/>
   <part name="value" type="xs:string"/>
</message>

<portType name="glossaryTerms">
   <operation name="setTerm">
      <input name="newTerm" message="newTermValues"/>
   </operation>
</portType >
```

#### request-response

```xml
<message name="getTermRequest">
   <part name="term" type="xs:string"/>
</message>

<message name="getTermResponse">
   <part name="value" type="xs:string"/>
</message>

<portType name="glossaryTerms">
  <operation name="getTerm">
    <input message="getTermRequest"/>
    <output message="getTermResponse"/>
  </operation>
</portType>
```



### binding

为webService定义消息格式和协议细节。

**binding** has two attributes: *name* and *type*, the forward gives the binding's name and the last gives the bindings port;

**soap:binding** has two attributes: *style* and *transport*, in the forward we can choose between "rpc" and "document", the last point out which SOAP principles we use.

**operation**定义了每个端口提供的操作符。对于每个操作，响应的SOAP行为都需要被定义。还要规定输入输出的编码，例如“literal”。

e.g.

```xml
<message name="getTermRequest">
   <part name="term" type="xs:string" />
</message>

<message name="getTermResponse">
   <part name="value" type="xs:string" />
</message>

<portType name="glossaryTerms">
  <operation name="getTerm">
      <input message="getTermRequest" />
      <output message="getTermResponse" />
  </operation>
</portType>

<binding type="glossaryTerms" name="b1">
<soap:binding style="document"
transport="http://schemas.xmlsoap.org/soap/http" />
  <operation>
    <soap:operation
     soapAction="http://example.com/getTerm" />
    <input>
      <soap:body use="literal" />
    </input>
    <output>
      <soap:body use="literal" />
    </output>
  </operation>
</binding>
```

### 完整WSDL语法示例

e.g.

```xml
<wsdl:definitions name="nmtoken"? targetNamespace="uri">

    <import namespace="uri" location="uri"/> *
	
    <wsdl:documentation .... /> ?

    <wsdl:types> ?
        <wsdl:documentation .... /> ?
        <xsd:schema .... /> *
    </wsdl:types>

    <wsdl:message name="ncname"> *
        <wsdl:documentation .... /> ?
        <part name="ncname" element="qname"? type="qname"?/> *
    </wsdl:message>

    <wsdl:portType name="ncname"> *
        <wsdl:documentation .... /> ?
        <wsdl:operation name="ncname"> *
            <wsdl:documentation .... /> ?
            <wsdl:input message="qname"> ?
                <wsdl:documentation .... /> ?
            </wsdl:input>
            <wsdl:output message="qname"> ?
                <wsdl:documentation .... /> ?
            </wsdl:output>
            <wsdl:fault name="ncname" message="qname"> *
                <wsdl:documentation .... /> ?
            </wsdl:fault>
        </wsdl:operation>
    </wsdl:portType>

    <wsdl:serviceType name="ncname"> *
        <wsdl:portType name="qname"/> +
    </wsdl:serviceType>

    <wsdl:binding name="ncname" type="qname"> *
        <wsdl:documentation .... /> ?
        <-- binding details --> *
        <wsdl:operation name="ncname"> *
            <wsdl:documentation .... /> ?
            <-- binding details --> *
            <wsdl:input> ?
                <wsdl:documentation .... /> ?
                <-- binding details -->
            </wsdl:input>
            <wsdl:output> ?
                <wsdl:documentation .... /> ?
                <-- binding details --> *
            </wsdl:output>
            <wsdl:fault name="ncname"> *
                <wsdl:documentation .... /> ?
                <-- binding details --> *
            </wsdl:fault>
        </wsdl:operation>
    </wsdl:binding>

    <wsdl:service name="ncname" serviceType="qname"> *
        <wsdl:documentation .... /> ?
        <wsdl:port name="ncname" binding="qname"> *
            <wsdl:documentation .... /> ?
            <-- address details -->
        </wsdl:port>
    </wsdl:service>

</wsdl:definitions>
```





## UDDI

Universal Description, Discovery and Integration, 一种目录服务（存储有关webService的信息的目录，经由SOAP通信），企业可以使用它对webService进行注册和搜索。



## SOAP

基于xml的简易协议，可以使应用程序在http上进行信息交换。

- SOAP 消息必须用 XML 来编码
- SOAP 消息必须使用 SOAP Envelope 命名空间
- SOAP 消息必须使用 SOAP Encoding 命名空间
- SOAP 消息不能包含 DTD 引用
- SOAP 消息不能包含 XML 处理指令

e.g.

```xml
<?xml version="1.0"?>
<soap:Envelope
xmlns:soap="http://www.w3.org/2001/12/soap-envelope"
soap:encodingStyle="http://www.w3.org/2001/12/soap-encoding">

<soap:Header>
  ...
  ...
</soap:Header>

<soap:Body>
  ...
  ...
  <soap:Fault>
    ...
    ...
  </soap:Fault>
</soap:Body>

</soap:Envelope>
```



## WebService

通过它可以是应用程序向全世界发布功能或消息使用XML来编解码数据，并使员工SOAP借由开放的协议来传输数据。它的创建爱你与编程语言的种类无关，一般都不用自己编写WSDL和SOAP文档。

它有三种基本的元素：SOAP、WSDL、UDDI。上面都已经简单的介绍过了:smiley:.

