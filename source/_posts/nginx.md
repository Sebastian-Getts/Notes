---
title: nginx
date: 2019-11-02 22:53:32
categories: Network
tags: network
---
# NIGNX

*Nginx* (engine x) 是一个高性能的HTTP和**反向代理**web服务器，同时也提供了IMAP/POP3/SMTP服务。Nginx是由伊戈尔·赛索耶夫为俄罗斯访问量第二的Rambler.ru站点（俄文：Рамблер）开发的，第一个公开版本0.1.0发布于2004年10月4日。

它是一款轻量级的Web服务器反向代理服务器及电子邮件（IMAP/POP3）代理服务器，在BSD-like 协议下发行。其特点是占有内存少，并发能力强，事实上nginx的并发能力确实在同类型的网页服务器中表现较好。

特点：

- 反向代理
- 负载均衡
- 动静分离
- 高可用



## 反向代理

客户端对代理是无感知的，因为客户端不需要任何配置就可以访问，只需要将请求发送到反向代理服务器，由反向代理服务器去选择目标服务器获取数据后，再返回给客户端。此时反向代理服务器的目标服务器对外就是一个服务器，暴露的是代理服务器地址，隐藏了真实服务器IP地址。

## 正向代理

如果把局域网外的Internet比作资源库，则局域网中的客户端要访问Internet，则需要通过代理服务器来访问，这种代理服务就称作正向代理。（nginx还可以用作正向代理来进行上网功能。）

正向访问需要在浏览器配置代理服务器。



## 负载均衡

单个服务器解决不了问题，我们增加服务器的数量，然后将请求分发到各个服务上，将原先请求集中到单个服务器上的情况改为将请求分发到多个服务器上，将负载分发到不同的服务器，即负载均衡。



## 动静分离

为了加快网站的解析速度，可以把动态页面和静态页面由不同的服务器来解析，加快解析速度。降低原来单个服务器的压力。静态资源和动态资源分开部署放置两台不同的服务器。

静态资源：html, css, js

动态资源：jsp, servlet

## 操作

### 常用命令

前提条件：进入nginx目录

/usr/localnginx/sbin

- 查看nginx版本号
- 启动
- 关闭
- 重新加载nginx

[referenct](https://mp.weixin.qq.com/s/PeNWaCDf_6gp2fCQa0Gvng)

# 配置

1. 配置EPEL源

   ```bash
   sudo yum install -y epel-release
   sudo yum -y update
   ```

2. 安装nginx

   ```bash
   sudo yum instll -y nginx
   ```

   安装成功后：

   `默认网站目录`：_/usr/share/nginx/html_

   `默认的配置文件为`：_/etc/nginx/nginx.conf_

   `自定义配置文件目录为`：_/etc/nginx/conf.d/_

3. 开启端口80和443

   如果关闭了防火墙，直接略过。

   ```bash
   sudo firewall-cmd --permanent --zone=public --add-service=http
   sudo firewall-cmd --permanent --zone=public --add-service=https
   sudo firewall-cmd --reload
   ```

4. 命令

   - 启动

     ```bash
     systemctl start nginx
     ```

   - 停止

     ```bash
     systemctl stop nginx
     ```

   - 重启

     ```bash
     systemctl restart nginx
     ```

   - 查看状态

     ```bash
     systemctl status nginx
     ```

   - 启用开机启动

     ```bash
     systemctl enable nginx
     ```

     测试的时候，直接`nginx`命令即可，方便调试，调试时使用：

     ```bash
     nginx -t
     ```

     ```bash
     nginx -s reload
     ```

     

   - 禁止开机启动

     ```bash
     systemctl disbale nginx
     ```

5. https

   1. 关于https的相关证书，可以从阿里云控制台获取（因为我租用的是阿里云服务器）。

   3. 拷贝证书至nginx
   
      domain为个人域名。
   
      ```bash
   mkdir -p /etc/nginx/ssl
      
   acme.sh --install-cert -d domain \
      --key-file       /etc/nginx/ssl/domain.key  \
      --fullchain-file /etc/nginx/ssl/domain.cer \
      --reloadcmd     "service nginx force-reload"
      ```
   
6. 配置nginx

   删除**/etc/nginx/nginx.conf**中的server部分代码

   ```markdown
   server{
   ...
   }
   ```

   在**/etc/nginx/conf.d**创建自定义配置文件夹**default.conf**

   ```properties
   server {
       listen 80;
       listen 443 ssl;
       server_name  domain www.domain;
       location / {
            root /usr/share/nginx/html;
            index  index.html index.htm;
        }
   
       ssl_certificate /etc/nginx/ssl/domain.crt;
       ssl_certificate_key /etc/nginx/ssl/domain.key;
       ssl_session_timeout  5m;
       ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
       ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE:ECDH:AES:HIGH:!NULL:!aNULL:!MD5:!ADH:!RC4:!DH:!DHE;
       ssl_prefer_server_ciphers  on;
   
       error_page 497  https://$host$uri?$args;
   }
   ```
   

   

   
