##### 简介 #####

问题：

1. 每两秒发一次请求  缺点 并发量很大

2. 长连接   websocket 一种实现了长连接的技术  不能很好兼容所有的浏览器

   （HTTP 短连接   一次请求一次响应就结束）

##### 解决方法 #####

​	goeasy  是对websocket的封装  能够兼容所有的浏览器

##### 应用步骤 #####

（需注册账号，使用goeasy的服务器发送长连接）

​	1.前端引入js

```javascript
<script src="http(s)://<CDN Host>/goeasy.js"></script>
```

​	2.导入依赖

```xml
//需使用goeasy的仓库
<repositories>
  <repository>
    <id>goeasy</id>
    <name>goeasy</name>
    <url>
      http://maven.goeasy.io/content/repositories/releases/
    </url>
  </repository>
</repositories>
  
  <dependency>
      <groupId>io.goeasy</groupId>
      <artifactId>goeasy-sdk</artifactId>
      <version>0.3.8</version>
    </dependency>
```

​	3.服务端开发

```java
@Test
public void test1(){
    //此key为发布订阅，内容的appkey
    GoEasy goEasy = new GoEasy( "http://rest-hangzhou.goeasy.io", "BC-c5daff84bbe44baabf72dab5bb69a9e3");

    /**
     * channel 通道 频道的名字
     * content 要发布的内容
     */
    goEasy.publish("cmfzChannel", "Hello, GoEasy!");
}
```

​	4.浏览器端开发

```javascript
//此key为接收订阅的appkey
var goEasy = new GoEasy({
    appkey: "BS-c63779afdd1a4c0a9211648876b201a0"
});

goEasy.subscribe({
    channel: "cmfzChannel",
    onMessage: function (message) {
       alert("Channel:" + message.channel + " content:" + message.content);
    }
});
```

​	5.推送注册量信息

```java
   @Test
    public void test1() throws InterruptedException {
//需要把要传送的数据转换为json发送过去
//        1.获取数据
            Map map = cmfzUserService.selectByDayCount();
//        2.创建Gson 转json
            Gson gson = new Gson();
            String json = gson.toJson(map);

//        3.创建GoEasy 对象
            GoEasy goEasy = new GoEasy( "http://rest-hangzhou.goeasy.io", "BC-c5daff84bbe44baabf72dab5bb69a9e3");

//        4.推送信息
            /**
             * channel 通道 频道的名字
             * content 要发布的内容
             */
            goEasy.publish("cmfzChannel", json);
    }
```

​	6.前台转换json

```javascript
//写在onMessage的函数里面
var data = JSON.parse(message.content);
```

