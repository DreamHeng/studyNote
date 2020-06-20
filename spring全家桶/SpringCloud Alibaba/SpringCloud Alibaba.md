# SpringCloud Alibaba

## 选择Alibaba的原因

##### SpringCloud缺点

- SpringCloud的部分组件已经不再维护，比如Eureka、Hystrix；
- 环境搭建复杂，没有完善的可视化界面，需要二次开发；
- 配置复杂，难以上手。

##### SpringCloud Alibaba优点

- 经过实战考验，性能强悍；
- 成套搭配具有完善的可视化界面；
- 搭建简单，学习成本低。

## 1.简单使用

### 1.1.引入SpringCloud Alibaba依赖到项目中

根据使用的SpringBoot版本引用对应的Alibaba版本包，两个版本号相对应

在基础服务（Common）里面引用该依赖，

```xml
<!--使用SpringBoot2.2.X版本，所以SpringCloud Alibaba使用2.2.X版本-->
    <dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>com.alibaba.cloud</groupId>
                <artifactId>spring-cloud-alibaba-dependencies</artifactId>
                <version>2.2.1.RELEASE</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
        </dependencies>
    </dependencyManagement>
```

### 1.2.Nacos注册中心配置

#### 1.2.1.启动服务端

下载Nacos Server（https://github.com/alibaba/nacos/releases）

启动startup.cmd

默认端口8848

#### 1.2.2.配置客户端

（1）引入依赖

```xml
		<!--nacos注册中心依赖-->
        <dependency>
            <groupId>com.alibaba.cloud</groupId>
            <artifactId>spring-cloud-starter-alibaba-nacos-discovery</artifactId>
        </dependency>
```

（2）在对应应用服务的配置文件中配置nacos server地址

```properties
spring.cloud.nacos.discovery.server-addr=127.0.0.1:8848
spring.application.name=service-provider
server.port=8070
```

（3）在启动类配置注解`@EnableDiscoveryClient`开启服务注册和发现功能

#### 1.2.3.控制台查看服务列表

http://127.0.0.1:8848/nacos/

默认账号密码都为nacos

### 1.3.Feign远程服务调用

#### 1.3.1.Feign和OpenFeign

​	Feign是Netflix开源的，后来不再维护后，社区推出了OpenFeign，是在Feign的基础上不断更新维护的。

#### 1.3.2.OpenFeign

​	OpenFeign是声明式Http客户端，在SpringCloud中通常是**服务间**互相调用的方式，可以搭配OkHttp使用。

#### 1.3.3.OpenFeign简单使用（调用方）

（1）引入OpenFeign依赖

```xml
		<dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-openfeign</artifactId>
        </dependency>
```

（2）编写接口，声明需要调用的方法

```java
package com.heng.gulimail.member.feign;

import com.heng.common.utils.R;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.RequestMapping;

//远程服务名称
@FeignClient("gulimail-coupon")
public interface CouponFeignService {

    //远程调用服务方法的全路径和方法的全部声明
    @RequestMapping("/coupon/coupon/testOpenFeign")
    public R testOpenFeign();
}
```

（3）启动类开启远程调用，并扫描声明式接口

```java
import org.springframework.cloud.openfeign.EnableFeignClients;
@EnableFeignClients(basePackages = "com.heng.gulimail.member.feign")
```

（4）可以在程序中使用`@Autowired`引入接口，调用其中的方法。

### 1.4.Nacos配置中心

#### 1.4.1.基本使用

（1）引入依赖

```xml
		<!--nacos配置中心依赖-->
        <dependency>
            <groupId>com.alibaba.cloud</groupId>
            <artifactId>spring-cloud-starter-alibaba-nacos-config</artifactId>
        </dependency>
```

（2）在 `bootstrap.properties` 中配置 Nacos server 的地址和应用名

```properties
spring.cloud.nacos.config.server-addr=127.0.0.1:8848

spring.application.name=gulimail-member
```

说明：之所以需要配置 `spring.application.name` ，是因为它是构成 Nacos 配置管理 `dataId`字段的一部分。

在 Nacos Spring Cloud 中，`dataId` 的完整格式如下：

```plain
${prefix}-${spring.profile.active}.${file-extension}
```

- `prefix` 默认为 `spring.application.name` 的值，也可以通过配置项 `spring.cloud.nacos.config.prefix`来配置。
- `spring.profile.active` 即为当前环境对应的 profile，详情可以参考 [Spring Boot文档](https://docs.spring.io/spring-boot/docs/current/reference/html/boot-features-profiles.html#boot-features-profiles)。 **注意：当 `spring.profile.active` 为空时，对应的连接符 `-` 也将不存在，dataId 的拼接格式变成 `${prefix}.${file-extension}`**
- `file-exetension` 为配置内容的数据格式，可以通过配置项 `spring.cloud.nacos.config.file-extension` 来配置。目前只支持 `properties` 和 `yaml` 类型。

（3）通过 Spring Cloud 原生注解 `@RefreshScope` 实现配置自动更新

```yml
member.name=小梦
member.age=38
```

```java
@RefreshScope
@PropertySource(value = "classpath:my.yml", encoding = "UTF-8")
public class GrowthChangeHistoryController {

    @Value("${member.name}")
    String memberName;
    @Value("${member.age}")
    String memberAge;

    @RequestMapping("testNacosConfig")
    public R testNacosConfig(){
        return R.ok().put("name",memberName).put("age",memberAge);
    }
}   
```

注意：在获取配置文件中的值时有关于中文乱码的坑，遇见可参考SpringBoot技术总结。

#### 1.4.2.使用技巧

##### 1.4.2.1.命名空间

​	命名空间是进行配置隔离的，默认新增都是public，可以在`bootstrap.properties`中修改

```properties
spring.cloud.nacos.config.namespace=968e1794-e48d-4a7f-8c70-ada1385d80bb
```

​	可以利用命名空间进行环境隔离，如开发、测试、生产；也可以进行服务间的隔离。

##### 1.4.2.2.配置集和配置集ID

​	配置集指的是所有配置的集合，配置集ID就是DataID，类似配置文件名称

##### 1.4.2.3.配置分组

​	把同个命名空间里面的配置进行分组处理，可以在`bootstrap.properties`文件中指定使用的分组

```properties
spring.cloud.nacos.config.group=dev
```

##### 1.4.2.4.使用推荐

​	可以为每个微服务创建自己的命名空间，使用配置分组区分环境。

#### 1.4.3.多配置源

​	可以将不同用处的配置分别放在不同的配置文件中，在`bootstrap.properties`导入指定的配置文件即可

```properties
#数据源配置文件
#配置集Id
spring.cloud.nacos.config.extension-configs[0].data-id=DataSource.yaml
#配置分组
spring.cloud.nacos.config.extension-configs[0].group=dev
#是否动态刷新，默认false
spring.cloud.nacos.config.extension-configs[0].refresh=true

#MyBatisPlus配置文件
spring.cloud.nacos.config.extension-configs[1].data-id=MyBatisPlus.yaml
spring.cloud.nacos.config.extension-configs[1].group=dev
spring.cloud.nacos.config.extension-configs[1].refresh=true
```

### 1.5.网关Gateway

​	网关是所欲偶流量请求的入口，常用功能包括路由转发、权限校验、限流控制等。SpringCloud Gateway是SpringCloud官方推出的第二代网关框架，用来取zuul网关。

#### 1.5.1.基本使用

（1）引入注册中心和配置中心依赖

（2）启动类开启服务发现

（3）添加注册中心和配置中心配置

（4）在配置文件application.yml中书写规则（可在配置中心创建同名配置文件用来免重启更新配置）