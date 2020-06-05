# Quartz

## 1.概述

​	Quartz（http://www.quartz-scheduler.org/）是一个开放源代码任务调度框架。Quartz功能强大，可以让你的程序在指定时间执行，也可以按照某一个频度执行，支持数据库、监听器、插件、集群等特性。
使用场景：定时消息推送、定时抢购、定时发送邮件、定时统计等

## 2.环境搭建

### maven坐标

```xml
<dependency>
	<groupId>org.quartz-scheduler</groupId>
	<artifactId>quartz</artifactId>
	<version>2.2.1</version>
</dependency>
<dependency>
	<groupId>org.quartz-scheduler</groupId>
	<artifactId>quartz-jobs</artifactId>
	<version>2.2.1</version>
</dependency>
```

### 代码操作

#### 1.定义任务内容

```java
package com.heng;

import org.quartz.Job;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;

import java.util.Date;

public class MyJob implements Job {

    //需要执行的任务
    @Override
    public void execute(JobExecutionContext jobExecutionContext) throws JobExecutionException {
        System.out.println(new Date());
    }
}

```

#### 2.构建调度任务

```java
package com.heng;

import org.quartz.JobDetail;
import org.quartz.Scheduler;
import org.quartz.SchedulerException;
import org.quartz.Trigger;
import org.quartz.impl.StdSchedulerFactory;

import static org.quartz.JobBuilder.newJob;
import static org.quartz.SimpleScheduleBuilder.simpleSchedule;
import static org.quartz.TriggerBuilder.newTrigger;

public class App {
    public static void main( String[] args ) throws SchedulerException {
        //获取调度器
        Scheduler scheduler = StdSchedulerFactory.getDefaultScheduler();
        //包装任务内容
        JobDetail job = newJob(MyJob.class).withIdentity("job1", "group1").build();
        //定义触发器
        Trigger trigger = 						           newTrigger().withIdentity("TRIGGER1","GROUP1").startNow().withSchedule(
            simpleSchedule().withIntervalInSeconds(3).repeatForever()
        ).build();
        //组装任务
        scheduler.scheduleJob(job, trigger);
        //启动调度器 开始调度
        scheduler.start();
    }
}

```

## 3.体系架构

### Job

​	是一个接口，只定义一个方法execute（JobEexcutionContext context），在实现接口的execute方法中编写所
需要定时执行的Job任务，JobEexcutionContext 类提供了调度应用的一些信息。Job运行时的信息保存在JobDataMap实例中。

### JobDetail

​	JobDetail定义的是任务数据，而真正的执行逻辑是在Job中。sheduler每次执行，都会根据JobDetail创建一个
新的Job实例。

### Trigger

​	是一个类，描述触发Job执行的时间触发规则。主要有SimpleTrigger和CronTrigger这两个子类。当且仅当需要
调度一次或者以固定时间间隔周期执行调度，SimpleTrigger是最适合j简单任务的选择；而CronTrigger则可以
通过Cron表达式定义出各种复杂时间规则的调度方案：如工作日周一到周五的15:00~16:00执行调度等。

Cron表达式的格式：秒 分 时 日 月 周 年(可选)。

| 字段名         | 允许的值         | 允许的特殊符号          |
| -------------- | ---------------- | ----------------------- |
| 秒             | 0-59             | , - * /                 |
| 分             | 0-59             | , - * /                 |
| 时             | 0-23             | , - * /                 |
| 日             | 1-31             | , - * / L W C           |
| 月             | 1-12 or JAN-DEC  | , - * /                 |
| 周             | 1-7 or SUN-SAT   | , - * / ? L C # MON FRI |
| 年（可选字段） | empty，1970-2099 | , - * /                 |

允许的特殊字符：

1. *字符：代表所有可能的值。在Month中表示每个月，在Day-of-Month中表示每天，在Hours表
  示每小时
2. “,”字符：指定数个值。例如：在Minutes子表达式中，“5,20”表示在5分钟和20分钟触发。
3. “-”字符：指定一个值的范围
4. “/”字符：指定一个值的增加幅度。n/m表示从n开始，每次增加m。例如：在Minutes子表达式中，“0/15”表示
  从0分钟开始，每15分钟执行一次。"3/20"表示从第三分钟开始，每20分钟执行一次。和"3,23,43"（表示第3，
  23，43分钟触发）的含义一样。
5. “L”字符：用在日表示一个月中的最后一天，用在周表示该月最后一个星期X
6. “W”字符：指定离给定日期最近的工作日(周一到周五)
7. “#”字符：表示该月第几个周X。6#3表示该月第3个周五
8. ? 字符：用在Day-of-Month和Day-of-Week中，指“没有具体的值”。当两个子表达式其中一个被指定了值以后，
  为了避免冲突，需要将另外一个的值设为“?”。例如：想在每月20日触发调度，不管20号是星期几，只能用如下
  写法：0 0 0 20 * ?，其中最后以为只能用“?”，而不能用“*”。
9. C：该字符只在日期和星期字段中使用，代表“Calendar”的意思。它的意思是计划所关联的日期，如果日期没有
  被关联，则相当于日历中所有日期。例如5C在日期字段中就相当于日历5日以后的第一天。1C在星期字段中相
  当于星期日后的第一天。

Cron表达式对特殊字符的大小写不敏感，对代表星期的缩写英文大小写也不敏感。

Cron表达式范例:

1. 每隔5秒执行一次：*/5 * * * * ?
2. 每隔1分钟执行一次：0 */1 * * * ?
3. 每天23点执行一次：0 0 23 * * ?
4. 每天凌晨1点执行一次：0 0 1 * * ?

5. 每月1号凌晨1点执行一次：0 0 1 1 * ?
6. 每月最后一天23点执行一次：0 0 23 L * ?
7. 每周星期天凌晨1点执行一次：0 0 1 ? * L
8. 在26分、29分、33分执行一次：0 26,29,33 * * * ?
9. 每天的0点、13点、18点、21点都执行一次：0 0 0,13,18,21 * * ?

### Scheduler

​	代表一个Quartz的独立运行容器， Trigger和JobDetail可以注册到Scheduler中， 两者在 Scheduler
中拥有各自的组及名称， 组及名称是Scheduler查找定位容器中某一对象的依据， Trigger的组及名称必须唯
一， JobDetail的组和名称也必须唯一（但可以和Trigger的组和名称相 同，因为它们是不同类型的）。
Scheduler定义了了多个接口方法， 允许外部通过组及名称访问和 控制容器中Trigger和JobDetail。

### JobBuilder

用于定义/构建已经定义了了Job实例的JobDetail实例

### TriggerBuilder

用于定义/构建Trigger实例

## 4.Spring集成

### maven坐标

```xml
<!-- quartz依赖 -->
<dependency>
	<groupId>org.quartz-scheduler</groupId>
	<artifactId>quartz</artifactId>
	<version>2.2.1</version>
</dependency>
<dependency>
	<groupId>org.quartz-scheduler</groupId>
	<artifactId>quartz-jobs</artifactId>
	<version>2.2.1</version>
</dependency>
<!--spring依赖-->
<dependency>
	<groupId>org.springframework</groupId>
	<artifactId>spring-context-support</artifactId>
	<version>3.2.8.RELEASE</version>
</dependency>
<dependency>
	<groupId>org.springframework</groupId>
	<artifactId>spring-tx</artifactId>
	<version>3.2.8.RELEASE</version>
</dependency>
```

