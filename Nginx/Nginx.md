# Nginx

#### 1.在CentOS7上安装Nginx

1. 去官网http://nginx.org/下载对应的nginx包，推荐使用稳定版本 

2. 上传nginx到linux系统 

3. 安装依赖环境 

   (1)安装gcc环境 

   ```shell
   yum install gcc-c++ 
   ```

   (2)安装PCRE库，用于解析正则表达式 

   ```shell
   yum install -y pcre pcre-devel
   ```

   (3)zlib压缩和解压缩依赖， 

   ```shell
   yum install -y zlib zlib-devel 
   ```

   (4)SSL 安全的加密的套接字协议层，用于HTTP安全传输，也就是https 

   ```shell
   yum install -y openssl openssl-devel 
   ```

4. 解压，需要注意，解压后得到的是源码，源码需要编译后才能安装 

   ```shell
   tar -zxvf nginx-1.16.1.tar.gz 
   ```

5. 编译之前，先创建nginx临时目录，如果不创建，在启动nginx的过程中会报错 

   ```shell
   mkdir /var/temp/nginx -p 
   ```

6. 在nginx目录，输入如下命令进行配置，目的是为了创建makefile文件 

```shell
./configure \
--prefix=/usr/local/nginx \
--pid-path=/var/run/nginx/nginx.pid \
--lock-path=/var/lock/nginx.lock \
--error-log-path=/var/log/nginx/error.log \
--http-log-path=/var/log/nginx/access.log \
--with-http_gzip_static_module \
--http-client-body-temp-path=/var/temp/nginx/client \
--http-proxy-temp-path=/var/temp/nginx/proxy \
--http-fastcgi-temp-path=/var/temp/nginx/fastcgi \
--http-uwsgi-temp-path=/var/temp/nginx/uwsgi \
--http-scgi-temp-path=/var/temp/nginx/scgi

##  ‘\’是指换行，增加可读性
```

配置命令解释 

```shell
–prefix 指定nginx安装目录 

–pid-path 指向nginx的pid 

–lock-path 锁定安装文件，防止被恶意篡改或误操作 

–error-log 错误日志 

–http-log-path http日志 

–with-http_gzip_static_module 启用gzip模块，在线实时压缩输出数据流 

–http-client-body-temp-path 设定客户端请求的临时目录 

–http-proxy-temp-path 设定http代理临时目录 

–http-fastcgi-temp-path 设定fastcgi临时目录 

–http-uwsgi-temp-path 设定uwsgi临时目录 

–http-scgi-temp-path 设定scgi临时目录
```

7. make编译 

```shell
make
```

8. 安装 （默认安装位置为默认安装位置为/usr/local/nginx）

```shell
make install
```

9. 进入sbin目录启动nginx 

```shell
./nginx

#强制停止：
./nginx -s stop

#优雅停止：（会等请求返回后在停止）
./nginx -s quit

#重新加载：
./nginx -s reload 
```

10. 打开浏览器，访问虚拟机所处内网ip即可打开nginx默认页面，显示如下便表示安装成功： 

    ![1583069816630](assets/1583069816630.png)

注意事项: 

1. 如果在云服务器安装，需要开启默认的nginx端口：80 

2. 如果在虚拟机安装，需要关闭防火墙 

3. 本地win或mac需要关闭防火墙



#### 2.Nginx的请求机制

​	nginx的请求机制是异步非阻塞形式的，所以非常高效，且节约系统资源。

​	在nginx中有两种角色，master和worker，master负责接收请求分配给worker，worker指派给具体的Client来处理请求。master接收到一个请求分给一个worker，worker分给具体的client处理请求，master在再接收到一个请求时可以发给另一个worker，或者若第一个请求处理时间长第一个worker处于等待时也可分给第一个worker，由第一个worker分给另一个client处理，即异步非阻塞机制。



#### 扩展：网络编程的一些概念：同步 异步、阻塞和非阻塞

​	同步和异步其实是从消息的通知机制方面来说的。同步调用就是指调用方发出一个同步调用，一直等待结果的返回，并依赖这个返回进行下一步处理。异步调用指的是调用方发出一个异步调用后，继续执行后续操作，不依赖于此返回，后续的结果由调用方通过循环获取状态或者被调用方通过通知、回调函数的形式返回给调用方，像通过状态这种效率低，不建议使用。作为一个任务序列来说，同步调用强调执行并得到返回结果，属于可靠的序列，但异步只需要执行并不在乎结果，属于不可靠的。

​	阻塞和非阻塞其实是从程序（线程）等待消息时的状态来说的，阻塞就是说线程执行一件事若没有执行完就不会执行下一件事，非阻塞是说程序调用时，若不能及时得到结果，就会转而执行另一件事。

​	这四个概念两两组合就是我们常见的网络编程形式，同步阻塞、同步非阻塞、异步阻塞、异步非阻塞；除第三个外一一对应BIO、NIO、AIO。

​	

#### 3.nginx.conf 核心配置文件

1. 设置worker进程的用户，指的linux中的用户，会涉及到nginx操作目录或文件的一些权限，默认为 nobody

   **nobody用户没有访问静态资源权限** 

```shell
user root; 
```

2. worker进程工作数设置，一般来说CPU有几个，就设置几个，或者设置为N-1也行 

```shell
worker_processes 1; 
```

3. nginx 日志级别 debug | info | notice | warn | error | crit | alert | emerg ，错误级别从左到右越来越大 

4. 设置nginx进程 pid （就是存放nginx当前启动的进程号）

```shell
pid logs/nginx.pid; 
```

5. 设置工作模式 

```shell
events { 

# 默认使用epoll （可以根据不同的操作系统使用不同的工作模式）

use epoll; 

# 每个worker允许连接的客户端最大连接数 

worker_connections 10240; 

} 
```

6. http 是指令块，针对http网络传输的一些指令配置 

```shell
http { 
	
} 
```

7. include 引入外部配置，提高可读性，避免单个配置文件过大 

```shell
include mime.types; 
```

8. log_format设定日志格式， main 为定义的格式名称，如此 access_log 就可以直接使用这个变量了（log_format与access_log搭配使用）

       #log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
       #                  '$status $body_bytes_sent "$http_referer" '
       #                  '"$http_user_agent" "$http_x_forwarded_for"';
       
       #access_log  logs/access.log  main;

| 参数名                | 参数意义                             |
| --------------------- | ------------------------------------ |
| $remote_addr          | 客户端ip                             |
| $remote_user          | 远程客户端用户名，一般为：’-’        |
| $time_local           | 时间和时区                           |
| $request              | 请求的url以及method                  |
| $status               | 响应状态码                           |
| $body_bytes_send      | 响应客户端内容字节数                 |
| $http_referer         | 记录用户从哪个链接跳转过来的         |
| $http_user_agent      | 用户所使用的代理，一般来时都是浏览器 |
| $http_x_forwarded_for | 通过代理服务器来记录客户端的ip       |

9. sendfile 使用高效文件传输，提升传输性能。启用后才能使用 tcp_nopush ，是指当数据表累积一定大小后才发送，提高了效率。 

```shell
sendfile on; 

tcp_nopush on; 
```

10. keepalive_timeout 设置客户端与服务端请求的超时时间，保证客户端多次请求的时候不会重复建立新的连接，节约资源损耗。 

```shell
#keepalive_timeout 0; 单位为秒

keepalive_timeout 65;
```

11. gzip 进行资源压缩，

```shell
#开启gzip压缩功能，目的：提高传输效率，节约带宽
gzip on;
#限制最小压缩，小于1字节的资源不会压缩
gzip_min_length 1;
#定义压缩级别，（压缩比，文件越大，压缩越多，但是CPU使用会越多）
gzip_comp_level 3;
#定义压缩文件的类型
gzip_types text/plain/...;
```



##### tip：nginx.pid打开失败或者失效的解决方法

​	打开失败可以重新创建nginx.pid父级文件夹路径，失效可以重新配置nginx配置文件：

```shell
./nginx -c /usr/local/nginx/conf/nginx.conf
```

#### 4.Nginx日志切割

​	Nginx日志切割就是把Nginx中的请求日志(access.log)和错误日志(erro.log)按照一定的规则切割为小文件，防止单个文件过大，方式有两种：手动和定时。手动就是指手动执行脚本切割，定时就是用定时任务按时切割文件。在Linux中可以用**crontabs**。

手动：

- 创建一个shell可执行文件： cut_my_log.sh 

```shell
#!/bin/bash
LOG_PATH="/var/log/nginx/"
RECORD_TIME=$(date -d "yesterday" +%Y-%m-%d+%H:%M)
PID=/var/run/nginx/nginx.pid
mv ${LOG_PATH}/access.log ${LOG_PATH}/access.${RECORD_TIME}.log
mv ${LOG_PATH}/error.log ${LOG_PATH}/error.${RECORD_TIME}.log

#向Nginx主进程发送信号，用于重新打开日志文件
kill -USR1 `cat $PID`
```

- 为 cut_my_log.sh 添加可执行的权限

```shell
chmod +x cut_my_log.sh
```

-  执行脚本测试日志切割后的结果

```shell
./cut_my_log.sh
```

定时：

- 安装定时任务： 

```shell
yum install crontabs
```

- crontab -e 编辑并且添加一行新的任务： 

```shell
*/1 * * * * /usr/local/nginx/sbin/cut_my_log.sh
```

- 重启定时任务： 

```shell
service crond restart
```

常用定时任务命令:

```shell
/bin/systemctl start crond   //启动
/bin/systemctl stop crond    //停止
/bin/systemctl restart crond //重启
/bin/systemctl reload crond  //重新加载配置
/bin/systemctl status crond  //查看状态
crontab -e // 编辑任务 
crontab -l // 查看任务列表
```

定时任务的表达式为Cron表达式，下面为常用的表达式：

```shell
#每分钟执行：
*/1 * * * *
#每日凌晨（每天晚上23:59）执行：
59 23 * * *
#每日凌晨1点执行：
0 1 * * *
```

参考文档：每天定时为数据库备份：https://www.cnblogs.com/leechenxiang/p/7110382.html



#### 5.Nginx作为虚拟主机为静态资源提供服务



```conf
server {
        listen       90;
        server_name  localhost;
        
        #服务器路径为/home/foodie-shop/files/img/face.png
        
        #root 路径完全匹配访问
        #用户访问请求为url:port/files/img/face.png
        #下面表示访问ip:90后直接访问/home/foodie-shop路径下的index.html
        location / {
            root   /home/foodie-shop;
            index  index.html;
        }
        
        #下面表示访问ip:90/static后直接访问/workspaces/images/foodie/faces/191218H9SFHA66A8路径下的face-191218H9SFHA66A8.jpg，即用nginx作为虚拟主机为静态资源提供服务
        #alias表示隐藏路径
        location /static {
            alias  /workspaces/images/foodie/faces/191218H9SFHA66A8;
            index  face-191218H9SFHA66A8.jpg;
        }
        
        
        #以下配置可利用nginx实现跨域
        #允许跨域请求的域，*代表所有 
        add_header 'Access-Control-Allow-Origin' *; 
        #允许带上cookie请求 
        add_header 'Access-Control-Allow-Credentials' 'true'; 
        #允许请求的方法，比如 GET/POST/PUT/DELETE 
        add_header 'Access-Control-Allow-Methods' *; 
        #允许请求的header 
        add_header 'Access-Control-Allow-Headers' *;

    }
```

##### 扩展：SpringBoot实现跨域：

```java
package com.dreamshop.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import org.springframework.web.filter.CorsFilter;

/**
 * function: 跨域设置配置类
 * @author DreamHeng
 * @date 2019/12/18
 */
@Configuration
public class CorsConfig {

    public CorsConfig() {
    }

    @Bean
    public CorsFilter corsFilter(){
        //1.添加cors配置信息
        CorsConfiguration config = new CorsConfiguration();
        //添加支持的网址
        config.addAllowedOrigin("http://localhost:8080");
        config.addAllowedOrigin("*");
        //设置是否发送cookie信息
        config.setAllowCredentials(true);
        //设置允许请求的方式
        config.addAllowedMethod("*");
        //设置允许的header
        config.addAllowedHeader("*");

        //2.为url添加映射路径
        UrlBasedCorsConfigurationSource corsConfigSource = new UrlBasedCorsConfigurationSource();
        corsConfigSource.registerCorsConfiguration("/**",config);

        //3.返回重新定义好的CorsFilter
        return new CorsFilter(corsConfigSource);
    }
}
```

##### location的匹配规则

空格 ：默认匹配，普通匹配 

```con
location / { 

	root /home; 

}
```

= ：精确匹配 

```conf
location = /imooc/img/face1.png { 

	root /home; 

}
```

~* ：匹配正则表达式，不区分大小写 

```conf
#符合图片的显示 

location ~ \.(GIF|jpg|png|jpeg) { 

	root /home; 

}
```

~ ：匹配正则表达式，区分大小写 

```conf
#GIF必须大写才能匹配到 

location ~ \.(GIF|jpg|png|jpeg) { 

	root /home; 

}
```

^~ ：以某个字符路径开头 

```conf
location ^~ /imooc/img { 

	root /home; 

}
```

##### Nginx 防盗链配置支持

​	Nginx是防止其它网站随意引用本网站下的静态资源进行的保护措施。在http-->server里面配置：

```conf
#对源站点验证，对来源不是heng.com域的进行判断 
valid_referers *.heng.com; 
#非法引入会进入下方判断，返回定义的状态，状态可自定义 
if ($invalid_referer) { 
	return 404; 
}
```



#### 6.Nginx实现反向代理功能

​	反向代理就是指代理服务器接收客户端的请求，然后分发给具体处理请求的后端服务器。

​	Nginx作为反向代理的最大好处就是基于它异步非阻塞的请求机制，可以非常高效的处理和分发请求，使得后端服务器只需要负责逻辑运算，节约等待时间处理更多请求。

##### 反向代理基本配置

```shell
upstream baidunode {
	server 172.25.0.105:8081 weight=10 max_fails=3     fail_timeout=30s;
}
location / {
    add_header Cache-Control no-cache;
    proxy_set_header   Host local.baidu.com;
    proxy_set_header   X-Forwarded-For  $proxy_add_x_forwarded_for;
    proxy_set_header   X-Real-IP        $remote_addr;
    proxy_pass         http://baidunode;
    proxy_connect_timeout 30s;
 }
```

下面就代码里的配置做说明：
 	nginx配置文件通过使用`add_header`指令来设置`response header`，`response header`一般都是以key：value的形式，例如：“Content-Encoding：gzip、Cache-Control:no-store”，设置的命令为：

```shell
add_header Cache-Control no-store
add_header Content-Encoding gzip
```

nginx 为实现反向代理的需求增加了一个 [ngx_http_proxy_module 模块](https://link.jianshu.com?t=http://nginx.org/en/docs/http/ngx_http_proxy_module.html)。其中 proxy_set_header 指令就是该模块需要读取的配置。
 现在对每句配置做个说明

- `proxy_set_header Host local.baidu.com;`
   HTTP header 中的 Host 含义为所请求的目的主机名。当 nginx 作为反向代理使用，而后端真实 web 服务器设置有类似 **防盗链功能** ，或者根据 HTTP header 中的 Host 字段来进行 **路由** 或 **过滤** 功能的话，若作为反向代理的 nginx 不重写请求头中的 Host 字段，将会导致请求失败。
- `proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;`
   HTTP header 中的  X_Forward_For  表示该条 http 请求是由谁发起的。如果反向代理服务器不重写该请求头的话，那么后端真实 web 服务器在处理时会认为所有的请求都来自反向代理服务器。如果后端 web 服务器有防攻击策略的话，那么反向代理服务器对应的 ip 地址就会被封掉。
   上述配置的意思是增加一个 `$proxy_add_x_forwarded_for` 到 `X-Forwarded-For`里去，注意是增加，而不是覆盖。当然由于默认的 `X-Forwarded-For` 值是空的，所以我们总感觉 `X-Forwarded-For` 的值就等于 `$proxy_add_x_forwarded_for` 的值。
   `X-Forwarded-For`的格式为`X-Forwarded-For:real client ip, proxy ip 1, proxy ip N`，每经过一个反向代理就在请求头X-Forwarded-For后追加反向代理IP。
- `proxy_connect_timeout`
   nginx服务器与被代理的服务器建立连接的超时时间，默认60秒

详细配置可参考：https://www.cnblogs.com/knowledgesea/p/5199046.html